/*File Name: assign1a.s
Version 2; With Macros
Author: Deepinder Kaur
Date: January 31, 2022
Description:  ARMv8 A64 assembly language program that finds the maximum of y = -2x3 - 22x2 + 11x + 57 
in the range -10<=x<=4 by checking through the range one by one in a loop and testing.
Using only long integers for x.
*/

//defining macros
define(x, x19)
define(y, x25)
define(counter, x21)
define(max, x26)
define(a_value, x20)
define(b_value, x22)
define(c_value, x23)
define(d_value, x24)

fmt:    .string "If x = %d, then y = %d. Current max = %d\n" //labels for string creating new Strings in memory
        .global main                                         //Makes the label main visible to the linker
        .balign 4                                            //word alignment

main:   stp     x29,x30,[sp,-16]!                            //storing FP and LP in stack with 2 double spaces
        mov     x29, sp                                      //move SP to FP  
        mov     x, -10                                       //move -10 to x register
        mov     y, 0                                         //move 0 to x25
        mov     max, 0                                       //move 0 to x26
        mov     counter, 0                                   //move 0 to x21

loop:   cmp     x, 4                                         //comparing x19 and 4
        b.gt    end                                          //if 'x' is greater than 4, then end label will be called

        mov     a_value, -2                                  //move -2 to a_value 
        mov     b_value, -22                                 //move -22 to b_value  
        mov     c_value, 11                                  //move 11 to c_value 
        mov     d_value, 57                                  //move 57 to d_value 
        mov     y, 0                                         //move 0 to y 

        //-2x^3
        mul     a_value, a_value, x                          //a_value  = a_value  * x 
        mul     a_value, a_value, x                          //a_value  = a_value  * x 
        madd    y, a_value, x, y                             //y  = y  + (a_value  * x )

        //-22x^2
        mul     b_value, b_value, x                          //b_value  = b_value  * x 
        madd    y, b_value, x, y                             //y  = y  + (b_value  * x )

        //11x
        madd    y, c_value, x, y                             //y  = y  + (c_value  * x )

        //57
        add     y, y, d_value                                //y  = y  + d_value 

        cmp     counter, 0                                   //comparing counter with 0
        b.eq    flag                                         //if counter  = 0, flag label called

        cmp     y, max		                                 //comparing y with max
        b.gt    flag		                                 //if y > max, flag label called

        cmp     y, max		                                //comparing y  with max
        b.lt    output			                            //if y < max, then output label called       

flag:   mov     max, y                                      //moving max to y 
        b       output                                      //branched output label

output: adrp    x0, fmt                                     //adrp points the x0 to fmt location
        add     x0, x0, :lo12: fmt                          //adding first 12 bytes of fmt to orginal value

        mov     x1, x                                       //moving x19 to x1
        mov     x2, y 		                                //moving y  to x2
        mov     x3, max	                                    //moving max to x3

        bl      printf			                            //call to printf(fmt,x1,x2,x3)

        add     x, x , 1		                           //incrementing the value of x by 1
        add     counter, counter , 1		               //incrementing the value of loup counnter by 1
        b       loop			                           //branched loop label

end:					     
        ldp x29, x30, [sp], 16		                      //ldp restores sp to x29 and x30 then do sp + 16 and set to sp
        ret				                                  //return to OS
