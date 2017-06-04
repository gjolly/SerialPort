library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    rd               : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture behavorial of RxUnit is
	type t_etat is (Initial, launch_tmpclk, lecture_data, parity_check, traitement, test_lecture);
	signal etat : t_etat;
	signal cpt : natural;
	signal dataTmp : std_logic_vector(7 downto 0);
	signal cmpClk : integer range 0 to 15 := 0;
	signal cmpData : integer range 0 to 8 := 0;
	
begin
	process (clk, reset)
	
	variable parite, pariteRx : std_logic;

	variable stopBit : std_logic;
	
	
		begin
		
			if reset = '0' then
				etat <= Initial;
				parite := '0';
				cmpClk <= 0;
				cmpData <= 0;
				Ferr <= '0';
				OErr <= '0';
				DRdy <= '0';
				
			elsif rising_edge(clk) then
			
				case etat is
				
					when Initial =>
							if rxd = '0' then-- detection du bit de start
								parite := '0';
								cmpClk <= 0;
								cmpData <= 0;
								etat <= launch_tmpClk;
							end if;
						
					when launch_tmpClk =>
							if cmpClk = 7 then
								cmpClk <= 0;
								etat <= lecture_data;
							else
								cmpClk <= cmpClk + 1;
							end if;

					when lecture_data =>
							if cmpClk = 15 then
								cmpClk <= 0;
								if cmpData < 8 then
									dataTmp(7 - cmpData) <= rxd;
									parite := rxd xor parite;
									cmpData <= cmpData + 1;
								else
									pariteRx := rxd;
									etat <= parity_check;
								end if;
							else
								cmpClk <= cmpClk +1;
							end if;

					when parity_check =>
							if cmpClk = 15 then
								stopBit := rxd;
								etat <= traitement;
								cmpClk <= 0;
							else
								cmpClk <= cmpClk + 1;
							end if;

					when traitement =>
						if parite /= pariteRx or stopBit /= '1' then
							Ferr <= '1';
							etat <= initial;
						else
							DRdy <= '1';
							data <= dataTmp;
							etat <= test_lecture;
						end if;
							
					when test_lecture =>
						DRdy <= '0';
						if rd = '0' then
							OErr <= '1';
							etat <= Initial;
						else
							etat <= Initial;
						end if;
							
				end case;
			
			end if;
			
		end process;

end behavorial;
