 
    ;*******************************************************************************
;
;   Filename:	    Etch_a_sketch -> Principal.asm
;   Date:		    8/10/2020
;   File Version:	    v.1
;   Author:		    Noel Prado
;   Company:	    UVG
;   Description:	    Proyecto 2 etch a sketch
;
;*******************************************************************************  

    #include "p16f887.inc"

; CONFIG1
; __config 0xE0D5
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    GPR_VAR	    UDATA
DEL	    RES 1
NIBBLE_H	    RES 1
NIBBLE_L	    RES 1
BANDERAS    RES 1
STATUS_TEMP RES 1
 W_TEMP	    RES 1
NIBBLE_L2   RES 1
NIBBLE_H2   RES 1
 NIBBLE_L3   RES 1
NIBBLE_H3   RES 1
VAR_GENERAL1	RES 1
VAR_GENERAL2	RES 1
VAR_GENERAL3	RES 1
CANAL		RES 1
X_CEN		RES 1
X_DEC		RES 1
X_UNI		RES 1
Y_CEN		RES 1
Y_DEC		RES 1
Y_UNI		RES 1
CONTADOR	RES 1
		
		
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
       
ISR_VECT    CODE 0X0004
    
PUSH:
    MOVWF	    W_TEMP
    SWAPF	   STATUS, W
    MOVWF	   STATUS_TEMP 

ISR:
    BCF	PIR1, ADIF
    BTFSC   CANAL, 0
    GOTO	 CAMBIO_CANAL
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    MOVWF VAR_GENERAL1
    BANKSEL ADCON0
    MOVLW    B'01000101'    ;SE PONE CANAL 1
    MOVWF   ADCON0
    GOTO POP
    
CAMBIO_CANAL:
    ;SI YA CAMBIO EL CANAL EJECUTA ESTO
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    MOVWF VAR_GENERAL2
    BANKSEL ADCON0
    MOVLW    B'01000001'    ;SE PONE CANAL 0
    MOVWF   ADCON0

    
POP:
    INCF    CONTADOR
    MOVLW B'11111111'
    XORWF  CANAL, F	;CADA VEZ QUE SE ENTRA A LA INTERRUPCION SE CAMBIA EL CANAL
    SWAPF	    STATUS_TEMP, W
    MOVWF	    STATUS
    SWAPF	    W_TEMP, F
    SWAPF	    W_TEMP, W
    BSF	    INTCON, GIE
  
    RETFIE

 TABLE
    ANDWF   B'00001111'; LIMITANDO DE 0 A F
    ADDWF   PCL, F
    ;	  PBAFGECD
    RETLW   B'01110111'	;0
    RETLW   B'01000010'	;1
    RETLW   B'01101101'	;2
    RETLW   B'01101011'	;3
    RETLW   B'01011010'	;4
    RETLW   B'00111011'	;5
    RETLW   B'00111111'	;6
    RETLW   B'01100010'	;7
    RETLW   B'01111111'	;8
    RETLW   B'01111011'	;9
    RETLW   B'01111110'	;A
    RETLW   B'00011111'	;B
    RETLW   B'00110101'	;C
    RETLW   B'01001111'	;D
    RETLW   B'00111101'	;E
    RETLW   B'00111100'	;F
    RETURN

MAIN_PROG CODE                      ; let linker place main program
 
START
 
    CALL	CONFIG_IO   
    CALL	CONFIG_INTERRUPT
 
LOOP:
    CLRF    X_CEN
    CLRF    X_DEC
    CLRF    X_UNI
    CLRF    Y_CEN
    CLRF    Y_DEC
    CLRF    Y_UNI
        
    CALL    DELAY
    LECTURA:
    BTFSS   ADCON0, GO
    BSF	ADCON0,GO		;INICIAR LA CONVERSION
    
    MOVLW .2
    SUBWF   CONTADOR, W
    BTFSS   STATUS, Z
    GOTO    LECTURA
    
    CLRF    CONTADOR
    
    
   ;antes de mandar el código hay que hacer la conversión
XCENTENAS:
    MOVLW   .100
    SUBWF   VAR_GENERAL1, W
    BTFSC    STATUS, C
    MOVWF    VAR_GENERAL1
    BTFSC   STATUS, C
    INCF	X_CEN, F  
    BTFSC	STATUS, C
    GOTO XCENTENAS
   
XDECENAS:
    MOVLW    .10
    SUBWF   VAR_GENERAL1, W
    BTFSC    STATUS, C
    MOVWF    VAR_GENERAL1
    BTFSC   STATUS, C
    INCF	X_DEC, F
    BTFSC	STATUS, C
    GOTO XDECENAS
    
XUNIDADES:
    MOVLW    .1
    SUBWF   VAR_GENERAL1, W
    BTFSC    STATUS, C
    MOVWF    VAR_GENERAL1
    BTFSC   STATUS, C
    INCF	X_UNI, F
    BTFSC	STATUS, C
    GOTO XUNIDADES    

YCENTENAS:
    MOVLW   .100
    SUBWF   VAR_GENERAL2, W
    BTFSC    STATUS, C
    MOVWF    VAR_GENERAL2
    BTFSC   STATUS, C
    INCF	Y_CEN, F  
    BTFSC	STATUS, C
    GOTO YCENTENAS
   
YDECENAS:
    MOVLW    .10
    SUBWF   VAR_GENERAL2, W
    BTFSC    STATUS, C
    MOVWF    VAR_GENERAL2
    BTFSC   STATUS, C
    INCF	Y_DEC, F  
    BTFSC	STATUS, C
    GOTO YDECENAS
    
YUNIDADES:
    MOVLW    .1
    SUBWF   VAR_GENERAL2, W
    BTFSC    STATUS, C
    MOVWF    VAR_GENERAL2
    BTFSC   STATUS, C
    INCF	Y_UNI, F  
    BTFSC	STATUS, C
    GOTO YUNIDADES    
       
  ;despues de hacer la conversion para mandar centenas, decenas y unidades, tengo que sumarles 48 para que correspondan a numeros en ascii
  
    CALL	SEPARAR_NIBBLE
    CALL	DISPLAY
  
  
    MOVLW	.48
    ADDWF	X_CEN, F
    MOVLW	.48
    ADDWF	X_DEC, F
    MOVLW	.48
    ADDWF	X_UNI, F
    MOVLW	.48
    ADDWF	Y_CEN, F
    MOVLW	.48
    ADDWF	Y_DEC, F
    MOVLW	.48
    ADDWF	Y_UNI, F
  
   
    MOVF	    X_CEN, W
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    CALL	DELAY
    
    MOVF	    X_DEC, W
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    CALL	DELAY
    
    MOVF	    X_UNI, W
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    CALL	DELAY
    
    MOVLW   B'00101100'    ;COMA
    MOVWF   TXREG
    BTFSS   PIR1, TXIF
    GOTO $-1
    CALL    DELAY
    CALL    DELAY
    CALL    DELAY
    
    MOVF	    Y_CEN, W
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    CALL	DELAY
        
    MOVF	    Y_DEC, W
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    CALL	DELAY

    MOVF	    Y_UNI, W
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    CALL	DELAY
    
    MOVLW   B'00001010'	;NUEVA LINEA
    MOVWF   TXREG
    BTFSS   PIR1, TXIF
    GOTO $-1
    CALL    DELAY
    
<<<<<<< HEAD
    ;DESPUES DE MANDAR LOS DATOS VOY A REVISAR SI ESTAN ENTRANDO DATOS
=======
>>>>>>> parent of 7dae519... se corrigio lo de velocidades
    
    GOTO LOOP
    GOTO $                          ; loop forever
    
    
        
;***********************************************************SUBRUTINAS* *****************************************************************
     
    
        SEPARAR_NIBBLE
	
    MOVF    X_CEN, W
    MOVWF  NIBBLE_L
    
    MOVF   X_DEC, W
    MOVWF  NIBBLE_H
    
    MOVF    X_UNI, W
    MOVWF  NIBBLE_L2
    
    
    MOVF    Y_CEN, W
    MOVWF  NIBBLE_H2
    
    MOVF    Y_DEC, W
    MOVWF  NIBBLE_L3
    
    MOVF    Y_UNI, W
    MOVWF  NIBBLE_H3
    
    
   
    RETURN
    
    ;SE UTILIZA PARA VER QUE DISPLAY SE PRENDERA, VARIANDO VALOR DE BANDERAS CONTINUAMENTE 
TOGGLE_B0
    INCF   BANDERAS, F
    MOVLW    .6
    SUBWF    BANDERAS, W
    BTFSC    STATUS, Z 
    CLRF	BANDERAS
    RETURN   
    
      DISPLAY	    
    CLRF    PORTB
    MOVLW   .0
    SUBWF   BANDERAS,W
    BTFSC   STATUS, Z
    GOTO    DISPLAY_0
    MOVLW   .1
    SUBWF   BANDERAS, W
    BTFSC   STATUS, Z 
    GOTO DISPLAY_1
    MOVLW   .2
    SUBWF   BANDERAS,W
    BTFSC   STATUS, Z
    GOTO    DISPLAY_2
    MOVLW   .3
    SUBWF   BANDERAS, W
    BTFSC   STATUS, Z 
    GOTO  DISPLAY_3
    MOVLW   .4
    SUBWF   BANDERAS,W
    BTFSC   STATUS, Z
    GOTO    DISPLAY_4
    MOVLW   .5
    SUBWF   BANDERAS, W
    BTFSC   STATUS, Z 
    GOTO  DISPLAY_5
    
DISPLAY_0:
    MOVF  NIBBLE_L, W
    CALL	  TABLE
    MOVWF   PORTD
    BSF	    PORTB, RB0
    GOTO	 FIN_DISPLAY
DISPLAY_1:
    MOVF    NIBBLE_H, W	
    CALL    TABLE
    MOVWF   PORTD
    BSF	    PORTB, RD1
    GOTO	 FIN_DISPLAY
DISPLAY_2:
    MOVF    NIBBLE_L2, W
    CALL	TABLE
    MOVWF   PORTD
    BSF	PORTB, RB2
    GOTO    FIN_DISPLAY  
DISPLAY_3:
    MOVF    NIBBLE_H2, W
    CALL	TABLE
    MOVWF   PORTD
    BSF	PORTB, RB3
    GOTO	 FIN_DISPLAY
DISPLAY_4:
    MOVF    NIBBLE_L3, W
    CALL	TABLE
    MOVWF   PORTD
    BSF	PORTB, RB4
    GOTO    FIN_DISPLAY  
DISPLAY_5:
    MOVF    NIBBLE_H3, W
    CALL	TABLE
    MOVWF   PORTD
    BSF	PORTB, RB5
    GOTO	 FIN_DISPLAY
FIN_DISPLAY:
    CALL    TOGGLE_B0
    RETURN
    
    
    DELAY
    MOVLW   .255
    MOVWF   DEL
    DECFSZ  DEL, F
    GOTO    $-1
    RETURN

    
;***************************************************CONFIGURACIONES *****************************************************************
    CONFIG_IO
  
    BANKSEL	TRISA
    CLRF		TRISB
    CLRF		TRISD
    CLRF		TRISC
    
    BANKSEL	PORTA
    CLRF		PORTA
    CLRF		PORTC
    CLRF		PORTD
    CLRF		PORTB
    CLRF		NIBBLE_H
    CLRF		NIBBLE_L
    
    CLRF		CANAL
    CLRF		VAR_GENERAL1
    CLRF		VAR_GENERAL2
    CLRF		VAR_GENERAL3


    BANKSEL ADCON1
    MOVLW B'00000000' ; JUSTIFICADO A LA IZQUIERDA
    MOVWF ADCON1	   ; VDD COMO REFER ENCIA
    BANKSEL TRISA
    BSF	TRISA, 0
    BSF	TRISA, 1
    BANKSEL ANSEL
    BSF	ANSEL, 0
    BSF	ANSEL, 1
    BANKSEL ADCON0
    MOVLW B'01000001'	;FOSC/8
    MOVWF ADCON0		;AN0, On
    
    BANKSEL TRISA
    MOVLW   .25	;PARA BAUDRATE DE 9615
    MOVWF    SPBRG
    CLRF    SPBRGH  

    BSF	TXSTA, BRGH ; HIGH SPEED DE BAUDIOS
    BCF	TXSTA, SYNC;MODO ASINCRONO
    BSF	TXSTA, TXEN; SE HABILITA LA TRANSMISION
    BCF	TXSTA, TX9 ; SOLO 8 BITS
    BANKSEL BAUDCTL
    BCF	BAUDCTL, BRG16 ;SE USAN 8 BITS
    
    BANKSEL PORTA
    BSF	RCSTA, SPEN ;PARA QUE LA SALIDA SEA EN TX   
    
    RETURN
    
    
     CONFIG_INTERRUPT
    
    BANKSEL	TRISA
    BSF		PIE1, ADIE
    BANKSEL	PORTA
    BSF		INTCON, GIE
    BSF		INTCON, PEIE
    BCF		PIR1, ADIF

    RETURN

    END