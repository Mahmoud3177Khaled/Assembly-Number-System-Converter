.data
	prompt_num: .asciiz "Please enter number: "
	prompt_base: .asciiz "Please enter system: "
	prompt_base_test: .asciiz "base: "
	prompt_num_test: .asciiz "Number in base: "
	prompt_num_decimal: .asciiz "Number in Base 10: "
	#newLine
	number_to_decimal: .space 50
	base_to_decimal: .word 10

.text
	
	Other_To_Decimal_function:		
		
		# read num_to_decimal prompt
		li $v0, 4
		la $a0, prompt_base
		syscall
		
		# read the base of the number to conver to decimal
		li $v0, 5
		syscall
		sw $v0, base_to_decimal
		
		
		# read base_to_decimal prompt
		li $v0, 4
		la $a0, prompt_num
		syscall
		
		# read the number to convert to decimal
		li $v0, 8
		la $a0, number_to_decimal
		li $a1, 50
		syscall
		
		
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
		la $s0, number_to_decimal
		# base
		lw $s1, base_to_decimal
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
		
		# test
		li $v0, 4
		la $a0, prompt_base_test
		syscall
		
		li $v0, 1
		lw $a0, base_to_decimal
		syscall
		
		
		li $v0, 4
		la $a0, prompt_num_test
		syscall
		
		li $v0, 4
		la $a0, number_to_decimal
		syscall
		
		
		li $v0, 4
		la $a0, prompt_num_decimal
		syscall
		
		li $v0, 1
		move $a0, $t2
		syscall
		
		li $v0, 10
		syscall
	
	validate_number:
		# Assume the first input line is the base in $a0
		# Assume the second input line is the address of the number string in $a1

		li $t0, 0              # Initialize valid digit counter to 0
		li $t2, 0              # Initialize current character variable

	loop:
		lb $t2, 0($a1)         # Load the next byte (character) from the input string
		beqz $t2, end_loop     # If null terminator (end of string), jump to end_loop

		# Convert character to numeric value
		blt $t2, '0', invalid  # If character is less than '0', it's invalid
		li $t3, '9'            # Load ASCII value of '9' into $t3
		ble $t2, $t3, convert_digit # If character is between '0' and '9', convert it to a number

		# Handle uppercase letters 'A'-'F'
		li $t4, 'A'            # Load ASCII value of 'A' into $t4
		li $t5, 'F'            # Load ASCII value of 'F' into $t5
		bge $t2, $t4           # If character is greater than or equal to 'A', check next condition
		ble $t2, $t5, convert_alpha # If character is between 'A' and 'F', convert it to a number

		# Handle lowercase letters 'a'-'f'
		li $t4, 'a'            # Load ASCII value of 'a' into $t4
		li $t5, 'f'            # Load ASCII value of 'f' into $t5
		bge $t2, $t4           # If character is greater than or equal to 'a', check next condition
		ble $t2, $t5, convert_alpha_lower # If character is between 'a' and 'f', convert it to a number

		j invalid               # If character is not valid, jump to invalid label

	convert_digit:
		sub $t6, $t2, '0'      # Convert ASCII character '0'-'9' to its numeric value (0-9)
		j validate_base         # Jump to validate_base to check if it's valid for the base

	convert_alpha:
		sub $t6, $t2, 'A'      # Convert ASCII character 'A'-'F' to its numeric value (10-15)
		addi $t6, $t6, 10      # Adjust value to be in the range 10-15
		j validate_base         # Jump to validate_base to check if it's valid for the base

	convert_alpha_lower:
		sub $t6, $t2, 'a'      # Convert ASCII character 'a'-'f' to its numeric value (10-15)
		addi $t6, $t6, 10      # Adjust value to be in the range 10-15

	validate_base:
		blt $t6, $a0, next_char # If numeric value is less than the base, it's valid
		j invalid               # Otherwise, jump to invalid label

	next_char:
		addi $t0, $t0, 1        # Increment valid digit counter
		addi $a1, $a1, 1        # Move to the next character in the input string
		j loop                   # Repeat the loop for the next character

	invalid:
		li $v0, 0               # Set return value to 0 (invalid number)
		jr $ra                   # Return from the function

	end_loop:
		bgtz $t0, valid         # If valid digit counter > 0, jump to valid
		li $v0, 0               # Otherwise, set return value to 0 (invalid)
		jr $ra                   # Return from the function

	valid:
		li $v0, 1               # Set return value to 1 (valid number)
		jr $ra                   # Return from the function