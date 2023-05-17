/*File Name: a5a.asm
Author: Deepinder Kaur
Date: March 30, 2023
Description:  Assignment 5
ARMv8 assembly language program that implements the given c code
*/

//defining registers
define(i_r, w21)
define(c_r, w22)

//Alias fp & lr
fp      .req x29
lr      .req x30

//Initializing
MAXVAL  = 100
BUFSIZE = 100
МАХОР   = 20
NUMBER  = '0'
TOOBIG  = '9'

//others
            .data
            .global new_sp
            .global val
            .global bufp
            .global buf
new_sp:     .word 0
bufp:       .word 0
val:        .skip MAXVAL * 4
buf:        .skip BUFSIZE * 4

//Strings
                .text                                                               
stackFull:      .string "error: stack full\n"                                      
stackEmpty:     .string "error: stack empty\n"                                      
ungetchError:   .string "ungetch: too many characters\n"

            .balign 4
            .global push
push:               
    stp     fp, lr, [sp, -16]!                  //allocating                                             
    mov     fp, sp                              //mov x29, sp

    mov     w26, w0                                                                                    

    adrp    x9, new_sp                                                                  
    add     x9, x9, :lo12:new_sp                
    ldr     w10, [x9]                           //w10 = sp                                                     
           
    cmp     w10, MAXVAL                         //compare sp and MAXVAL                                                   
    b.ge    else                                //if sp >= MAXVAL, jump to else                                                       

    adrp    x28, val                            
    add     x28, x28, :lo12:val                 //calculate val[]                                              
    str     w26, [x28, w10, SXTW 2]             //store f into val[sp]                                     

    add     w10, w10, 1                         //sp++                              
    str     w10, [x9]                           //storing sp                                           

    b       if_exit                             //jump to if_exit                                                 
                  
else:               
    adrp    x0, stackFull                       //print               
    add     x0, x0, :lo12:stackFull             //print                                      
    bl      printf                              //call to printf                                                                  

if_exit:            
    ldp     fp, lr, [sp], 16
    ret                                         //return                                        


            .balign 4
            .global clear                       //make visible to linker  
clear:             
    stp     fp, lr, [sp, -16]!
    mov     fp, sp

    adrp    x9, new_sp                          //setting sp                                       
    add     x9, x9, :lo12:new_sp
    ldr     w10, [x9]                           //w10 = sp                                          
    mov     w10, 0                              //sp = 0                                                       
    str     w10, [x9]                           //store sp vlue                                                 
                 
    ldp     fp, lr, [sp], 16
    ret                                         //return                                                                


            .balign 4
            .global pop                         //make visible to linker       
pop:                
    stp     fp, lr, [sp, -16]!
    mov     fp, sp

    adrp    x9, new_sp                          //calling sp                                                             
    add     x9, x9, :lo12:new_sp
    ldr     w10, [x9]                           //w10 = sp                                         
          
    cmp     w10, 0                              //compare sp and 0                                                        
    b.le    pop_else                            //if sp <=0, jump to pop_else                                                 

    sub     w10, w10, 1                         //--sp                                                
    adrp    x28, val
    add     x28, x28, :lo12:val                 //base adderess for val[]                                          
    ldr     w0, [x28, w10, SXTW 2]              //load --sp                                    
    str     w10, [x9]                           //store new sp value                                                

    b       if_end                              //jump to if_end                                                     
                                    
pop_else:            
    adrp    x0, stackEmpty                      //print                                         
    add     x0, x0, :lo12:stackEmpty                                        
    bl      printf                              //call to printf                                                          
    bl      clear                               //branch to clear                                                      

if_end:              
    ldp     fp, lr, [sp], 16                
    ret                                         //return                                                           

//allocating and dealloc
alloc   = -(16 + 8) & -16
dealloc = -alloc

            .balign 4
            .global getop                       //make visible to linker     
getop:              
    stp     fp, lr, [sp, alloc]!
    mov     fp, sp
                    
    add     x14, fp, 16                         //move 16 to x14                                               
    mov     x26, x0                             //moving array * s to x26                                    
    mov     w25, w1                             //move int lim into w25                              
    str     x26, [x14]                          //storing in x26                                              

true:               
    bl      getch                               //branch to getch                                                         
    mov     c_r, w0                             // c = getch()                                              
                    
//while ((c = getch()) == ' ' || c == '\t' || c == '\n')
    cmp     c_r, ' '                            //comparing and jumping to true                                           
    b.eq    true                                                           

    cmp     c_r, '\t'                                                       
    b.eq    true                                                           

    cmp     c_r, '\n'                                                       
    b.eq    true                                                           
                    
    cmp     c_r, '0'                                                        
    b.lt    if_true                             //jump to if_true                                        

    cmp     c_r, '9'                                                       
    b.gt    if_true                                                         

    b       next                                //branch to next                                                      

if_true:              
    mov     w0, c_r                             //movinf c_r into w0                                                      
    b       top_end                             //branch to top_end                                                          

next:               
    add     x14, fp, 16                         //loading address of s                                               
    ldr     x26, [x14]                                                      
    str     c_r, [x26]                          //s[0] - c                                                
              
    mov     i_r, 1                              //i_r = 1                                                        
    b       test                                //branch to test                                                          
                  
loop:              
    cmp     i_r, w25                            //compare i_r and w25(lim)                                                  
    b.ge    exit_if                             //if i_r >= w25, jump to exit_if                       
    add     x14, fp, 16                         //load address of s                                  
    ldr     x26, [x14]                                                      
    str     c_r, [x26, i_r, SXTW 2]             //s[i] = c                                        

exit_if:         
    add     i_r, i_r, 1                         //i++                                              

test:               
    bl      getchar                             //call to getchar                                                      
    mov     c_r, w0                             //c_r = getchar()                                                     
    cmp     c_r, '0'                            //compare c_r and '0'                                                     
    b.lt    out                                 //if c < '0', jump to out                                    

    cmp     c_r, '9'                            //compare c_r and '9'                                                        
    b.le    loop                                //if c =< '9', jump to loop                                    

out:                
    cmp     i_r, w25                            //compare i_r and w25                                                                             
    b.ge    else_top                            //if i_r >= w25, jump to else_top                                                      

    mov     w0, c_r                             //move c to w0                                                   
    bl      ungetch                             //branch to ungetch                                                          

    mov     w11, '\0'                           //move '/0' to w11                                                   
    add     x14, fp, 16                         //loading to x14                                      
    ldr     x26, [x14]                          //loading to x26                                  
    str     w11, [x26, i_r, SXTW 2]             //s[i] = '\0'                          
    mov     w0, NUMBER                          //moving NUMBER to w0                                                
    b       top_end                                                            

else_top:                             
    cmp     c_r, '\n'                           //compare c_r and '\n'                                                     
    b.eq    out2                                //if c == '\n', branch to out2                                              

    cmp     c_r, -1                             //compare c_r and -1(EOF)                                                    
    b.eq    out2                                //if c_r == -1, branch to out2                                      

    bl      getchar                             //call to getchar                                                        
    mov     c_r, w0                             //c_r = getchar()                                                  
    b       else_top                            //branch else_top                                                 

out2:               
    mov     w11, '\0'                           //moving '\0' to w11                                                 
    add     x14, fp, 16                         //x14 = fp + 16                                               
    ldr     x26, [x14]                          //loading s to x26                                                  
    str     w11, [x26, w25, SXTW 2]             //s[lim - 1] = '\0'                                 
    sub     w25, w25, 1                         //lim - 1                                        
    mov     w0, TOOBIG                          //move TOOBIG to w0                                       

top_end:             
    ldp     fp, lr, [sp], dealloc
    ret                                         //return                                              


            .balign 4
            .global getch                       //make visible to linker
getch:              
    stp     fp, lr, [sp, -16]!
    mov     fp, sp

    adrp    x9, bufp                                                       
    add     x9, x9, :lo12:bufp                                              
    ldr     w10, [x9]                           //load bufp to w10                                                 

    cmp     w10, 0                              //compare w10(bufp) and 0                                                    
    b.le    else_getch                          //if bufp =< 0, jump to else_getch                                

    sub     w10, w10, 1                         //--bufp                                                  
    adrp    x27, buf                                               
    add     x27, x27, :lo12:buf                                             
    ldr     w0, [x27, w10, SXTW 2]              //buf[--bufp]                                      
    str     w10, [x9]                           //store new value of bufp                                                

    b       getch_end                           //branch to getch_end                                                          

else_getch:            
    bl      getchar                             //call to getchar                                                  

getch_end:             
    ldp     fp, lr, [sp], 16
    ret                                         //return                                                        
           
                                                   
            .balign 4
            .global ungetch                     //make visible to linker   
ungetch:            
    stp     fp, lr, [sp, -16]!
    mov     fp, sp

    mov     w26, w0                             //move w0(c) to w26                                                 

    adrp    x9, bufp
    add     x9, x9, :lo12:bufp                                              
    ldr     w10, [x9]                           //storing bufp into w10                                                   
                               
    cmp     w10, BUFSIZE                        //compare w10 and BUFSIZE                                                 
    b.le    u_else                              //if bufp =< BUFSIZE, jump to u_else                                            

    adrp    x0, ungetchError                    //print                                            
    add     x0, x0, :lo12:ungetchError                                       
    bl      printf                              //call to printf                                                         

    b       u_if                                //branch to u_if                                                          

u_else:             
    adrp    x27, buf                                                       
    add     x27, x27, :lo12:buf                                             
    str     w26, [x27, w10, SXTW 2]             //buf[bufp++] = c                                    

    add     w10, w10, 1                                                                          
    str     w10, [x9]                           //storing new value of bufp                                                   

u_if:               
    ldp     fp, lr, [sp], 16
    ret                                         //return to OS
