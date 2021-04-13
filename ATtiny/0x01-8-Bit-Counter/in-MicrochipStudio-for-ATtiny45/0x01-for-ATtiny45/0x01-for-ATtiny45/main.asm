; interrupt table
.org 0x0000
rjmp RESET	; main program

.org 0x0003
rjmp TIMER1_COMPA_ISR

; interrupt handling
TIMER1_COMPA_ISR:
	in r15, SREG

	; r19 current bit
	; r20 SREG copy

	; r21 stores value to bit bang
	; r22 value copy to shift

	mov r22, r21
	; bit bang loop
	BIT_BANG_LOOP:
		lsr r22
		in r20, SREG
		sbrc r20, 0; skip if carry is 0
		sbi 0x18, 2 ; PORTB2 - output PB2 high	| DATA

		nop
		sbi 0x16, 3 ; PB3 - toggle PB3			| CLOCK
		nop
		sbi 0x16, 3 ; PB3 - toggle PB3			| CLOCK
		nop
		cbi 0x18, 2 ; PORT2 - output PB2 low	| DATA
		
		inc r19
		cpi r19, 8
		brne BIT_BANG_LOOP

	sbi 0x16, 1 ; PINB1 - toggle PB1			| LATCH
	ldi r19, 0
	sbi 0x16, 1 ; PINB1 - toggle PB1			| LATCH

	inc r21		; increment value to bit bang
	out SREG, r15
	reti

RESET: ; main program
; SETUP START
	; initialize Stack Pointer
	; This Stack space in the data SRAM must be defined by the program before any subroutine calls are executed or interrupts are enabled
	
	ldi r16, HIGH(RAMEND)
	out SPH, r16

	ldi r16, LOW(RAMEND)
	out SPL, r16

	; set pointer Z for reaching I/O registers 32-64 (sbi, cbi,... can handle only 0-31), or for writing bitfield across entire range
	clr ZH
	ldi ZL, 0x20 ; point ZL to 0x20

	; configure output pin
	ldi r16, 0b1110
	; DDRB3 - configure pin B3 as output
	; DDRB2 - configure pin B2 as output
	; DDRB1 - configure pin B1 as output

	std Z+0x17, r16 

	; configure TIMER 1
	
	; set bit 7 in TCCR1 - CTC1 - for Clear Timer/Counter on Compare Match
	; set bit 2 in TCCR1 - set CS13, CS11 - for clk/512 prescale
	ldi r16, 0b10001010
	std Z+0x30, r16
	
	ldi r16, 250;
	out 0x2E, r16 ; load OCR1A with value above

	ldi r16, (1<<6)
	std Z+0x39, r16	; in TIMSK -  set OCIE1A (Timer/Counter1 Output Compare Match A Interrupt Enable)

	; enable interrupts
	sei

; SETUP END

; MAIN LOOP
sleep	; wait for TIMER 1 interrupt