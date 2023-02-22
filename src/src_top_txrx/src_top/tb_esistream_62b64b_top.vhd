library work;
use work.esistream6264_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;

entity tb_esistream_62b64b_top is
end tb_esistream_62b64b_top;

architecture Behavioral of tb_esistream_62b64b_top is
  constant NB_LANES       : natural                               := 8;
  constant COMMA          : std_logic_vector(63 downto 0)         := x"00FFFF0000FFFF00";  --x"ACF0FF00FFFF0000";
  constant clk125_period  : time                                  := 8 ns;
  constant clk50_period   : time                                  := 20 ns;
  constant clk1875_period : time                                  := 5.333 ns;
  constant clk1565_period : time                                  := 6.4 ns;
  signal CLK_50MHZ_I      : std_logic                             := '1';
  signal sync             : std_logic                             := '0';
  signal rst_in_n         : std_logic                             := '0';
  signal refclk_p         : std_logic                             := '1';
  signal refclk_n         : std_logic                             := '0';
  --
  signal txp              : std_logic_vector(NB_LANES-1 downto 0) := (others => '0');
  signal txn              : std_logic_vector(NB_LANES-1 downto 0) := (others => '1');
  --
  signal d_ctrl           : std_logic_vector(1 downto 0)          := "01";
  signal toggle_ena       : std_logic                             := '1';
  signal prbs_ena         : std_logic                             := '1';
  signal dc_ena           : std_logic                             := '1';
  signal ip_ready         : std_logic                             := '0';
  signal lanes_ready      : std_logic                             := '0';
  signal err_status       : std_logic                             := '0';
  signal valid_status     : std_logic                             := '0';
  --
  signal sw1              : std_logic;
  signal sw2              : std_logic;
  signal dip1             : std_logic;
  signal dip2             : std_logic;
  signal dip3             : std_logic;
  signal dip4             : std_logic;
  signal led              : std_logic_vector(3 downto 0);
--
--
begin
  -- SYSTEM clock:
  CLK_50MHZ_I <= not CLK_50MHZ_I after clk50_period/2;
  refclk_p    <= not refclk_p    after clk1565_period/2;
  refclk_n    <= not refclk_n    after clk1565_period/2;
  --
  esistream_62b64b_top_1 : entity work.esistream_62b64b_top
    generic map
    (
      NB_LANES  => NB_LANES,
      COMMA     => COMMA,
      DEB_WIDTH => 2
      )
    port map
    (
      CLK_50MHZ_I => CLK_50MHZ_I,
      refclk_n    => refclk_n,
      refclk_p    => refclk_p,
      rxp         => txp,
      rxn         => txn,
      txp         => txp,
      txn         => txn,
      SW1         => sw1,
      SW2         => sw2,
      DIP1        => dip1,
      DIP2        => dip2,
      DIP3        => dip3,
      DIP4        => dip4,
      LED         => led
      );
  --
  sw1          <= rst_in_n;
  sw2          <= not sync;
  lanes_ready  <= led(0);
  ip_ready     <= led(1);
  valid_status <= led(2);
  err_status   <= led(3);
  --
  dip1         <= d_ctrl(0);
  dip2         <= toggle_ena;
  dip3         <= prbs_ena;
  dip4         <= dc_ena;
  --
  stimulus_process : process
    procedure write_log
      (
        signal err_status : in std_logic
        ) is
      file logfile     : text;
      variable fstatus : file_open_status;
      variable buf     : line;
    begin
      --
      file_open(fstatus, logfile, "bit_error_status.txt", append_mode);
      L1 : write(buf, string'("tb result: [cb_status or be_status] = ["));
      L2 : write(buf, err_status);
      L3 : write(buf, string'("] "));
      L4 : writeline(logfile, buf);
      file_close(logfile);
    end write_log;

    procedure send_sync(
      signal lanes_ready  : in  std_logic;
      signal valid_status : in  std_logic;
      signal sync         : out std_logic) is
    begin
      wait for 100 ns;
      sync <= '1';
      wait for 100 ns;
      sync <= '0';
      report "sync sent...";
      wait for 100 ns;
      report "wait lanes_ready";
      wait until rising_edge(lanes_ready);
      report "lanes ready...";
      report "wait valid_status";
      wait until rising_edge(valid_status);
      report "valid status...";
    end send_sync;
  begin
    sync     <= '0';
    rst_in_n <= '0';
    wait for 100 ns;
    rst_in_n <= '1';
    report "release reset...";
    report "start testbench...";
    report "wait ip_ready";
    wait until rising_edge(ip_ready);  -- 20 us;
    -- HSSLs shifts to check rx_frame_alignment module
    for ii in 0 to 63 loop
      wait until rising_edge(refclk_p);
      send_sync(lanes_ready, valid_status, sync);
      wait for 1 us;
      write_log(err_status);
      wait for 100 ns;
    end loop;
    wait for 1 us;
    assert false report "Test finish" severity failure;
    wait;
  end process;
end behavioral;
