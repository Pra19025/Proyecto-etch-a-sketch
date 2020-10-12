 
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
    ;probando git
    ;probando git por segunda vez
    #include "p16f887.inc"

; CONFIG1
; __config 0xE0D5
    __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
    
    GPR_VAR	    UDATA
RESULTHI	    RES 1
RESULTLO    RES 1
DEL	    RES 1
NIBBLE_H	    RES 1
NIBBLE_L	    RES 1
BANDERAS    RES 1
STATUS_TEMP RES 1
 W_TEMP	    RES 1

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
    MOVWF RESULTHI
    
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
 
; CALL	CONFIG_IO   
 ;CALL	CONFIG_INTERRUPT
 
LOOP:


    GOTO $                          ; loop forever

    END