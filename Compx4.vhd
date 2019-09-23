library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx4 is
	port(
		temp1	: in std_logic_vector(3 downto 0);		--represents the 4-bit to be compared (i.e. current temp.)
		temp2	: in std_logic_vector(3 downto 0);		--represents the 4-bit being compared to (i.e. desired temp.)
		output	: out std_logic_vector(2 downto 0)	--result outputted as vector (i.e. output(2) is GT, output(1) is EQ, output(0) is LT)
	);
end entity Compx4;

architecture Structure of Compx4 is

	--create component of Compx1 to compare bit by bit
	component Compx1 port (
		inputA	: in std_logic;							--represents the 1-bit to be compared (i.e. current temp.)
		inputB	: in std_logic;							--represents the 1-bit being compared to (i.e. desired temp.)
		output	: out std_logic_vector(2 downto 0) 	--result outputted as vector (i.e. output(2) is GT, output(1) is EQ, output(0) is LT)
	);
	end component;

	--create four signals to be used as outputs of the instantiations of Compx1
	signal input1	: std_logic_vector(2 downto 0);
	signal input2	: std_logic_vector(2 downto 0);
	signal input3	: std_logic_vector(2 downto 0);
	signal input4	: std_logic_vector(2 downto 0);
	
begin

	--instantiate Compx1 four times to compare between each bit of the two 4-bit input values one by one (i.e. 1st bit of temp1 and 1st bit of temp2, etc.)
	INST0: Compx1 port map(temp1(3), temp2(3), input4);
	INST1: Compx1 port map(temp1(2), temp2(2), input3);
	INST2: Compx1 port map(temp1(1), temp2(1), input2);
	INST3: Compx1 port map(temp1(0), temp2(0), input1);
	
	--if 4th bit of temp1 greater than 4th bit of temp2 or
	--if 4th bits are equal and 3rd bit of temp1 greater than 3rd bit of temp2 or
	--if 4th and 3rd bits are equal and 2nd bit of temp1 greater than 2nd bit of temp2 or
	--if 2nd to 4th bits are equal and 1st bit of temp1 greater than 1st bit of temp2, then assign 1 to output(2) to represent greater than
	output(2) <= input4(2) OR (input4(1) AND input3(2)) OR (input4(1) AND input3(1) AND input2(2)) OR (input4(1) AND input3(1) AND input2(1) AND input1(2));
	
	--if all 4 bits of temp1 are equal to all 4 bits of temp2, then assign 1 to output(1) to represent equality
	output(1) <= input4(1) AND input3(1) AND input2(1) AND input1(1);

	--if 4th bit of temp1 less than 4th bit of temp2 or
	--if 4th bits are equal and 3rd bit of temp1 less than 3rd bit of temp2 or
	--if 4th and 3rd bits are equal and 2nd bit of temp1 less than 2nd bit of temp2 or
	--2nd to 4th bits are equal and 1st bit of temp1 less than 1st bit of temp2, then assign 1 to output(0) to represent less than
	output(0) <= input4(0) OR (input4(1) AND input3(0)) OR (input4(1) AND input3(1) AND input2(0)) OR (input4(1) AND input3(1) AND input2(1) AND input1(0));
	
end Structure;