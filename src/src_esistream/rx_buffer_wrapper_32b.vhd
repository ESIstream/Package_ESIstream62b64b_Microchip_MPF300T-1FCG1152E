library work;
use work.esistream6264_pkg.all;

library IEEE;
use ieee.std_logic_1164.all;

entity rx_buffer_wrapper is
  port (
    clk        : in  std_logic;
    clk_acq    : in  std_logic;
    rst        : in  std_logic;
    rd_en      : in  std_logic;
    din_rdy    : in  std_logic;
    din        : in  std_logic_vector(DESER_WIDTH-1 downto 0);
    dout       : out std_logic_vector(DESER_WIDTH-1 downto 0);
    lane_ready : out std_logic
    );
end entity rx_buffer_wrapper;

architecture rtl of rx_buffer_wrapper is

  signal wr_en   : std_logic := '0';
  signal empty_1 : std_logic := '1';
  signal empty_2 : std_logic := '1';

begin

  delay_decoding_rdy : entity work.delay
    generic map (
      LATENCY => (3-DESER_WIDTH/32)*32-1-1-2
      )
    port map (
      clk => clk,
      rst => rst,
      d   => din_rdy,
      q   => wr_en
      );

  i_output_buffer_16b_1 : entity work.rx_fifo_dc
    generic map
    (
      G_DATA_LENGTH => 16,
      G_ADDR_LENGTH => 9
      )
    port map
    (
      RESET => rst,

      CLK_WR  => clk,
      WR      => wr_en,
      DATA_IN => din(31 downto 16),

      CLK_RD   => clk_acq,
      RD       => rd_en,
      DATA_OUT => dout(31 downto 16),

      THRESHOLD_HIGH => (others => '1'),
      THRESHOLD_LOW  => (others => '0'),

      FULL           => open,
      ALMOST_FULL    => open,
      FULL_N         => open,
      ALMOST_FULL_N  => open,
      EMPTY          => empty_1,
      ALMOST_EMPTY   => open,
      EMPTY_N        => open,
      ALMOST_EMPTY_N => open
      );

  i_output_buffer_16b_2 : entity work.rx_fifo_dc
    generic map
    (
      G_DATA_LENGTH => 16,
      G_ADDR_LENGTH => 9
      )
    port map
    (
      RESET => rst,

      CLK_WR  => clk,
      WR      => wr_en,
      DATA_IN => din(15 downto 0),

      CLK_RD   => clk_acq,
      RD       => rd_en,
      DATA_OUT => dout(15 downto 0),

      THRESHOLD_HIGH => (others => '1'),
      THRESHOLD_LOW  => (others => '0'),

      FULL           => open,
      ALMOST_FULL    => open,
      FULL_N         => open,
      ALMOST_FULL_N  => open,
      EMPTY          => empty_2,
      ALMOST_EMPTY   => open,
      EMPTY_N        => open,
      ALMOST_EMPTY_N => open
      );

  lane_ready <= not empty_1 and not empty_2;

end architecture rtl;
