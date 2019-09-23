library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY Mux7 is port(
	input1	: in std_logic_vector(6 downto 0);
	input2	: in std_logic_vector(6 downto 0);
	enable	: in std_logic;
	output	: out std_logic_vector(6 downto 0)
);
END ENTITY;

ARCHITECTURE BEHAVIOUR OF Mux7 IS

BEGIN
	WITH enable SELECT
	output <= input1 when '0', --If the enable is 0, input1 is the output
				 input2 when others; --If the enable is 1, input2 is the output

END ARCHITECTURE BEHAVIOUR;