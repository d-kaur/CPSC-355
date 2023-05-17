/*File Name: assign3.asm
Author: Deepinder Kaur
Date: March 30, 2023
Description:  Assignment 5
Given the following declaration in C:
char *month[] = {"January", "February", "March", "April", "May",
                 "June", "July", "August", "September", "October",
                 "November", "December"};
create an ARMv8 assembly language program to accept as 
command line arguments three strings representing a date in the 
format mm dd yyyy. Your program will print the date with the name of 
month as well as the correct suffix. For example: 
./a5b 9 11 1990
September 11th, 1990
*/

//defining Strings
        .text
result: .string "%s %d%s, %d\n"
usage:  .string "usage: a5b mm dd yyyy\n"

jan:    .string "January"
feb:    .string "February"
march:  .string "March"
april:  .string "April"
may:    .string "May"
june:   .string "June"
july:   .string "July"
aug:    .string "August"
sept:   .string "September"
oct:    .string "October"
nov:    .string "November"
dec:    .string "December"

st:     .string "st"
nd:     .string "nd"
rd:     .string "rd"
th:     .string "th"

//arrays
months_arr:     .dword jan, feb, march, april, may, june, july, aug, sept, oct, nov, dec
ending_arr:     .dword st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st //1-31

//defining
define(c_arg, w23)                                      //cmd line arguments
define(v_arg, x24)

define(month, w19)
define(day, w20)
define(year, x21)

define(month_r, x22)
define(ending_r, x23)

        .balign 4
        .global main                                    //make visible to linker

main:
    stp     x29, x30, [sp, -16]!                        //allocating
    mov     x29, sp

    mov     c_arg, w0                                   //storing argc
    mov     v_arg, x1                                   //storing argv

    mov     w25, 1
    mov     w26, 2
    mov     w27, 3

    cmp     c_arg, 4                                    //comparing c_arg and 4
    b.lt    incorrect                                   //jump to error

continue:
    ldr     x0, [v_arg, w25, SXTW 3]
    bl      atoi                                        //call to atoi
    mov     month, w0                                   //moving atoi to month

    cmp     month, 0                                    //comparing month and 0
    b.le    incorrect                                   // if m >= 0, branch to incorrect

    cmp     month, 12                                   //comparing month and 12
    b.gt    incorrect                                   //if m > 12, branch to incorrect

    ldr     x0, [v_arg, w26, SXTW 3]
    bl      atoi                                        //call to atoi (connverting to int)
    mov     day, w0                                     //moving atoi to day

    cmp     day, 0                              
    b.le    incorrect                                   //if d <= 0, branch to incorrect

    cmp     day, 31
    b.gt    incorrect                                   //if d > 31, branch to incorrect

    ldr     x0, [v_arg, w27, SXTW 3]
    bl      atoi                                        //converting to int
    mov     year, x0

    cmp     year, 0
    b.le    incorrect                                   //if year is > 0, branch to incorrect

    b       out

incorrect:
    adrp    x0, usage                                   //print
    add     x0, x0, :lo12:usage

    bl      printf                                      //call to printf
    b       end                                         //branch to end

out:
    adrp    month_r, months_arr                         //base array to register
    add     month_r, month_r, :lo12:months_arr          //formatting lower 12 bits
    sub     month, month, 1

    adrp    ending_r, ending_arr                        //base array to register
    add     ending_r, ending_r, :lo12:ending_arr        //formatting lower 12 bits

    adrp    x0, result
    add     x0, x0, :lo12:result                        //setting up result

    ldr     x1, [month_r, month, SXTW 3]                //loading month

    mov     w2, day                                     //mov day to w2
    sub     day, day, 1
    ldr     x3, [ending_r, day, SXTW 3]                 //loaading endings

    mov     x4, year

    bl      printf                                      //call to printf

end:
    ldp     x29, x30, [sp], 16                          //deallocating
    ret                                                 //return to os
