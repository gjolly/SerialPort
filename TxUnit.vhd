library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is

	type t_etat is (Initial, chargement_registre, envoi_start, envoi_donnees, envoi_parite, envoi_stop);
	signal etat : t_etat;
	signal le_buffer, le_registre : std_logic_vector(7 downto 0);
	signal cpt : natural;
	signal buffer_libre, registre_libre : std_logic;
	
	begin
	bufE <= buffer_libre;
	regE <= registre_libre;
	process (clk, reset)
		variable parite : std_logic := '0';
		begin
			if reset = '0' then
				etat <= Initial;
				buffer_libre <= '1';
				registre_libre <= '1';
				txd <= '1';
			elsif rising_edge(clk) then
				case etat is
					when Initial =>
						if ld = '1' then
							le_buffer <= data;
							buffer_libre <= '0';
							etat <= chargement_registre;
							parite := '0';
						end if;
					when envoi_donnees =>
						if enable = '1' then
							txd <= le_registre(cpt);
							parite := parite xor le_registre(cpt);
							if cpt > 0 then
								cpt <= cpt - 1;
							else
								etat <= envoi_parite;
							end if;
						end if;
					when chargement_registre =>
						le_registre <= le_buffer;
						buffer_libre <= '1';
						registre_libre <= '0';
						etat <= envoi_start;
					when envoi_start =>
						if enable = '1' then
							txd <= '0';
							cpt <= 7;
							etat <= envoi_donnees;
						end if;
					when envoi_parite =>
						if enable = '1' then
							txd <= parite;
							etat <= envoi_stop;
						end if;
					when envoi_stop =>
						if enable = '1' and buffer_libre = '1' then
							txd <= '1';
							registre_libre <= '1';
							etat <= Initial;
						elsif enable = '1' and buffer_libre = '0' then
							txd <= '1';
							registre_libre <= '1';
							etat <= chargement_registre;
						end if;
					end case;
				end if;
	end process;
end behavorial;
