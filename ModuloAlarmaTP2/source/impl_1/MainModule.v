module MainModule (
    // I/O PINS
    output wire SIREN_OUT,   	//Salida de sirena
    input SENSOR1_IN, SENSOR2_IN,  //Sensores

    output wire STATUS_OUT, 	//Datos
    output wire STATUS_SEND, 	//Habilitador
    input wire [1:0] KB_IN,   	//Datos
    input wire KB_RECV,   			//Habilitador 

    output wire SERCLK_OUT,

    //input CTRL_IN, CTRL_RECV, CTRL_CLK,

    input RESET_IN,
		
	//DEBUG	
	output [1:0] DEBUG_KEY
);

    // Clock interno del modulo principal
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
    wire [3:0] MSG = {SENSOR2_IN, SENSOR1_IN, Sreg==ALARMA, !(Sreg==INACTIVO)};
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
	wire [7:0] key = {2'b00,2'b01,2'b10,2'b11};
    reg KEY_RST = 1'b0;
    keyChecker Keyboard(
        .pulsed(KB_RECV), 
        .cable1(KB_IN[1]), 
        .cable2(KB_IN[0]), 
        .keyIn(key),
        .keyStatus(KEY_STATUS),
        //.reset(KEY_RST),
		.salidaActualKey(DEBUG_KEY)
    );
    //--------------------------------------------------------------------


    // Asignacion de estados
    always @ (Sreg, KEY_STATUS, SENSOR1_IN, SENSOR2_IN, TIME_OUT) begin      //IT IS NOT TERMINADO
		case (Sreg)
			INACTIVO: begin
				if (KEY_STATUS == KEY_OK) Snext <= ARMADO;	
				else Snext <= INACTIVO;
			end
			
			ARMADO:	begin
				if (KEY_STATUS == KEY_OK) Snext <= INACTIVO;
				else if (KEY_STATUS == KEY_ERROR) Snext <= ALARMA;
				else if (KEY_STATUS == NO_KEY) begin
					if (SENSOR1_IN) Snext <= ALARMA; // Ventana
					else if (SENSOR2_IN) Snext <= ESPERA; // Puerta
				end
				else Snext <= ARMADO;
			end
				
			ESPERA: begin
				if (KEY_STATUS == KEY_ERROR || KEY_STATUS == NO_KEY) TIMER_EN <= 1'b1;
				else if (TIME_OUT) begin
					TIMER_EN <= 1'b0;
					Snext <= ALARMA;
				end				
				else if (KEY_STATUS == KEY_OK) begin
					TIMER_EN <= 1'b0;
					Snext <= INACTIVO;
				end
				else Snext <= ESPERA;
			end
				
			ALARMA:	begin
				if (KEY_STATUS == KEY_OK) Snext <= INACTIVO;
				else Snext <= ALARMA;
			end
					
			default:
				Snext <= INACTIVO;
		endcase

		if (KEY_STATUS == NO_KEY) KEY_RST = 1'b0;
		else KEY_RST = 1'b1;
    end
    //--------------------------------------------------------------------


    //Cambiador de estados para la maquina de estados
	always @(posedge SERCLK_OUT or posedge RESET_IN) begin
        if (RESET_IN == 1) Sreg <= INACTIVO; 
		else Sreg <= Snext;
	end
    //--------------------------------------------------------------------


    assign SIREN_OUT = Sreg == ALARMA;  
 
endmodule