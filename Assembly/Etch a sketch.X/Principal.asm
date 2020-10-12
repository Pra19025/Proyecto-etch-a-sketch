 
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
VAR_GENERAL1	RES 1
VAR_GENERAL2	RES 1

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
       
ISR_VECT    CODE 0X0004
    
PUSH:
    MOVWF	    W_TEMP
    SWAPF	   STATUS, W
    MOVWF	   STATUS_TEMP 

ISR:
    
    BCF	PIR1, ADIF
    BANKSEL ADRESH	     
    MOVF ADRESH,W		;GUARDAR 8 BITS EN RESULTHI
    MOVWF VAR_GENERAL1
    
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
    RETLW   B'01111010'	;9
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
    
    CALL    DELAY    
    BTFSS   ADCON0, GO
    BSF	ADCON0,GO		;INICIAR LA CONVERSION
    
   MOVF	    VAR_GENERAL1, W
   BTFSC	    PIR1, TXIF
   BANKSEL  PORTA
   MOVWF    TXREG
  
   CALL	SEPARAR_NIBBLE
   CALL	DISPLAY
   

    GOTO $                          ; loop forever
    
    
        
;***********************************************************SUBRUTINAS* *****************************************************************
    
        SEPARAR_NIBBLE
    MOVF    VAR_GENERAL1, W
    ANDLW   B'00001111'
    MOVWF   NIBBLE_L
    SWAPF   VAR_GENERAL1, W
    ANDLW   B'00001111'
    MOVWF   NIBBLE_H

    MOVF    VAR_GENERAL2, W
    ANDLW   B'00001111'
    MOVWF   NIBBLE_L2
    SWAPF   VAR_GENERAL2, W
    ANDLW   B'00001111'
    MOVWF   NIBBLE_H2
   
    RETURN
    
    ;SE UTILIZA PARA VER QUE DISPLAY SE PRENDERA, VARIANDO VALOR DE BANDERAS CONTINUAMENTE 
TOGGLE_B0
    INCF   BANDERAS, F
    MOVLW    .4
    SUBWF    BANDERAS, W
    BTFSC    STATUS, Z 
    CLRF	BANDERAS
    RETURN   
    
      DISPLAY	    
    CLRF    PORTD
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
    
DISPLAY_0:
    MOVF  NIBBLE_L, W
    CALL	  TABLE
    MOVWF   PORTC
    BSF	    PORTD, RD0
    GOTO	 FIN_DISPLAY
DISPLAY_1:
    MOVF    NIBBLE_H, W	
    CALL    TABLE
    MOVWF   PORTC
    BSF	    PORTD, RD1
    GOTO	 FIN_DISPLAY
DISPLAY_2:
    MOVF    NIBBLE_L2, W
    CALL	TABLE
    MOVWF   PORTC
    BSF	PORTD, RD2
    GOTO    FIN_DISPLAY  
DISPLAY_3:
    MOVF    NIBBLE_H2, W
    CALL	TABLE
    MOVWF   PORTC
    BSF	PORTD, RD3
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

    BANKSEL ADCON1
    MOVLW B'00000000' ; JUSTIFICADO A LA IZQUIERDA
    MOVWF ADCON1	   ; VDD COMO REFER ENCIA
    BANKSEL TRISA
    BSF	TRISA, 0
    BANKSEL ANSEL
    BSF	ANSEL, 0
    BANKSEL ADCON0
    MOVLW B'01000001'	;FOSC/8
    MOVWF ADCON0		;AN0, On
    
    BANKSEL TRISA
    MOVLW   .207
    MOVWF    SPBRG
    CLRF    SPBRGH  

    BCF	TXSTA, BRGH ; LOW SPEED DE BAUDIOS
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