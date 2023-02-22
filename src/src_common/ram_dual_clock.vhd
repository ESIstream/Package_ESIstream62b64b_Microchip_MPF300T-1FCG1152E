---------------------------------------------------------------------------------
--                                                                             --
-- Author           : Florian TUTZO                                            --
--                                                                             --
-- Project          :                                                          --
--                                                                             --
-- Date             :  03/12/18                                                --
--                                                                             --
-- Description      :                                                          --
--                                                                             --
-- ------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_DUAL_CLOCK is
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
end entity RAM_DUAL_CLOCK;

architecture ARCH_RAM_DUAL_CLOCK of RAM_DUAL_CLOCK is

  constant CST_RAM_DEPTH : integer := 2**G_ADDR_LENGTH;
  type mem is array(0 to CST_RAM_DEPTH-1) of std_logic_vector(G_DATA_LENGTH-1 downto 0);
  shared variable ram_block : mem :=(others=>(others=>'0'));

  signal addra_r : std_logic_vector(G_ADDR_LENGTH-1 downto 0);
  signal addrb_r : std_logic_vector(G_ADDR_LENGTH-1 downto 0);
  signal douta_r : std_logic_vector(G_DATA_LENGTH-1 downto 0);
  signal doutb_r : std_logic_vector(G_DATA_LENGTH-1 downto 0);

begin

  ------------------------------------------------------------------------
  -- PROCESS : P_PORTA 
  -- Description :
  ------------------------------------------------------------------------
  P_PORTA : process(CLKA)
  begin
    if rising_edge(CLKA) then
      addra_r <= ADDRA;
      if WEA = '1' then
        ram_block(to_integer(unsigned(ADDRA))) := DINA;
        douta_r <= DINA;
      else
        douta_r <= ram_block(to_integer(unsigned(addra_r)));
      end if;
    end if;
  end process P_PORTA;

  ------------------------------------------------------------------------
  -- Generate output register for DOUTA
  ------------------------------------------------------------------------
  GEN_DOUTA_REG : if G_DOUTA_REG_EN = '1' generate
    P_DOUTA_REG : process(CLKA)
    begin
      if rising_edge(CLKA) then
        DOUTA <= douta_r;
      end if;
    end process P_DOUTA_REG;
  end generate GEN_DOUTA_REG;

  ------------------------------------------------------------------------
  -- no ouput register for DOUTA
  ------------------------------------------------------------------------
  GEN_DOUTA_REG_N : if G_DOUTA_REG_EN = '0' generate
    DOUTA <= douta_r;
  end generate GEN_DOUTA_REG_N;

  ------------------------------------------------------------------------
  -- PROCESS : P_PORTB
  -- Description :
  ------------------------------------------------------------------------
  P_PORTB : process(CLKB)
  begin
    if rising_edge(CLKB) then
      addrb_r <= ADDRB;
      if WEB = '1' then
        ram_block(to_integer(unsigned(ADDRB))) := DINB;
        doutb_r <= DINB;
      else
        doutb_r <= ram_block(to_integer(unsigned(addrb_r)));
      end if;
    end if;
  end process P_PORTB;

  ------------------------------------------------------------------------
  -- Generate output register for DOUTB
  ------------------------------------------------------------------------
  GEN_DOUTB_REG : if G_DOUTB_REG_EN = '1' generate
    P_DOUTB_REG : process(CLKB)
    begin
      if rising_edge(CLKB) then
        DOUTB <= doutb_r;
      end if;
    end process P_DOUTB_REG;
  end generate GEN_DOUTB_REG;

  ------------------------------------------------------------------------
  -- no ouput register for DOUTB
  ------------------------------------------------------------------------
  GEN_DOUTB_REG_N : if G_DOUTB_REG_EN = '0' generate
    DOUTB <= doutB_r;
  end generate GEN_DOUTB_REG_N;

end architecture ARCH_RAM_DUAL_CLOCK;
