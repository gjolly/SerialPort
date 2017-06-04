library IEEE;
use IEEE.std_logic_1164.all;
use work.n7.all;

entity testClk is
end testClk;

architecture testClk_arch of testClk is

  component clkUnit
  
    port (
      clk, reset : in  std_logic;
      enableTX   : out std_logic;
      enableRX   : out std_logic);
    
  end component;

  signal clk : std_logic;
  signal reset : std_logic;
  signal enableTX : std_logic;
  signal enableRX : std_logic;
  
begin  -- testClk_arch

  C: clock(clk, 5 ns, 0 ns, 1000 ns);

  diviseur: clkUnit port map (clk, reset, enableTX, enableRX);

  reset <= '0', '1' after 10 ns;

end testClk_arch;
