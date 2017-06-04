library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is
	
begin

	div : process (clk, reset)
	variable compteur : integer range 0 to 15 := 0;
	begin
		if reset = '0' then
			enableTX <= '0';
			compteur := 0;
		elsif rising_edge(clk) theN
			if compteur = 15 then 
				compteur := 0;
			else 
				compteur := compteur +1;
			end if;
			if compteur = 0 then
				enableTX <= clk;
			else
				enableTX <= '0';
			end if;
		end if;
	end process;
	
	enableRX <= clk;
end behavorial;
