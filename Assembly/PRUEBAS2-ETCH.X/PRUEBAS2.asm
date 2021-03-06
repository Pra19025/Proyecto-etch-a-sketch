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
ENTRADA		RES 1
CONTADOR2	RES 1
PIXEL_CEN	RES 1
PIXEL_DEC	RES 1
PIXEL_UNI		RES 1
PXH		RES 1
PXM		RES 1
PXL		RES 1
PYH		RES 1
PYM		RES 1
PYL		RES 1
DATO1		RES 1
DATO2		RES 1
DATO3		RES 1
DATOAUX		RES 1
VARCONTDISP	RES 1
	
		
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
       
ISR_VECT    CODE 0X0004
    BTFSC   INTCON, T0IF
    GOTO    INTERRUPCION_TIMER0
    BTFSC PIR1, RCIF
   GOTO RECEPCION
   BTFSC PIR1, ADIF
   GOTO INT_ADC
   GOTO POP
   
   INTERRUPCION_TIMER0
    INCF	    VARCONTDISP
    MOVF	    VARCONTDISP, W
    SUBLW	     .5
    BTFSS	    STATUS, Z
    GOTO	    POP
    CLRF	    VARCONTDISP
    MOVLW	    .237    ;CON .237 SE TIENE 0.005S, SI SE REPITE 5 VECES SE TIENE 25MS 
    MOVWF	    TMR0
    BCF	    INTCON, T0IF
    CALL	    DISPLAY
   GOTO	POP
   
   RECEPCION:
    BANKSEL PORTA
    MOVFW RCREG
    MOVWF  DATOAUX
    SUBLW .44
    BTFSS STATUS, Z
    GOTO VALORES_Y
    
    CLRF    CONTADOR2
    MOVF DATO1, W
    MOVWF PXH
    MOVF DATO2, W
    MOVWF PXM
    MOVF DATO3, W
    MOVWF PXL
    GOTO POP
    
    
    
    VALORES_Y:
    MOVLW .0
    SUBWF   DATOAUX, W
    BTFSS STATUS, Z
    GOTO GUARDAR
    
    CLRF    CONTADOR2
    MOVF DATO1, W
    MOVWF PYH
    MOVF DATO2, W
    MOVWF PYM
    MOVF DATO3, W
    MOVWF PYL
    GOTO POP
    

    GUARDAR:
    MOVFW    CONTADOR2
    ADDWF PCL, F
    GOTO    UNO
    GOTO    DOS
    GOTO    TRES
    CLRF    CONTADOR2
    
    UNO:
    MOVLW .48
    SUBWF   DATOAUX
    MOVWF DATO1
    INCF    CONTADOR2
    GOTO POP
    
    DOS:
    MOVLW .48
    SUBWF   DATOAUX
    MOVWF DATO2
    INCF    CONTADOR2
    GOTO POP
    
    TRES:
    MOVLW .48
    SUBWF   DATOAUX
    MOVWF DATO3
    INCF    CONTADOR2
    GOTO POP
    
    INT_ADC:
    BCF	PIR1, ADIF
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    
    BTFSC   ADCON0, 2
    GOTO	 CAMBIO_CANAL
    MOVWF VAR_GENERAL1
    BANKSEL ADCON0
    ;MOVLW    B'01000101'    ;SE PONE CANAL 1
    BSF   ADCON0, 2
    GOTO REINICIOADC
    
CAMBIO_CANAL:
    ;SI YA CAMBIO EL CANAL EJECUTA ESTO
    MOVWF VAR_GENERAL2
    BANKSEL ADCON0
    BCF   ADCON0, 2
    
    REINICIOADC:
    NOP
    NOP
    NOP
    NOP
    NOP
    BANKSEL ADCON0
    BTFSS   ADCON0, GO
    BSF ADCON0, GO
    
    
POP:
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
    CALL	CONFIG_TMR0
 
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
    INCF	CONTADOR
    MOVLW .2
    SUBWF   CONTADOR
    BTFSS   STATUS, Z 
    GOTO    LECTURA
    
    CLRF    CONTADOR
    
   ;antes de mandar el c�digo hay que hacer la conversi�n
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
     ;CALL	DISPLAY
  
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
    
    
    
    
    
    GOTO LOOP
    GOTO $                          ; loop forever
    
    
        
;***********************************************************SUBRUTINAS* *****************************************************************
     
    
        SEPARAR_NIBBLE
	
    MOVF    PXH, W
    MOVWF  NIBBLE_L
    
    MOVF    PXM, W
    MOVWF  NIBBLE_H
    
    MOVF    PXL, W
    MOVWF  NIBBLE_L2
    
    
    MOVF    PYH, W
    MOVWF  NIBBLE_H2
    
    MOVF    PYM, W
    MOVWF  NIBBLE_L3
    
    MOVF    PYL, W
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
    MOVLW		B'11111111'
    MOVWF		TRISC
    
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
    CLRF		PXH
    CLRF		PXM
    CLRF		PXL
    CLRF		PYH
    CLRF		PYM
    CLRF		PYL


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
    BSF	RCSTA, CREN;PARA QUE LA ENTRADA SEA EN RX
    RETURN
    
    CONFIG_TMR0
    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS;	RELOJ INTERNO
    BCF	    OPTION_REG, PSA;	PRESCALER A TMR0
    BSF	    OPTION_REG, PS2;	SE PONE 111 PARA PRESCALER DE 256
    BSF	    OPTION_REG, PS1
    BSF	    OPTION_REG, PS0
    BANKSEL PORTA
    MOVLW   .237
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    RETURN
    
     CONFIG_INTERRUPT
    
    BANKSEL	TRISA
    BSF		PIE1, ADIE
    BSF		PIE1, RCIE
    BANKSEL	PORTA
    BSF		INTCON, GIE
    BSF		INTCON, PEIE
    BCF		PIR1, ADIF

    RETURN

    END