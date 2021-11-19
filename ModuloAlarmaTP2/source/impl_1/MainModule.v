module MainModule (
    // I/O PINS
    output wire SIREN_OUT,   		//Salida de sirena
    input SENSOR1_IN, SENSOR2_IN,  //Sensores

    output wire STATUS_OUT, 	//Datos
    output wire STATUS_SEND, 	//Habilitador
    input wire [1:0] KB_IN,   	//Datos
    input wire KB_RECV,   		//Habilitador 

    output wire SERCLK_OUT,		//Salida de Clock

    input RESET_IN				//Reset (just in case)
);

    // Clock interno del modulo principal --------------------------------
    LSOSC OSCInst1 (.CLKLFEN(1'b1), .CLKLFPU(1'b1), .CLKLF(SERCLK_OUT));
    //--------------------------------------------------------------------	


    //Variables y parametros ---------------------------------------------
    parameter [1:0] INACTIVO = 2'd0, ARMADO = 2'd1, ESPERA = 2'd2, ALARMA = 2'd3;
    parameter [1:0] KEY_OK = 2'd0, KEY_ERROR = 2'd2, NO_KEY = 2'd3;
	reg [1:0]Sreg = INACTIVO; // Comienza en modo inactivo
    reg [1:0]Snext;
	wire [1:0]KEY_STATUS;
	//--------------------------------------------------------------------


    // SET DE TIMER ------------------------------------------------------
    wire TIME_OUT;
    reg TIMER_EN;
    wire [17:0] TIMER_COUNTER = 18'd150000; 	// 1 Segundo = 10000
    timer mainTimer (		 					// CLK con tiempo customizable
        .clkSignal(SERCLK_OUT),		    		// Se?al del CLK a utilizar
        .maxCount(TIMER_COUNTER),       		// Cantidad de pulsos a contar. Max: 262.143e3
        .EN(TIMER_EN),                  		// Se?al de ENABLE
        .RST(1'b0),                     		// Se?al de RESET
        .clkFinish(TIME_OUT) 		    		// Cuando se llega a 0, emite se?al de FINISH (Activo alto)
    );
    //--------------------------------------------------------------------
	

    // SET DE KEYBOARD - SERIAL OUT --------------------------------------
    wire [3:0] MSG = {!(Sreg==INACTIVO), Sreg==ALARMA, SENSOR1_IN, SENSOR2_IN};
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


	// Verificador de mensaje recibido
	codeCkeck keyboard(
        .KB_RECV(KB_RECV),
        .KB_IN(KB_IN),
        .validKey({2'd1, 2'd1, 2'd1, 2'd1}), //Password
        .CLK(SERCLK_OUT),
        .KEY_STATUS(KEY_STATUS)
    );
    //--------------------------------------------------------------------
	reg [1:0]PREV_KEY = NO_KEY;

    // Máquina de estados ------------------------------------------------
    always @ (Sreg, KEY_STATUS, SENSOR1_IN, SENSOR2_IN, TIME_OUT) begin    
		case (Sreg)
			INACTIVO: begin
				if (KEY_STATUS == KEY_OK) begin
					PREV_KEY <= KEY_OK;
					Snext <= ARMADO;
				end
				else Snext <= INACTIVO;
			end
			
			ARMADO:	begin
				if (KEY_STATUS == KEY_OK) begin
					if(PREV_KEY == KEY_OK) Snext <= ARMADO;
					else Snext <= INACTIVO;
				end
				else if (KEY_STATUS == KEY_ERROR) Snext <= ALARMA;
				else if (KEY_STATUS == NO_KEY) begin
					if (SENSOR1_IN) Snext <= ALARMA; // Ventana
					else if (SENSOR2_IN) begin
						TIMER_EN <= 1'b0;
						Snext <= ESPERA; // Puerta
					end
					else begin 
						PREV_KEY <= NO_KEY;
						TIMER_EN <= 1'b0;
						Snext <= ARMADO;
					end
				end
				else Snext <= ARMADO;
			end
				
			ESPERA: begin
				if (TIME_OUT) Snext <= ALARMA;				
				else if (KEY_STATUS == NO_KEY) TIMER_EN <= 1'b1;
				else if (KEY_STATUS == KEY_OK) begin
					PREV_KEY <= KEY_OK;
					TIMER_EN <= 1'b0;
					Snext <= INACTIVO;
				end
				else Snext <= ESPERA;
			end
				
			ALARMA:	begin
				TIMER_EN <= 1'b0;
				if (KEY_STATUS == KEY_OK) Snext <= INACTIVO;
				else Snext <= ALARMA;
			end
					
			default:
				Snext <= INACTIVO;
		endcase
    end
    //--------------------------------------------------------------------


    //Cambiador de estados para la maquina de estados --------------------
	always @(posedge SERCLK_OUT or posedge RESET_IN) begin
        if (RESET_IN == 1) Sreg <= INACTIVO;
		else Sreg <= Snext;
	end
    //--------------------------------------------------------------------


    assign SIREN_OUT = Sreg == ALARMA;  
 
endmodule