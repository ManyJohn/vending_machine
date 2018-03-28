

;vending maching
;z5119641 (Qingchen Zhong)
.include "m2560def.inc"


.equ LCD_DISP_OFF = 0b00001000
.equ LCD_DISP_CLR = 0b00000001
.equ LCD_CHANGE_ADDR = 0b10101000


.equ lcd_base = 0b00110000
.equ COLIN = 0b00001111
.equ COLOUT = 0b00001111
.equ ROWIN = 0b11110000
.equ ROWOUT = 0b11110000
.equ ROWMSK =  0b00001111
.equ COLMSK = 0b11110000
.equ YES_INPUT = 1
.equ NO_INPUT = 0
.equ INITIAL_INVENTORY = 1


.def lcd_display = r14;using it to deliver lcd command
.def temp = r16
.def led = r17
.def display_counter = r18
.def row = r19
.def col = r20
.def key = r21
.def digit_counter = r22
.def result_temp=r23
.def temp2 = r13 
.def coin_needed = r12
.def coin_inserted = r11
.def coin_display = r10



;.def lcd_display = r26


;TEMP(R16) IS USED BY MACRO
.macro load_lcd_data
	mov temp, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

.macro do_lcd_command
	ldi temp, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro

.macro do_lcd_data
	ldi temp, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

;for timer
.macro clear
	ldi YL,low(@0)
	ldi YH,high(@0)
	clr temp
	st Y+,temp
	st Y,temp
.endmacro 

.macro clean_byte
	ldi YL,low(@0)
	ldi YH,high(@0)
	clr temp
	st Y,temp
.endmacro 

.macro set_byte
	ldi YL,LOW(@0)
	ldi YH,HIGH(@0)
	ldi temp,1
	st Y,temp
.endmacro


.macro load_byte
	ldi YL,low(@1)
	ldi YH,high(@1)
	ld @0,y
.endmacro


.macro store_byte
	ldi YL,low(@0)
	ldi YH,high(@0)
	st y,@1
.endmacro



.macro reset_inventory;macro to increase stock and cost
	ldi YL, low(@0)
	ldi YH, high(@0)
	ldi temp, INITIAL_INVENTORY
	st Y,temp
.endmacro

.macro set_to_two;macro to increase stock and cost
	ldi YL, low(@0)
	ldi YH, high(@0)
	ldi temp, 2
	st Y,temp
.endmacro

.macro set_to_one;macro to increase stock and cost
	ldi YL, low(@0)
	ldi YH, high(@0)
	ldi temp, 1
	st Y,temp
.endmacro

.macro inc_byte ;macro to increase stock and cost
	ldi YL, low(@0)
	ldi YH, high(@0)
	ld temp, y
	inc temp
	st Y,temp
.endmacro


.macro dec_byte ;macro to increase stock and cost
	ldi YL, low(@0)
	ldi YH, high(@0)
	ld temp, y
	dec temp
	st Y,temp
.endmacro



.macro turn_on_potential
	LDI TEMP,(3 << REFS0) | (0 << ADLAR) | (0 << MUX0);
	STS ADMUX,TEMP 
	LDI TEMP,(1 << MUX5);
	STS ADCSRB,TEMP
	LDI TEMP,(1 << ADEN) | (1 << ADSC) | (1 << ADIE) | (5 << ADPS0);
	STS ADCSRA,TEMP 
.endmacro

.macro turn_off_potential
	LDI TEMP,(3 << REFS0) | (0 << ADLAR) | (0 << MUX0);
	STS ADMUX,TEMP 
	LDI TEMP,(1 << MUX5);
	STS ADCSRB,TEMP
	LDI TEMP,(1 << ADEN) | (1 << ADSC) | (0 << ADIE) | (5 << ADPS0);
	STS ADCSRA,TEMP 
.endmacro






.dseg
anykey_is_pressed: .byte 1
qtr_second_counter: .byte 2
target_time: .byte 1
sellect_screen_call: .byte 1
need_start_screen: .byte 1
need_sellect_screen: .byte 1
number_is_pressed: .byte 1
need_input: .byte 1
num_shown: .byte 1
at_start_screen: .byte 1
at_selection_screen: .byte 1
keydown: .byte 1
choice:	.byte 1
need_empty_screen:.byte 1
at_empty_screen:.byte 1
;empty_time: .byte 1
choice_is_empty: .byte 1
need_stock_check: .byte 1
need_insert_screen: .byte 1
at_insert_screen: .byte 1
hash_pressed: .byte 1 
need_deliver_screen: .byte 1
at_deliver_screen: .byte 1
pb0_pressed: .byte 1
pb1_pressed:.byte 1
star_is_pressed: .byte 1

need_admin_screen: .byte 1
at_admin_screen: .byte 1
star_counter: .byte 1
admin_shown :.byte 1
;admin_choice: .byte 1
admin_inventory:  .byte 1
admin_cost:.byte 1
first_low: .byte 1
first_high: .byte 1
need_return_coin: .byte 1 
motor_on: .byte 1
//inventory setting
inven_cost_1: .byte 1 ;stores cost of inventory 1
inven_cost_2: .byte 1
inven_cost_3: .byte 1
inven_cost_4: .byte 1
inven_cost_5: .byte 1
inven_cost_6: .byte 1
inven_cost_7: .byte 1
inven_cost_8: .byte 1
inven_cost_9: .byte 1

inven_stock_1: .byte 1 ;stores stock of inventory 1
inven_stock_2: .byte 1
inven_stock_3: .byte 1
inven_stock_4: .byte 1
inven_stock_5: .byte 1
inven_stock_6: .byte 1
inven_stock_7: .byte 1
inven_stock_8: .byte 1
inven_stock_9: .byte 1


.cseg
.org 0
	jmp RESET

.org INT0addr
	jmp push_button0
.org INT1addr
	jmp push_button1

.org OVF0addr
	jmp Time0OVR
.ORG 0X003A
	jmp run_coin


RESET:
	
	;SET REGISTERS USED
	clr temp
	clr led
	clr display_counter
	clr row
	clr col 
	clr key 
	clr digit_counter
	;clr input_num 
	;clr result 
	;clr ten_register 
	clr result_temp
	clean_byte target_time
	clear qtr_second_counter
	clean_byte target_time
	clean_byte sellect_screen_call
	clean_byte need_start_screen
	clean_byte need_sellect_screen
	clean_byte anykey_is_pressed
	clean_byte number_is_pressed
	clean_byte need_input
	clean_byte num_shown
	clean_byte at_start_screen
	clean_byte at_selection_screen
	clean_byte keydown
	clean_byte choice
	clean_byte need_empty_screen
	clean_byte choice_is_empty
	clean_byte need_stock_check
	clean_byte at_insert_screen
	clean_byte hash_pressed
	clean_byte first_high
	clean_byte first_low
	clean_byte at_deliver_screen
	clean_byte need_deliver_screen
	clean_byte need_return_coin
	clean_byte motor_on
	clr coin_display
	clean_byte pb0_pressed
	clean_byte pb1_pressed
	clean_byte need_admin_screen
	clean_byte star_is_pressed
	clean_byte at_admin_screen
	clean_byte star_counter
	clean_byte admin_shown
	;clean_byte empty_time

	;initialize the stock value
	set_byte inven_stock_1
	ldi temp,2
	store_byte inven_stock_2,temp
	ldi temp,3
	store_byte inven_stock_3,temp
	ldi temp,4
	store_byte inven_stock_4,temp
	ldi temp,5
	store_byte inven_stock_5,temp
	ldi temp,6
	store_byte inven_stock_6,temp
	ldi temp,7
	store_byte inven_stock_7,temp
	ldi temp,8
	store_byte inven_stock_8,temp
	ldi temp,9
	store_byte inven_stock_9,temp

	set_to_one inven_cost_1
	set_to_one inven_cost_3
	set_to_one inven_cost_5
	set_to_one inven_cost_7
	set_to_one inven_cost_9

	set_to_two inven_cost_2
	set_to_two inven_cost_4
	set_to_two inven_cost_6
	set_to_two inven_cost_8
	inc_byte inven_cost_2

	clr temp
	mov coin_needed,temp
	mov coin_inserted,temp

	;potentialmeter
	turn_on_potential
	;SET SP
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	
	;TURN ON LED
	;top two led
	ser temp
	out DDRG,temp
	SER TEMP
	;low eight led
	OUT DDRC ,TEMP
	LDI led,0X00
	OUT PORTC,led

	;SET THE TIMER
	clear qtr_second_counter
	ldi temp,0
	out TCCR0A,temp
	ldi temp,2
	out TCCR0B,temp
	ldi temp,(1<<TOIE0);
	sts TIMSK0,temp;

	;pwm setting
	ldi temp,0XFF
	OUT DDRE,temp

	ldi temp,0X00
	;mov OFvalue,temp
	sts OCR3BL,temp
	clr temp
	sts OCR3BH,temp

	ldi temp,(1<<CS30)
	sts TCCR3B, temp
	ldi temp,(1<<WGM30)|(1<<COM3B1)
	STS TCCR3A,temp

	;turn on push button
	ldi temp,(1<<ISC11)|(1<<ISC01)
	sts EICRA,temp
	in temp,EIMSK
	ori temp,(1<<INT0)|(1<<INT1)
	out EIMSK, temp

	;TURN ON LCD
	ser temp;SET AS OUTPUT PORT
	out DDRF, temp
	out DDRA, temp
	;SHOW NOT THING
	clr temp
	out PORTF, temp
	out PORTA, temp
	;SET UP LCD DISPLAY
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink
	
	
	;TURN ON ALL THE INTERUPT
	sei

	rcall show_start_screen


	/*led debug*/
	ser temp
	out DDRG,temp
	ldi temp,0b00000000
	out PORTG,temp
halt:

	rjmp halt




;LCD SETTING
.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
	sbi PORTA, @0
.endmacro
.macro lcd_clr
	cbi PORTA, @0
.endmacro

;
; Send a command to the LCD (temp)
;


sleep_5ms:
	in temp,SREG
	push temp
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	pop temp
	out SREG,temp
	ret

lcd_command:
	out PORTF, temp
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

lcd_data:
	out PORTF, temp
	lcd_set LCD_RS
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	lcd_clr LCD_RS
	ret

lcd_wait:
	push temp
	clr temp
	out DDRF, temp
	out PORTF, temp
	lcd_set LCD_RW
lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	in temp, PINF
	lcd_clr LCD_E
	sbrc temp, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser temp
	out DDRF, temp
	pop temp
	ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret







Time0OVR:
	push temp
	in temp, SREG
	push temp
	push YL
	push YH
	push r24 ;counter increment
	push r25
	
	;OUT portc,result_temp
if_at_start:
	load_byte temp,at_start_screen
	cpi temp,1
	brne if_at_selection
	rcall read_key
	clr result_temp
	
	;check wether a key been pressed
	

if_at_selection:
	load_byte temp,at_selection_screen
	cpi temp,1
	brne if_at_insert

	load_byte temp,need_input
	cpi temp,YES_input
	brne counting_time
	`/*read key debug*/
	;ldi temp,0xff
	;out portc,temp
	;clr result_temp	
	clean_byte keydown
	rcall read_key
	/*result_debyg*/
	;out portc,result_temp
	store_byte choice,result_temp
	rcall show_digit


if_at_insert:
	load_byte temp,at_insert_screen
	cpi temp,1
	brne if_at_admin
	turn_on_potential
	rcall read_key
	clr result_temp
if_at_admin:
	load_byte temp,at_admin_screen
	cpi temp,1
	brne counting_time
	rcall read_key
	cpi result_temp,0
	breq counting_time
	store_byte choice,result_temp
	clean_byte admin_shown
		
//*******************************************//
//THIS LINE ABOVE WILL BE CONSTANTLY CHECKED //
//*******************************************//
counting_time:
	lds r24,qtr_second_counter;low
	lds r25,qtr_second_counter+1
	adiw r25:r24,1
	
	;//check if it is one second 
	cpi r24,low(1953) ;time change 7812/4
	ldi temp,HIGH(1953)
	cpc r25, temp
	;brne rjmp_NOT_SECOND
	breq do_second_job
	rjmp NOT_QTR_SECOND
do_second_job:
	/****************************************/
	/*HERE IS THE END --OF--qtr SECOND------*/
	/****************************************/
	/*one sec debug*/
	;com led
	;out PORTc,led	
	;clean qtr_second_counter every qtr second
	clear qtr_second_counter
	clean_byte pb0_pressed
	clean_byte pb1_pressed

second_start_check:
	load_byte temp,at_start_screen
	cpi temp,1
	brne second_select_check
	load_byte temp,anykey_is_pressed
	cpi temp,1
	brne second_select_check
	rjmp pre_check_sellection

second_select_check:
	load_byte temp,at_selection_screen
	cpi temp,1
	breq next_second_select_check
	rjmp second_empty_check
next_second_select_check:
	clr temp
	cp coin_inserted,temp
	breq no_return_needed
	set_byte need_return_coin
	;-----------
no_return_needed:
//------------star----------------
	load_byte temp,star_counter
	cpi temp,10
	brne further_star_check
	clean_byte star_counter
	clean_byte star_is_pressed
	set_byte need_admin_screen
	/*admin debug*/
	;ldi temp,0xff
	;out portc,temp
	clean_byte at_selection_screen
	clean_byte need_sellect_screen
	ldi temp,4;wait little bit
	store_byte target_time,temp
	clr display_counter
	rjmp check_target_time
further_star_check:
	load_byte temp,star_is_pressed
	cpi temp,1
	brne clean_star_counter
	inc_byte star_counter
	clean_byte star_is_pressed
	rjmp select_num_check
clean_star_counter:
	clean_byte star_counter
select_num_check:
	
	load_byte temp,choice
	cpi temp,0
	brne further_second_select_check 
	rjmp check_target_time
	/*choice debug*/
	;out portc,temp
further_second_select_check:
	clean_byte need_start_screen
	clean_byte need_sellect_screen
	set_byte need_stock_check
	
	clean_byte at_selection_screen
	;clear qtr_second_counter
	clr display_counter
	ldi temp,4;wait little bit
	store_byte target_time,temp
	rjmp check_target_time
//----------------------------------------
second_empty_check:
	load_byte temp,at_empty_screen
	cpi temp,1
	brne second_insert_check
	
	;inc_byte empty_time
	;load_byte temp,empty_time
	cpi display_counter,2
	brne empty_flash_3
	ldi temp,0b00000011
	mov temp2,temp
	ldi temp,0xff
	out portc,temp
	out PORTG,temp2

empty_flash_3:
	cpi display_counter,5
	breq further_empty_flash_3
	rjmp check_target_time
further_empty_flash_3:
	clr temp
	clr temp2
	out portc,temp
	out PORTG,temp2
	;clean_byte empty_time
	clean_byte at_empty_screen

	rjmp check_target_time

//--------------------------------------------------
second_insert_check:
	load_byte temp,at_insert_screen
	cpi temp,1
	breq further_second_insert_check
	rjmp second_delivery_check
further_second_insert_check:
	clr temp
	cp coin_needed,temp
	brne waiting_coin
	ldi temp,0xff
	out PORTC,temp
	set_byte need_deliver_screen
	clean_byte need_insert_screen
	clean_byte at_insert_screen
	clean_byte hash_pressed
	clean_byte anykey_is_pressed

	ldi temp,4;wait little bit
	store_byte target_time,temp
	clr display_counter
	rjmp check_target_time

waiting_coin:
	out PORTC,coin_display
	mov result_temp,coin_needed
	clean_byte num_shown
	rcall show_insert_screen

	load_byte temp,hash_pressed
	cpi temp,1
	breq futher_waiting_coin
	rjmp check_target_time
futher_waiting_coin:
	set_byte need_sellect_screen
	clean_byte need_insert_screen
	clean_byte at_insert_screen
	clean_byte hash_pressed
	clean_byte anykey_is_pressed

	ldi temp,4;wait little bit
	store_byte target_time,temp
	clr display_counter
	rjmp check_target_time
//------------------------------
second_delivery_check:
	load_byte temp,at_deliver_screen
	cpi temp,1
	breq further_second_delivery_check
	rjmp secon_admin_check
further_second_delivery_check:
	cpi display_counter,11
	brne delivery_flash_next
	ldi temp,0X00
	sts OCR3BL,temp
	clean_byte at_deliver_screen
	clean_byte need_deliver_screen
	set_byte need_sellect_screen
	rcall dec_each_inventory
	rjmp check_target_time
delivery_flash_next:
	cpi display_counter,0
	brne delivery_flash_3
	ldi temp,0b00000011
	mov temp2,temp
	ldi temp,0xff
	out portc,temp
	out PORTG,temp2

delivery_flash_3:
	cpi display_counter,5
	breq further_delivery_flash_3
	rjmp check_target_time
further_delivery_flash_3:
	clr temp
	clr temp2
	out portc,temp
	out PORTG,temp2
	;turn off motor
	
	;clean_byte at_deliver_screen
	rjmp check_target_time
//----------------------

secon_admin_check:
	load_byte temp,at_admin_screen
	cpi temp,1
	breq further_secon_admin_check
	rjmp check_target_time
further_secon_admin_check:
	load_byte temp,hash_pressed
	cpi temp,1
	brne continue_admin_display
	clean_byte at_admin_screen
	clean_byte need_admin_screen
	set_byte need_sellect_screen
	clr display_counter
	clean_byte choice
	clr coin_needed
	clean_byte star_is_pressed
	clean_byte hash_pressed
	clean_byte admin_shown
	ldi temp,4;wait little bit
	store_byte target_time,temp
	rjmp check_target_time
continue_admin_display:
	rcall show_admin_screen
	rjmp check_target_time





/*this is to extend the capicity of brach*/
jmp_pre_check_sellection:
	rjmp pre_check_sellection


check_target_time:

second_return_check:
	load_byte temp,need_return_coin
	cpi temp,1
	breq further_second_return_check
	rjmp further_check_target_time
further_second_return_check:
	load_byte temp,motor_on
	cpi temp,0
	brne turn_off_return_moter
turn_on_return_moter:
	ldi temp,0Xff
	sts OCR3BL,temp
	set_byte motor_on
	rjmp further_check_target_time
turn_off_return_moter:
	ldi temp,0X00
	sts OCR3BL,temp
	clean_byte motor_on
	clean_byte need_return_coin
	dec coin_inserted
	lsr coin_display
	out portc,coin_display
	rjmp further_check_target_time

further_check_target_time:

	/****************************************/
	/*checking ---------target time---------*/
	/****************************************/
	;//how many second we want to wait
	load_byte temp,target_time
	;//check how many 1 sec we have
	
	/*display_counter debug*/
	;mov led,display_counter
	;OUT PORTc,led
	/*display input*/
	

	/*when target_time is 0 sec, the timer will not do further operation*/
	inc display_counter;
	cp display_counter,temp;load tag
	brne JMP_END_TIMER0

	/****************************************/
	/*HERE IS THE END OF EVERY TARGET SECOND*/
	/****************************************/
	
	;wait till sec for debiunce
	clean_byte need_input

begin_screen_check:
	;change the display when the time is ripe
	;choose the secreen you want to display here
check_start_screen:	
	
	load_byte temp,need_start_screen
	cpi temp,1
	brne check_sellection

	clean_byte at_selection_screen
	clean_byte need_input
	do_lcd_command LCD_DISP_CLR;clean screen
	rcall show_start_screen

	clean_byte need_start_screen
	rjmp finish_check
;here is just help the program to reach not sec
rjmp_NOT_QTR_SECOND:
	rjmp NOT_QTR_SECOND
JMP_END_TIMER0:
	rjmp END_TIMER0

;========================================================
;CHECK WEHTER WE NEED TO CHANGE SCREEN EVERY TARGET SEC
;=========================================================
pre_check_sellection:
	;rest the time to synchronous
	clear qtr_second_counter
	clean_byte anykey_is_pressed
	clr display_counter
check_sellection:
	load_byte temp,need_sellect_screen
	cpi temp,1
	brne check_stock
	clean_byte at_start_screen
	clean_byte anykey_is_pressed
	clean_byte at_empty_screen

	do_lcd_command LCD_DISP_CLR;clean screen
	rcall show_sellection_screen
	set_byte at_selection_screen
	set_byte need_input
	clean_byte num_shown
	
end_check_sellection:
	clr result_temp
	clean_byte need_sellect_screen
	rjmp finish_check


;==============================================
check_stock:
	load_byte temp,need_stock_check
	cpi temp,1
	breq do_stock_check
	;rjmp finish_check
	RJMP check_Insert_coin
do_stock_check:
	/*do_stock_check debug*/

	;ldi temp,0xff
	;out portc,temp

	clean_byte need_stock_check
	clean_byte choice_is_empty
	rcall Check_each_inventory
	load_byte temp,choice_is_empty
	cpi temp,1
	breq set_up_check_empty_screen
	set_byte need_insert_screen
	rjmp check_Insert_coin
set_up_check_empty_screen:
	set_byte need_empty_screen

//----------------------------------------------
check_empty_screen:
	load_byte temp,need_empty_screen
	cpi temp,1
	brne check_Insert_coin
	do_lcd_command LCD_DISP_CLR;clean screen
	clean_byte at_start_screen
	clean_byte anykey_is_pressed
	clean_byte at_selection_screen
	;clean_byte empty_time
	/*check stock debug*/
	;ldi temp,0xff
	;out portc,temp

	clean_byte num_shown
	load_byte result_temp,choice
	rcall show_empty_screen
	set_byte at_empty_screen
	
	ldi temp,12
	store_byte target_time,temp
	set_byte need_sellect_screen
end_check_empty:
	clr display_counter
	clean_byte need_empty_screen
	rjmp END_TIMER0

//--------------------------------------------
check_Insert_coin:

	load_byte temp,need_insert_screen
	cpi temp,1
	brne check_delivery

	/*check insert debug*/
	;ldi temp,0xff
	;out portc,temp
	clr coin_inserted

	clean_byte at_start_screen
	clean_byte anykey_is_pressed
	clean_byte at_selection_screen
	clean_byte at_empty_screen
	clean_byte num_shown
	set_byte at_insert_screen
	

	rcall Check_each_cost
	mov result_temp,coin_needed
	do_lcd_command LCD_DISP_CLR;clean screen
	rcall show_insert_screen

end_check_insert:
	clr display_counter
	clean_byte need_insert_screen
	rjmp END_TIMER0
//===============================================
check_delivery:
	;ldi temp,0xff
	;out PORTC,temp
	load_byte temp,need_deliver_screen
	cpi temp,1
	brne check_admin
	ldi temp,0xff
	sts OCR3BL,temp
	clr coin_inserted
	clr coin_display
	do_lcd_command LCD_DISP_CLR;clean screen
	rcall show_delivery_screen
	set_byte at_deliver_screen
	ldi temp,12;wait little bit
	store_byte target_time,temp
	clean_byte need_deliver_screen
	clr display_counter
	rjmp END_TIMER0

//===============================================
check_admin:
	load_byte temp,need_admin_screen
	cpi temp,1
	brne END_TIMER0
	clean_byte admin_shown
	do_lcd_command LCD_DISP_CLR;clean screen
	set_byte choice
	rcall show_admin_screen

	set_byte at_admin_screen
	clean_byte hash_pressed
	clean_byte need_admin_screen
	clr display_counter
	rjmp END_TIMER0

/*for the timer conting purpose*/
finish_check:
	clr display_counter
	clear  qtr_second_counter;necessery
	clear  target_time
END_TIMER0:
	/*one sec debug*/
	;OUT PORTc,led
	//clean display_counter,in case it goes too large
	cpi display_counter,40
	brsh clean_display_counter

pop_timer0:
	POP R25
	POP R24
	POP YH
	POP YL
	POP TEMP
	OUT SREG,TEMP
	POP temp
reti
NOT_QTR_SECOND:
	sts qtr_second_counter,r24;low
	sts qtr_second_counter+1,r25
	rjmp END_TIMER0
clean_display_counter:
	clr display_counter
	rjmp pop_timer0





/*read key function*/
read_key:
	push temp
	in temp,SREG
	push temp
	push key

	load_byte temp,keydown
	cpi temp,1
	brne continue_read_key
	rjmp debounce_key
continue_read_key:
	ldi temp, ROWIN
	sts DDRL,temp
	ldi temp, COLOUT;ROW IS HIGH
	sts PORTL, temp
	;DELAY
	CLR TEMP
d1:
	INC TEMP;
	NOP
	NOP
	CPI TEMP,255
	BRNE D1

row_check:
    ldS temp,PINL
    ORi temp,COLMSK
	;OUT PORTC, TEMP
	cpi temp, 0B11111111
	BREQ jmp_end_read_key;NO ROWS HAS BEEN PRESSED
	;OUT PORTC,TEMP
	;save the old value of temp here
	MOV ROW, TEMP
	
	load_byte temp,at_start_screen
	cpi temp,1 
	brne further_row_check
	set_byte anykey_is_pressed
	rjmp debounce_key

further_row_check:	
	;MOV ROW, TEMP
	ldi temp, COLIN
	sts DDRL,temp
	ldi temp, ROWOUT
	sts PORTL, temp
	;DELAY
	CLR TEMP
d2:
	INC TEMP;
	NOP
	NOP
	CPI TEMP,255
	BRNE d2
	ldS temp,PINL
    ORi temp,ROWMSK
	MOV COL, TEMP

	AND ROW,COL
	mov key,row
	;OUT PORTc,key
comparison:
	;assume a number has been pressed
	;set the number_is_pressed flag up
	ldi YH,HIGH(anykey_is_pressed)
	ldi YL,LOW(anykey_is_pressed)
	ldi temp,1
	st Y,temp
	ldi YH,HIGH(number_is_pressed)
	ldi YL,LOW(number_is_pressed)
	ldi temp,1
	st Y,temp
check_one:
	cpi key,0b11101110//lower bit is row
	brne check_two
	ldi result_temp,1
	rjmp end_read_key
check_two:
	cpi key,0b11011110
	brne check_three
	ldi result_temp,2
	rjmp end_read_key
check_three:
	cpi key,0b10111110
	brne check_four
	ldi result_temp,3
	rjmp end_read_key

jmp_end_read_key:
	rjmp end_read_key

check_four:
	cpi key,0b11101101
	brne check_five
	ldi result_temp,4
	rjmp end_read_key
check_five:
	cpi key,0b11011101
	brne check_six
	ldi result_temp,5
	rjmp end_read_key
check_six:
	cpi key,0b10111101
	brne check_seven
	ldi result_temp,6
	rjmp end_read_key
check_seven:
	cpi key,0b11101011
	brne check_eight
	ldi result_temp,7
	rjmp end_read_key
check_eight:
	cpi key,0b11011011
	brne check_nine
	ldi result_temp,8
	rjmp end_read_key
check_nine:
	cpi key,0b10111011
	brne check_star
	ldi result_temp,9
	rjmp end_read_key
check_star:
	cpi key,0b11100111
	brne check_hash
	clean_byte number_is_pressed
	set_byte star_is_pressed
	rjmp end_read_key

check_hash:
	cpi key,0b10110111
	brne check_A
	clean_byte number_is_pressed
	set_byte hash_pressed
	rjmp end_read_key
check_A:
	cpi key,0b01111110
	brne check_B
	load_byte temp,at_admin_screen
	cpi temp,1
	brne not_valid_input
	rcall inc_each_cost
	clean_byte admin_shown
	rcall show_admin_screen
	rjmp not_valid_input
check_B:
	cpi key,0b01111101
	brne check_C
	load_byte temp,at_admin_screen
	cpi temp,1
	brne not_valid_input
	rcall dec_each_cost
	clean_byte admin_shown
	rcall show_admin_screen
	rjmp not_valid_input
check_C:
	cpi key,0b01111011
	brne not_valid_input
	load_byte temp,at_admin_screen
	cpi temp,1
	brne not_valid_input
	rcall clear_each_inventory
	clean_byte admin_shown
	rcall show_admin_screen
	rjmp not_valid_input

not_valid_input:
	clean_byte number_is_pressed
	/*clear_each_inventory
	ldi YH,HIGH(number_is_pressed)
	ldi YL,LOW(number_is_pressed)
	ldi temp,0
	st Y,temp
	*/
debounce_key:
	load_byte temp,at_start_screen
	cpi temp,1
	brne end_read_key
	set_byte keydown
end_read_key:;WHEN THE KEY IS PRESSED

	pop key
	pop temp
	out SREG,temp
	pop temp
	ret






show_start_screen:
	push temp
	in temp,SREG
	push temp

	; set it to display next screen 3 sec later
	ldi YL,LOW(target_time)
	ldi YH,HIGH(target_time)
	ldi temp,12
	st Y,temp 


	/*debug*/
	;out PORTC,led
;
	;set next screen
	ldi YL,LOW(need_sellect_screen)
	ldi YH,HIGH(need_sellect_screen)
	ldi temp,1
	st Y,temp 

	set_byte at_start_screen

	do_lcd_data '2'
	do_lcd_data '1'
	do_lcd_data '2'
	do_lcd_data '1'
	do_lcd_data ' '
	do_lcd_data '1'
	do_lcd_data '7'
	do_lcd_data 'S'
	do_lcd_data '1'
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data 'P'
	do_lcd_data '7'

	do_lcd_command LCD_CHANGE_ADDR;CHANGE THE DD RAM ADDRESS
	
	do_lcd_data 'V'
	do_lcd_data 'e'
	do_lcd_data 'n'
	do_lcd_data 'd'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'g'
	do_lcd_data ' '
	do_lcd_data 'M'
	do_lcd_data 'a'
	do_lcd_data 'c'
	do_lcd_data 'h'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'e'
end_show_start_screen:
	pop temp
	out SREG,temp
	pop temp
	ret



show_sellection_screen:
	push temp
	in temp,SREG
	push temp
	
	; set it to display next screen 3 sec later
	ldi YL,LOW(target_time)
	ldi YH,HIGH(target_time)
	ldi temp,12
	st Y,temp 


	do_lcd_data 'S'
	do_lcd_data 'e'
	do_lcd_data 'l'
	do_lcd_data 'e'
	do_lcd_data 'c'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'i'
	do_lcd_data 't'
	do_lcd_data 'e'
	do_lcd_data 'm'

	do_lcd_command LCD_CHANGE_ADDR;CHANGE THE DD RAM ADDRESS
	
	
end_sellection_screen:
	pop temp
	out SREG,temp
	pop temp
	ret




show_empty_screen:
	push temp
	in temp,SREG
	push temp
	
	; set it to display next screen 3 sec later
	ldi YL,LOW(target_time)
	ldi YH,HIGH(target_time)
	ldi temp,12
	st Y,temp 


	do_lcd_data 'O'
	do_lcd_data 'u'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'o'	
	do_lcd_data 'f'
	do_lcd_data ' '
	do_lcd_data 's'
	do_lcd_data 't'
	do_lcd_data 'o'	
	do_lcd_data 'c'
	do_lcd_data 'k'						

	do_lcd_command LCD_CHANGE_ADDR;CHANGE THE DD RAM ADDRESS
	rcall show_digit
	
end_show_empty_screen:
	pop temp
	out SREG,temp
	pop temp
	ret

show_insert_screen:
	push temp
	in temp,SREG
	push temp

	do_lcd_command LCD_DISP_CLR

	do_lcd_data 'I'
	do_lcd_data 'n'
	do_lcd_data 's'
	do_lcd_data 'e'
	do_lcd_data 't'	
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'c'
	do_lcd_data 'o'
	do_lcd_data 'i'	
	do_lcd_data 'n'
	do_lcd_data 's'	
		
	do_lcd_command LCD_CHANGE_ADDR;CHANGE THE DD RAM ADDRESS
	rcall show_digit	
	
end_insert_screen:
	pop temp
	out SREG,temp
	pop temp
	ret





show_delivery_screen:
	push temp
	in temp,SREG
	push temp


	do_lcd_command LCD_DISP_CLR
	do_lcd_data 'D'
	do_lcd_data 'e'
	do_lcd_data 'l'
	do_lcd_data 'i'
	do_lcd_data 'v'	
	do_lcd_data 'e'
	do_lcd_data 'r'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'g'	
	do_lcd_data ' '
	do_lcd_data 'i'	
	do_lcd_data 't'		
	do_lcd_data 'e'		
	do_lcd_data 'm'	
		
end_delivery_screen:
	pop temp
	out SREG,temp
	pop temp
	ret




show_admin_screen:
	push temp
	in temp,SREG
	push temp

	load_byte temp,admin_shown
	cpi temp,1
	brne further_show_admin_screen
	rjmp end_admin_screen
further_show_admin_screen:
	set_byte admin_shown
	do_lcd_command LCD_DISP_CLR
	do_lcd_data 'A'
	do_lcd_data 'd'
	do_lcd_data 'm'
	do_lcd_data 'i'
	do_lcd_data 'n'	
	do_lcd_data ' '
	do_lcd_data 'm'
	do_lcd_data 'o'
	do_lcd_data 'd'
	do_lcd_data 'e'	
	do_lcd_data ' '
	load_byte result_temp,choice
	clean_byte num_shown
	
	rcall show_digit

	do_lcd_command LCD_CHANGE_ADDR;CHANGE THE DD RAM ADDRESs

	do_lcd_data '0'
	rcall check_each_inventory
	mov result_temp,r24
	clean_byte num_shown
	rcall show_digit

	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data '$'
	rcall check_each_cost
	mov result_temp,coin_needed
	clean_byte num_shown
	rcall show_digit
	clr result_temp
end_admin_screen:
	pop temp
	out SREG,temp
	pop temp
	ret





show_digit:
	in temp,SREG
	push temp
	push r26
	push r27
	push result_temp
	
check_shown_flag:
	
	cpi result_temp,0
	breq end_show_digit

	load_byte temp,num_shown
	cpi temp,1
	breq end_show_digit
	set_byte num_shown

	ldi temp,lcd_base
	mov lcd_display,temp
	clr r26;result_ten_digit
	clr r27;result_h_digit
minus_100_loop:	
	cpi result_temp,100
	brsh sub_100
show_100_digit:
	cpi r27,1
	brlo minus_10_loop
	load_lcd_data lcd_display
	;rcall sleep_5ms
	ldi temp,lcd_base
	mov lcd_display,temp

minus_10_loop:
	cpi result_temp,10
	brsh sub_10
show_10_digit:
	cpi r26,0
	brne display_10_digit
	cpi r27,1
	brge display_10_digit
	rjmp directly_display
display_10_digit:
	load_lcd_data lcd_display
	ldi temp,lcd_base
	mov lcd_display,temp


directly_display:	
	ldi temp,lcd_base
	mov lcd_display,temp
	add lcd_display,result_temp
	load_lcd_data lcd_display
	;rcall sleep_5ms
	;do_lcd_command 0b10101000;CHANGE THE DD RAM ADDRESS
	rjmp end_show_digit
sub_10:
	subi result_temp,10
	inc lcd_display
	inc r26
	rjmp minus_10_loop
sub_100:
	subi result_temp,100
	inc lcd_display
	inc r27
	rjmp minus_100_loop
	
end_show_digit:;WHEN THE KEY IS PRESSED

	pop result_temp
	pop r27
	pop r26
	pop temp
	out SREG,temp

   ret



Check_each_inventory:
	push temp
	in temp,SREG
	push temp

	/*check inv debug*/
	;ldi temp,0xf0
	;out portc,temp 

	clean_byte choice_is_empty
	load_byte temp,choice
check_inventory1:
	cpi temp,1
	brne check_inventory2

	load_byte r24,inven_stock_1
	load_byte temp,inven_stock_1
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory
check_inventory2:
	cpi temp,2
	brne check_inventory3
	load_byte r24,inven_stock_2
	load_byte temp,inven_stock_2
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

check_inventory3:
	cpi temp,3
	brne check_inventory4

	load_byte r24,inven_stock_3
	load_byte temp,inven_stock_3
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

check_inventory4:
	cpi temp,4
	brne check_inventory5
	load_byte r24,inven_stock_4
	load_byte temp,inven_stock_4
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory
check_inventory5:
	cpi temp,5
	brne check_inventory6
	load_byte r24,inven_stock_5
	load_byte temp,inven_stock_5
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

set_up_empty_flage:
`	/*check each stock debug*/
	;clr temp
	;out portc,temp

	set_byte choice_is_empty
	set_byte need_empty_screen
	rjmp end_Check_each_inventory

check_inventory6:
	cpi temp,6
	brne check_inventory7
	load_byte r24,inven_stock_6
	load_byte temp,inven_stock_6
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

check_inventory7:
	cpi temp,7
	brne check_inventory8

	load_byte r24,inven_stock_7
	load_byte temp,inven_stock_7
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

check_inventory8:
	cpi temp,8
	brne check_inventory9
	load_byte r24,inven_stock_8
	load_byte temp,inven_stock_8
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

check_inventory9:
	cpi temp,9
	brne end_Check_each_inventory
	load_byte r24,inven_stock_9
	load_byte temp,inven_stock_9
	cpi temp,0
	breq set_up_empty_flage
	rjmp end_Check_each_inventory

end_Check_each_inventory:
	pop temp
	out SREG,temp
	pop temp
	ret


	
Check_each_cost:
	push temp
	in temp,SREG
	push temp

	load_byte temp,choice
check_cost1:
	cpi temp,1
	brne check_cost2
	load_byte coin_needed,inven_cost_1
	rjmp end_Check_each_cost
check_cost2:
	cpi temp,2
	brne check_cost3
	load_byte coin_needed,inven_cost_2
	rjmp end_Check_each_cost

check_cost3:
	cpi temp,3
	brne check_cost4
	load_byte coin_needed,inven_cost_3
	rjmp end_Check_each_cost

check_cost4:
	cpi temp,4
	brne check_cost5
	
	load_byte coin_needed,inven_cost_4
	rjmp end_Check_each_cost
check_cost5:
	cpi temp,5
	brne check_cost6
	load_byte coin_needed,inven_cost_5
	rjmp end_Check_each_cost

check_cost6:
	cpi temp,6
	brne check_cost7
	load_byte coin_needed,inven_cost_6
	rjmp end_Check_each_cost

check_cost7:
	cpi temp,7
	brne check_cost8
	load_byte coin_needed,inven_cost_7
	rjmp end_Check_each_cost

check_cost8:
	cpi temp,8
	brne check_cost9
	load_byte coin_needed,inven_cost_8
	rjmp end_Check_each_cost

check_cost9:
	cpi temp,9
	brne end_Check_each_cost
	load_byte coin_needed,inven_cost_9
	rjmp end_Check_each_cost

end_Check_each_cost:
	pop temp
	out SREG,temp
	pop temp
	ret










dec_each_inventory:
	push temp
	in temp,SREG
	push temp

	/*check inv debug*/
	;ldi temp,0xf0
	;out portc,temp 

	clean_byte choice_is_empty
	load_byte temp,choice
dec_inventory1:
	cpi temp,1
	brne dec_inventory2
	load_byte temp,inven_stock_1
	cpi temp,0
	brne further_dec_inventory1
	rjmp dec_empty
further_dec_inventory1:
	dec_byte inven_stock_1
	load_byte r24,inven_stock_1
	rjmp end_dec_each_inventory
dec_inventory2:
	cpi temp,2
	brne dec_inventory3
	load_byte temp,inven_stock_2
	cpi temp,0
	breq dec_empty
		dec_byte inven_stock_2
	load_byte r24,inven_stock_2
	rjmp end_dec_each_inventory
dec_inventory3:
	cpi temp,3
	brne dec_inventory4
	load_byte temp,inven_stock_3
	cpi temp,0
	breq dec_empty
	dec_byte inven_stock_3
	load_byte r24,inven_stock_3
	rjmp end_dec_each_inventory

dec_inventory4:
	cpi temp,4
	brne dec_inventory5
	
	load_byte temp,inven_stock_4
	cpi temp,0
	breq dec_empty
		dec_byte inven_stock_4
	load_byte r24,inven_stock_4
	rjmp end_dec_each_inventory

dec_inventory5:
	cpi temp,5
	brne dec_inventory6
	load_byte temp,inven_stock_5
	cpi temp,0
	breq dec_empty
	dec_byte inven_stock_5
	load_byte r24,inven_stock_5
	rjmp end_dec_each_inventory
dec_empty:

	rjmp end_dec_each_inventory


dec_inventory6:
	cpi temp,6
	brne dec_inventory7
	
	load_byte temp,inven_stock_6
	cpi temp,0
	breq dec_empty
		dec_byte inven_stock_6
	load_byte r24,inven_stock_6
	rjmp end_dec_each_inventory

dec_inventory7:
	cpi temp,7
	brne dec_inventory8
	load_byte temp,inven_stock_7
	cpi temp,0
	breq dec_empty
		dec_byte inven_stock_7
		load_byte r24,inven_stock_7
	rjmp end_dec_each_inventory
dec_inventory8:
	cpi temp,8
	brne dec_inventory9

	load_byte temp,inven_stock_8
	cpi temp,0
	breq dec_empty
	dec_byte inven_stock_8
	load_byte r24,inven_stock_8
	rjmp end_dec_each_inventory

dec_inventory9:
	cpi temp,9
	brne end_dec_each_inventory
	load_byte temp,inven_stock_9
	cpi temp,0
	breq dec_empty
	dec_byte inven_stock_9
	load_byte r24,inven_stock_9
	rjmp end_dec_each_inventory

end_dec_each_inventory:
	pop temp
	out SREG,temp
	pop temp
	ret



inc_each_inventory:
	push temp
	in temp,SREG
	push temp

	/*check inv debug*/
	;ldi temp,0xf0
	;out portc,temp 

	clean_byte choice_is_empty
	load_byte temp,choice
inc_inventory1:
	cpi temp,1
	brne inc_inventory2
	load_byte temp,inven_stock_1
	cpi temp,10
	brne further_inc_inventory1
	rjmp inc_ten
further_inc_inventory1:
	inc_byte inven_stock_1
	load_byte r24,inven_stock_1
	rjmp end_inc_each_inventory
inc_inventory2:
	cpi temp,2
	brne inc_inventory3
	load_byte temp,inven_stock_2
	cpi temp,10
	breq inc_ten
		inc_byte inven_stock_2
	load_byte r24,inven_stock_2
	rjmp end_inc_each_inventory
inc_inventory3:
	cpi temp,3
	brne inc_inventory4
	load_byte temp,inven_stock_3
	cpi temp,10
	breq inc_ten
	inc_byte inven_stock_3
	load_byte r24,inven_stock_3
	rjmp end_inc_each_inventory

inc_inventory4:
	cpi temp,4
	brne inc_inventory5
	
	load_byte temp,inven_stock_4
	cpi temp,10
	breq inc_ten
		inc_byte inven_stock_4
	load_byte r24,inven_stock_4
	rjmp end_inc_each_inventory

inc_inventory5:
	cpi temp,5
	brne inc_inventory6
	load_byte temp,inven_stock_5
	cpi temp,10
	breq inc_ten
	inc_byte inven_stock_5
	load_byte r24,inven_stock_5
	rjmp end_inc_each_inventory
inc_ten:

	rjmp end_inc_each_inventory


inc_inventory6:
	cpi temp,6
	brne inc_inventory7
	
	load_byte temp,inven_stock_6
	cpi temp,10
	breq inc_ten
		inc_byte inven_stock_6
	load_byte r24,inven_stock_6
	rjmp end_inc_each_inventory

inc_inventory7:
	cpi temp,7
	brne inc_inventory8
	load_byte temp,inven_stock_7
	cpi temp,10
	breq inc_ten
		inc_byte inven_stock_7
		load_byte r24,inven_stock_7
	rjmp end_inc_each_inventory
inc_inventory8:
	cpi temp,8
	brne inc_inventory9

	load_byte temp,inven_stock_8
	cpi temp,10
	breq inc_ten
	inc_byte inven_stock_8
	load_byte r24,inven_stock_8
	rjmp end_inc_each_inventory

inc_inventory9:
	cpi temp,9
	brne end_inc_each_inventory
	load_byte temp,inven_stock_9
	cpi temp,10
	breq inc_ten
	inc_byte inven_stock_9
	load_byte r24,inven_stock_9
	rjmp end_inc_each_inventory

end_inc_each_inventory:
	pop temp
	out SREG,temp
	pop temp
	ret

	;-------------------------------


	
inc_each_cost:
	push temp
	in temp,SREG
	push temp

	

	load_byte temp,choice
inc_cost1:
	cpi temp,1
	brne inc_cost2
	load_byte temp,inven_cost_1
	cpi temp,3
	brne further_inc_cost1
	rjmp inc_cost_three
further_inc_cost1:
	inc_byte inven_cost_1
	load_byte coin_needed,inven_cost_1
	rjmp end_inc_each_cost
inc_cost2:
	cpi temp,2
	brne inc_cost3
	load_byte temp,inven_cost_2
	cpi temp,3
	breq inc_cost_three
		inc_byte inven_cost_2
	load_byte coin_needed,inven_cost_2
	rjmp end_inc_each_cost
jmp_to_inc_end:
	rjmp end_inc_each_cost
inc_cost3:
	cpi temp,3
	brne inc_cost4
	load_byte temp,inven_cost_3
	cpi temp,3
	breq inc_cost_three
	inc_byte inven_cost_3
	load_byte coin_needed,inven_cost_3
	rjmp end_inc_each_cost
inc_cost4:
	cpi temp,4
	brne inc_cost5
	
	load_byte temp,inven_cost_4
	cpi temp,3
	breq inc_cost_three
		inc_byte inven_cost_4
	load_byte coin_needed,inven_cost_4
	rjmp end_inc_each_cost

inc_cost5:
	cpi temp,5
	brne inc_cost6
	load_byte temp,inven_cost_5
	cpi temp,3
	breq inc_cost_three
	inc_byte inven_cost_5
	load_byte coin_needed,inven_cost_5
	rjmp end_inc_each_cost
inc_cost_three:

	rjmp end_inc_each_cost


inc_cost6:
	cpi temp,6
	brne inc_cost7
	
	load_byte temp,inven_cost_6
	cpi temp,3
	breq inc_cost_three
		inc_byte inven_cost_6
	load_byte coin_needed,inven_cost_6
	rjmp end_inc_each_cost

inc_cost7:
	cpi temp,7
	brne inc_cost8
	load_byte temp,inven_cost_7
	cpi temp,3
	breq inc_cost_three
		inc_byte inven_cost_7
		load_byte coin_needed,inven_cost_7
	rjmp end_inc_each_cost
inc_cost8:
	cpi temp,8
	brne inc_cost9

	load_byte temp,inven_cost_8
	cpi temp,3
	breq inc_cost_three
	inc_byte inven_cost_8
	load_byte coin_needed,inven_cost_8
	rjmp end_inc_each_cost

inc_cost9:
	cpi temp,9
	brne end_inc_each_cost
	load_byte temp,inven_cost_9
	cpi temp,3
	breq inc_cost_three
	inc_byte inven_cost_9
	load_byte coin_needed,inven_cost_9
	rjmp end_inc_each_cost

end_inc_each_cost:
	pop temp
	out SREG,temp
	pop temp
	ret


//-------------------------------------------


	
dec_each_cost:
	push temp
	in temp,SREG
	push temp

	

	load_byte temp,choice
dec_cost1:
	cpi temp,1
	brne dec_cost2
	load_byte temp,inven_cost_1
	cpi temp,254
	brne further_dec_cost1
	rjmp dec_cost_three
further_dec_cost1:
	dec_byte inven_cost_1
	load_byte coin_needed,inven_cost_1
	rjmp end_dec_each_cost
dec_cost2:
	cpi temp,2
	brne dec_cost3
	load_byte temp,inven_cost_2
	cpi temp,254
	breq dec_cost_three
		dec_byte inven_cost_2
	load_byte coin_needed,inven_cost_2
	rjmp end_dec_each_cost
jmp_to_dec_end:
	rjmp end_dec_each_cost
dec_cost3:
	cpi temp,254
	brne dec_cost4
	load_byte temp,inven_cost_3
	cpi temp,254
	breq dec_cost_three
	dec_byte inven_cost_3
	load_byte coin_needed,inven_cost_3
	rjmp end_dec_each_cost
dec_cost4:
	cpi temp,4
	brne dec_cost5
	
	load_byte temp,inven_cost_4
	cpi temp,254
	breq dec_cost_three
		dec_byte inven_cost_4
	load_byte coin_needed,inven_cost_4
	rjmp end_dec_each_cost

dec_cost5:
	cpi temp,5
	brne dec_cost6
	load_byte temp,inven_cost_5
	cpi temp,254
	breq dec_cost_three
	dec_byte inven_cost_5
	load_byte coin_needed,inven_cost_5
	rjmp end_dec_each_cost
dec_cost_three:

	rjmp end_dec_each_cost


dec_cost6:
	cpi temp,6
	brne dec_cost7
	
	load_byte temp,inven_cost_6
	cpi temp,254
	breq dec_cost_three
		dec_byte inven_cost_6
	load_byte coin_needed,inven_cost_6
	rjmp end_dec_each_cost

dec_cost7:
	cpi temp,7
	brne dec_cost8
	load_byte temp,inven_cost_7
	cpi temp,254
	breq dec_cost_three
		dec_byte inven_cost_7
		load_byte coin_needed,inven_cost_7
	rjmp end_dec_each_cost
dec_cost8:
	cpi temp,8
	brne dec_cost9

	load_byte temp,inven_cost_8
	cpi temp,254
	breq dec_cost_three
	dec_byte inven_cost_8
	load_byte coin_needed,inven_cost_8
	rjmp end_dec_each_cost

dec_cost9:
	cpi temp,9
	brne end_dec_each_cost
	load_byte temp,inven_cost_9
	cpi temp,254
	breq dec_cost_three
	dec_byte inven_cost_9
	load_byte coin_needed,inven_cost_9
	rjmp end_dec_each_cost

end_dec_each_cost:
	pop temp
	out SREG,temp
	pop temp
	ret


//-------------------------------------------




clear_each_inventory:
	push temp
	in temp,SREG
	push temp

	/*check inv debug*/
	;ldi temp,0xf0
	;out portc,temp 

	clean_byte choice_is_empty
	load_byte temp,choice
clear_inventory1:
	cpi temp,1
	brne clear_inventory2
	load_byte temp,inven_stock_1
	cpi temp,0
	brne further_clear_inventory1
	rjmp clear_empty
further_clear_inventory1:
	clean_byte inven_stock_1
	load_byte r24,inven_stock_1
	rjmp end_clear_each_inventory
clear_inventory2:
	cpi temp,2
	brne clear_inventory3
	load_byte temp,inven_stock_2
	cpi temp,0
	breq clear_empty
		clean_byte inven_stock_2
	load_byte r24,inven_stock_2
	rjmp end_clear_each_inventory
clear_inventory3:
	cpi temp,3
	brne clear_inventory4
	load_byte temp,inven_stock_3
	cpi temp,0
	breq clear_empty
	clean_byte inven_stock_3
	load_byte r24,inven_stock_3
	rjmp end_clear_each_inventory

clear_inventory4:
	cpi temp,4
	brne clear_inventory5
	
	load_byte temp,inven_stock_4
	cpi temp,0
	breq clear_empty
	clean_byte inven_stock_4
	load_byte r24,inven_stock_4
	rjmp end_clear_each_inventory

clear_inventory5:
	cpi temp,5
	brne clear_inventory6
	load_byte temp,inven_stock_5
	cpi temp,0
	breq clear_empty
	clean_byte inven_stock_5
	load_byte r24,inven_stock_5
	rjmp end_clear_each_inventory
clear_empty:

	rjmp end_clear_each_inventory


clear_inventory6:
	cpi temp,6
	brne clear_inventory7
	
	load_byte temp,inven_stock_6
	cpi temp,0
	breq clear_empty
		clean_byte inven_stock_6
	load_byte r24,inven_stock_6
	rjmp end_clear_each_inventory

clear_inventory7:
	cpi temp,7
	brne clear_inventory8
	load_byte temp,inven_stock_7
	cpi temp,0
	breq clear_empty
		clean_byte inven_stock_7
		load_byte r24,inven_stock_7
	rjmp end_clear_each_inventory
clear_inventory8:
	cpi temp,8
	brne clear_inventory9

	load_byte temp,inven_stock_8
	cpi temp,0
	breq clear_empty
	clean_byte inven_stock_8
	load_byte r24,inven_stock_8
	rjmp end_clear_each_inventory

clear_inventory9:
	cpi temp,9
	brne end_clear_each_inventory
	load_byte temp,inven_stock_9
	cpi temp,0
	breq clear_empty
	clean_byte inven_stock_9
	load_byte r24,inven_stock_9
	rjmp end_clear_each_inventory

end_clear_each_inventory:
	pop temp
	out SREG,temp
	pop temp
	ret






//------------------------------------------
run_coin:
	in temp,SREG
	push temp

	load_byte temp,at_insert_screen
	cpi temp,1
	brne end_run
	;ldi temp,0xff
	;out portc,temp
	clr TEMP2
	LDS TEMP,ADCL
	cpi temp,0x0A
	LDS temp,ADCH
	cpc temp,TEMP2
	brlo printlow_1
	
	
	ldi temp,0x03
	mov temp2,temp
	LDS temp,ADCL
	cpi temp,0xff
	LDS temp,ADCH
	cpc temp,temp2
	brsh printhigh1
	;ldi temp,0
	;out portc,temp
	rjmp end_run

printlow_1:
	load_byte temp,first_high
	cpi temp,1
	breq printlow_2
	;ldi temp,1
	;OUT PORTC,temp
	;ldi r18,1;min flag
	set_byte first_low
	rjmp end_run 
printhigh1:
	load_byte temp,first_low
	cpi temp,1
	brne end_run
	;ldi temp,0xff
	;OUT PORTC,temp
	set_byte first_high
	;ldi r19,1;high flag
	rjmp end_run 
printlow_2:
	load_byte temp,first_high
	cpi temp,1
	brne end_run
	;ldi temp,0x0f
	;OUT PORTC,temp
	inc coin_inserted
	lsl coin_display
	inc coin_display
	dec coin_needed
	
	clean_byte first_low
	clean_byte first_high
end_run:	

	pop temp
	out SREG,TEMP
	RETI



push_button0:	
	in temp,SREG
	push temp

	load_byte temp,pb0_pressed
	cpi temp,1
	breq end_push_button0
	load_byte temp,at_empty_screen
	cpi temp,1
	brne pb_dec0
	ldi display_counter,11
	ldi temp,0
	out portc,temp
	set_byte pb0_pressed
pb_dec0:
	load_byte temp,at_admin_screen
	cpi temp,1
	brne end_push_button1
	rcall inc_each_inventory
	clean_byte admin_shown
	rcall show_admin_screen
	set_byte pb0_pressed
end_push_button0:
	pop temp
	out SREG,TEMP
	RETI

push_button1:	
	in temp,SREG
	push temp

	load_byte temp,pb1_pressed
	cpi temp,1
	breq end_push_button1

	load_byte temp,at_empty_screen
	cpi temp,1
	brne pb_dec1
	ldi display_counter,11
	ldi temp,0
	out portc,temp
	set_byte pb1_pressed
pb_dec1:
	load_byte temp,at_admin_screen
	cpi temp,1
	brne end_push_button1
	rcall dec_each_inventory
	clean_byte admin_shown
	rcall show_admin_screen
	set_byte pb1_pressed
end_push_button1:
	pop temp
	out SREG,TEMP
	RETI
	





