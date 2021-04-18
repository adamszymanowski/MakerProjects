; interrupt table
.org 0x0000
rjmp RESET	; main program

.org 0x0003
rjmp TIMER1_COMPA_ISR


; interrupt handling
TIMER1_COMPA_ISR:
	in r15, SREG
	;in r25, PC
	push r16
	;push r17
	;push r18
	;push r19

	; for testing
	sbi PINB, PINB3
	
	cpi r21, 0
	brne SKIP_HALT
	cpi r20, 0
	brne SKIP_HALT
	; clear bit 4		 OCIE1A			Timer/Counter1 Output Compare Match A Interrupt Disable
	ldd r16, Z + TIMSK
	ldi r26, 1 << OCIE1A
	eor r16, r26
	out TIMSK, r16	
	rjmp TIMER1_COMPA_ISR_END

SKIP_HALT:
	cpi r20, 0
	breq DEC_POS1

	dec r20
	rjmp TIMER1_COMPA_ISR_END

DEC_POS1:
	ldi r20, 9
	dec r21

TIMER1_COMPA_ISR_END:
	ldi r16, 0		; force TCNT1 to clear, since CTC1 does not work for some reason
	out TCNT1, r16

	;pop r19
	;pop r18
	;pop r17
	pop r16
	;out PC, r25
	out SREG, r15
	reti

RESET:
	; MICROCONTROLER SETUP BEGIN

	; initialize Stack Pointer
	; This Stack space in the data SRAM must be defined by the program before any subroutine calls are executed or interrupts are enabled
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; set pointer Z for reaching I/O registers 32-64 (sbi, cbi,... can handle only 0-31), or for writing bitfield across entire range
	clr ZH
	ldi ZL, 0x20 ; point ZL to 0x20
	; example: std Z+0x39, r16

	; configure output pins			page 64
	ldi r16, (1 << DDB3 | 1 << DDB2 | 1 << DDB1 | 1 << DDB0)
	out DDRB, r16
	; TODO: configure input pins

	; configure TIMER 1
	; in TCCR1						page 89
	; set bit 7 	 CTC1 			for Clear Timer/Counter on Compare Match	| NOTE: does not work for now, for some reason
	; set bits 3:0  CS13:CS10		for CK/16384 prescale
	ldi r16, (1 << CTC1 | 1 << CS13 | 1 << CS12 | 1 << CS11 | 1 << CS10)
	out TCCR1, r16

	; in TIMSK						page 92
	; set bit 4		 OCIE1A			Timer/Counter1 Output Compare Match A Interrupt Enable
	ldi r16, 1 << OCIE1A
	out TIMSK, r16	
	
	; in OCR1A						page 91
	;								load value to compare to
	ldi r16, 60;					; 61.03515625 should be exaclty 1 second, but timer says this should do the job
	out OCR1A, r16

	; enable interrupts
	sei
	; MICROCONTROLER SETUP END

	; values to display
	ldi r21, 6	; POS1	10^1 digit 
	ldi r20, 3	; POS0	10^0 digit

LOOP:
; 4 upper bits control which 7-segment display should be active
; 4 lower bits corresond to displayed number
	
	mov r16, r21
	swap r16

	ldi r18, 0b01
	or r16, r18
	rcall SHIFT_REGISTER_OUTPUT
		
	mov r16, r20
	swap r16

	ldi r18, 0b10
	or r16, r18
	rcall SHIFT_REGISTER_OUTPUT

	rjmp LOOP


SHIFT_REGISTER_OUTPUT:
	cli
	mov r22, r16
	BIT_BANG_LOOP:
		lsl r22

		in r17, SREG
		sbrc r17, 0; if next bit to output is 0, skip setting DATA to 1

		sbi PORTB, PORTB2 ; high	| DATA

		nop
		sbi PINB, PINB0 ;	toggle	| CLOCK
		nop
		sbi PINB, PINB0 ;  toggle 	| CLOCK
		nop
		cbi PORTB, PORTB2 ; low		| DATA
		
		inc r19	; count 8 bits
		cpi r19, 8
		brne BIT_BANG_LOOP

	sbi PINB, PINB1 ; toggle		| LATCH
	ldi r19, 0	; reset 8 bits counter
	sbi PINB, PINB1 ; toggle 		| LATCH
	sei
	ret