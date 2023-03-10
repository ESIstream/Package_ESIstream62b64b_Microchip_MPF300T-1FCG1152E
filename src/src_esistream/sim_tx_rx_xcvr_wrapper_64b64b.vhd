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
    rst              : in  std_logic;                              -- Active high (A)synchronous reset
    rst_xcvr         : in  std_logic;                              -- Active high (A)synchronous reset
    sysclk           : in  std_logic;                              -- transceiver ip system clock
    refclk_n         : in  std_logic;                              -- transceiver ip reference clock
    refclk_p         : in  std_logic;                              -- transceiver ip reference clock
    rxp              : in  std_logic_vector(NB_LANES-1 downto 0);  -- lane serial input p
    rxn              : in  std_logic_vector(NB_LANES-1 downto 0);  -- lane Serial input n
    txp              : out std_logic_vector(NB_LANES-1 downto 0);  -- lane serial output p
    txn              : out std_logic_vector(NB_LANES-1 downto 0);  -- lane Serial output n
    rx_rstdone       : out std_logic_vector(NB_LANES-1 downto 0);  --  := (others => '0');
    rx_frame_clk     : out std_logic;
    tx_frame_clk     : out std_logic;
    rx_usrclk        : out std_logic_vector(NB_LANES-1 downto 0);
    tx_usrclk        : out std_logic;
    xcvr_pll_lock    : out std_logic_vector(NB_LANES-1 downto 0);
    tx_ip_ready      : out std_logic;
    data_in          : in  std_logic_vector(SER_WIDTH*NB_LANES-1 downto 0);
    data_out         : out std_logic_vector(DESER_WIDTH*NB_LANES-1 downto 0)
    );
end entity xcvr_wrapper;

architecture rtl of xcvr_wrapper is
  --
  signal rst_n          : std_logic := '1';
  signal refclk_o       : std_logic := '0';
  signal frame_clk      : std_logic := '0';
  signal frame_clk_lock : std_logic := '1';
  --
begin
  --
  rst_n         <= not rst;
  --
  data_out      <= data_in;
  xcvr_pll_lock <= (others => (rst_n and frame_clk_lock));
  -- rx 
  rx_rstdone    <= (others => (rst_n and frame_clk_lock));
  rx_usrclk     <= (others => refclk_o);
  rx_frame_clk  <= refclk_o;
  -- tx
  tx_ip_ready   <= rst_n and frame_clk_lock;
  tx_usrclk     <= refclk_o;
  tx_frame_clk  <= refclk_o;
  txp           <= (others => '1');
  txn           <= (others => '0');
  --
  -- transceiver ref clock buffer
  i_ref_clk: PF_XCVR_REF_CLK_C0
    port map (
    -- Inputs
    REF_CLK_PAD_N  => refclk_n,
    REF_CLK_PAD_P  => refclk_p,
    -- Outputs
    REF_CLK       => refclk_o
    );
  --
end architecture rtl;
