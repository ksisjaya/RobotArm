library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY Mux4 is port(
	input1	: in std_logic_vector(3 downto 0);
	input2	: in std_logic_vector(3 downto 0);
	enable	: in std_logic;
	output	: out std_logic_vector(3 downto 0)
);
END ENTITY;

ARCHITECTURE BEHAVIOUR OF Mux4 IS

BEGIN
	WITH enable SELECT
	output <= input1 when '0', --If the push button is not pressed, output input1
				 input2 when others; --If the push button is pressed, output input2

END ARCHITECTURE BEHAVIOUR;