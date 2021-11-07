module MainModule (
    // I/O PINS
    output reg SIREN_OUT = 0,   //Salida de sirena
    input SENSOR1_IN, SENSOR2_IN,  //Sensores

    output reg STATUS_OUT, 	//Datos
    output reg STATUS_SEND, //Habilitador
    input KB_IN,   		//Datos
    input KB_RECV,   	//Habilitador 

    output reg SERCLK_OUT=0,

    input CTRL_IN, CTRL_RECV, CTRL_CLK,

    output reg RESET_OUT 
    //input RESET_IN
);

// Clock interno del módulo principal
always #10ns SERCLK_OUT = ~SERCLK_OUT;
//--------------------------------------------------------------------	

// SET DE TIMER
reg TIME_OUT;
reg TIMER_EN;
reg [17:0] TIMER_COUNTER = 5; // 15 Segundos = 150000
timer mainTimer (		 // CLK con tiempo customizable
    .clkSignal(SERCLK_OUT),		        // Señal del CLK a utilizar
    .maxCount(TIMER_COUNTER),           // Cantidad de pulsos a contar. Max: 262.143e3
    .EN(TIMER_EN),                      // Señal de ENABLE
    .RST(0),                            // Señal de RESET
    .clkFinish(TIME_OUT) 		        // Cuando se llega a 0, emite señal de FINISH (Activo alto)
);
//--------------------------------------------------------------------

// SET DE KEYBOARD
reg [3:0]MSG = {SENSOR1_IN, SENSOR2_IN, 1'b0, 1'b1};
reg INIT = 1;
serialOut STATE_OUT(
    .init(INIT),        // Recibo de aviso de transmisión
    .clk(SERCLK_OUT),         // señal de clock
    .state(MSG),        // Estado a transmitir
    .status_send(STATUS_SEND),// Envio de aviso de transmisión
    .status_out(STATUS_OUT) // Canal de transmisión
);
//--------------------------------------------------------------------



    //Variables y parametros
    reg [1:0]state = 0; // Comienza en modo inactivo
    parameter INACTIVO = 0, ARMADO = 1, ESPERA = 2, ALARMA = 3;
    reg [1:0]KEY_STATUS;
    parameter KEY_OK = 0, KEY_OKNEG = 1, KEY_ERROR = 2, NO_KEY = 3;
    //--------------------------------------------------------------------
	
	
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
                if (SENSOR1_IN)		 	//Puerta
                    state <= ESPERA;
                else if (SENSOR2_IN) 	//Ventana
                    state <= ALARMA;
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
	
	
    always @(KB_IN, KB_RECV) begin
        if (KB_RECV == 1)
			KEY_STATUS <= NO_KEY;
        else
        	KEY_STATUS <= KEY_OK;
    end
    //--------------------------------------------------------------------
 

endmodule