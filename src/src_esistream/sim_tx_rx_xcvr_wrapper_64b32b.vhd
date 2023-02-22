-------------------------------------------------------------------------------
-- This is free and unencumbered software released into the public domain.
--
-- Anyone is free to copy, modify, publish, use, compile, sell, or distribute
-- this software, either in source code form or as a compiled bitstream, for 
-- any purpose, commercial or non-commercial, and by any means.
--
-- In jurisdictions that recognize copyright laws, the author or authors of 
-- this software dedicate any and all copyright interest in the software to 
-- the public domain. We make this dedication for the benefit of the public at
-- large and to the detriment of our heirs and successors. We intend this 
-- dedication to be an overt act of relinquishment in perpetuity of all present
-- and future rights to this software under copyright law.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABIqLITY, 
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- THIS DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES. 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.esistream6264_pkg.all;
use work.component6264_pkg.all;

library polarfire;
use polarfire.all;


entity xcvr_wrapper is
  generic (
    NB_LANES    : natural := 11;                                -- number of lanes
    DESER_WIDTH : natural := 64;
    SER_WIDTH   : natural := 64
    );
  port (
    rst           : in  std_logic;                              -- Active high (A)synchronous reset
    rst_xcvr      : in  std_logic;                              -- Active high (A)synchronous reset
    sysclk        : in  std_logic;                              -- transceiver ip system clock
    refclk_n      : in  std_logic;                              -- transceiver ip reference clock
    refclk_p      : in  std_logic;                              -- transceiver ip reference clock
    rxp           : in  std_logic_vector(NB_LANES-1 downto 0);  -- lane serial input p
    rxn           : in  std_logic_vector(NB_LANES-1 downto 0);  -- lane Serial input n
    txp           : out std_logic_vector(NB_LANES-1 downto 0);  -- lane serial output p
    txn           : out std_logic_vector(NB_LANES-1 downto 0);  -- lane Serial output n
    rx_rstdone    : out std_logic_vector(NB_LANES-1 downto 0);  --  := (others => '0');
    rx_frame_clk  : out std_logic;
    tx_frame_clk  : out std_logic;
    rx_usrclk     : out std_logic_vector(NB_LANES-1 downto 0);
    tx_usrclk     : out std_logic;
    xcvr_pll_lock : out std_logic_vector(NB_LANES-1 downto 0);
    tx_ip_ready   : out std_logic;
    data_in       : in  std_logic_vector(SER_WIDTH*NB_LANES-1 downto 0);
    data_out      : out std_logic_vector(DESER_WIDTH*NB_LANES-1 downto 0)
    );
end entity xcvr_wrapper;

architecture rtl of xcvr_wrapper is
  --
  signal rst_n            : std_logic                                       := '1';
  signal refclk_o         : std_logic                                       := '0';
  signal frame_clk        : std_logic                                       := '0';
  signal frame_clk_lock   : std_logic                                       := '0';
  signal frame_clk_lock_d : std_logic                                       := '0';
  signal tick             : std_logic                                       := '1';
  signal data_in_mem      : std_logic_vector(SER_WIDTH*NB_LANES-1 downto 0) := (others => '0');
  --
  signal data_out_mem     : std_logic_vector(DESER_WIDTH*NB_LANES-1 downto 0) := (others => '0');
  signal data_out_96a     : type_96_array(NB_LANES downto 0) := (others => (others => '0')); 
  constant ALIGNMENT_SHIFT : natural range 0 to 63 := 56;
--
begin
  --
  rst_n <= not rst;
  --
  gen_data_out : for ii in 1 to NB_LANES generate
    process(frame_clk, frame_clk_lock_d)
    begin
      if frame_clk_lock_d = '0' then
        tick        <= '0';
        data_in_mem <= (others => '0');
      elsif rising_edge(frame_clk) then
        tick        <= not tick;
        data_in_mem <= data_in;
        if tick = '1' then
          data_out_mem(DESER_WIDTH*ii-1 downto DESER_WIDTH*(ii-1)) <= data_in_mem(SER_WIDTH*ii-DESER_WIDTH-1 downto SER_WIDTH*ii-SER_WIDTH);
        else
          data_out_mem(DESER_WIDTH*ii-1 downto DESER_WIDTH*(ii-1)) <= data_in_mem(SER_WIDTH*ii-1 downto SER_WIDTH*ii-DESER_WIDTH);
        end if;
        --
        data_out_96a(ii)(DESER_WIDTH*3-1 downto DESER_WIDTH*(3-1)) <= data_out_mem(DESER_WIDTH*ii-1 downto DESER_WIDTH*(ii-1));
        data_out_96a(ii)(63 downto 0) <= data_out_96a(ii)(95 downto 32);
        --
      end if;
    end process;
    data_out(DESER_WIDTH*ii-1 downto DESER_WIDTH*(ii-1)) <= data_out_96a(ii)(31+ALIGNMENT_SHIFT downto 0+ALIGNMENT_SHIFT);
  end generate gen_data_out;
  --
  process(refclk_o)
  begin
    if rising_edge(refclk_o) then
      frame_clk_lock_d <= frame_clk_lock;
    end if;
  end process;
  --
  xcvr_pll_lock <= (others => (rst_n and frame_clk_lock));
  -- rx 
  rx_rstdone    <= (others => (rst_n and frame_clk_lock));
  rx_usrclk     <= (others => frame_clk);
  rx_frame_clk  <= frame_clk;
  -- tx
  tx_ip_ready   <= rst_n and frame_clk_lock;
  tx_usrclk     <= refclk_o;
  tx_frame_clk  <= refclk_o;
  txp           <= (others => '1');
  txn           <= (others => '0');
  --
  -- transceiver ref clock buffer
  i_ref_clk : PF_XCVR_REF_CLK_C0
    port map (
      -- Inputs
      REF_CLK_PAD_N => refclk_n,
      REF_CLK_PAD_P => refclk_p,
      -- Outputs
      REF_CLK       => refclk_o
      );

  -- frame_clk pll 
  i_frame_clk : PF_CCC_C1
    port map (
      -- Inputs
      PLL_POWERDOWN_N_0 => rst_n,
      REF_CLK_0         => refclk_o,
      -- Outputs
      OUT0_FABCLK_0     => frame_clk,  -- 2x frame_clk
      PLL_LOCK_0        => frame_clk_lock
      );

end architecture rtl;
