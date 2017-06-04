library IEEE;
use IEEE.std_logic_1164.all;

entity diviseurClk_UART is
  port (
    clk, reset : in  std_logic;
    nclk       : out std_logic);
end diviseurClk_UART;

architecture arch_divClk of diviseurClk_UART is

  signal top : std_logic := '0';
  
begin  

  div32 : process (clk, reset)
    variable cpt32 : integer range 0 to 31 := 0;
  begin 
    if reset='0' then
      top<='0';
      cpt32:=0;
    elsif clk'event and clk='1' then
      if cpt32=31 then
        top<='1';
      else
        top<='0';
      end if;
      cpt32:=(cpt32+1) mod 32;
    end if;
    
  end process;

  div10: process (top, reset)
    variable cpt10 : integer range 0 to 9:= 0;
  begin 
    if reset = '0' then                 
      cpt10:=9;
      nclk<='0';
    elsif top'event and top = '1' then  
      if cpt10=9 then
        nclk<='1';
      else
        nclk<='0';
      end if;
      cpt10:=(cpt10+1) mod 10;
    end if;
  end process div10;

end arch_divClk;
