; interrupt table
.org 0x0000
rjmp RESET

.org 0x0006
rjmp TIMER0_COMPA_ISR

; interrupt handling
TIMER0_COMPA_ISR:
	in r15, SREG  ; save
	; -----------
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
		sbi PORTB, PORTB2 ; high	| DATA

		nop
		sbi PINB, PINB0 ;	toggle	| CLOCK
		nop
		sbi PINB, PINB0 ;	toggle	| CLOCK
		nop
		cbi PORTB, PORTB2 ; low		| DATA
		
		inc r19
		cpi r19, 8
		brne BIT_BANG_LOOP

	sbi PINB, PINB1 ;		toggle	| LATCH
	ldi r19, 0
	sbi PINB, PINB1 ;		toggle	| LATCH

	inc r21		; increment value to bit bang
	
	out SREG, r15 ; restore
	reti


RESET: ; main program
	; initialize Stack Pointer
	; This Stack space in the data SRAM must be defined by the program before any subroutine calls are executed or interrupts are enabled
	ldi r16, LOW(RAMEND) ; architecture is so small that only SPL is needed. In this case, the SPH Register is not present
	out SPL, r16

	; configure output pins
	sbi DDRB, DDB0 ; configure pin B0 as output
	sbi DDRB, DDB1 ; configure pin B1 as output
	sbi DDRB, DDB2 ; configure pin B2 as output



	; set pointer Z for reaching I/O registers 32-64 (sbi, cbi,... can handle only 0-31)
	clr ZH
	ldi ZL, 0x20 ; point ZL to 0x20 I/O registers beginning

	; configure TIMER0
	ldi r16, (1 << CS02 | 1 << CS00) 
	std Z + TCCR0B, r16  ; set CS02, CS00 for clk/1024 prescale
	
	ldi r16, 1 << WGM01
	std Z + TCCR0A, r16  ; set WGM01 for CTC operation
	
	ldi r16, 166 ; manipulate this value for timing
	out OCR0A, r16 ; load OCR0A with value

	ldi r16, 1 << OCIE0A
	std Z + TIMSK0, r16	; Timer/Counter0 Output Compare Match A Interrupt Enable

	; enable interrupts
	sei

; MAIN LOOP
loop: 
	nop
    rjmp loop ; wait for TIMER 0 interrupt