/*File Name: assign4.asm
Author: Deepinder Kaur
Date: March 2, 2023
Description:  Assignment 4
ARMv8 assembly language program that implements the given code.
*/

//defining strings
iValue:     .string "\nInitial sphere values:\n"
cValue:     .string "\nChanged sphere values:\n"
result:     .string "Sphere %s origin = (%d, %d, %d) radius = %d\n"
first:      .string "first"
second:     .string "second"

//defining the macros
define(deltaX, w3)
define(deltaY, w4)
define(deltaZ, w5)
define(factor, w6)
define(pointer, w19)

//Alias
fp          .req x29                                        
lr          .req x30  

//Stack offsets
x_s          = 0
y_s          = 4
z_s          = 8
radius_s     = 12
result_s     = 28

//Initializing
int = 4
char = 2
firstSphere  = 16
secondSphere = 32 

//Structs
st_first  = int * 4
st_second = int * 4

//allocs & deallocs
alloc     = -(16 + st_first + st_second) & -16
dealloc   = -alloc

allocP = -(16 + int * 3) & -16                              //alloc and dealloc for point
deallocP = -allocP

allocS   = -(16 + int * 4) & -16                            //alloc and dealloc for Sphere
deallocS = -allocS

allocNS   = -(16 + st_first) & -16                          //alloc and dealloc for New Sphere
deallocNS = -allocNS

allocME   = -(16) & -16                                     //alloc and dealloc for move and expand
deallocME = -allocME

allocEq   = -(16 + int) & -16                               //alloc and dealloc for equal
deallocEq = -allocEq

allocPrint   = -(16 + char) & -16                           //alloc and dealloc for print
deallocPrint = -allocPrint


.balign 4                                                   //alligns
.global main                                                //makes visible to linker  

main:        
    stp     fp, lr, [sp, alloc]!                            //allocating
    mov     fp, sp                                          //mov x29, sp

    add     x8, fp, firstSphere                             //x8 = fp + firstSphere                              
    bl      newSphere                                       //call to newSphere

    add     x8, fp, secondSphere                                      
    bl      newSphere                           

    adrp    x0, iValue                                      //print Intial Value
    add     x0, x0, :lo12:iValue
    bl      printf                                          //call to printf

    adrp    x0, first                                       //print first
    add     x0, x0, :lo12:first
    add     x1, fp, firstSphere
    bl      print                                           //call to print

    adrp    x0, second                                      //print second
    add     x0, x0, :lo12:second
    add     x1, fp, secondSphere
    bl      print
            
    add     x1, fp, firstSphere                             //x1 = fp + firstSphere
    add     x2, fp, secondSphere                            //x2 = fp + secondSphere
             
    bl      equal                                           //call to equal
    ldr     x20, [fp, result_s]                             //load x20 from stack

    cmp     x20, 0                                          //compare x20 t0 0

    b.eq    jump                                            //branch to jump
           
    add     x1, fp, firstSphere                             //x1 = fp + firstSphere
    mov     deltaX, -5                                      //moving -5 to deltaX
    mov     deltaY, 3                                       //moving 3 to deltaY
    mov     deltaZ, 2                                       //moving 2 to deltaZ

    bl      move                                            //branch to move
    add     x1, fp, secondSphere                            //x1 = fp + secondSphere
    mov     factor, 8
    bl      expand                                          //call to expand
                       
jump:       
    adrp    x0, cValue                                      //print changed value
    add     x0, x0, :lo12:cValue
    bl      printf

    adrp    x0, first                                       //print first   
    add     x0, x0, :lo12:first
    add     x1, fp, firstSphere
    bl      print                                           //call to print
         
    adrp    x0, second                                      //print second
    add     x0, x0, :lo12:second
    add     x1, fp, secondSphere
    bl      print
             
    mov     w0, 0                                           //moving 0 to w0
    ldp     fp, lr, [sp], dealloc                           //deallocate
    ret                                                     //return to os

point:
    stp     fp, lr, [sp, allocP]!                           //allocating
    mov     fp, sp

    str     wzr, [x8, x_s]                                  //storing on x stack
    str     wzr, [x8, y_s]                                  //storing on y stack
    str     wzr, [x8, z_s]                                  //storing on z stack

    ldp     fp, lr, [sp], deallocP                          //deallocate
    ret                                                     //return to os

sphere:      
    stp     fp, lr, [sp, allocS]!                           //allocating
    mov     fp, sp
    bl      point                                           //call to point

    str     wzr, [x8, radius_s]                             //storing on radius stack

    ldp     fp, lr, [sp], deallocS                          //deallocating
    ret                                                     //return to os

newSphere:   
    stp     fp, lr, [sp, allocNS]!                          //allocating
    mov     fp, sp

    bl      sphere                                          //call to sphere
    mov     w0, 0                                           //setting w0 to 0
    str	    w0, [x8, x_s]                                   //storing w0 on x_s stack
             
    mov     w0, 0       
    str	    w0, [x8, y_s]                                   
             
    mov     w0, 0       
    str	    w0, [x8, z_s]
             
    mov     w0, 1       
    str	    w0, [x8, radius_s]

    ldp     fp, lr, [sp], deallocNS                         //deallocating
    ret                                                     //return to os

move:        
    stp     fp, lr, [sp, allocME]!                          //allocating
    mov     fp, sp

    ldr     w10, [x1, x_s]                                  //loading w10 from stack
    add     w10, w10, deltaX                                //w10 = w10 + deltaX
    str     w10, [x1, x_s]                                  //storing w10 on x stack

    ldr     w10, [x1, y_s]
    add     w10, w10, deltaY
    str     w10, [x1, y_s]

    ldr     w10, [x1, z_s]
    add     w10, w10, deltaZ
    str     w10, [x1, z_s]

    ldp     fp, lr, [sp], deallocME                         //deallocating
    ret                                                     //return to os

expand:      
    stp     fp, lr, [sp, allocME]!                          //allocating
    mov     fp, sp

    ldr     w10, [x1, radius_s]                             //loading w10 from radius stack
    mul     w10, w10, factor                                //w10 = w10 * factor
    str     w10, [x1, radius_s]                             //storing w10 on stack

    ldp     fp, lr, [sp], deallocME                         //deallocating
    ret                                                     //return to os

equal:       
    stp     fp, lr, [sp, allocEq]!                          //allocating
    mov     fp, sp
             
    mov     pointer, 0                                      //setting pointer to 0
    str     pointer, [fp, result_s]                         //storing pointer to result stack
    ldr     x0, [fp, result_s]                              //loading from stack
             
    ldr     w10, [x1, x_s]
    ldr     w11, [x2, x_s]
    cmp     w10, w11                                        //comparing w10 and w11
    b.ne    next                                            //branch over to next if not

    ldr     w10, [x1, y_s]
    ldr     w11, [x2, y_s]
    cmp     w10, w11  
    b.ne    next

    ldr     w10, [x1, z_s]
    ldr     w11, [x2, z_s]
    cmp     w10, w11  
    b.ne    next

    ldr     w10, [x1, radius_s]
    ldr     w11, [x2, radius_s]
    cmp     w10, w11  
    b.ne    next

    mov     pointer, 1                                      //setting pointer to 1
    str     pointer, [fp, result_s]                         //storing pointer on stack
    ldr     x0, [fp, result_s]
                   
next:    
    ldp     fp, lr, [sp], deallocEq                         //deallocating
    ret                                                     //return to os

print:
    stp     fp, lr, [sp, allocPrint]!                       //allocating
    mov     fp, sp 

    ldr     w2, [x1, x_s]                                   //loading from stack
    ldr     w3, [x1, y_s]
    ldr     w4, [x1, z_s]
    ldr     w5, [x1, radius_s]

    mov     x1, x0
    adrp    x0, result                                      //printing
    add     x0, x0, :lo12:result
    bl      printf

    ldp     fp, lr, [sp], deallocPrint                      //deallocating
    ret                                                     //return to os
             