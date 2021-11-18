module MainModule (
    // I/O PINS
    output wire SIREN_OUT,   	//Salida de sirena
    input  SENSOR1_IN, 	//Sensores
	input  SENSOR2_IN,  //Sensores

    //output wire STATUS_OUT, 	//Datos
    //output wire STATUS_SEND, 	//Habilitador
    //input wire [1:0] KB_IN,   	//Datos
    //input wire KB_RECV,   			//Habilitador 

    output reg SERCLK_OUT,

    //input CTRL_IN, CTRL_RECV, CTRL_CLK,

    //output reg RESET_OUT, 
    input RESET_IN,
	
	//DEBUG
	output reg [1:0]Sreg,
	output wire [1:0]KEY_STATUS,
	input wire TIME_OUT
);

    // Clock interno del módulo principal
    always #10ns SERCLK_OUT = ~SERCLK_OUT;
    
		
    //Variables y parametros
    //reg [1:0]Sreg = 0; // Comienza en modo inactivo
    reg [1:0]Snext;
	
	reg TIMER_EN;
	reg KEY_RST = 1'b0;

    parameter [1:0] INACTIVO = 0, ARMADO = 1, ESPERA = 2, ALARMA = 3;
    parameter [1:0] KEY_OK = 0, KEY_ERROR = 2, NO_KEY = 3;


    //--------------------------------------------------------------------
	//assign MSG = {SENSOR2_IN, SENSOR1_IN, Sreg==ALARMA, !(Sreg==INACTIVO)};
    //--------------------------------------------------------------------


    // Asignacion de estados
    always @ (Sreg, KEY_STATUS, SENSOR1_IN, SENSOR2_IN, TIME_OUT) begin
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
					if (SENSOR1_IN)		 // Ventana
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


    //Cambiador de Estados para la maquina de estados
	   always @(posedge SERCLK_OUT or posedge RESET_IN)
        if (RESET_IN == 1) Sreg <= INACTIVO;
		else Sreg <= Snext;
    //--------------------------------------------------------------------

    assign SIREN_OUT = Sreg == ALARMA;  
 
endmodule