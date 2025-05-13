/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Benzen Raspur"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */

    /*r0 = ptrToInputText r1 = key (from 0 to 25 abc)*/
    LDR   r2, =cipherText   /*r2 output buffer*/
    MOV   r5, r2            /*r5 holds base addr and to return later*/

    /*MAIN LOOP*/
loop_start:
    LDRB  r3, [r0], #1      /*r3 increment r0*/
    CMP   r3, #0            /*NULL*/
    BEQ   finish
    /*Uppercase A to Z*/
    CMP   r3, #'A'
    BLT   check_lower
    CMP   r3, #'Z'
    BGT   check_lower
    SUB   r4, r3, #'A'      /*r4 = index 0 to 25*/
    ADD   r4, r4, r1        /*shift*/
    CMP   r4, #26           /*wrap if GREATER or EQUAL to 26*/
    BLT   upper_done
    SUB   r4, r4, #26
upper_done:
    ADD   r3, r4, #'A'      /*back to ascii*/
    B     store_cha

/*Lowercase A to Z*/
check_lower:
    CMP   r3, #'a'
    BLT   store_char        /*not alpha, copy*/
    CMP    r3, #'z'
    BGT   store_char        /*not alpha, copy*/
    SUB   r4, r3, #'a'
    ADD   r4, r4, r1
    CMP   r4, #26
    BLT   lower_done
    SUB   r4, r4, #26
lower_done:
    ADD   r3, r4, #'a'
/*Store the byte*/
    
store_char:
    STRB  r3, [r2], 1      /*cipherText = r3 */
    B     loop_start
    
/*Null and Return*/
finish:
    MOVS   r3, #0            /*Null*/
    STRB  r3, [r2]          /*store at end cipherText*/

    MOV    r0, r5            /*return to cipherText*/


    
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




