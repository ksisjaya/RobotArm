library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx1 is
	port(
		inputA	: in std_logic;							--represents the 1-bit to be compared (i.e. current temp.)
		inputB	: in std_logic;							--represents the 1-bit being compared to (i.e. desired temp.)
		output	: out std_logic_vector(2 downto 0)	--result outputted as vector (i.e. output(2) is GT, output(1) is EQ, output(0) is LT)
	);
end entity Compx1;

architecture Behavior of Compx1 is

begin

	output(2) <= inputA AND (NOT inputB);	--inputA is 1 and inputB is 0 gives A > B
	output(1) <= NOT(inputA XOR inputB);	--input A and inputB have an even no. of 1’s gives A == B
	output(0) <= (NOT inputA) AND inputB;	--inputA is 0 and inputB is 1 gives A < B

end Behavior;