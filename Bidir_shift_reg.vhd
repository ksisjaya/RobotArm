library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Bidir_shift_reg is port
	(
			CLK	: in std_logic := '0';
			RESET_n	: in std_logic := '0'; --Signal used to reset the counter to 0000
			CLK_EN	: in std_logic := '0'; 
			LEFT0_RIGHT1	: in std_logic := '0'; --This variable controls the left and right shift of bits
			REG_BITS	 : out std_logic_vector(3 downto 0)
	);
	end Entity;
	
	ARCHITECTURE one OF Bidir_shift_reg IS
	
	Signal sreg	: std_logic_vector(3 downto 0);

BEGIN

--Operation of Bidirectional Shift Register:
--This register is clocked by the Main_Clk signal. 
--It will only be enabled to change if the CLK_EN signal is 1 and the Main_Clk is running.
--If the LEFT0_RIGHT1 is 1 then the shift register shifts to the right
--If the LEFT0_RIGHT1 is 0 then the shift register shifts to the left

process(CLK, RESET_n) is
begin
	if(RESET_n = '0') then 
			sreg <= "0000";
	
	elsif (rising_edge(CLK) AND (CLK_EN = '1')) then --When the rising edge arrives and CLK_EN is 1
	
		if(LEFT0_RIGHT1 = '1') then --RIGHT shift
			sreg(3 downto 0) <= '1' & sreg(3 downto 1);
		
		elsif(LEFT0_RIGHT1 = '0') then --LEFT shift
			sreg(3 downto 0) <= sreg(2 downto 0) & '0';
		
		end if;
	
	end if;
	REG_BITS <= sreg;

end process;

END one;