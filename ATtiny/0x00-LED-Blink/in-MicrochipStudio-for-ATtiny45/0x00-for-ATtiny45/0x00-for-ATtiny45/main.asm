; interrupt table
.org 0x0000
rjmp RESET

.org 0x000A
rjmp TIMER0_COMPA_ISR

; interrupt handling
TIMER0_COMPA_ISR:
	in r15, SREG
	inc r17
	cpi r17, 80 ; timing factor, value 40 times at 80.338 us
	brne TIMER0_COMPA_ISR_END

	sbi $16, 0 ; PINB0 - toggle PB0
	ldi r17, 0

TIMER0_COMPA_ISR_END:
	out SREG, r15
	reti

RESET: ; main program
	; initialize Stack Pointer
	; This Stack space in the data SRAM must be defined by the program before any subroutine calls are executed or interrupts are enabled
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; configure output pin
	sbi $17, 0 ; DDRB0 - configure pin B0 as output
	cbi $18, 0 ; PORTB0 - pin B0 output is low

	; set pointer Z for reaching I/O registers 32-64 (sbi, cbi,... can handle only 0-31)
	clr ZH
	ldi ZL, $20 ; point ZL to 0x20

	; configure timer
	ldi r16, 0b10 
	std Z+$33, r16  ; in TCCR0B - set CS01 for clk/8 prescale
	
	std Z+$2A, r16  ; in TCCR0A - set WGM01 for CTC operation
	
	ldi r16, 250;
	out $29, r16 ; load OCR0A with value

	ldi r16, 0b10000
	std Z+$39, r16	; in TIMSK -  set OCIE0A (Timer/Counter0 Output Compare Match A Interrupt Enable)

	; enable interrupts
	sei

loop: ; this could be probably be handled by sleep, but I'll leave it just like that
	nop
    rjmp loop