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

    //output reg RESET_OUT, 
    //input RESET_IN
	
	
	//DEBUG
	output reg [1:0]Sreg = 0,
	output wire [1:0]KEY_STATUS,
	
	output [1:0] DEBUG_KEY
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
	
	//--------------------------------------------------------------------
	//assign MSG = {SENSOR2_IN, SENSOR1_IN, Sreg==ALARMA, !(Sreg==INACTIVO)};
    //--------------------------------------------------------------------

    // SET DE KEYBOARD - SERIAL OUT
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
	//wire [1:0]KEY_STATUS;
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


    //Variables y parametros
    //reg [1:0]Sreg = 0; // Comienza en modo inactivo
    reg [1:0]Snext;
    parameter [1:0] INACTIVO = 0, ARMADO = 1, ESPERA = 2, ALARMA = 3;
    parameter [1:0] KEY_OK = 0, KEY_ERROR = 2, NO_KEY = 3;

    // Asignacion de estados
    always @ (Sreg, KEY_STATUS, SENSOR1_IN, SENSOR2_IN, TIME_OUT) begin      //IT IS NOT TERMINADO
    case (Sreg)
        INACTIVO: begin
			if (KEY_STATUS == KEY_OK) begin
				Snext <= ARMADO;	
			end
			// KEY_STATUS <= NO_KEY;
		   	end
        
		ARMADO:	begin
            if (KEY_STATUS == KEY_OK)
                Snext <= INACTIVO;
            else if (KEY_STATUS == KEY_ERROR)
                Snext <= ALARMA;
            else if (KEY_STATUS == NO_KEY) begin
                if (SENSOR1_IN)		 	// Ventana
                    Snext <= ALARMA;
                else if (SENSOR2_IN) 	// Puerta
                    Snext <= ESPERA;
            end
			// KEY_STATUS <= NO_KEY;
			end
			
        ESPERA: begin
			if (TIME_OUT) begin
                Snext <= ALARMA;
                TIMER_EN <= 1'b0;
            end				
            else if (KEY_STATUS == KEY_OK) begin
                Snext <= INACTIVO;
                TIMER_EN <= 1'b0;
            end
            else if (KEY_STATUS == KEY_ERROR || KEY_STATUS == NO_KEY) begin
				TIMER_EN <= 1'b1;
			end
			//KEY_STATUS <= NO_KEY;
			end
			
        ALARMA:	begin
            if (KEY_STATUS == KEY_OK)
                Snext <= INACTIVO;
			// KEY_STATUS <= NO_KEY;
			end
                
		default:
			Snext <= INACTIVO;
    endcase

    if (KEY_STATUS == NO_KEY) begin
        KEY_RST = 1'b0;
    end
    else begin
        KEY_RST = 1'b1;
    end
    end
    //--------------------------------------------------------------------


    //Cambiador de Estados para la máquina de ...
    always @(posedge SERCLK_OUT)
	    Sreg <= Snext;
    //--------------------------------------------------------------------

    assign SIREN_OUT = Sreg == ALARMA;  
 
endmodule