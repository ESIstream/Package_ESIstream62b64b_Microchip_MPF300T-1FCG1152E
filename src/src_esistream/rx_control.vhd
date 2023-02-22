library work;
use work.esistream6264_pkg.all;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_control is
  port
    (
      pll_lock : in  std_logic;         -- Indicates whether GTH CPLL is locked
      rst_done : in  std_logic;         -- Indicates that GTH is ready
      rst_xcvr : out std_logic := '0';  -- Reset GTH, active high
      ip_ready : out std_logic := '0'   -- Indicates that IP is ready if driven high
      );
end entity rx_control;

architecture rtl of rx_control is

begin

  ip_ready <= rst_done and pll_lock;
  rst_xcvr <= not pll_lock;

end architecture rtl;

