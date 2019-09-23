library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity U_D_Bin_Counter4bit is port
	(
		CLK	: in std_logic := '0'; --Main clock input
		RESET_n	: in std_logic := '0'; --Reset signal
		CLK_EN	: in std_logic := '0'; --Clock enable from Mealy_SM
		UP1_DOWN0	: in std_logic := '0'; --This variable controls the up and down count
		COUNTER_BITS	: out std_logic_vector(3 downto 0) --4 bits needed
	);
	end ENTITY;
	
	ARCHITECTURE one OF U_D_Bin_Counter4bit IS
	
	SIGNAL ud_bin_counter : UNSIGNED(3 downto 0);

BEGIN

--Operation of Up/Down Binary Counter Component:
--This register is clocked by the Main_Clk signal. 
--It will only be enabled to change if the CLK_EN signal is 1 and the Main_Clk is running.
--If the UP1_DOWN0 is 1 then the counter counts up
--If the UP1_DOWN0 is 0 then the counter counts down

process(CLK, RESET_n) is
begin
	if(RESET_n = '0') then
			ud_bin_counter <= "0000";
		
	elsif(rising_edge(CLK)) then --When the rising edge arrives
		if((UP1_DOWN0 = '1') AND (CLK_EN = '1')) then --UP count
			ud_bin_counter <= (ud_bin_counter + 1);
		
		elsif((UP1_DOWN0 = '0') AND (CLK_EN = '1')) then --DOWN count
			ud_bin_counter <= (ud_bin_counter - 1);
		
		end if;
	 end if;
	 
	 COUNTER_BITS <= std_logic_vector(ud_bin_counter);
	
end process;

end;