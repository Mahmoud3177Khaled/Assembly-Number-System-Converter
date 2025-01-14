.data
	prompt_current_system: .asciiz "Enter the current system: "
	prompt_number: .asciiz "Enter the number: "
	prompt_new_system: .asciiz "Enter the new system: "
	output_message: .asciiz "The number in the new system: "
	not_valid_message: .asciiz "Number is invalid"
	error_message: .asciiz "Error: Number doesn't belong to the current system.\n"
	RANGE_NUMBERS: .byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	
	number_to_decimal: .space 50
	base_to_decimal: .word 10
	#current_system: .word 0
	#number: .word 0
	#new_system: .word 0
.text 
	main:
		# 1- read the input
		
		#prompt for current system
    		li $v0, 4
    		la $a0, prompt_current_system
    		syscall

    		# read the base of the number to conver to decimal
		li $v0, 5
		syscall
		# sw $v0, base_to_decimal
		move $s7, $v0                                     # s7 --> old system   DON'T CHANGE VERY DANGEROUS
	
   		#prompt for number
    		li $v0, 4
    		la $a0, prompt_number
    		syscall

    		# read the number to convert to decimal
		li $v0, 8
		la $a0, number_to_decimal
		li $a1, 50
		syscall            
		
	
   		#prompt for new system
    		li $v0, 4
    		la $a0, prompt_new_system
    		syscall

   		#read new system
   		li $v0, 5
    		syscall
    		#sw $v0, new_system
    		move $t8,$v0                       # $t8 --> new system    DON'T CHANGE VERY DANGEROUS

		# 2- validation function call
    		move $a0, $s7
    		la $a1, number_to_decimal
    		jal validate_number

		# 3- otherToDecimal function call
		move $a0, $s7
		la $a1, number_to_decimal
    		jal other_to_decimal_function
    		 
    		 
  		# 4- decimalToOther function call
		
    		move $a0,$t2    #- some output from OtherToDecimal -
    		move $a1, $t8
    		li $s0 , 0 # $s0 --> count number in the stack
		jal decimal_to_other_function
		
		

		# 5- write Output
    		li $v0, 4
    		la $a0, output_message
    		syscall

    		print_loop:
    			beqz $s0 ,exit
    			li $v0, 11
    			lb $a0,0($sp) 
    			syscall
    			
    			addi $sp , $sp ,1
    			addi $s0 , $s0 , -1
    			j print_loop

   		exit:
    		li $v0, 10
    		syscall
    		
    		validate_number:
    		
    			#number to valiate
    			move $t0, $a1
    			# base
			move $t1, $a0
			# char for comparison
			lb $t2, 0($t0)
			
			# number for comparisons
			li $s0, 48
			li $s1, 57
			li $s2, 65
			li $s3, 70
			li $s4, 10
			
			# loop that checks
			subi $t0, $t0, 1
			validate_loop:
				
				#get next char
				addi $t0, $t0, 1
				lb $t2, 0($t0)
				
				# exit condition
				beq $t2, $s4, valid
				
				# number validations
				bge $t2, $s0, check2
				j invalid
				check2:
				ble $t2, $s1, validate_num
				#j invalid
				
				# alpha validations
				bge $t2, $s2, check2alpha
				j invalid
				check2alpha:
				ble $t2, $s3, validate_alpha
				j invalid
				
				# base validation for numbers
				validate_num:
				subi $t2, $t2, 48
				
				bge $t2, $t1, invalid
				j validate_loop
				
				# base validation for alphabet letters
				validate_alpha:
				subi $t2, $t2, 55
				
				bge $t2, $t1, invalid
				j validate_loop
				
			valid:
				# continue app if valid
				jr $ra
				
			invalid:
				
				#error message if invalid
	    			li $v0, 4
    				la $a0, not_valid_message
	    			syscall
	    			
	    			#then end append app 
	    			li $v0, 10
	    			syscall
				
	
	other_to_decimal_function:
		# get the string length
		
		# number start
		la $t0, number_to_decimal
		# counter
		li $t1, 0
		# char for comparison
		lb $t2, 0($t0)
		
		find_length_loop:
			beq $t2, $zero, length_found
			addi $t1, $t1, 1
			addi $t0, $t0, 1
			lb $t2, 0($t0)
			j find_length_loop
			
		length_found:
		subi $t1, $t1, 2   # subt 2 to get last index (jump \0 and account for 0-based)
		#li $v0, 1
		#move $a0, $t1
		#syscall
		
		# start conversion
		
		# adress of first char of number
		move $s0, $a1
		# base
		move $s1, $a0
		# temp char to proccess
		lb $s2, 0($s0)
		# length of num
		move $s3, $t1
		# loop length (s3 + 1)
		move $t6, $s3
		addi $t6, $t6, 1
		# temp location of cuurent char
		move $s4, $s0 
		# x to mult by each time (step: i = i*$t0)
		li $t1, 1
		# sum (TOTAL number in decimal)
		li $t2, 0 
		
		find_in_decimal_loop:
			move $s4, $s0
			beq $t6, $zero, found_in_decimal
			add $s4, $s4, $s3  # add length in s3 to s4 to get address of next char from behind
			lb $s2, 0($s4)     # s2 has first char address
			
			li $t7, 65
			bge $s2, $t7, subt_alpha
			li $t7, 48
			bge $s2, $t7, subt_num
			
			subt_alpha:
			subi $s2, $s2, 55
			#addi $s2, $s2, 10
			j continue
			
			subt_num:
			subi $s2, $s2, 48
			j continue
			
			
			continue: # s2 now has the degit value
			
			mul $s2, $s2, $t1  # mult by base^x    (x is t1)
			add $t2, $t2, $s2  # add digit value
			
			subi $s3, $s3, 1   # get next char from behind
			subi $t6, $t6, 1
			move $s4, $s0      # reset s4 to first char address 
			mul $t1, $t1, $s1  # multi x by base for conversion
		
		j find_in_decimal_loop
		
		
		found_in_decimal:
			jr $ra
				
	
	decimal_to_other_function:
		la $t3,RANGE_NUMBERS # $t3 --> range number array
		move $t4,$a1 #  $t4 --> new system
		move $t5,$a0 #  $t5 --> decimal number		
						
		beging_of_loop:
			beq $t5,0,end_of_loop
			li $t7 ,0
			
		body_of_loop:
			div $t5,$t4  # decimal number / new system
			mflo $t5 # new decimal number
			mfhi $t6 # reminder
			add $t7,$t3,$t6 # adress of range number(reminder)
			lb $t7,0($t7) # the number in number array
			addi $sp , $sp, -1
			sb $t7 , 0($sp) #store the reminder in stack
			addi $s0,$s0, 1 # count number in stack ++
			#li $v0, 11
    			#move $a0,$t7
    			#syscall
			j beging_of_loop
			
		end_of_loop:
			jr $ra	
