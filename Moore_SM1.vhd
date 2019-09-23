library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY MOORE_SM1 IS PORT (
			CLK		     		: in  std_logic := '0'; --Main clock input
         RESET_n      		: in  std_logic := '0'; --Reset signal
			EXT_BUTTON			: in  std_logic := '0'; --Extender toggle button
			EXT_ENBL				: in  std_logic := '0'; --Extender enable
			CURRENT				: in	std_logic_vector(3 downto 0); --Current 4 bit input from Bidir_shift_reg
         EXT_RESULT			: out std_logic; --Signal for left/right shift input for Bidir_shift_reg
			EXT_OUT				: out std_logic; --Extender out shift to output to Mealy_SM
			CLK_EN				: out std_logic; --Clk_en signal for 4-bit Bidir_shift_reg
			GRAP_ENBL			: out std_logic --Grappler enable for MOORE_SM2
			 );
END ENTITY;

ARCHITECTURE SM OF MOORE_SM1 IS

-- list all the STATES  
   TYPE STATES IS (INIT, EXTENDING, FULL_EXT, RETRACTING);   

   SIGNAL current_state, next_state			:  STATES;       -- current_state, next_state signals are of type STATES

BEGIN


-- STATE MACHINE: MOORE Type

REGISTER_SECTION: PROCESS(CLK, RESET_n, next_state) -- creates sequential logic to store the state. The rst_n is used to asynchronously clear the register
   BEGIN
		IF (RESET_n = '0') THEN
	         current_state <= INIT;
		ELSIF (rising_edge(CLK)) then
				current_state <= next_state; -- on the rising edge of clock the current state is updated with next state
		END IF;
   END PROCESS;
	

 TRANSITION_LOGIC: PROCESS(EXT_ENBL, EXT_BUTTON, current_state) -- logic to determine next state. 
   BEGIN
     CASE current_state IS
          WHEN INIT =>	--If the current state is initial
				IF(EXT_ENBL = '1' AND EXT_BUTTON = '1') THEN --If the extender is enabled and the extender toggle button is pressed
					next_state <= EXTENDING; --Extender is now extending
				ELSE
					next_state <= INIT; --Else it is still in the initial state
				END IF;
			
			WHEN EXTENDING => --If the current state is extending
				IF(CURRENT = "1111") THEN --If the current input from the Bidir_shift_reg is 1111
					next_state <= FULL_EXT; --Extender is fully extended
				ELSE
					next_state <= EXTENDING; --Else it is still extending
				END IF;
				
			WHEN FULL_EXT => --If the current state is fully extended
				IF(EXT_BUTTON = '1') THEN --If the extender toggle is pressed
					next_state <= RETRACTING; --Extender is not retracting
				ELSE
					next_state <= FULL_EXT; --Else it is still fully extended
				END IF;
			
			WHEN RETRACTING => --If the current state is retracting
				IF(CURRENT = "0000") THEN --If the current input from the Bidir_shift_reg is 0000
					next_state <= INIT; --Extender is in the initial state
				ELSE
					next_state <= RETRACTING; --Extender is still retracting
				END IF;
				
 		END CASE;
 END PROCESS;
 

 MOORE_DECODER: PROCESS(current_state) 			-- logic to determine outputs from state machine states
   BEGIN
     CASE current_state IS
	  
			--When in initial state, the CLK_EN is 0, the grappler is not enabled, the Bidir_shift_reg is not shifting to the left nor right and the extender is not extended
			WHEN INIT =>	
				CLK_EN <= '0';
				GRAP_ENBL <= '0';
				EXT_RESULT <= '0';
				EXT_OUT <= '0';

			--When in extending state, the CLK_EN is 1, the grappler is not enabled, the Bidir_shift_reg is shifting to the right and the extender is extending out
			WHEN EXTENDING =>		
				CLK_EN <= '1';
				GRAP_ENBL <= '0';
				EXT_RESULT <= '1';
				EXT_OUT <= '1';
			 
			 --When in fully extended state, the CLK_EN is 0, the grappler is now enabled, the Bidir_shift_reg is not shifting and the extender is extended
			WHEN FULL_EXT =>
				CLK_EN <= '0';
				GRAP_ENBL <= '1';
				EXT_RESULT <= '0';
				EXT_OUT <= '1';
			
			--When in retracting state, the CLK_EN is 0, the grappler is not enabled, the Bidir_shift_reg is shifting to the left and the extender is retracting
			WHEN RETRACTING =>
				CLK_EN <= '1';
				GRAP_ENBL <= '0';
				EXT_RESULT <= '0';
				EXT_OUT <= '1';
			 
		END CASE;

 END PROCESS;

END SM;
