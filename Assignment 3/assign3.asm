/*File Name: assign3.asm
Author: Deepinder Kaur
Date: March 2, 2023
Description:  Assignment 3
ARMv8 assembly language program that implements selection sort algorithm
*/

//defining the strings
printArray:     .string "v[%d]: %d\n"                       //prints array values
printLabel:     .string "\nSorted Array: \n"                //prints "Sorted Array"
printLabel2:    .string "\nUnsorted Array: \n"              //prints "Unsorted Array"

.balign 4                                                   //alligns
.global main                                                //makes visible to linker

//defining the macros
define(i, w19)
define(j, w20)
define(min, w21)
define(temp, w22)
define(base, x23)
define(randomNum, w24)
define(v_min, w25)
define(v_j, w26)

//Initializing
i_size  = 4
size    = 50
t_size  = size * i_size

//alloc & dealloc
alloc   = -(16 + 16 + size) & -16
dealloc = -alloc

//Stack offsets
i_s     = 16
j_s     = 20
min_s   = 24
b_s     = 28

//Alias
fp          .req x29                                        
lr          .req x30                                        

main: 
    stp     fp, lr, [sp, alloc]!                            //allocating
    mov     fp, sp                                          //mov x29, sp

    mov     base, fp                                        //setting base to fp
    add     base, base, b_s                                 //base location by adding offset to fp

    ldr     i, [fp, i_s]                                    //load index from i_s
    mov     i, 0                                            //setting index to 0
    str     i, [fp, i_s]                                    //store index

    adrp    x0, printLabel2                                 //print
    add     x0, x0, :lo12:printLabel2                       //print
    bl      printf                                          //call to printf

    b       test1                                           //jump to test1

loop1:                                                      //generates random array
    ldr     i, [fp, i_s]                                    //load index from i_s
    bl      rand                                            //generate random nums
    and     randomNum, w0, 0xFF                             //v[i] = rand() & 0xFF
    str     randomNum, [base, i, SXTW 2]                    //store results 

    ldr     randomNum, [base, i, SXTW 2]                    //load randomNum

    adrp    x0, printArray                                  //print
    add     x0, x0, :lo12:printArray                        //print
    mov     w1, i                                           //moving i value to w1
    mov     w2, randomNum                                   //moving randomNum to w2
    bl      printf                                          //call to printf

    mov     temp, 0                                         //setting temp to 0
    add     i, i, 1                                         //i++
    str     i, [fp, i_s]                                    //store i on stack

test1: 
    cmp     i, size                                         //compare i to size
    b.lt    loop1                                           //if i < 50, continue with the loop

print2:
    adrp    x0, printLabel                                  //print
    add     x0, x0, :lo12:printLabel                        //print
    bl      printf                                          //call to printf

loop2a:
    mov     i, 0                                            //setting i to 0
    str     i, [fp, i_s]                                    //store new i on stack
    b       test2                                           //jump to test2

loop2b:                                                     //selection sort
    mov     min, i                                          //setting min = i
    str     min, [fp, min_s]                                //store min on stack

    ldr     j, [fp, j_s]                                    //load j from stack
    ldr     i, [fp, i_s]                                    //load i from stack
    mov     j, i                                            //set j = i
    add     j, j, 1                                         //j++
    str     j, [fp, j_s]                                    //store j on stack

    b       test3                                           //jump to test3

loop3:                                                      //compare
    ldr     min, [fp, min_s]                                //load min from stack
    ldr     j, [fp, j_s]                                    //load j from stack

    ldr     v_min, [base, min, SXTW 2]                      //load v[min] from stack
    ldr     v_j, [base, j, SXTW 2]                          //load v[j] from stack

    cmp     v_min, v_j                                      //compare v[min] & v[j]
    b.lt    next                                            //jump to next

    mov     min, j                                          //min = j
    str     j, [fp, min_s]                                  //store j on min_s stack

next:
    ldr     j, [fp, j_s]                                    //load j from stack
    add     j, j, 1                                         //j++
    str     j, [fp, j_s]                                    //store j on stack

test3:
    ldr     j, [fp, j_s]                                    //load j from stack
    cmp     j, size                                         //compare j and size
    b.lt    loop3                                           //if i < 50, comtinue with the loop

    ldr     min, [fp, min_s]                                //load min from stack
    ldr     v_min, [base, min, SXTW 2]                      //load v[min] from stack
    ldr     v_j, [base, j, SXTW 2]                          //load v[j] from stack

    ldr     i, [fp, i_s]                                    //load i from stack
    ldr     w27, [base, i, SXTW 2]                           //store v[i] in w27 register

    mov     temp, w27                                       //temp = v[min]
    mov     w27, v_min                                      //v[min] = v[i]
    mov     v_min, temp                                     //v[i] = temp

    str     v_min, [base, min, SXTW 2]                      //store min in v[min]
    str     w27, [base, i, SXTW 2]                          //store v[i] in w27 register

    adrp    x0, printArray                                  //print
    add     x0, x0, :lo12:printArray                        //print
    mov     w1, i                                           //first args is i
    ldr     w27, [base, i, SXTW 2]                          //load v[i]
    mov     w2, w27                                         //second args is v[i]
    bl      printf                                          //call to printf

    ldr     i, [fp, i_s]                                    //load i from stack
    add     i, i, 1                                         //i++
    str     i, [fp, i_s]                                    //store i on stack

test2: 
    cmp     i, size                                         //compare i to size
    b.lt    loop2b                                          //if i < 50, continue with the loop

end:
    mov     x0, 0                                           //restore registers
    ldp     fp, lr, [sp], dealloc                           //deallocate

    ret                                                     //return to os     
