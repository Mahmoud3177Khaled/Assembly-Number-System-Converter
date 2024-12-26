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
    # Assume the number to validate is in $a0
    # Check if number < 1
    li $t0, 1          # Load 1 into $t0
    blt $a0, $t0, invalid  # If number < 1, jump to invalid

    # Check if number > 10
    li $t1, 10         # Load 10 into $t1
    bgt $a0, $t1, invalid  # If number > 10, jump to invalid

    li $v0, 1          # Return 1 (valid)
    jr $ra             # Return from function

invalid:
    li $v0, 0          # Return 0 (invalid)
    jr $ra             # Return from function