.data
    ADDR_DISPLAY: .word 0x10008000
    ADDR_KBRD: .word 0xffff0000
    DISPLAY_WIDTH: .word 17
    DISPLAY_HEIGHT: .word 17
    WHITE_COLOUR: .word 0xFFFFFF
    BLACK_COLOUR: .word 0x000000
    BLUE_COLOUR: .word 0x0000FF # let blue be x/1
    RED_COLOUR: .word 0xFF0000 # let red be o/2
    STATE_ARRAY: .word 0:9 # let 1 be x, o be 2 
    CURRENT_CELL: .word 0
    
    WINNER_X_MSG: .asciiz "Player X has won!"
    WINNER_O_MSG: .asciiz "Player O has won!"
    WINNER_TIE_MSG: .asciiz "Game ended in a tie!"
# let s1 be the current turn

    .macro func (%instruction)
        addi $sp, $sp, -60
        sw $t0, 0($sp)
        sw $t1, 4($sp)
        sw $t2, 8($sp)
        sw $t3, 12($sp)
        sw $t4, 16($sp)
        sw $t5, 20($sp)
        sw $t6, 24($sp)
        sw $t7, 28($sp)
        sw $t8, 32($sp)
        sw $t9, 36($sp)
        sw $a0, 40($sp)
        sw $a1, 44($sp)
        sw $a2, 48($sp)
        sw $a3, 52($sp)
        sw $ra, 56($sp)
        jal %instruction
        lw $t0, 0($sp)
        lw $t1, 4($sp)
        lw $t2, 8($sp)
        lw $t3, 12($sp)
        lw $t4, 16($sp)
        lw $t5, 20($sp)
        lw $t6, 24($sp)
        lw $t7, 28($sp)
        lw $t8, 32($sp)
        lw $t9, 36($sp)
        lw $a0, 40($sp)
        lw $a1, 44($sp)
        lw $a2, 48($sp)
        lw $a3, 52($sp)
        lw $ra, 56($sp)
        addi $sp, $sp, 60
    .end_macro
    
    .text
	.globl main
main:
    lw $s0, ADDR_DISPLAY
    lw $s1, BLACK_COLOUR
    lw $s2, WHITE_COLOUR
    
    li $t0, 0
    lw $t1, DISPLAY_HEIGHT
    lw $t3, DISPLAY_WIDTH
    li $s1, 1
    
    fill_display_outer:
        li $t2, 0
        fill_display_inner:
            sll $t4, $t2, 2
            
            mul $t5, $t0, 68
            
            add $t4, $t4, $t5
            add $t4, $s0, $t4
            
            sw $s1, 0($t4)
            
            addi $t2, $t2, 1
        blt $t2, $t3, fill_display_inner
        
        addi $t0, $t0, 1
    blt $t0, $t1, fill_display_outer
    
    li $t0, 0
    lw $t1, DISPLAY_HEIGHT
    li $t2, 5
    draw_line_1:
        sll $t4, $t2, 2
        
        mul $t5, $t0, 68
        
        add $t4, $t4, $t5
        add $t4, $s0, $t4
        
        sw $s2, 0($t4)
        
        addi $t0, $t0, 1
    blt $t0, $t1, draw_line_1
    
    li $t0, 0
    lw $t1, DISPLAY_HEIGHT
    li $t2, 11
    draw_line_2:
        sll $t4, $t2, 2
        
        mul $t5, $t0, 68
        
        add $t4, $t4, $t5
        add $t4, $s0, $t4
        
        sw $s2, 0($t4)
        
        addi $t0, $t0, 1
    blt $t0, $t1, draw_line_2
    
    li $t0, 5
    lw $t1, DISPLAY_WIDTH
    li $t2, 0
    draw_line_3:
        sll $t4, $t2, 2
        mul $t5, $t0, 68
        
        add $t4, $t4, $t5
        add $t4, $s0, $t4
        
        sw $s2, 0($t4)
        
        addi $t2, $t2, 1
    blt $t2, $t1, draw_line_3

    li $t0, 11
    lw $t1, DISPLAY_WIDTH
    li $t2, 0
    draw_line_4:
        sll $t4, $t2, 2
        mul $t5, $t0, 68
        
        add $t4, $t4, $t5
        add $t4, $s0, $t4
        
        sw $s2, 0($t4)
        
        addi $t2, $t2, 1
    blt $t2, $t1, draw_line_4
    
    
game_loop:
    func(clear_turn_cell)
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    done_keyboard_input:

    # Draw coloured cell for turn
    func(draw_turn_cell)
    # Draw all filled cells
    # func(draw_x_o)
    
	li $v0, 32
	li $a0, 1
	syscall

	b game_loop

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x77, respond_to_W
    beq $a0, 0x61, respond_to_A
    beq $a0, 0x73, respond_to_S
    beq $a0, 0x64, respond_to_D
    beq $a0, 0x20, respond_to_CONFIRM
    
    
    
    li $v0, 1                       # ask system to print $a0
    syscall

    b done_keyboard_input
    
respond_to_W:
    lw $t1, CURRENT_CELL # Get the current cell
    
    li $t2, 0
    beq $t1, $t2, done_keyboard_input
    li $t2, 1
    beq $t1, $t2, done_keyboard_input
    li $t2, 2
    beq $t1, $t2, done_keyboard_input
    
    addi $t1, $t1, -3
    sw $t1, CURRENT_CELL
    b done_keyboard_input
    

respond_to_A:
    lw $t1, CURRENT_CELL # Get the current cell
    
    li $t2, 0
    beq $t1, $t2, done_keyboard_input
    li $t2, 3
    beq $t1, $t2, done_keyboard_input
    li $t2, 6
    beq $t1, $t2, done_keyboard_input
    
    addi $t1, $t1, -1
    sw $t1, CURRENT_CELL
    b done_keyboard_input

respond_to_S:
    lw $t1, CURRENT_CELL # Get the current cell
    
    li $t2, 6
    beq $t1, $t2, done_keyboard_input
    li $t2, 7
    beq $t1, $t2, done_keyboard_input
    li $t2, 8
    beq $t1, $t2, done_keyboard_input
    
    addi $t1, $t1, 3
    sw $t1, CURRENT_CELL
    b done_keyboard_input

respond_to_D:
    lw $t1, CURRENT_CELL # Get the current cell
    
    li $t2, 2
    beq $t1, $t2, done_keyboard_input
    li $t2, 5
    beq $t1, $t2, done_keyboard_input
    li $t2, 8
    beq $t1, $t2, done_keyboard_input
    
    addi $t1, $t1, 1
    sw $t1, CURRENT_CELL
    b done_keyboard_input

respond_to_CONFIRM:
    # Use space to confirm
    
    lw $t1, CURRENT_CELL # Get the current cell
    la $t2, STATE_ARRAY
    
    sll $t3, $t1, 2
    add $t2, $t2, $t3 # Address of the cell to be replaced
    
    lw $t3, 0($t2) # State of the cell
    bne $t3, $zero, done_keyboard_input
    
    sw $s1, 0($t2) # Set the cell
    func(draw_x_o)
    func(check_win)
    
    # change turn
    not $s1, $s1
    li $t1, 3
    and $s1, $s1, $t1
    
    # reset position to 0
    sw $zero, CURRENT_CELL

    b done_keyboard_input
    
    
clear_turn_cell:
    lw $t3, CURRENT_CELL
    li $t4, 3
    div $t3, $t4
    # lo is row, hi is col
    mfhi $t4
    mflo $t5
    mult $t4, $t4, 24
    add $t3, $zero, $t4
    
    mult $t5, $t5, 408
    add $t3, $t3, $t5
    
    # Update display
    add $t3, $s0, $t3
    sw $zero, 0($t3)
    jr $ra


draw_turn_cell:
    
    li $t0, 1
    beq $s1, $t0, select_blue_turn

    lw $t1, RED_COLOUR
    b done_select_turn
    select_blue_turn:
    lw $t1, BLUE_COLOUR
    done_select_turn:
    
    lw $t3, CURRENT_CELL
    li $t4, 3
    div $t3, $t4
    # lo is row, hi is col
    mfhi $t4
    mflo $t5
    mult $t4, $t4, 24
    add $t3, $zero, $t4
    
    mult $t5, $t5, 408
    add $t3, $t3, $t5
    
    # Update display
    add $t3, $s0, $t3
    sw $t1, 0($t3)
    
    jr $ra


draw_x_o:
# let s1 be the current turn
    li $t1, 0
    li $t2, 9
    lw $t3, WHITE_COLOUR
    la $t0, STATE_ARRAY
    draw_x_o_loop:
        lw $t9, 0($t0)
        beq $t9, $zero, draw_x_o_empty
        

        li $t5, 3
        div $t1, $t5
        # lo is row, hi is col
        mfhi $t4
        mflo $t5
        mult $t4, $t4, 24
        add $t4, $zero, $t4
        
        mult $t5, $t5, 408
        add $t4, $t4, $t5
        addi $t4, $t4, 4 # Shift 1 right
        addi $t4, $t4, 68 # shift 1 down
        add $t4, $s0, $t4
        beq $t9, 1, draw_x
        beq $t9, 2, draw_o
        
        draw_x:
            # somehow get the corner into t4
            
            sw $t3, 0($t4)
            sw $t3, 8($t4)
            sw $t3, 72($t4)
            sw $t3, 136($t4)
            sw $t3, 144($t4)
        b draw_x_o_empty
        
        draw_o:
            # somehow get the corner into t4
            sw $t3, 0($t4)
            sw $t3, 4($t4)
            sw $t3, 8($t4)
            sw $t3, 68($t4)
            sw $t3, 76($t4)
            sw $t3, 136($t4)
            sw $t3, 140($t4)
            sw $t3, 144($t4)
        b draw_x_o_empty
    
        draw_x_o_empty:
        addi $t1, $t1, 1
        addi $t0, $t0, 4
    blt $t1, $t2, draw_x_o_loop
    jr $ra
    

    
check_win:
    # jr $ra # TODO
# 0   4  8
# 12 16 20
# 24 28 32
    func(draw_x_o)
    la $t0, STATE_ARRAY
# row 1
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    func(check_line)

# row 2
    lw $a0, 12($t0)
    lw $a1, 16($t0)
    lw $a2, 20($t0)
    func(check_line)

# row 3
    lw $a0, 24($t0)
    lw $a1, 28($t0)
    lw $a2, 32($t0)
    func(check_line)
# col 1
    lw $a0, 0($t0)
    lw $a1, 12($t0)
    lw $a2, 24($t0)
    func(check_line)
# col 2
    lw $a0, 4($t0)
    lw $a1, 16($t0)
    lw $a2, 28($t0)
    func(check_line)
# col 3
    lw $a0, 8($t0)
    lw $a1, 20($t0)
    lw $a2, 32($t0)
    func(check_line)
# diag 1
    lw $a0, 0($t0)
    lw $a1, 16($t0)
    lw $a2, 32($t0)
    func(check_line)
# diag 2
    lw $a0, 8($t0)
    lw $a1, 16($t0)
    lw $a2, 24($t0)
    func(check_line)
    
# check tie
    li $t1, 0
    li $t2, 9
    li $t3, 0
    la $t0, STATE_ARRAY
    count_tie:
        lw $t4, 0($t0)
        sne $t4, $zero, $t4
        add $t3, $t3, $t4
        
        addi $t0, $t0, 4
        addi $t1, $t1, 1
        blt $t1, $t2, count_tie
    beq $t3, 9, winner_tie
    jr $ra

check_line:
    # la $t0, STATE_ARRAY
    # lw $a0, 0($t0)
    # lw $a1, 4($t0)
    # lw $a2, 8($t0)
    li $a3, 1
    seq $t4, $a0, $a3
    seq $t5, $a1, $a3
    seq $t6, $a2, $a3
    add $t7, $zero, $t4
    add $t7, $t7, $t5
    add $t7, $t7, $t6
    beq $t7, 3, winner_x
    
    li $a3, 2
    seq $t4, $a0, $a3
    seq $t5, $a1, $a3
    seq $t6, $a2, $a3
    add $t7, $zero, $t4
    add $t7, $t7, $t5
    add $t7, $t7, $t6
    beq $t7, 3, winner_o
    
    done_check_line:
        jr $ra

winner_x:
    li $v0, 4
    la $a0, WINNER_X_MSG
    syscall
    b quit
winner_o:
    li $v0, 4
    la $a0, WINNER_O_MSG
    syscall
    b quit
winner_tie:
    li $v0, 4
    la $a0, WINNER_TIE_MSG
    syscall
    b quit

respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall

quit:
    li $v0, 10                      # Quit gracefully
	syscall