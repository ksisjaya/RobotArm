library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY Mealy_SM IS PORT (
          CLK		     		: in  std_logic := '0'; --Main clock input
          RESET_n      		: in  std_logic := '0'; --Reset signal
			 pb_in				: in 	std_logic_vector(1 downto 0); --Push button inputs
			 Xinput				: in 	std_logic_vector(2 downto 0); --X comparison input from Compx4
			 Yinput				: in	std_logic_vector(2 downto 0); --Y comparison input from Compx4
			 ext_out				: in	std_logic; --Extender out signal from MOORE_SM1
			 Xoutput				: out std_logic; --Up/down X counter output to U_D_Bin_Counter4bit
			 Youtput				: out std_logic; --Up/down Y counter output to U_D_Bin_Counter4bit
			 XCLK					: out std_logic; --X clock output to U_D_Bin_Counter4bit
			 YCLK					: out std_logic; --Y clock output to U_D_Bin_Counter4bit
			 led0					: out std_logic --led[0] for error
			 );
END ENTITY;

ARCHITECTURE SM OF Mealy_SM IS

-- list all the STATES

	TYPE STATES IS (INIT, X_MOVING, Y_MOVING, BOTH_MOVING, HOLD, ERROR); --6 states used
	
	SIGNAL current_State, next_State	: STATES; --Used to control the current and next state


BEGIN

-- STATE MACHINE: MEALY Type

REGISTER_SECTION: PROCESS(CLK, RESET_n, next_State) -- creates sequential logic to store the state. The rst_n is used to asynchronously clear the register
   BEGIN
		IF (RESET_n = '0') THEN
	         current_State <= INIT;
		ELSIF (rising_edge(CLK)) then
				current_State <= next_State;
		END IF;
   END PROCESS;
	
Transition_Section: PROCESS (pb_in(1 downto 0), Xinput, Yinput, current_State) --Transitions from current state to next state

BEGIN
	CASE current_State is
		WHEN INIT =>
			IF(Xinput(1) = '1' AND Yinput(1) = '1') THEN 
				next_State <= HOLD; --When the target X and Y is equal to the current X and Y, next state is HOLD
			ELSIF(Xinput(1) = '0' AND Yinput(1) = '0' AND pb_in = "11") THEN
				next_State <= BOTH_MOVING; --When the target X and Y is not equal to the current X and Y and the both push buttons (3 and 2) are pushed, next state is BOTH_MOVING
			ELSIF(Yinput(1) = '0' AND pb_in(0) = '1') THEN
				next_State <= Y_MOVING; --When the target Y is not equal to the current Y and the respective push button for Y movement is pressed (push button 2), next state is Y_MOVING
			ELSIF(Xinput(1) = '0' AND pb_in(1) = '1') THEN
				next_State <= X_MOVING; --When the target X is not equal to the current X and the respective push button for X movement is pressed (push button 3), next state is X_MOVING
			ELSE
				next_State <= INIT; --Else go back to INITIAL state
			END IF;
		
		WHEN X_MOVING =>
			IF(Xinput(1) = '1' AND Yinput(1) = '1') THEN
				next_State <= HOLD; --When the target X and Y is equal to the current X and Y, next state is HOLD
			ELSIF(Xinput(1) = '0' AND Yinput(1) = '0' AND pb_in = "11") THEN
				next_State <= BOTH_MOVING; --When the target X and Y is not equal to the current X and Y and the both push buttons (3 and 2) are pushed, next state is BOTH_MOVING
			ELSIF(Yinput(1) = '0' AND pb_in(0) = '1') THEN
				next_State <= Y_MOVING; --When the target Y is not equal to the current Y and the respective push button for Y movement is pressed (push button 2), next state is Y_MOVING
			ELSIF(Xinput(1) = '0' AND pb_in(1) = '1') THEN
				next_State <= X_MOVING; --When the target X is not equal to the current X and the respective push button for X movement is pressed (push button 3), next state is X_MOVING
			ELSE
				next_State <= INIT; --Else go back to INITIAL state
			END IF;
		
		WHEN Y_MOVING =>
			IF(Xinput(1) = '1' AND Yinput(1) = '1') THEN
				next_State <= HOLD; --When the target X and Y is equal to the current X and Y, next state is HOLD
			ELSIF(Xinput(1) = '0' AND Yinput(1) = '0' AND pb_in = "11") THEN
				next_State <= BOTH_MOVING; --When the target X and Y is not equal to the current X and Y and the both push buttons (3 and 2) are pushed, next state is BOTH_MOVING
			ELSIF(Yinput(1) = '0' AND pb_in(0) = '1') THEN
				next_State <= Y_MOVING; --When the target Y is not equal to the current Y and the respective push button for Y movement is pressed (push button 2), next state is Y_MOVING
			ELSIF(Xinput(1) = '0' AND pb_in(1) = '1') THEN
				next_State <= X_MOVING; --When the target X is not equal to the current X and the respective push button for X movement is pressed (push button 3), next state is X_MOVING
			ELSE
				next_State <= INIT; --Else go back to INITIAL state
			END IF;
		
		WHEN BOTH_MOVING =>
			IF(Xinput(1) = '1' AND Yinput(1) = '1') THEN
				next_State <= HOLD; --When the target X and Y is equal to the current X and Y, next state is HOLD
			ELSIF(Xinput(1) = '0' AND Yinput(1) = '0' AND pb_in = "11") THEN
				next_State <= BOTH_MOVING; --When the target X and Y is not equal to the current X and Y and the both push buttons (3 and 2) are pushed, next state is BOTH_MOVING
			ELSIF(Yinput(1) = '0' AND pb_in(0) = '1') THEN
				next_State <= Y_MOVING; --When the target Y is not equal to the current Y and the respective push button for Y movement is pressed (push button 2), next state is Y_MOVING
			ELSIF(Xinput(1) = '0' AND pb_in(1) = '1') THEN
				next_State <= X_MOVING; --When the target X is not equal to the current X and the respective push button for X movement is pressed (push button 3), next state is X_MOVING
			ELSE
				next_State <= INIT; --Else go back to INITIAL state
			END IF;
			
		WHEN HOLD =>
			IF(Xinput(1) = '1' AND Yinput(1) = '1') THEN
				next_State <= HOLD; --When the target X and Y is equal to the current X and Y, next state is HOLD
			ELSIF(Xinput(1) = '0' AND Yinput(1) = '0' AND pb_in = "11") THEN
				next_State <= BOTH_MOVING; --When the target X and Y is not equal to the current X and Y and the both push buttons (3 and 2) are pushed, next state is BOTH_MOVING
			ELSIF(Yinput(1) = '0' AND pb_in(0) = '1') THEN
				next_State <= Y_MOVING; --When the target Y is not equal to the current Y and the respective push button for Y movement is pressed (push button 2), next state is Y_MOVING
			ELSIF(Xinput(1) = '0' AND pb_in(1) = '1') THEN
				next_State <= X_MOVING; --When the target X is not equal to the current X and the respective push button for X movement is pressed (push button 3), next state is X_MOVING
			ELSIF(ext_out = '1' AND (Xinput(1) = '0' OR Yinput(1) = '0')) THEN
				next_State <= ERROR; --If the extender is extended and either the target X is not equal to the current X or the target Y is not equal to the current Y
			ELSE
				next_State <= INIT; --Else go back to INITIAL state
			END IF;
		
		WHEN ERROR =>
			IF(ext_out = '0') then
				next_state <= INIT; --If the extender is not out/retracted then go back to INITIAL state
			ELSE
				next_state <= ERROR; --Else go back to ERROR
			END IF;
		
		END CASE;
END PROCESS;

Decoder_Section: PROCESS (pb_in(1 downto 0), current_State, Xinput, Yinput, ext_out) --Sets the output signals when the state machine reaches specific state

BEGIN
	IF(current_State = X_MOVING) THEN
		XCLK <= NOT Xinput(1); --If the current X is not equal to the target X, set the XCLK to 1
		YCLK <= '0'; --The YCLK will be set to 0 (because Y is not moving)
		Xoutput <= Xinput(0);	-- If the current X is less than, set the Xoutput to 1 (count up). That means if current X is more than, the Xoutput is set to 0 (count down)
		led0 <= '0'; --Error has not occurred
	ELSIF(current_State = Y_MOVING) THEN
		XCLK <= '0'; --The XCLK will be set to 0 (because X is not moving)
		YCLK <= NOT Yinput(1); --If the current Y is not equal to the target Y, set the YCLK to 1
		Youtput <= Yinput(0);	-- If the current Y is less than, set the Youtput to 1 (count up). That means if current Y is more than, the Youtput is set to 0 (count down)
	led0 <= '0'; --Error has not occurred
	ELSIF(current_State = BOTH_MOVING) THEN
		XCLK <= NOT Xinput(1); --If the current X is not equal to the target X, set the XCLK to 1.
		YCLK <= NOT Yinput(1); --If the current Y is not equal to the target Y, set the YCLK to 1.
		Xoutput <= Xinput(0);	-- If the current X is less than, set the Xoutput to 1 (count up). That means if current X is more than, the Xoutput is set to 0 (count down)
		Youtput <= Yinput(0);	-- If the current Y is less than, set the Youtput to 1 (count up). That means if current Y is more than, the Youtput is set to 0 (count down)
		led0 <= '0';
	ELSIF(current_State = HOLD) THEN
		Xoutput <= Xinput(1); --If the current X is equal to target X, set Xoutput to 1.
		Youtput <= Yinput(1); --If the current Y is equal to target Y, set Youtput to 1.
		XCLK <= '0'; --XCLK is 0
		YCLK <= '0'; --YCLK is 0
		led0 <= '0'; --Error has not occurred
	ELSIF(current_State = INIT) THEN --Nothing is moving as yet
		XCLK <= '0'; --XCLK is 0
		YCLK <= '0'; --YCLK is 0
		Xoutput <= '0'; --Xoutput is 0
		Youtput <= '0'; --Youtput is 0
		led0 <= '0'; --Error has not occurred
	ELSIF(current_State = ERROR) THEN
		XCLK <= '0';
		YCLK <= '0';
		Xoutput <= '0';
		Youtput <= '0';
		led0 <= ext_out; --If extender is extended/ing and you try to move it, error will occur
	END IF;

END PROCESS;

END ARCHITECTURE SM;