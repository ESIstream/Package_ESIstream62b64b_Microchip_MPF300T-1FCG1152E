---------------------------------------------------------------------------------
--                                                                             --
-- Author           : Florian TUTZO                                            --
--                                                                             --
-- Project          :                                                          --
--                                                                             --
-- Date             :  14/02/19                                                --
--                                                                             --
-- Description      :                                                          --
--                                                                             --
-- ------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity FIFO_DC is
  generic
  (
    G_DATA_LENGTH     : integer := 32;
    G_ADDR_LENGTH     : integer := 4;
    G_RAM_TYPE        : string  := "RAM_1K20"
  );
  port
  (
    RESET_N        : in    std_logic;

    CLK_WR         : in    std_logic;
    WR             : in    std_logic;
    DATA_IN        : in    std_logic_vector(G_DATA_LENGTH-1 downto 0);

    CLK_RD         : in    std_logic;
    RD             : in    std_logic;
    DATA_OUT       : out   std_logic_vector(G_DATA_LENGTH-1 downto 0);

    FULL           : out   std_logic;
    EMPTY          : out   std_logic
  );
end entity FIFO_DC;

architecture ARCH_FIFO_DC of FIFO_DC is

  component RAM_DUAL_CLOCK is
    generic
    (
      G_ADDR_LENGTH  : integer := 8;
      G_DATA_LENGTH  : integer := 8;
      G_DOUTA_REG_EN : std_logic := '0';
      G_DOUTB_REG_EN : std_logic := '0'
    );
    port
    (
      CLKA    : in    std_logic;
      ADDRA   : in    std_logic_vector(G_ADDR_LENGTH-1 downto 0);
      DINA    : in    std_logic_vector(G_DATA_LENGTH-1 downto 0);
      WEA     : in    std_logic;
      DOUTA   : out   std_logic_vector(G_DATA_LENGTH-1 downto 0);
      CLKB    : in    std_logic;
      ADDRB   : in    std_logic_vector(G_ADDR_LENGTH-1 downto 0);
      DINB    : in    std_logic_vector(G_DATA_LENGTH-1 downto 0);
      WEB     : in    std_logic;
      DOUTB   : out   std_logic_vector(G_DATA_LENGTH-1 downto 0)
    );
  end component RAM_DUAL_CLOCK;

  ----------------------------------------------------------------------------
  -- Type
  ----------------------------------------------------------------------------
  type t_block_ram_data_length is array (integer range <>) of integer;

  ----------------------------------------------------------------------------
  -- FUNCTIONS
  ----------------------------------------------------------------------------
  function binary_to_gray_code (data : unsigned(G_ADDR_LENGTH-1 downto 0)) return unsigned is
  begin
    return data(data'high) & (data(data'high downto 1) xor data(data'high-1 downto 0));
  end function binary_to_gray_code;

  function gray_to_binary_code (data_gray : unsigned(G_ADDR_LENGTH-1 downto 0)) return unsigned is
    variable data : unsigned (data_gray'range);
  begin
    data(data'high) := data_gray(data'high);
    for i in data'high-1 downto 0 loop
      data(i) := data(i+1) xor data_gray(i);
    end loop;
    return data;
  end function gray_to_binary_code;

  function get_nb_parallel_block_ram return integer is
  variable v_max_data_length : integer := 0;
  begin
    if G_RAM_TYPE = "RAM_1K20" then
      v_max_data_length := 20;
      return integer(ceil(real(G_DATA_LENGTH)/real(v_max_data_length)));
    else
      return 1;
    end if;
  end function get_nb_parallel_block_ram;

  ----------------------------------------------------------------------------
  constant C_NB_PARALLEL_BLOCK   : integer := get_nb_parallel_block_ram;
  constant C_BLOCK_DATA_LENGTH   : integer := integer(ceil(real(G_DATA_LENGTH)/real(C_NB_PARALLEL_BLOCK)));
  constant CST_DEPTH             : integer := 2**G_ADDR_LENGTH;

  ----------------------------------------------------------------------------
  signal wr_en_s                : std_logic:='0';

  signal ptr_wr_s               : std_logic_vector(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_wr_r              : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_wr_inc_s          : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_wr_gray_r         : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_wr_gray_sync_r    : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_wr_gray_sync_rr   : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_wr_sync_r         : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');

  signal ptr_rd_s               : std_logic_vector(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_rd_r              : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_rd_inc_s          : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_rd_gray_r         : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_rd_gray_sync_r    : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_rd_gray_sync_rr   : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');
  signal addr_rd_sync_r         : unsigned(G_ADDR_LENGTH-1 downto 0):=(others=>'0');

  signal data_in_s              : std_logic_vector(C_NB_PARALLEL_BLOCK*C_BLOCK_DATA_LENGTH-1 downto 0);
  signal ram_out_s              : std_logic_vector(C_NB_PARALLEL_BLOCK*C_BLOCK_DATA_LENGTH-1 downto 0):=(others=>'0');

  signal fifo_full_r            : std_logic:='0';
  signal fifo_empty_r           : std_logic:='1';
  signal fifo_rd_s              : std_logic;

begin

  data_in_s <= std_logic_vector(resize(unsigned(DATA_IN), data_in_s'length));

  ---------------------------------------------------------------------------
  -- RAM
  ---------------------------------------------------------------------------
  GEN_PARALLEL_BLOCK_RAM : for i in 0 to C_NB_PARALLEL_BLOCK-1 generate
    INST_RAM : RAM_DUAL_CLOCK
    generic map
    (
      G_ADDR_LENGTH  => G_ADDR_LENGTH,
      G_DATA_LENGTH  => C_BLOCK_DATA_LENGTH,
      G_DOUTA_REG_EN => '0',
      G_DOUTB_REG_EN => '0'
    )
    port map
    (
      CLKA    => CLK_WR,
      ADDRA   => ptr_wr_s,
      DINA    => data_in_s((i+1)*C_BLOCK_DATA_LENGTH-1 downto i*C_BLOCK_DATA_LENGTH),
      WEA     => wr_en_s,
      DOUTA   => open,
      CLKB    => CLK_RD,
      ADDRB   => ptr_rd_s,
      DINB    => (others => '0'),
      WEB     => '0',
      DOUTB   => ram_out_s((i+1)*C_BLOCK_DATA_LENGTH-1 downto i*C_BLOCK_DATA_LENGTH)
    );
  end generate GEN_PARALLEL_BLOCK_RAM;

  ---------------------------------------------------------------------------
  -- RD/WR POINTERS MANAGEMENT
  ---------------------------------------------------------------------------

  ------------------------------------------------------------------------
  -- COMBINATORIAL
  -- Description : commands write enable
  ------------------------------------------------------------------------
  wr_en_s <= WR and not fifo_full_r;

  ------------------------------------------------------------------------
  -- COMBINATORIAL
  -- Description : increment address
  ------------------------------------------------------------------------
  addr_wr_inc_s <= addr_wr_r + 1;
  addr_rd_inc_s <= addr_rd_r + 1;

  ------------------------------------------------------------------------
  -- COMBINATORIAL
  -- Description :
  ------------------------------------------------------------------------
  ptr_wr_s <= std_logic_vector(addr_wr_r);
  ptr_rd_s <= std_logic_vector(addr_rd_r);

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_WR
  -- Description : address write increment
  ------------------------------------------------------------------------
  P_ADDR_WR : process(CLK_WR, RESET_N)
  begin
    if RESET_N = '0' then
      addr_wr_r <= (others => '0');
    elsif rising_edge(CLK_WR) then
      if wr_en_s = '1' then
        addr_wr_r <= addr_wr_inc_s;
      end if;
    end if;
  end process P_ADDR_WR;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_WR_GRAY
  -- Description : transform write address into gray code
  ------------------------------------------------------------------------
  P_ADDR_WR_GRAY : process(CLK_WR, RESET_N)
  begin
    if RESET_N = '0' then
      addr_wr_gray_r <= (others => '0');
    elsif rising_edge(CLK_WR) then
      addr_wr_gray_r <= binary_to_gray_code(addr_wr_r);
    end if;
  end process P_ADDR_WR_GRAY;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_WR_GRAY_SYNC
  -- Description : double resynchronization into read clock domain
  ------------------------------------------------------------------------
  P_ADDR_WR_GRAY_SYNC : process(CLK_RD, RESET_N)
  begin
    if RESET_N = '0' then
      addr_wr_gray_sync_r  <= (others => '0');
      addr_wr_gray_sync_rr <= (others => '0');
    elsif rising_edge(CLK_RD) then
      addr_wr_gray_sync_r  <= addr_wr_gray_r;
      addr_wr_gray_sync_rr <= addr_wr_gray_sync_r;
    end if;
  end process P_ADDR_WR_GRAY_SYNC;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_WR_SYNC
  -- Description : write address into read clock domain
  ------------------------------------------------------------------------
  P_ADDR_WR_SYNC : process(CLK_RD, RESET_N)
  begin
    if RESET_N = '0' then
      addr_wr_sync_r  <= (others => '0');
    elsif rising_edge(CLK_RD) then
      addr_wr_sync_r  <= gray_to_binary_code(addr_wr_gray_sync_rr);
    end if;
  end process P_ADDR_WR_SYNC;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_RD
  -- Description : address read increment
  ------------------------------------------------------------------------
  P_ADDR_RD : process(CLK_RD, RESET_N)
  begin
    if RESET_N = '0' then
      addr_rd_r     <= (others => '0');
    elsif rising_edge(CLK_RD) then
      if fifo_rd_s = '1' then
        addr_rd_r <= addr_rd_inc_s;
      end if;
    end if;
  end process P_ADDR_RD;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_RD_GRAY
  -- Description : transform read address into gray code
  ------------------------------------------------------------------------
  P_ADDR_RD_GRAY : process(CLK_RD, RESET_N)
  begin
    if RESET_N = '0' then
      addr_rd_gray_r <= (others => '0');
    elsif rising_edge(CLK_RD) then
      addr_rd_gray_r <= binary_to_gray_code(addr_rd_r);
    end if;
  end process P_ADDR_RD_GRAY;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_RD_GRAY_SYNC
  -- Description : double resynchronization into write clock domain
  ------------------------------------------------------------------------
  P_ADDR_RD_GRAY_SYNC : process(CLK_WR, RESET_N)
  begin
    if RESET_N = '0' then
      addr_rd_gray_sync_r  <= (others => '0');
      addr_rd_gray_sync_rr <= (others => '0');
    elsif rising_edge(CLK_WR) then
      addr_rd_gray_sync_r  <= addr_rd_gray_r;
      addr_rd_gray_sync_rr <= addr_rd_gray_sync_r;
    end if;
  end process P_ADDR_RD_GRAY_SYNC;

  ------------------------------------------------------------------------
  -- PROCESS : P_ADDR_RD_SYNC
  -- Description : read address into write clock domain
  ------------------------------------------------------------------------
  P_ADDR_RD_SYNC : process(CLK_WR, RESET_N)
  begin
    if RESET_N = '0' then
      addr_rd_sync_r  <= (others => '0');
    elsif rising_edge(CLK_WR) then
      addr_rd_sync_r  <= gray_to_binary_code(addr_rd_gray_sync_rr);
    end if;
  end process P_ADDR_RD_SYNC;

  ---------------------------------------------------------------------------
  -- STATUS MANAGEMENT
  ---------------------------------------------------------------------------

  ------------------------------------------------------------------------
  -- PROCESS : P_FIFO_FULL
  -- Description :
  ------------------------------------------------------------------------
  P_FIFO_FULL : process(CLK_WR, RESET_N)
  begin
    if RESET_N = '0' then
      fifo_full_r   <= '0';
    elsif rising_edge(CLK_WR) then
      if addr_wr_inc_s = addr_rd_sync_r and wr_en_s = '1' then
        fifo_full_r   <= '1';
      elsif addr_wr_r /= addr_rd_sync_r then
        fifo_full_r   <= '0';
      end if;
    end if;
  end process P_FIFO_FULL;

  ------------------------------------------------------------------------
  -- PROCESS : P_FIFO_EMPTY
  -- Description :
  ------------------------------------------------------------------------
  P_FIFO_EMPTY : process(CLK_RD, RESET_N)
  begin
    if RESET_N = '0' then
      fifo_empty_r   <= '1';
    elsif rising_edge(CLK_RD) then
      if addr_rd_inc_s = addr_wr_sync_r and RD = '1' then
        fifo_empty_r   <= '1';
      elsif addr_rd_r /= addr_wr_sync_r then
        fifo_empty_r   <= '0';
      end if;
    end if;
  end process P_FIFO_EMPTY;

  ---------------------------------------------------------------------------
  -- BUFF OUT
  ---------------------------------------------------------------------------

  fifo_rd_s      <= RD and not fifo_empty_r;
  EMPTY          <= fifo_empty_r;
  FULL           <= fifo_full_r;
  DATA_OUT       <= ram_out_s(G_DATA_LENGTH-1 downto 0);


end architecture ARCH_FIFO_DC;
