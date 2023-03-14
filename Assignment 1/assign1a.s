/*File Name: assign1a.s
Version 1; No Macros
Author: Deepinder Kaur
Date: January 31, 2022
Description:  ARMv8 A64 assembly language program that finds the maximum of y = -2x3 - 22x2 + 11x + 57 
in the range -10<=x<=4 by checking through the range one by one in a loop and testing.
Using only long integers for x.
*/

fmt:    .string "If x = %d, then y = %d. Current max = %d\n" //labels for string creating new Strings in memory

        .global main                         //Makes the label main visible to the linker
        .balign 4                            //word alignment

main:   stp     x29,x30,[sp,-16]!            //storing FP and LP in stack with 2 double spaces
        mov     x29, sp                      //move SP to FP
        mov     x19,-10                      //move -10 to x19 register
        mov     x25,0                        //move 0 to x25
        mov     x26,0                        //move 0 to x26
        mov     x21,0                        //move 0 to x21

loop:   cmp     x19,4                        //comparing x19 and 4
        b.gt    end                          //if x19 is greater than 4, then end label will be called

        mov     x20,-2                       //move -2 to x20
        mov     x23, -22                     //move -22 to x23  
        mov     x24,11                       //move 11 to x24
        mov     x22,57                       //move 57 to x22
     
        //-2x^3
        mul     x20,x20,x19                  //x20 = x20 * x19
        mul     x20,x20,x19                  //x20 = x20 * x19
        mul     x20,x20,x19                  //x20 = x20 * x19

        //-22x^2
        mul     x23,x23,x19                  //x23 = x23 * x19
        mul     x23,x23,x19                  //x23 = x23 * x19

        //11x
        mul     x24,x24,x19	             //x24 = x24 * by x19

        add     x25,x20,x23                  //x25 = -2x^3 + (-22x^2)
        add     x25,x25,x24                  //x25 = -2x^3 + (-22x^2) + 11x
        add     x25,x25,x22                  //x25 = -2x^3 + (-22x^2) + 11x + 57

        cmp     x21,0                        //comparing x21 with 0
        b.eq    flag                         //if x21 = 0, flag label called

        cmp     x25,x26		             //comparing x25 with x26
        b.gt    flag		             //if x25 > x26, flag label called

        cmp     x25, x26		     //comparing x25 with x26
        
        b.lt    output			     //if x25 < x26, then output label called

flag:   mov     x26,x25                      //moving x25 to x26
        b       output                       //branched output label

output: adrp    x0,fmt                       //adrp points the x0 to fmt location
        add     x0,x0, :lo12: fmt            //adding first 12 bytes of fmt to orginal value

        mov     x1,x19                       //moving x19 to x1
        mov     x2, x25			     //moving x25 to x2
        mov     x3, x26			     //moving x26 to x3

        bl      printf			     //call to printf(fmt,x1,x2,x3)

        add     x19, x19, 1		     //incrementing the value of x by 1
        add     x21, x21, 1		     //incrementing the value of loup counnter by 1
        b       loop			     //branched loop label

end:					     
        ldp x29, x30, [sp], 16		     //ldp restores sp to x29 and x30 then do sp + 16 and set to sp
        ret				     //return to OS
        