library IEEE;
use IEEE.std_logic_1164.all;
use work.n7.all;

entity testTxUnit is
  
end testTxUnit;

architecture testTxUnit_arch of testTxUnit is

  component TxUnit
    port (
      clk, reset : in std_logic;
      enable     : in std_logic;
      ld         : in std_logic;
      txd        : out std_logic;
      regE       : out std_logic;
      bufE       : out std_logic;
      data       : in std_logic_vector(7 downto 0));
  end component;

  component clkUnit
  
    port (
      clk, reset : in  std_logic;
      enableTX   : out std_logic;
      enableRX   : out std_logic);
    
  end component;

  signal clk, reset     : std_logic;
  signal enableTX, enableRX : std_logic;  -- signal enable
  signal ld          : std_logic;
  signal txd         : std_logic;         -- bit transmit sur le support
  signal regE, bufE  : std_logic;          
                    -- etat du registre et du buffer d'emission
  signal data : std_logic_vector(7 downto 0);  -- donnees a transmettre

begin  -- testTxUnit_arch

  C: clock(clk, 25 ns, 50 ns, 30000 ns);

  uniteHorloge: clkUnit port map (clk, reset, enableTX, enableRX);

  uniteEmission: TxUnit port map (clk, reset, enableTX, ld, txd, regE, bufE, data);

  reset <= '0', '1' after 75 ns;

  testEmission: process
  begin  -- process testEmission

    ld<='0';
    wait for 500 ns;

    -- emission du caractere 0x55
    data<="01010101";

    -- l'emetteur est dispo ?
    if not (regE='1' and bufE='1') then
      wait until regE='1' and bufE='1';
    end if;

    -- si oui, on charge les donnees
    wait until clk='1' and clk'event;
    ld<='1';
    if not (regE='1' and bufE='0') then
      wait until regE='1' and bufE='0';
    end if;
    wait until clk='1' and clk'event;
    ld<='0';

    -- on attend que l'emetteur redevienne dispo
    if not (regE='1' and bufE='1') then
      wait until regE='1' and bufE='1';
    end if;

    -- 
    for i in 0 to 50 loop
      wait until clk='1' and clk'event;
    end loop;

    -- emission d'un deuxieme caractere, 0xAA
    data<="10101010";
    wait until clk='1' and clk'event;
    ld<='1';
    if not (regE='1' and bufE='0') then
      wait until regE='1' and bufE='0';
    end if;
    wait until clk='1' and clk'event;
    ld<='0';
    
    wait for 100 ns;

    -- emission d'un troisieme 0x45
    -- (test load pendant envoi_start)
    data<="01000101";
    if not bufE='1' then
      wait until bufE='1';
    end if;
    wait for 100 ns;
    ld<='1';
    wait until clk='1' and clk'event;
    wait until clk='1' and clk'event;
    ld<='0';

    wait for 5000 ns;
	 
    -- emission d'un quatrieme caractere 0x88
    -- (test load pendant envoi_data)
    data<="10001000";
    ld<='1';
    wait until clk='1' and clk'event;
    wait until clk='1' and clk'event;
    ld<='0';

    wait for 7100 ns;
	 
	 -- emission d'un cinquieme caractere 0xF0
         -- (test load pendant envoi_parite)
    data<="11110000";
    ld<='1';
    wait until clk='1' and clk'event;
    wait until clk='1' and clk'event;
    ld<='0';

    wait for 4900 ns;
	 
    -- emission d'un sixieme caractere 0x1F
    -- (test load pendant envoi_stop)
    data<="00011111";
    ld<='1';
    wait until clk='1' and clk'event;
    wait until clk='1' and clk'event;
    ld<='0';

    wait;
    
  end process testEmission;

end testTxUnit_arch;
