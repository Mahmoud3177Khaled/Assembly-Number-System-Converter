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
		
		# Validate the number based on the current base
		lw $a0, base_to_decimal  # Load the base into $a0
		la $a1, number_to_decimal # Load the address of the number string into $a1
		jal validate_number        # Call the validation function

		# Check the result of validation
		beqz $v0, invalid_input    # If validation fails, jump to invalid_input
		
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
	
	invalid_input:
		# Handle invalid input case
		li $v0, 4
		la $a0, prompt_num_test
		syscall
		# Print error message or handle accordingly
		li $v0, 10
		syscall
	
	# Subroutine: validate_number
	# Parameters:
	#   $a0 = base
	#   $a1 = address of the number string
	# Returns:
	#   $v0 = 1 if valid, 0 if invalid
	validate_number:
		li $t0, 0              # Initialize valid digit counter
		li $t2, 0              # Initialize current character

	validate_loop:
		lb $t2, 0($a1)         # Load byte from input string
		beqz $t2, end_validate  # If null terminator, end loop

		# Convert character to numeric value
		blt $t2, '0', invalid   # Invalid if less than '0'
		li $t3, '9'
		ble $t2, $t3, convert_digit # If '0'-'9', convert to number

		# Handle uppercase letters 'A'-'F'
		li $t4, 'A'
		li $t5, 'F'
		bge $t2, $t4            # If character >= 'A', check next condition
		ble $t2, $t5, convert_alpha # If 'A'-'F', convert to number

		# Handle lowercase letters 'a'-'f' (if needed)
		li $t4, 'a'
		li $t5, 'f'
		bge $t2, $t4            # If character >= 'a', check next condition
		ble $t2, $t5, convert_alpha_lower # If 'a'-'f', convert to number

		j invalid                # Otherwise, invalid character

	convert_digit:
		sub $t6, $t2, '0'       # Convert '0'-'9' to numeric value
		j validate_base          # Jump to validate_base

	convert_alpha:
		sub $t6, $t2, 'A'       # Convert 'A'-'F' to numeric value (10-15)
		addi $t6, $t6, 10       # Adjust value to be in the range 10-15
		j validate_base          # Jump to validate_base

	convert_alpha_lower:
		sub $t6, $t2, 'a'       # Convert 'a'-'f' to numeric value (10-15)
		addi $t6, $t6, 10       # Adjust value to be in the range 10-15

	validate_base:
		blt $t6, $a0, next_char # Valid if numeric value < base
		j invalid                # Otherwise, invalid character

	next_char:
		addi $t0, $t0, 1        # Increment valid digit counter
		addi $a1, $a1, 1        # Move to next character
		j validate_loop          # Repeat the loop for the next character

	invalid:
		li $v0, 0                # Set return value to 0 (invalid number)
		j end_validate            # Return from the function

	end_validate:
		bgtz $t0, valid          # If digit counter > 0, valid
		li $v0, 0                # Otherwise, set return value to 0 (invalid)
		j end_validate            # Return from the function

	valid:
		li $v0, 1                # Set return value to 1 (valid number)
		j end_validate            # Return from the function