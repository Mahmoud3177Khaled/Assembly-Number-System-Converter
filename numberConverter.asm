.data
	prompt_current_system: .asciiz "Enter the current system: "
	prompt_number: .asciiz "Enter the number: "
	prompt_new_system: .asciiz "Enter the new system: "
	output_message: .asciiz "The number in the new system: "
	error_message: .asciiz "Error: Number doesn't belong to the current system.\n"
	RANGE_NUMBERS: .byte '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
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

    		#read current system
    		li $v0, 5
    		syscall
    		#sw $v0, current_system
		move $t0,$v0            # $t0 --> cureent system 
	
   		#prompt for number
    		li $v0, 4
    		la $a0, prompt_number
    		syscall

    		#read number
    		li $v0, 5
    		syscall
    		#sw $v0, number
		move $t1,$v0            # $t1 --> number 
		
	
   		#prompt for new system
    		li $v0, 4
    		la $a0, prompt_new_system
    		syscall

   		#read new system
   		li $v0, 5
    		syscall
    		#sw $v0, new_system
    		move $t2,$v0            # $t2 --> new system 

		# 2- validation function call
    		# Assuming validate_number belongs in current system: other function call placeholder
    		# Example usage: jal validate_number (this would be part of the extended implementation)

		# 3- otherToDecimal function call

		# Convert other to decimal: call OtherToDecimal function
    		# Example: 
    		# lw $a0, number
    		# lw $a1, current_system
    		# jal OtherToDecimal
  
  		# 4- decimalToOther function call
		
    		move $a0,$t1    #- some output from OtherToDecimal -
    		move $a1, $t2
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
