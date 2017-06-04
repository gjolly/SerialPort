library IEEE;
use IEEE.std_logic_1164.all;

entity echoUnit is
    port (
      clk, reset : in  std_logic;
      cs, rd, wr : out  std_logic;
      IntR       : in std_logic;
      IntT       : in std_logic;
      addr       : out  std_logic_vector(1 downto 0);
      data_in    : in  std_logic_vector(7 downto 0);
      data_out   : out std_logic_vector(7 downto 0));
end echoUnit;

architecture echoUnit_arch of echoUnit is

  type t_etat is (test_emission, attente, reception,
                  attente_emission, pret_a_emettre, emission);
  signal etat : t_etat := attente;
  signal donnee : std_logic_vector(7 downto 0) := (others => '0');
	
begin

  process (clk, reset)
  begin
    if reset='0' then
      etat <= test_emission;
    elsif clk='1' and clk'event then
      case etat is
        -- cet etat n'est destine qu a tester l'emission
        -- il suffit de modifier l'etat dans la partie reset
        when test_emission =>
          cs <= '1';
          rd <= '1';
          wr <= '1';
          data_out <= (others => '0');
          addr <= (others => '0');
          -- donnee = caractere A (0x41) (poids faibles d'abord)
          donnee <= "10000010";
          etat <= pret_a_emettre;
                        
        when attente => 
          cs <= '1';
          rd <= '1';
          wr <= '1';
          data_out <= (others => '0');
          addr <= (others => '0');
          if (IntR='0') then
            -- IntR=0 -> une nouvelle donnee est recue
            -- on la lit
            etat <= reception;
            cs <= '0';
            rd <= '0';
            wr <= '1';
          end if;

        when reception => 
          donnee <= data_in;
          if (IntR='1') then
            -- la donnee est lue
            addr <= "00";
            etat <= attente_emission;
          end if;
                      
        when attente_emission =>
          cs <= '1';
          rd <= '1';
          wr <= '1';
          etat <= pret_a_emettre;

        when pret_a_emettre =>
          -- pour savoir si l unite d emission est prete
          -- on teste le registre de controle
          cs <= '0';
          rd <= '0';
          wr <= '1';
          addr <= "01";
          -- le bit 3 correspond a TxRdy=1
          if data_in(3)='1' then
            cs <= '1';
            rd <= '1';
            wr <= '1';
            -- on positionne la donnee pour l'UART
            data_out <= donnee;
            etat <= emission;
          end if;
                        
        when emission =>
          -- on ecrit la donnee dans le buffer d emission
          cs <= '0';
          rd <= '1';
          wr <= '0';
          donnee <= (others => '0');
          etat <= attente;
                   
      end case;
    end if;
  end process;
	
end echoUnit_arch;
