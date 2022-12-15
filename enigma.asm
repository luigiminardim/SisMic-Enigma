;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------


RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;----------------------------------------------------------------------------
; Main loop here
;----------------------------------------------------------------------------

PREPARE:
	mov		#ALL_RT,R10						; ALL_RT = {null, RT1, RT2, RT3, RT4, RT5}
	mov		#RT1,2(R10)
	mov		#RT2,4(R10)
	mov		#RT3,6(R10)
	mov		#RT4,8(R10)
	mov		#RT5,10(R10)

	mov		#ALL_RF,R10						; ALL_RF = {null, RF1, RF2, RF3}
	mov		#RF1,2(R10)
	mov		#RF2,4(R10)
	mov		#RF3,6(R10)

	mov		#IRTS,R10
	mov		#IRT1,0(R10)
	mov		#IRT2,2(R10)
	mov		#IRT3,4(R10)

	call	#DESAFIO
	mov		#CHAVE,R5
	mov		#MSG_DECIFR_DESAFIO,R6
	bis.b	#BIT0,&P1DIR					; P1.out = 1
	bis.b	#BIT0,&P1OUT

 	jmp 	$
 	NOP

VISTO1:
	mov		#MSG_CLARA,R5					; enigma(MSG_CLARA, MSG_CIFR)
 	mov		#MSG_CIFR,R6
	call 	#ENIGMA

	mov		#MSG_CIFR,R5					; enigma(MSG_CIRF, MSG_DECIRF)
  	mov		#MSG_DECIFR,R6
	call 	#ENIGMA

	bis.b	#BIT0,&P1DIR					; P1.out = 1
	bis.b	#BIT0,&P1OUT

 	jmp 	$
 	NOP

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; Coloque aqui sua sub-rotina ENIGMA %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DECODE_CHAVE:
	push	R10;
	push	R11;

	mov		#0,R10							; RTS[0] = ALL_RT[CHAVE[0]]
	add		R10,R10
	mov		CHAVE(R10),R10
	add		R10,R10
	mov		ALL_RT(R10),R10
	mov		#0,R11
	add		R11,R11
	mov		R10,RTS(R11)

	mov		#2,R10							; RTS[1] = ALL_RT[CHAVE[2]]
	add		R10,R10
	mov		CHAVE(R10),R10
	add		R10,R10
	mov		ALL_RT(R10),R10
	mov		#1,R11
	add		R11,R11
	mov		R10,RTS(R11)

	mov		#4,R10							; RTS[2] = ALL_RT[CHAVE[4]]
	add		R10,R10
	mov		CHAVE(R10),R10
	add		R10,R10
	mov		ALL_RT(R10),R10
	mov		#2,R11
	add		R11,R11
	mov		R10,RTS(R11)

	mov		#1,R10							; CONFIGS[0] = CHAVE[1]
	add		R10,R10
	mov		CHAVE(R10),R10
	mov		#0,R11
	mov.b	R10,CONFIGS(R11)

	mov		#3,R10							; CONFIGS[1] = CHAVE[3]
	add		R10,R10
	mov		CHAVE(R10), R10
	mov		#1,R11
	mov.b	R10,CONFIGS(R11)

	mov		#5,R10							; CONFIGS[2] = CHAVE[5]
	add		R10,R10
	mov		CHAVE(R10), R10
	mov		#2,R11
	mov.b	R10,CONFIGS(R11)

	mov		#6,R10							; reflector = ALL_RF[CHAVE[6]]
	add		R10,R10
	mov		CHAVE(R10),R10
	add		R10,R10
	mov		ALL_RF(R10),&REFLECTOR

	pop		R11
	pop 	R10
	ret



FILL_IRT:	; fillIrt()
	push	R10
	push	R11
	push	R12
	push 	R13

	mov		#0,R10							; for(rotorIndex = 0; rotorIndex < 3; rotorIndex++)
FILL_IRT_FOR_ROTOR:
	cmp		#6,R10
	jeq		FILL_IRT_FOR_ROTOR_END

	mov		#0,R11							; for(msgChar = 0; msgChar < RT_TAM; msgChar++)
FILL_IRT_FOR_CHAR:
	cmp		&RT_TAM,R11
	jeq		FILL_IRT_FOR_CHAR_END

	mov		RTS(R10),R12					; gsmChar = RTS[rotorIndex][msgChar]
	add		R11,R12
	mov.b	0(R12),R12

	mov		IRTS(R10),R13					; IRTS[rotorIndex][gsmChar] = msgChar
	add		R12,R13
	mov.b	R11,0(R13)

	inc		R11
	jmp		FILL_IRT_FOR_CHAR
FILL_IRT_FOR_CHAR_END:

	incd	R10
	jmp		FILL_IRT_FOR_ROTOR
FILL_IRT_FOR_ROTOR_END:

	pop		R13
	pop		R12
	pop		R11
	pop		R10
	ret



MOD_RT_TAM: ; modRtTam(byte index = R5) -> R5: byte
	cmp		#0,R5
	jn		MOD_RT_TAM_ADD
	cmp		&RT_TAM,R5
	jhs		MOD_RT_TAM_SUB
	ret
MOD_RT_TAM_ADD:
	add		&RT_TAM,R5
	jmp		MOD_RT_TAM
MOD_RT_TAM_SUB:
	sub		&RT_TAM,R5
	jmp		MOD_RT_TAM



APPLY_ROTOR: ; applyRotor(byte *rotor = R5, byte config = R6, byte rotation = R7, byte msgChar = R8) -> R5: byte
	push	R10

	mov		R5,R10							; byte *rotor = R5

	mov		R6,R5							; return rotor[modRtTam(config - rotation + msgChar)])
	sub		R7,R5
	add		R8,R5
	call	#MOD_RT_TAM
	add		R10,R5
	mov.b	0(R5),R5

	pop		R10
	ret



APPLY_REFLECTOR: ; applyReflector(byte msgChar) -> R5: byte
	add		&REFLECTOR,R5
	mov.b	0(R5),R5
	ret



APPLY_IROTOR: ; inverseApplyRotor(byte *iRotor = R5, byte config = R6, byte rotation = R7, byte gsmChar = R8) -> R5: byte
	add		R8,R5							; return getRotorIndex(iRotor[gsmChar] - config + rotation)
	mov.b	0(R5),R5
	sub		R6,R5
	add		R7,R5
	call	#MOD_RT_TAM

	ret



ENCODE_MSG: ; encode(byte* msg = R5, byte* gsm = R6)
	push	R5
	push	R10
	push	R11
	push	R12

	mov		#ROTATIONS,R10
	mov.b	#0,0(R10)						; rotations = {0, 0, 0}
	mov.b	#0,1(R10)
	mov.b	#0,2(R10)

	mov		R5,R10							; byte *msgIt = msg;

	mov		R6,R11							; byte *gsmIt = gsm;

ENCODE_MSG_WHILE_MSGIT:						; while(*msgIt !== '\0')
	cmp.b	#0,0(R10)
	jeq 	ENCODE_MSG_WHILE_MSGIT_END

	cmp.b	#'A',0(R10)						; if (*msgIt < 'A' || *msgIt > 'Z')
	jlo		ENCODE_MSG_IF_NOTCHAR
	cmp.b	#'Z',0(R10)
	jlo		ENCODE_MSG_IF_NOTCHAR_END
	jeq		ENCODE_MSG_IF_NOTCHAR_END
ENCODE_MSG_IF_NOTCHAR:

	mov.b	0(R10),0(R11)					; *gsmIt = *msgIt

	inc		R10								; msgIt++

	inc		R11								; gsmIt++

	jmp		ENCODE_MSG_WHILE_MSGIT			; continue

ENCODE_MSG_IF_NOTCHAR_END:

	mov.b	0(R10),0(R11)					; *gsmIt = *msgIt - 'A'
	sub.b	#'A',0(R11)

	mov		#0,R12							; for (int i = 0; i < 3; i++)
ENCODE_MSG_FOR_RT:
	cmp		#3,R12
	jhs		ENCODE_MSG_FOR_RT_END

	mov		#RTS,R5						; *gsmIt = applyRotor(rotors[i], configs[i], rotations[i], *gsmIt)
	add		R12,R5
	add		R12,R5
	mov		0(R5),R5
	mov		#CONFIGS,R6
	add		R12,R6
	mov.b	0(R6),R6
	mov		#ROTATIONS,R7
	add		R12,R7
	mov.b	0(R7),R7
	mov.b	0(R11),R8
	call	#APPLY_ROTOR
	mov.b		R5,0(R11)

	inc		R12
	jmp		ENCODE_MSG_FOR_RT
ENCODE_MSG_FOR_RT_END:

	mov.b	0(R11),R5						; *gsmIt = applyReflector(*gsmIt);
	call	#APPLY_REFLECTOR
	mov.b	R5,0(R11)

	mov		#2,R12
ENCODE_MSG_FOR_IRT:
	tst		R12
	jn		ENCODE_MSG_FOR_IRT_END

	mov		#IRTS,R5						; *gsmIt = inverseApplyRotor(inverseRotors[i], configs[i], rotations[i], *gsmIt);
	add		R12,R5
	add		R12,R5
	mov		0(R5),R5
	mov		#CONFIGS,R6
	add		R12,R6
	mov.b	0(R6),R6
	mov		#ROTATIONS,R7
	add		R12,R7
	mov.b	0(R7),R7
	mov.b	0(R11),R8
	call	#APPLY_IROTOR
	mov.b		R5,0(R11)

	dec		R12
	jmp		ENCODE_MSG_FOR_IRT
ENCODE_MSG_FOR_IRT_END:

	add.b	#'A',0(R11)						; *gsmIt = *gsmIt + 'A'

	mov		#ROTATIONS,R12					; rotations[0]++
	inc.b	0(R12)

	cmp.b	&RT_TAM,0(R12)					; if (rotations[0] >= RT_TAM) { rotations[1]++; rotations[0] = 0 }
	jlo		ROTATION0_END
	inc.b	1(R12)
	mov.b	#0,0(R12)
ROTATION0_END:

	cmp.b	&RT_TAM,1(R12)					; if (rotations[1] >= RT_TAM) { rotations[2]++; rotations[1] = 0 }
	jlo		ROTATION1_END
	inc.b	2(R12)
	mov.b	#0,1(R12)
ROTATION1_END:

	cmp.b	&RT_TAM,2(R12)					; if (rotations[2] >= RT_TAM) { rotations[2] = 0 }
	jlo		ROTATION2_END
	mov.b 	#0,2(R12)
ROTATION2_END:

    inc		R10								; msgIt++;

    inc		R11								; gsmIt++;

	jmp		ENCODE_MSG_WHILE_MSGIT
ENCODE_MSG_WHILE_MSGIT_END:

	mov.b	#0,0(R11)							; *gsmIt = '\0'

	pop	R12
	pop R11
	pop R10
	pop R5
	ret



ENIGMA: ; enigma(byte* msg = R5, byte* gsm = R6)
	call 	#DECODE_CHAVE
	call	#FILL_IRT

	mov		R5,R5
	mov		R6,R6
	call	#ENCODE_MSG
	ret


HAS_SIGNATURE: ; hasSignature(byte* msg = R5)
HAS_SIGNATURE_WHILE_NOTEND:
	cmp.b	#0,0(R5)
	jeq		HAS_SIGNATURE_WHILE_NOTEND_END

	inc		R5
	jmp 	HAS_SIGNATURE_WHILE_NOTEND
HAS_SIGNATURE_WHILE_NOTEND_END:
	sub			#14,R5
	cmp.b		#'@',0(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'M',1(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'A',2(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'C',3(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'H',4(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'A',5(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'D',6(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'O',7(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'\',8(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'A',9(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'S',10(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'S',11(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'I',12(R5)
	jnz		HAS_SIGNATURE_FALSE
	cmp.b		#'S',13(R5)
	jnz		HAS_SIGNATURE_FALSE

	mov		#1,R5
	ret

HAS_SIGNATURE_FALSE:
	mov		#0,R5
	ret



DESAFIO:
	push	R10
	mov		#CHAVE,R10

	mov		#1,0(R10)
DESAFIO_FOR_ROT1:
	cmp		#6,0(R10)
	jhs		DESAFIO_FOR_ROT1_END

	mov		#0,2(R10)
DESAFIO_FOR_CONFIG1:
	cmp		2(R10),&RT_TAM
	jeq		DESAFIO_FOR_CONFIG1_END

	mov		#1,4(R10)
DESAFIO_FOR_ROT2:
	cmp		#6,4(R10)
	jhs		DESAFIO_FOR_ROT2_END

	mov		#0,6(R10)
DESAFIO_FOR_CONFIG2:
	cmp		6(R10),&RT_TAM
	jeq		DESAFIO_FOR_CONFIG2_END

	mov		#1,8(R10)
DESAFIO_FOR_ROT3:
	cmp		#6,8(R10)
	jhs		DESAFIO_FOR_ROT3_END

	mov		#0,10(R10)
DESAFIO_FOR_CONFIG3:
	cmp		10(R10),&RT_TAM
	jeq		DESAFIO_FOR_CONFIG3_END

	mov		#1,12(R10)
DESAFIO_FOR_REF:
	cmp		#4,12(R10)
	jhs		DESAFIO_FOR_REF_END

	mov		#MSG_CIFR_DESAFIO_TESTE,R5
	mov		#MSG_DECIFR_DESAFIO,R6
	call	#ENIGMA

	mov		#MSG_DECIFR_DESAFIO,R5
	call 	#HAS_SIGNATURE

	cmp		#0,R5
	jeq		DESAFIO_ELSE
	jmp		DESAFIO_RETURN
DESAFIO_ELSE:

	inc		12(R10)
	jmp		DESAFIO_FOR_REF
DESAFIO_FOR_REF_END:

	inc		10(R10)
	jmp		DESAFIO_FOR_CONFIG3
DESAFIO_FOR_CONFIG3_END:

	inc		8(R10)
	jmp		DESAFIO_FOR_ROT3
DESAFIO_FOR_ROT3_END:

	inc		6(R10)
	jmp		DESAFIO_FOR_CONFIG2
DESAFIO_FOR_CONFIG2_END:

	inc		4(R10)
	jmp		DESAFIO_FOR_ROT2
DESAFIO_FOR_ROT2_END:

	inc		2(R10)
	jmp		DESAFIO_FOR_CONFIG1
DESAFIO_FOR_CONFIG1_END:

	inc		0(R10)
	jmp		DESAFIO_FOR_ROT1
DESAFIO_FOR_ROT1_END:

DESAFIO_RETURN:
	pop 	R10
	ret



***********************************************
*** Área dos dados do Enigma. Não os altere ***
***********************************************

RT_TAM: .word 26 ;Tamanho
RT_QTD: .word 05 ;Quantidade de Rotores
RF_QTD: .word 03 ;Quantidade de Refletores
VAZIO: .space 12 ;Para facilitar endereço do rotor 1

;Rotores com 26 posições
ROTORES:
RT1:	.byte 20, 6, 21, 25, 11, 15, 16, 18, 0, 7, 1, 22, 9
		.byte 17, 24, 5, 8, 23, 19, 13, 12, 14, 3, 2, 10, 4
RT2:	.byte 12, 18, 25, 22, 2, 23, 9, 5, 3, 6, 15, 14, 24
 		.byte 11, 19, 4, 8, 21, 17, 7, 16, 1, 0, 10, 13, 20
RT3:	.byte 23, 21, 18, 2, 15, 14, 0, 25, 3, 8, 4, 17, 7
		.byte 24, 5, 10, 11, 20, 22, 1, 12, 9, 16, 6, 19, 13
RT4:	.byte 22, 21, 7, 0, 16, 3, 4, 8, 2, 9, 23, 20, 1
		.byte 11, 25, 5, 24, 14, 12, 6, 18, 13, 10, 19, 17, 15
RT5:	.byte 20, 17, 13, 11, 25, 16, 23, 3, 19, 4, 24, 5, 1
		.byte 12, 8, 9, 15, 22, 6, 0, 21, 7, 14, 18, 2, 10

;Refletores com 26 posições
REFLETORES:
RF1:	.byte 14, 11, 25, 4, 3, 22, 20, 18, 15, 13, 12, 1, 10
		.byte 9, 0, 8, 24, 23, 7, 21, 6, 19, 5, 17, 16, 2
RF2:	.byte 1, 0, 16, 25, 6, 24, 4, 23, 14, 13, 17, 18, 19
		.byte 9, 8, 22, 2, 10, 11, 12, 21, 20, 15, 7, 5, 3
RF3:	.byte 21, 7, 5, 19, 18, 2, 16, 1, 14, 22, 24, 17, 20
		.byte 25, 8, 23, 6, 11, 4, 3, 12, 0, 9, 15, 10, 13

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Área da mesagem em claro, cifrada e decifrada ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.data

MSG_CLARA:
 .byte "UMA NOITE DESTAS, VINDO DA CIDADE PARA O ENGENHO NOVO,"
 .byte " ENCONTREI NO TREM DA CENTRAL UM RAPAZ AQUI DO BAIRRO,"
 .byte " QUE EU CONHECO DE VISTA E DE CHAPEU.@MACHADO\ASSIS",0
MSG_CIFR:
 .byte "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 .byte "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
 .byte "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0
MSG_DECIFR:
 .byte "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
 .byte "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
 .byte "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",0

MSG_CIFR_DESAFIO_TESTE:
	.byte "TFY QRRQI ABTUSM, OJRUQ GI VZLNKZ NKPN B OWQCXUE STEY, ULPLXDONV BC LWPN SV XOISHOA KI CZLWF GLQQ VM CXMUTQ, MWH MQ ZNLSCKW BC WKVWX N AB FUQMBX.@ZNEXRAR\MPXFV",0

MSG_CIFR_DESAFIO:
	.byte "CBI MNEXL NOLMBI, GBUKI CS NPVSWR WUYM H YXAXETV MNFI,"
	.byte " BGVXTIAOB OP YQTR QC JCCKVBY YH GRKFT USPE CI MEZDYU,"
	.byte " YBQ LC WHBVYRX JK GPEFC O AB FFVAUE.@KFVCKOR\HUHTM",0

MSG_DECIFR_DESAFIO:
	.byte "00000000000000000000000000000000000000000000000000000,"
	.byte "000000000000000000000000000000000000000000000000000000"
	.byte "000000000000000000000000000000000000000000000000000000",0

; Chave = A, B, C, D, E, F, G
;A = número do rotor à esquerda e B = sua configuração;
;C = número do rotor central e D = sua configuração;
;E = número do rotor à direita e F = sua configuração;
;G = número do refletor.
; A B C D E F G
CHAVE: .word 2,4, 5,8, 3,3, 2 ;<<<===========

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Coloque aqui suas Variáveis ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ALL_RT:		.word 0,0,0,0,0,0
ALL_RF: 	.word 0,0,0,0

RTS:		.word 0,0,0
CONFIGS:	.byte 0,0,0
REFLECTOR: 	.word 0

IRT1:		.byte -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
IRT2:		.byte -2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2
IRT3:		.byte -3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3
IRTS:		.word 0,0,0

ROTATIONS:	.byte -1,-1,-1

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
