library work;
use work.esistream6264_pkg.all;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rx_esistream is
  generic (
    NB_LANES    : natural;
    DESER_WIDTH : natural;
    COMMA       : std_logic_vector(63 downto 0));
  port (
    rst_xcvr      : out std_logic;                                          -- Reset of the XCVR
    rx_rstdone    : in  std_logic_vector(NB_LANES-1 downto 0);              -- Reset done of RX XCVR part
    xcvr_pll_lock : in  std_logic_vector(NB_LANES-1 downto 0);              -- PLL locked from XCVR part
    rx_usrclk     : in  std_logic_vector(NB_LANES-1 downto 0);              -- RX User Clock from XCVR
    xcvr_data_rx  : in  std_logic_vector(DESER_WIDTH*NB_LANES-1 downto 0);  -- RX User data from RX XCVR part
    --
    prbs_ena      : in  std_logic;
    sync_in       : in  std_logic;                                          -- active high synchronization pulse input
    clk_acq       : in  std_logic;                                          -- acquisition clock, output buffer read port clock, should be same frequency and no phase drift with receive clock (default: clk_acq should take rx_clk).
    frame_out     : out type_deser_width_array(NB_LANES-1 downto 0);        -- decoded output frame: disparity bit (0) + clk bit (1) + data (63 downto 2) (descrambling and disparity processed)  
    valid_out     : out std_logic;
    ip_ready      : out std_logic;                                          -- active high ip ready output (transceiver pll locked and transceiver reset done)
    lanes_ready   : out std_logic := '0';                                   -- active high lanes ready output, indicates all lanes are synchronized (alignement and prbs initialization done)
    lanes_on      : in  std_logic_vector(NB_LANES-1 downto 0)
    );
end entity rx_esistream;

architecture rtl of rx_esistream is
  --
  signal lane_ready_t  : std_logic_vector(NB_LANES-1 downto 0)       := (others => '0');
  signal lanes_ready_t : std_logic_vector(1 downto 0)                := (others => '0');
  signal xcvr_data     : type_deser_width_array(NB_LANES-1 downto 0) := (others => (others => '0'));
  signal rst_lane_xcvr : std_logic_vector(NB_LANES-1 downto 0)       := (others => '0');
  signal ip_lane_ready : std_logic_vector(NB_LANES-1 downto 0)       := (others => '0');
  signal read_fifo     : std_logic                                   := '0';
  --signal read_fifo_1   : std_logic                                   := '0';
--
begin

  --============================================================================================================================
  -- Instantiate RX Control module
  --============================================================================================================================
  lane_control_gen : for index in 0 to (NB_LANES - 1) generate
  begin
    --i_rx_control : entity work.rx_control
    --  port map(
    --    pll_lock  => xcvr_pll_lock(index),  -- IN     
    --    rst_done  => rx_rstdone(index),     -- IN     
    --    rst_xcvr  => rst_lane_xcvr(index),  -- OUT - rx_usrclk domain
    --    ip_ready  => ip_lane_ready(index)   -- OUT - rx_usrclk domain
    --    );
    ip_lane_ready(index) <= rx_rstdone(index) and xcvr_pll_lock(index);
    rst_lane_xcvr(index) <= not xcvr_pll_lock(index);
  end generate;
  rst_xcvr <= and1(rst_lane_xcvr);
  ip_ready <= and1(ip_lane_ready);
  --============================================================================================================================
  -- Instantiate rx_lane_decoding
  --============================================================================================================================
  lane_decoding_gen : for index in 0 to (NB_LANES - 1) generate
  begin

    rx_lane_decoding_1 : entity work.rx_lane_decoding
      generic map (
        COMMA => COMMA)
      port map (
        clk        => rx_usrclk(index),     -- rx_usrclk
        clk_acq    => clk_acq,              -- clk_acq
        frame_in   => xcvr_data(index),     -- rx_usrclk domain
        sync       => sync_in,              -- rx_usrclk domain
        prbs_ena   => prbs_ena,
        read_fifo  => read_fifo,
        lane_ready => lane_ready_t(index),  -- clk_acq domain
        frame_out  => frame_out(index)      -- clk_acq domain
        );
  end generate;
  read_fifo <= lanes_ready_t(0);
  --=================================================================================================================
  -- Assignements output 
  --=================================================================================================================
  process(clk_acq)
  begin
    if rising_edge(clk_acq) then
      lanes_ready_t <= lanes_ready_t(lanes_ready_t'high-1 downto 0) & and1(lane_ready_t and lanes_on);
      lanes_ready   <= lanes_ready_t(lanes_ready_t'high);
      --
      --read_fifo_1   <= read_fifo;
      --valid_out     <= read_fifo_1;
      valid_out     <= read_fifo;
    end if;
  end process;

  --=================================================================================================================
  -- Transceiver User interface
  --=================================================================================================================
  gen_xcvr_data : for idx in 0 to NB_LANES-1 generate
    xcvr_data(idx) <= xcvr_data_rx(DESER_WIDTH*idx + (DESER_WIDTH-1) downto DESER_WIDTH*idx);  -- rx_usrclk domain
  end generate gen_xcvr_data;

end architecture rtl;
