library IEEE;
use IEEE.std_logic_1164.all;

package n7 is

  -- procedure clock qui genere une pulsation binaire
  -- les parametres sont :
  --    en sortie : C, le signal binaire
  --    en entree : Period, la periode de ce signal
  --                StartTime, le temps absolu quand commence la pulsation
  --                StopTime, le temps absolu quand elle s'arrete
  procedure clock(signal C : out std_logic; Period, StartTime, StopTime : time);  

end n7;

package body n7 is

  -- implantation de la procedure clock
  procedure clock(signal C : out std_logic; Period, StartTime, StopTime : time) is
    begin
      assert(StartTime < StopTime);
      wait for StartTime;
      loop
        C <= '1'; wait for Period/2;
        C <= '0'; wait for Period/2;
        exit when (Now>StopTime); 
      end loop;
    end;

end n7;
