library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY MOORE_SM2 IS PORT (
          CLK		     		: in  std_logic := '0'; --Main clock input
          RESET_n      		: in  std_logic := '0'; --Reset signal
			 GRAP_BUTTON		: in  std_logic := '0'; --Grappler toggle button
			 GRAP_ENBL			: in  std_logic := '0'; --Grappler enable signal from MOORE_SM1
          GRAP_ON			   : out std_logic --Grappler active signal to led[3]
			 );
END ENTITY;

ARCHITECTURE SM OF MOORE_SM2 IS

-- list all the STATES  
   TYPE STATES IS (INIT, GRAP_OPEN, GRAP_CLOSED);   

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
	

 TRANSITION_LOGIC: PROCESS(GRAP_ENBL, GRAP_BUTTON, current_state) -- logic to determine next state. 
   BEGIN
     CASE current_state IS
          WHEN INIT =>		--When the current state is initial
            IF (GRAP_ENBL='1') THEN --If the grappler enable is 1
               next_state <= GRAP_OPEN; --Next state is grappler open
				ELSE
               next_state <= INIT; --else next state is initial
            END IF;
        WHEN GRAP_OPEN =>	--When the grappler is opened
            IF ((GRAP_ENBL='1') AND (GRAP_BUTTON='1')) THEN --If the grappler enable is 1 and the grappler toggle is pressed
               next_state <= GRAP_CLOSED; --The grappler will close
				ELSE
               next_state <= GRAP_OPEN; --Else the grappler remains opened
            END IF;

         WHEN GRAP_CLOSED =>	--When the grappler is closed
            IF ((GRAP_ENBL='1') AND (GRAP_BUTTON='1')) THEN --If the grappler enable is 1 and the grappler toggle is pressed
               next_state <= GRAP_OPEN; --The grappler will open
				ELSE
               next_state <= GRAP_CLOSED; --Else the grappler remains closed
            END IF;
				
			 WHEN OTHERS =>
               next_state <= INIT;
					
 		END CASE;
 END PROCESS;

 MOORE_DECODER: PROCESS(current_state) 			-- logic to determine outputs from state machine states
   BEGIN
     CASE current_state IS
	  
        WHEN INIT =>		
			 GRAP_ON	<= '0'; --When in initial state

			 WHEN GRAP_OPEN =>		
			 GRAP_ON	<= '0'; --When the grappler is not opened
			 			 
        WHEN GRAP_CLOSED =>
			 GRAP_ON	<= '1'; --When the grappler is closed
			 
			WHEN OTHERS =>
			 GRAP_ON	<= '0'; --Else others
			 
		END CASE;

 END PROCESS;

END SM;
