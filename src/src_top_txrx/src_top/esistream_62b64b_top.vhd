library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

library work;
use work.esistream6264_pkg.all;
use work.component6264_pkg.all;

library polarfire;
use polarfire.all;

entity esistream_62b64b_top is
  generic
    (
      NB_LANES  : natural                       := 8;
--     COMMA                : std_logic_vector(63 downto 0) := x"ACF0FF00FFFF0000"; -- x"00FFFF0000FFFF00";
      COMMA     : std_logic_vector(63 downto 0) := x"00FFFF0000FFFF00";
      DEB_WIDTH : integer                       := 25
      );
  port
    (
      CLK_50MHZ_I : in  std_logic;
      refclk_n    : in  std_logic;
      refclk_p    : in  std_logic;
      refclko_n   : out std_logic;
      refclko_p   : out std_logic;
      rxp         : in  std_logic_vector(7 downto 0);
      rxn         : in  std_logic_vector(7 downto 0);
      txp         : out std_logic_vector(7 downto 0);
      txn         : out std_logic_vector(7 downto 0);

      SW1  : in  std_logic;
      SW2  : in  std_logic;
      DIP1 : in  std_logic;
      DIP2 : in  std_logic;
      DIP3 : in  std_logic;
      DIP4 : in  std_logic;
      LED  : out std_logic_vector(3 downto 0)
      );

end esistream_62b64b_top;

architecture rtl of esistream_62b64b_top is

  constant C_CNT_RESET : unsigned(11 downto 0) := X"FFF";

  signal toggle_ena : std_logic := '1';
  signal xm107      : std_logic := '1';  -- high if the protocole is used with the loop-back card

  signal rst_in        : std_logic;
  --signal rst_re           : std_logic;
  signal rst_deb       : std_logic;
  signal sysrst_n      : std_logic;
  --gnal rst_tx           : std_logic;
  --gnal rst_tx_n         : std_logic;
  --gnal rst_rx           : std_logic;
  signal syslock       : std_logic;
  signal s_reset_i     : std_logic;
  --signal s_reset_i_n      : std_logic;
  signal sync_in       : std_logic;
  signal tx_sync_re    : std_logic;
  signal rx_sync       : std_logic;
  signal sync_deb      : std_logic;
  --signal sync_deb_r       : std_logic;
  --signal sync_deb_rr      : std_logic;
  signal d_ctrl        : std_logic_vector(1 downto 0)          := "00";
  signal prbs_ena      : std_logic;
  signal dc_ena        : std_logic;
  signal ip_ready      : std_logic;
  signal lanes_ready   : std_logic;
  signal be_status     : std_logic;
  signal cb_status     : std_logic;
  signal valid_status  : std_logic;
  signal fb_clk        : std_logic;
  signal sysclk        : std_logic;
  signal sysclk1       : std_logic;
  signal tx_frame_clk  : std_logic;
  signal rx_frame_clk  : std_logic;
  signal tx_data       : type_62_array(NB_LANES-1 downto 0);
  signal frame_out     : type_deser_width_array(NB_LANES-1 downto 0);
  signal valid_out     : std_logic;
  signal lanes_ready_t : std_logic;
  signal lanes_on      : std_logic_vector(NB_LANES-1 downto 0) := (others => '1');
  signal clk_50mhz     : std_logic                             := '0';
  --signal sync_in_re_valid : std_logic := '0';
  --signal cnt_1sec         : unsigned(29 downto 0) := (others => '1');
  --
  component OUTBUF_DIFF
    port (
      -- Inputs
      D    : in  std_logic;
      -- Outputs
      PADP : out std_logic;
      PADN : out std_logic
      );
  end component;
--
begin

  --
  --------------------------------------------------------------------------------------------
  -- User interface:
  --------------------------------------------------------------------------------------------
  --
  -------------------------
  -- push-buttons
  -------------------------
  rst_in     <= not SW1;
  sync_in    <= not SW2;
  -------------------------
  -- SW2 switch
  -------------------------
  d_ctrl(0)  <= DIP1;
  toggle_ena <= DIP2;
  prbs_ena   <= DIP3;
  dc_ena     <= DIP4;
  --
  -------------------------
  -- LEDs
  -------------------------
  LED(0)     <= lanes_ready;
  LED(1)     <= ip_ready;
  LED(2)     <= valid_status;
  LED(3)     <= cb_status or be_status;

  lanes_on <= X"FF" when xm107 = '1' else (others => '1');  -- xm107 has only 8 available serial links

  --------------------------------------------------------------------------------------------
  --  clk_out1 : 100.0MHz (must be consistent with C_SYS_CLK_PERIOD)
  --------------------------------------------------------------------------------------------
  i_pll_sys : PF_CCC_C0
    port map (
      -- Inputs
      PLL_POWERDOWN_N_0 => sysrst_n,
      REF_CLK_0         => CLK_50MHZ_I,
      -- Outputs
      OUT0_FABCLK_0     => sysclk,
      OUT1_FABCLK_0     => sysclk1,
      PLL_LOCK_0        => syslock
      );
  --
  outbuf_diff_1 : OUTBUF_DIFF
    port map (
      -- Inputs
      D    => sysclk1,
      -- Outputs
      PADP => refclko_p,
      PADN => refclko_n
      );
  --------------------------------------------------------------------------------------------
  --  Reset
  --------------------------------------------------------------------------------------------
  i_debouncer_rst : entity work.DEBOUNCER
    generic map
    (
      WIDTH => DEB_WIDTH
      )
    port map
    (
      clk   => CLK_50MHZ_I,
      deb_i => rst_in,
      deb_o => rst_deb
      );

  sysrst_n <= not rst_deb;  -- to sys pll 
  --
  sysreset_1 : entity work.sysreset_1
    generic map (
      RST_CNTR_INIT => x"000")
    port map (
      syslock => syslock,
      sysclk  => sysclk,
      reset   => s_reset_i,
      resetn  => open);

  --------------------------------------------------------------------------------------------
  --  Sync
  --------------------------------------------------------------------------------------------
  i_debouncer_sync : entity work.DEBOUNCER
    generic map
    (
      WIDTH => DEB_WIDTH
      )
    port map
    (
      clk   => sysclk,
      deb_i => sync_in,
      deb_o => sync_deb
      );
  
  rx_sync <= sync_deb;

  meta_re_2 : entity work.meta_re
    port map (
      rst       => rst_deb,
      pulse_in  => sync_deb,
      clk_out   => tx_frame_clk,
      pulse_out => tx_sync_re);

  data_gen_1 : entity work.data_gen
    generic map
    (
      NB_LANES => NB_LANES
      )
    port map
    (
      clk     => tx_frame_clk,
      rst_sys => s_reset_i,
      d_ctrl  => d_ctrl,
      tx_data => tx_data
      );
  --

  esistream_tx_rx_1 : entity work.esistream_tx_rx
    generic map
    (
      NB_LANES => NB_LANES,
      COMMA    => COMMA
      )
    port map
    (
      tx_sync        => tx_sync_re,
      tx_toggle_ena  => toggle_ena,
      tx_prbs_ena    => prbs_ena,
      tx_dc_ena      => dc_ena,
      tx_data_in     => tx_data,
      tx_frame_clk   => tx_frame_clk,
      --
      rst_pll        => s_reset_i,
      sysclk         => sysclk,
      refclk_n       => refclk_n,
      refclk_p       => refclk_p,
      rxp            => rxp,
      rxn            => rxn,
      txp            => txp,
      txn            => txn,
      ip_ready       => ip_ready,
      --
      rx_sync        => rx_sync,
      rx_prbs_ena    => prbs_ena,
      rx_frame_out   => frame_out,
      rx_valid_out   => valid_out,
      rx_lanes_ready => lanes_ready_t,
      rx_lanes_on    => lanes_on,
      rx_frame_clk   => rx_frame_clk
      );

  lanes_ready <= lanes_ready_t;

  txrx_frame_checking_1 : entity work.txrx_frame_checking
    generic map
    (
      NB_LANES => NB_LANES
      )
    port map
    (
      --t          => rst_rx,
      clk          => rx_frame_clk,
      d_ctrl       => d_ctrl,
      lanes_on     => lanes_on,
      frame_out    => frame_out,
      lanes_ready  => lanes_ready_t,
      be_status    => be_status,
      cb_status    => cb_status,
      valid_status => valid_status
      );

end rtl;
