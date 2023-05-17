/*File Name: a6.asm
Author: Deepinder Kaur
Date: April 11, 2023
Description:  Assignment 6
ARMv8 assembly language program that implements ln(x)
*/

//defining registers
define(fd, w19)
define(readByte, x20)
define(baseBuf, x21)
define(argc_r, w22)
define(argv_r, x23)

define(numer, d19)
define(denom, d20)
define(expo, d21)
define(accum, d22)
define(const, d23)
define(increment, d24)
define(i, d25)
define(fraction, d26)
define(expo_f, d27)
define(const_f, d28)
define(term, d29)

//others
buf_size = 8
alloc = -(16 + buf_size) & -16
dealloc = -alloc
buf_s = 16

            .data
constant:   .double 0r1.0e-13
float:      .double 0r0.0

//Strings
                .text
fmt:            .string "|	Input value (x)	| 	  ln(x)	 	 |\n"
values:         .string "|	%.10f	|	%.10f	|\n "    
errorString:    .string "Error: ./a6 input.bin\n"

            .global main                        //make visible to linker
            .balign 4

main:
    stp     x29, x30, [sp, alloc]!
    mov     x29, sp

    mov     argc_r, w0                          //move args from w0 to argc_r
    mov     argv_r, x1                          //move args string from x1 to argv_r

    cmp     argc_r, 2                           //comparing
    b.ne    error                               // if not equal, branch to error

    mov     w0, -100                            //setting 1st arg
    ldr     x1, [argv_r, 8]                     //place string in x1
    mov     w2, 0                               //3rd arg
    mov     w3, 0                               // 4th arg
    mov     x8, 56                              //I/O request

    svc     0                                   //call to system function
    mov     fd, w0                              //move w0 to fd
    cmp     fd, 0                               // comparing
    b.ge    open                                //opens the file if no error

error:
    adrp    x0, errorString                     //set 1st arg
    add     x0, x0, :lo12:errorString           // low order bits
    bl      printf                              //call to printf
    b       done                                //branch to done

open:
    adrp    x0, fmt                             //set 1st arg
    add     x0, x0, :lo12:fmt                   //low order bits
    bl      printf                              //call to printf
    
    add     baseBuf, x29, buf_s                 //store base address

loop:
    mov     w0, fd                              //set fd
    mov     x1, baseBuf                         //pointer to the baseBuf
    mov     x2, buf_size                        //set 'n'
    mov     x8, 63                              //I/O request
    svc     0                                   //call to system function
    mov     readByte, x0                        //move to readByte


    cmp     readByte, buf_size                  //check end of file
    b.ne    end                                 //branch to end

    ldr     d0, [baseBuf]                       //set input
    bl      ln                                  //call to ln
    fmov    d1, d0                              //store in d0

    adrp    x0, values                          //print
    add     x0, x0, :lo12:values                
    ldr     d0, [baseBuf]                       // Sets 2nd arg
    bl      printf                              //call to printf
    b       loop                                //loop till end of file

end: 
    mov     w0, fd                              //set fd
    mov     x8, 57                              //close I/O request
    svc     0                                   //call to system function
    mov     w0, 0                               //return 0

done:
    ldp     x29, x30, [sp], dealloc
    ret

            .global ln                          //make visible to linker
            .balign 4

ln:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    adrp    x23, constant                       //set 1st arg
    add     x23, x23, :lo12:constant              
    ldr     const, [x23]                        //load const value

    adrp    x24, float                          // Sets 1st arg
    add     x24, x24, :lo12:float                               
    ldr     accum, [x24]                        //accum - 0

    fmov    expo, 1.0                           //expo = 1
    fmov    increment, 1.0                      //increment = 1
    fmov    i, 1.0                              //i = 1
    fmov    const_f, 1.0                        //const_f = 1
    
    fmov    denom, d0                           //denom = x
    fsub    numer, denom, increment             //numer = x - 1
    fdiv    fraction, numer, denom              //fraction
    fmov    expo_f, fraction                    //expo_f 
    fmul    term, expo_f, const_f               //term = expo_f * const_f
    fadd    accum, accum, term                  //accum += term
    b       test                                //branches to test

top:
    fadd    expo, expo, increment               //increases expo by 1

top2:
    fmul    expo_f, expo_f, fraction            //expo_f *= fraction
    fadd    i, i, increment                     // i++
test1:
    fcmp    i, expo                             //compares i < expo
    b.lt    top2                                // branch to top2
    fdiv    const_f, increment, expo            // const_f = 1/expo
    fmul    term, expo_f, const_f               // term = expo_f * const_f
    fadd    accum, accum, term                  // accum += term

test:
    fabs    term, term                          // term = abs(term)
    fcmp    term, const                         //compare term >= const
    b.ge    top                                 //branche to top
    
done2:
    fmov    d0, accum                           //return accum
    stp     x29, x30, [sp], 16                 
    ret                                         //return to OS
