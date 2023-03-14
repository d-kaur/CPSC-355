/*File Name: assign2a.s
Version 3
Author: Deepinder Kaur
Date: Feburary 9, 2022
Description: An ARMv8 assembly language program that implements
given integer multiplication program
*/

//Defining the strings
initialValue:       .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"
printProduct:       .string "product = 0x%08x multiplier = 0x%08x\n"
result:             .string "64-bit result = 0x%016lx (%ld)\n"

//Defining macros
define(TRUE, 1)
define(FALSE,0)                                                                                                                                                      
define(multiplier, w19)                                                                        
define(multiplicand,w20)                                                                      
define(product, w21)                                                                           
define(i, w22)                                                                                
define(negative, w23)                                                                           
define(resultStore, x24)                                                                             
define(temp1, x25)                                                                             
define(temp2, x26)                                                                             
define(product64,x21)                                                                          
define(multiplier64,x19)  

        .global main                                //Makes the label main visible to the linker
        .balign 4                                   //word alignment

main:
        stp     x29,x30,[sp,-16]!                   //storing FP and LP in stack with 2 double spaces        
        mov     x29, sp                             //move sp to FP   

        mov     multiplicand, -252645136            //seting multiplicand to the value
        mov     multiplier, -256                    //setting multiplier to the value  
        mov     product, 0                          //setting product to 0
        mov     i, 0                                //setting i to 0

        adrp    x0, initialValue                    //set 1st args to printf() higher
        add     x0, x0, :lo12:initialValue          //set 2nd args to printf() lower
        mov     w1, multiplier                      //moving multiplier value to w1                                                                  
        mov     w2, multiplier                      //moving multiplier value to w2                                                               
        mov     w3, multiplicand                    //moving multiplicand value into w3 register                                                          
        mov     w4, multiplicand                    //moving multiplicand value into w4 
        bl      printf                              //call to printf 

        cmp     multiplier, 0                       //checking step1 the multiplier is -ive 
        b.ge    step1                               //step1 multiplier >= 0, branch to step1
        mov     negative, TRUE                      //step1 multiplier < 0, TRUE is stored in negative

step1:
        mov     i, 0                                //setting i to 0
	b       test                                //jump to test

step2:
        tst     multiplier, 0x1                     //comparing multiplier to 1
        b.eq    step3                               //step1 not equal, jump tp step3
        add     product, product, multiplicand      //if same, add

step3:
        asr     multiplier, multiplier, 1           //arthemtic shift right 
        tst     product, 0x1                        //arthemtic shift right by 1 of multiplier                                           
        b.eq    step4                               
        orr     multiplier, multiplier, 0x80000000  //if equal, execute orr statement
        b       step5                               //jump to step5

step4:
        and     multiplier, multiplier, 0x7FFFFFFF  //else statement

step5:
        asr     product, product, 1                 //arthmetic shift right of product by 1
        add     i, i, 1                             //incrementing i

test:
        cmp     i, 32                               //repeated add and shift
        b.lt    step2                               //compare i < 32

        cmp     negative, TRUE                      //if i < 32, jump to step2 
        b.ne    printNext                           //if not equal, jump to printNext
        sub     product, product, multiplicand      //subract, product = product - multiplicand

printNext:
        adrp    x0, printProduct                    //set 1st args to printf() higher
        add     x0, x0, :lo12:printProduct          //set 2nd args to printf() lower
        mov     w1, product                         //moving product value to w1
        mov     w2, multiplier                      //moving multiplier value to w2
        bl      printf                              //call to printf

        sxtw    temp1, product                      //moving product value into temp1 register
        and     temp1, product64, 0xFFFFFFFF        //moving product64, 0xFFFFFFF into temp1 res=gister                                                   
        lsl     temp1, temp1, 32                    //shifting temp1 value to the left by 32 

        sxtw    temp2, multiplier                   //moving multiplier value into temp2 register                                                              
        and     temp2, multiplier64, 0xFFFFFFFF     //moving multiplier64, 0xFFFFFFF into temp2 registers 

        add     resultStore, temp1, temp2           //resultStore = temp1 + temp2                                                           

        adrp    x0, result                          //set 1st args to printf() higher                                                                    
        add     x0, x0, :lo12:result                //set 2nd args to printf() lower                                                          
        mov     x1, resultStore                     //moving resultStores to x1                                                                    
        mov     x2, resultStore                     //moving resultStores to x2                                                                   
        bl      printf                              //call to printf                      

end:
        mov     w0, 0                               //restore registers
        ldp     x29, x30, [sp], 16                  //ldp restores sp to x29 and x30 then do sp + 16 and set to sp

        ret                                         //return to os
