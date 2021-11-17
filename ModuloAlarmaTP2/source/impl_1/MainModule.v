module MainModule (
    // I/O PINS
    output reg SIREN_OUT = 0,   	//Salida de sirena
    input SENSOR1_IN, SENSOR2_IN,  //Sensores

    output wire STATUS_OUT, 	//Datos
    output wire STATUS_SEND, 	//Habilitador
    input wire[1:0] KB_IN,   	//Datos
    input KB_RECV,   			//Habilitador 

    output wire SERCLK_OUT,

    input CTRL_IN, CTRL_RECV, CTRL_CLK,

    output reg RESET_OUT 
    //input RESET_IN
);

    // Clock interno del modulo principal
    LSOSC OSCInst1 (.CLKLFEN(1'b1), .CLKLFPU(1'b1), .CLKLF(SERCLK_OUT));
    //--------------------------------------------------------------------	

    // SET DE TIMER
    wire TIME_OUT;
    reg TIMER_EN;
    wire [17:0] TIMER_COUNTER = 15000; 	// 15 Segundos = 150000
    timer mainTimer (		 			// CLK con tiempo customizable
        .clkSignal(SERCLK_OUT),		    // Señal del CLK a utilizar
        .maxCount(TIMER_COUNTER),       // Cantidad de pulsos a contar. Max: 262.143e3
        .EN(TIMER_EN),                  // Señal de ENABLE
        .RST(1'b0),                     // Señal de RESET
        .clkFinish(TIME_OUT) 		    // Cuando se llega a 0, emite señal de FINISH (Activo alto)
    );
    //--------------------------------------------------------------------

    // SET DE KEYBOARD
    wire [3:0] MSG;
    reg INIT = 1;
    easySerialOut STATE_OUT(
        .EN(1'b1),	        		// ENANBLE
        .CLK(SERCLK_OUT),	    	// CLK Signal
        .msg(MSG),					// Mensaje a transmitir
        .SB(4'd3), 					// Stand By, canidad de pulsos en los que no se transmite
        .state_send(STATUS_SEND),	// Aviso de comienzo de transmision	
        .state_out(STATUS_OUT)		// Canal de transmision
    );
    //--------------------------------------------------------------------

    //Variables y parametros
    reg [1:0]state = 0; // Comienza en modo inactivo
    parameter INACTIVO = 0, ARMADO = 1, ESPERA = 2, ALARMA = 3;
    reg [1:0]KEY_STATUS;
    parameter KEY_OK = 0, KEY_OKNEG = 1, KEY_ERROR = 2, NO_KEY = 3;
    //--------------------------------------------------------------------
	assign MSG = {SENSOR2_IN, SENSOR1_IN, state==ALARMA, !(state==INACTIVO)};
	
    // Asignacion de estados
    always @ (state, KEY_STATUS, SENSOR1_IN, SENSOR2_IN, TIME_OUT) begin      //IT IS NOT TERMINADO
    case (state)
        INACTIVO: begin
			if (KEY_STATUS == KEY_OK) begin
				state <= ARMADO;	
			end				
			SIREN_OUT <= 0;
			KEY_STATUS <= NO_KEY;
		   	end 
        
		ARMADO:	begin
            if (KEY_STATUS == KEY_OKNEG)
                state <= INACTIVO;
            else if (KEY_STATUS == KEY_ERROR)
                state <= ALARMA;
            else if (KEY_STATUS == NO_KEY) begin
                if (SENSOR1_IN)		 	// Ventana
                    state <= ALARMA;
                else if (SENSOR2_IN) 	// Puerta
                    state <= ESPERA;
            end
			KEY_STATUS <= NO_KEY;
			end
			
        ESPERA: begin
			if (TIME_OUT) begin
                state <= ALARMA;
                TIMER_EN <= 0;
            end				
            else if (KEY_STATUS == KEY_OK) begin
                state <= INACTIVO;
                TIMER_EN <= 0;
            end
            else if (KEY_STATUS == KEY_ERROR || KEY_STATUS == NO_KEY) begin
				TIMER_EN <= 1;
			end
			KEY_STATUS <= NO_KEY;
			end
			
        ALARMA:	begin
            if (KEY_STATUS == KEY_OK)
                state <= INACTIVO;
            else if (KEY_STATUS == KEY_ERROR || KEY_STATUS == NO_KEY) begin
				SIREN_OUT <= 1;
            end	
			KEY_STATUS <= NO_KEY;
			end
                
		default:
			state <= INACTIVO;
    endcase
    end
    //--------------------------------------------------------------------
	// Verificacion de mensaje recibido
	wire[1:0] RESULT;
	wire[7:0] key = {2'b00,2'b01,2'b10,2'b11};
	
	/*initial
	begin
		key[0] = 0;
		key[1] = 1;
		key[2] = 2;
		key[3] = 3;
	end
	*/
    keyChecker Keyboard(.pulsed(KB_RECV), .cable1(KB_IN[1]), .cable2(KB_IN[0]), .keyIn(key), .valid(RESULT));
    
    //always @(RESULT) begin
    //    KEY_STATUS = RESULT;
    //end
    //--------------------------------------------------------------------
 
endmodule