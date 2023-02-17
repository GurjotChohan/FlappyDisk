###############################################################################
# File Name: gameproject2.asm
# author: Gurjot Chohan
# NetID: GKC200000
# Date created: Nov 1 2022
# Purpose: The porgram is a version of flappy bird that use a disk insted. it follows
# the same rules as flappy bird. as there are column like obstacles that the disk
# goes through. 
#################################################################################

# width of screen in pixels
.eqv	WIDTH		64
# height of screen in pixels
.eqv	HEIGHT		64
.data
	

colors:	.word	0xff71ce, 0x01cdfe, 0X05ffa1, 0xb967ff, 0xfffb96

randomnums: 20, 50, 30
	

.text 
 main:
	
 	addi $s4, $zero, 10 		#Set location for the disk object
 	addi $s6, $zero, 32
 	
 	li $a2, 0XEDC3CD 		#Set the color for the columns and disk
 	jal	draw_obj		#Draw the object
	jal	draw_background		#Draw the background

opening:	
	jal 	openingScreen		#Draw the opening screen
	
	lw $t0, 0xffff0000 		#t1 holds if input available
	beq  $t0, 0, opening		#Check if the register has an input 
	
	jal animation			#Display the animation which erases everything
	
loop:

	li	$a2, 0			#Load the color black to erase the following objects
	jal	draw_obj		#Erase disk
	jal	draw_background        #Erase columns

	
	li $a1, -1			#set the column height pointer to the very top
	li $a2, 0XEDC3CD		#Fill in a color
	addi $s6, $s6, 2		# Shift the disk pointer two down
	
	jal	draw_obj     		#Draw the disk object
	addi	$a0, $a0, -2		
	bge $a0, 0, jump8		#Check if the column pointer is in the deadzone (outside 0 to 64)

	addi $a0, $a0, 64 		#If so reset it back
	
jump8:
	jal	draw_background		#Draw the columns
	
	jal pause
	lw $t0, 0xffff0000  #t1 holds if input available
	beq  $t0, 0, loop  #Check if the register has an input 
	
checkinput:
	lw 	$s1, 	0xffff0004 	#check the input
	beq	$s1, 32, up		# input space
	beq	$s1, 113, exit		# input E
	#invalid input, ignore
	j	loop			# jump back to the loop
	
up:	
	li	$a2, 0			# Erase the obj 
	jal	draw_obj		#Shift the pointer up 4
	addi $s6, $s6, -4		
	j	loop			# Jump back to the loop

# exit call
exit:	
	jal goodbyescreen 		#Print the goodbye screen

	li	$v0, 10
	syscall
	
	
#################################################
# subroutine  for the ending screen
	
goodbyescreen:
	# save the $ra
	addi 	$sp, 	$sp, 	-4
	sw	$ra, 	($sp)
	addi $s1, $a2, 0
	
	jal animation #call the animation function
	jal openingScreen # call the operinfscreen funtion

	
	# restore the $ra
	lw 	$ra, 	($sp)
	addi 	$sp, 	$sp, 	4
	jr 	$ra

#################################################
# subroutine to clear everything from the screen

animation: 
	#save $ra
	addi 	$sp, 	$sp, 	-4
	sw	$ra, 	($sp)
	addi $s1, $a2, 0
	
	# save #a0, $1
	add $t4, $zero, $a0
	add $t5, $zero, $a1
	
	li $a0, 0 
	li $a1, 0

	lw $s0, colors
	li 	$t8,	0 				# j==0
	li 	$t2,  	4096 				# length limit of each side 

	
jumpback: 	
	beq 	$t2, 	$t8, 	exitloop  			# check if the j is equal to 4096
	li 	$a2, 	 0				# load the color into $a2
	jal 	draw_pixel 				# call the draw pixel function					# pause to make it more viewable
	addi 	$a0, 	$a0, 1  			# add 1 to the X so that the next adresse points to the pixel to the south			# add 4 to the colors array to point to the next color
	addi 	$t8, 	$t8, 1 				# add 1 to t5 to keep count of number of repeatations
	j 	jumpback
	
exitloop:
	# restore #a0, $1
	add $a0, $zero, $t4
	add $a1, $zero, $t5 
	
	# restore $ra
	lw 	$ra, 	($sp)
	addi 	$sp, 	$sp, 	4
	jr 	$ra
	
	
#################################################
# subroutine to draw a pixel
# $a0 = X
# $a1 = Y
# $a2 = color
draw_pixel:
	# s1 = address = MEM + 4*(x + y*width)

	mul	$t9,	$a1,	WIDTH   			# y * WIDTH
	add	$t9,	$t9,	$a0	  			# add X
	mul	$t9,	$t9, 	4	  			# multiply by 4 to get word offset
	add	$t9,	$t9, 	$gp	  			# add to base address
	sw	$a2,	0($t9)	  				# store color at memory location
	jr 	$ra
	
#################################################
# subroutine to draw the obj

draw_obj:
	addi 	$sp, 	$sp, 	-4
	sw	$ra, 	($sp)
	addi $s1, $a2, 0
	# save #a0, $1
	add $t4, $zero, $a0
	add $t5, $zero, $a1

	# laod the saved values
	add $a0, $s4, $zero 
	add $a1, $s6, $zero 
	
	# draw the disk
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	
	## update the disk location
	add $s4, $a0, $zero 
	add $s6, $a1, $zero 
	
	# restore $a0, $a1
	add $a0, $zero, $t4
	add $a1, $zero, $t5 
	
	# resore $ra
	lw 	$ra, 	($sp)
	addi 	$sp, 	$sp, 	4
	jr 	$ra
	
	

#################################################
# subroutine to draw the background
# $a0 = width
# $a1 = height
# $a2 = color
# some other save register beacuse i ran out of the paramters registers	
draw_background:
	#Stored the registers that need to be saved on the stack

	addi 	$sp, 	$sp, 	-4
	sw	$ra, 	($sp)
	addi $s1, $a2, 0
	
	
	li $a1, -1			#Set the height to 0
	
	add $t7, $a0, $zero		#Store the width value in a temp register

    	
	addi $a0, $a0, 20		#Add 20 to the $a0 value this is to create space between the columns
	li $a1, -1
	
	
	# Set the temp registers to zero since they might have been used before
	li $t0, 0
	li $t6, 0
	li $t2, 0
	li $t1, 0
	li $t4, 0
	li $t5, 0
	
	#Load the location of the random num array into the a register
	lw $s7, randomnums
	

	
	beq $t5, 3, redraw
	li $t5, 2
redraw:
	addi $a2, $s1, 0		#Add the color in to the $a2 register
	
	beq $s3, 0, updatecolelse	#Check if there is space for another column to be added 
	li $t5, 3 			#If so change the number of columns from 2 to 3
	
updatecolelse:	
	bge  $a0, 0, checkbounds	#Check to make sure that the $a0 value is in bound
	addi $a0, $a0, 63		#if not set the value to 63
	li $a1, -1
	
#Add the opening in the column by changing the color to black 
#if the current $a1 matches that of the one in the ransom array
#If the space if added jump the collision section

checkbounds:	
	ble $t0, $s7, addspace
	addi $s5, $s7, 20
	bge $t0, $s5,addspace
	li $a2, 0	
	j collision
#— collision section–
# Check if the current $a0, and $a1
# are equal to any of the points of the disk if so exit 
# the program cause a collision is detected 

addspace:
	addi $t8, $a0, -64
	ble $t8, $s4, collision
	addi $t3, $s4, 3 
	bge    $t8, $t3, collision
	beq   $t0, $s6, exit
	addi $t8, $s6,  -1	
	beq   $t0, $t8,  exit
#– end of collision check– 
collision:	
	li $t6, 64 #Load the max length of the column
	addi $t0, $t0, 1 #Set a temp register as a counter
	addi	$a1, 	$a1,	1 #Update the $a1 value
	jal draw_pixel #Draw the pixel
	bne  $t6, $t0, redraw #Most inner loop (draws the pixel)
	
	li $a1, -1 
	addi	$a1, 	$a1,	1
	jal draw_pixel
	li $a1, -1 
	li $t0, 0  # reset he counter varaible
	li $t1 , 7 #Set the number of lines for a column to 7 
	addi $t2 , $t2, 1 # counter
	addi	$a0, $a0, 1 # update the x value
	bne  $t2, $t1, redraw #Next most inner loop (counts the number of lines that make up one column)
	
	li $t2, 0 # reset he counter varaible
	
	
	addi 	$s7, 	$s7, 	4 # change the width of the obstacle
	addi $a0, $a0, 15 # add apce between col
	li $a1, -1
	addi $t4 , $t4, 1 # update counter
	
	# Check for space for another column if so set a boolean to yes (used at the top)

	addi $s2, $a0, 30 
	bne  $s2, 128, setboollen
	addi $s3, $zero, 1
	
setboollen:
	bne  $t4, $t5, redraw #Outermost loop (number of columns)
	
	
	add $a0, $t7, $zero
	

	#restore the $ra
	lw 	$ra, 	($sp)
	addi 	$sp, 	$sp, 	4
	jr 	$ra
	
	
#################################################
# subroutine to waste some time
# $a0 = amount of pause time	
pause: 
	#save $ra
	addi 	$sp, 	$sp, 	-8
	sw	$ra, 	($sp)
	sw 	$a0, 	4($sp)
	
	li 	$v0, 	32					# syscall value for pause
	li 	$a0, 	500					# pause of 5 ms
	syscall
	
	# restore $ra
	lw 	$ra, 	($sp)
	lw 	$a0, 	4($sp)
	addi 	$sp, 	$sp, 	8
	jr 	$ra
	
#################################################
# subroutine to draw a the opening screen
# $a0 = X
# $a1 = Y
# $a2 = color
openingScreen:
	# save $ra and other registers
	addi 	$sp, 	$sp, 	-4
	sw	$ra, 	($sp)
	addi $s1, $a2, 0
	
	add $t4, $zero, $a0
	add $t5, $zero, $a1

	add $a0, $s4, $zero 
	add $a1, $s6, $zero 

	 
	 
	li $a0, 15
	li $a1, 20
	
	li $a2, 0x00ccff
	

	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel

	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel

	
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	

	addi $a1, $a1, 2
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	
	li $a2, 0x00ffF0
	addi $a0, $a0, 5
	addi $a1, $a1, 3
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel

	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	
	
	
	
	li $a2, 0x00ff00
	
	addi $a0, $a0, 2
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0,$a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0,$a0, -1
	jal draw_pixel
	addi $a0,$a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0,$a0, -1
	jal draw_pixel
	addi $a0,$a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0,$a0, -1
	jal draw_pixel
	addi $a0,$a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0,$a0, -1
	jal draw_pixel
	addi $a0,$a0, 2
	addi $a1,$a1, -1
	jal draw_pixel
	addi $a0,$a0, 1
	jal draw_pixel
	addi $a1,$a1, -1
	jal draw_pixel
	addi $a0,$a0, -1
	jal draw_pixel
	addi $a0, $a0, 2
	addi $a1, $a1, 2
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	addi $a1, $a1, -2
	addi $a0, $a0, -2
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	li $a2, 0xf0fff0
	
	addi $a1, $a1, 2
	addi $a0, $a0, 6
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	addi $a0, $a0, 1
	
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	li $a2, 0xffff00
	
	addi $a0, $a0, 3
	addi $a1, $a1, 2
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	addi $a0, $a0, 1
	
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	li $a2, 0x8e02f9
	
	addi $a0, $a0, 3
	addi $a1, $a1, -4
	
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel 
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel  
	
	addi $a0, $a0, 1
	addi $a1, $a1, -6
	
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	addi $a1, $a1, 10
	addi $a0, $a0, -35
	
	
	li $a2, 0x00ff00
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel

	addi $a0, $a0, -2
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	
	
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	
	li $a2, 0x00fff0
	addi $a0, $a0, 8
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	
	addi $a1, $a1, 2
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	
	
	li $a2, 0xffff0f
	addi $a0, $a0, 9
	addi $a1, $a1, -6
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1

	
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel

	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, 1
	jal draw_pixel
	
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	addi $a1, $a1, 1
	
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	
	addi $a0, $a0, -2
	addi $a1, $a1, -3
	jal draw_pixel
	
	addi $a1, $a1, 1
	addi $a0, $a0, 1
	jal draw_pixel
	
	addi $a1, $a1, -1
	jal draw_pixel
	
	li $a2, 0xffffff
	addi $a1, $a1, 3
	addi $a0, $a0, 4
	jal draw_pixel
	
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	jal draw_pixel
	
	addi $a0, $a0, 2
	addi $a1, $a1, 4
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal draw_pixel
	
	
	addi $a0, $a0, -4
	addi $a1, $a1, -4
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal draw_pixel
	addi $a0, $a0, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal draw_pixel
	
	# restore $ra and other registers
	add $a0, $zero, $t4
	add $a1, $zero, $t5 
	
	
	lw 	$ra, 	($sp)
	addi 	$sp, 	$sp, 	4
	jr 	$ra
