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
    		# Assuming validate_number belongs in current system: other function call placeholder
    		# Example usage: jal validate_number (this would be part of the extended implementation)
    		
    		move $a0, $s7
    		la $a1, number_to_decimal
    		jal validate_number
    		
    		beq $v0, $zero, not_valid
    		j valid_number
    		
    		not_valid:
    			li $v0, 4
    			la $a0, not_valid_message
    			syscall
    			
    			li $v0, 10
    			syscall
    		
		valid_number:

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
    # Assume the first input line is the base in $a0
    # Assume the second input line is the address of the number string in $a1

    li $t0, 0              # Initialize valid digit counter
    li $t2, 0              # Initialize current character

loop:
    lb $t2, 0($a1)         # Load byte from input string
    beqz $t2, end_loop     # If null terminator, end loop

    # Convert character to numeric value
    blt $t2, '0', invalid  # Invalid if less than '0'
    li $t3, '9'
    ble $t2, $t3, convert_digit # If '0'-'9', convert to number

    # Handle uppercase letters 'A'-'F'
    li $t4, 'A'
    li $t5, 'F'
    bge $t2, $t4
    ble $t2, $t5, convert_alpha

    # Handle lowercase letters 'a'-'f'
    li $t4, 'a'
    li $t5, 'f'
    bge $t2, $t4
    ble $t2, $t5, convert_alpha_lower

    j invalid              # Otherwise, invalid character

convert_digit:
    sub $t6, $t2, '0'      # Convert '0'-'9' to numeric value
    j validate_base

convert_alpha:
    sub $t6, $t2, 'A'
    addi $t6, $t6, 10      # Convert 'A'-'F' to 10-15
    j validate_base

convert_alpha_lower:
    sub $t6, $t2, 'a'
    addi $t6, $t6, 10      # Convert 'a'-'f' to 10-15

validate_base:
    blt $t6, $a0, next_char # Valid if numeric value < base
    j invalid               # Otherwise, invalid character

next_char:
    addi $t0, $t0, 1        # Increment valid digit counter
    addi $a1, $a1, 1        # Move to next character
    j loop

invalid:
    li $v0, 0               # Return 0 for invalid number
    jr $ra

end_loop:
    bgtz $t0, valid         # If digit counter > 0, valid
    li $v0, 0               # Otherwise, invalid
    jr $ra

valid:
    li $v0, 1               # Return 1 for valid number
    jr $ra

	
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
