.MODEL SMALL          
.STACK 100H          
.DATA

    
    msg_prompt   DB '==============================', 13, 10
                 DB '   8086 ASSEMBLY CALCULATOR   ', 13, 10
                 DB '==============================', 13, 10, '$'

    msg_num1     DB 13, 10, 'Enter first number  : $'
    msg_num2     DB 13, 10, 'Enter second number : $'
    msg_op_ask   DB 13, 10, 'Choose operation (+, -, *, /): $'
    msg_result   DB 13, 10, 'Result = $'
    msg_newline  DB 13, 10, '$'
    msg_neg      DB '-$'                            
    msg_divzero  DB 13, 10, '  [ERROR] Division by zero! $'
    msg_invalid  DB 13, 10, '  [ERROR] Invalid operator!  $'
    msg_again    DB 13, 10, 'Calculate again? (y/n): $'
    msg_bye      DB 13, 10, 'Goodbye!', 13, 10, '$'
    msg_overflow DB 13, 10, '  [NOTE] Result may be large (showing lower 16 bits) $'

   
    num1        DW 0        
    num2        DW 0        
    op_char     DB 0        
    neg_flag    DB 0        

.CODE
MAIN PROC
    
    MOV  AX, @DATA
    MOV  DS, AX

    LEA  DX, msg_prompt     
    MOV  AH, 09H            
    INT  21H                

CALC_LOOP:

    
    
    LEA  DX, msg_num1
    MOV  AH, 09H
    INT  21H

    CALL READ_NUMBER        
    MOV  num1, AX   
	
	MOV  neg_flag, 0
   
    LEA  DX, msg_num2
    MOV  AH, 09H
    INT  21H

    CALL READ_NUMBER
    MOV  num2, AX

    LEA  DX, msg_op_ask
    MOV  AH, 09H
    INT  21H

    MOV  AH, 01H            
    INT  21H
    MOV  op_char, AL        

    LEA  DX, msg_newline
    MOV  AH, 09H
    INT  21H

    
    MOV  AX, num1          
    MOV  BX, num2          
   
    CMP  op_char, '+'
    JE   DO_ADD

    CMP  op_char, '-'
    JE   DO_SUB

    CMP  op_char, '*'
    JE   DO_MUL

    CMP  op_char, '/'
    JE   DO_DIV

   
    LEA  DX, msg_invalid
    MOV  AH, 09H
    INT  21H
    JMP  ASK_AGAIN

DO_ADD:
    ADD  AX, BX             ; AX = num1 + num2
    JMP  SHOW_RESULT


DO_SUB:
    SUB  AX, BX             

    JNS  SUB_POSITIVE       

    
    NEG  AX                 
    MOV  neg_flag, 1        

SUB_POSITIVE:
    JMP  SHOW_RESULT


DO_MUL:
    MOV  DX, 0              
    MUL  BX                 

    
    CMP  DX, 0
    JE   MUL_OK

    LEA  DX, msg_overflow  
    MOV  AH, 09H
    INT  21H
    MOV  AX, num1           
    MOV  BX, num2
    MOV  DX, 0
    MUL  BX                 

MUL_OK:
    
    JMP  SHOW_RESULT

DO_DIV:
    CMP  BX, 0              
    JE   DIV_BY_ZERO

    MOV  DX, 0             
    DIV  BX                 

    JMP  SHOW_RESULT

DIV_BY_ZERO:
    LEA  DX, msg_divzero
    MOV  AH, 09H
    INT  21H
    JMP  ASK_AGAIN


SHOW_RESULT:

    
    PUSH AX                 
    LEA  DX, msg_result
    MOV  AH, 09H
    INT  21H
    POP  AX                 

    
    CMP  neg_flag, 1
    JNE  PRINT_POS

    PUSH AX
    LEA  DX, msg_neg
    MOV  AH, 09H
    INT  21H
    POP  AX

PRINT_POS:
    CALL PRINT_NUMBER       

    LEA  DX, msg_newline
    MOV  AH, 09H
    INT  21H


ASK_AGAIN:
    LEA  DX, msg_again
    MOV  AH, 09H
    INT  21H

    MOV  AH, 01H            
    INT  21H
    ; AL = character entered

    LEA  DX, msg_newline
    MOV  AH, 09H
    INT  21H

    CMP  AL, 'y'
    JE   REPEAT_YES         
    CMP  AL, 'Y'
    JE   REPEAT_YES         

    
    LEA  DX, msg_bye
    MOV  AH, 09H
    INT  21H

    MOV  AH, 4CH            
    MOV  AL, 0              
    INT  21H


REPEAT_YES:
    JMP  CALC_LOOP          

MAIN ENDP

READ_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV  BX, 0              

READ_DIGIT:
    MOV  AH, 01H           
    INT  21H
    

    CMP  AL, 13             
    JE   READ_DONE          

    CMP  AL, '0'            
    JB   READ_DIGIT
    CMP  AL, '9'            
    JA   READ_DIGIT

    
    SUB  AL, '0'            
    MOV  AH, 0              
    MOV  CX, AX             

    
    MOV  AX, BX            
    MOV  DX, 10
    MUL  DX                
    ADD  AX, CX             
    MOV  BX, AX            

    JMP  READ_DIGIT

READ_DONE:
    MOV  AX, BX            
    POP  DX
    POP  CX
    POP  BX
    RET
READ_NUMBER ENDP

PRINT_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX

    MOV  BX, 10             
    MOV  CX, 0             

    
    CMP  AX, 0
    JNE  EXTRACT_DIGITS

    MOV  DL, '0'
    MOV  AH, 02H            
    INT  21H
    JMP  PRINT_DONE

EXTRACT_DIGITS:
   
    CMP  AX, 0
    JE   PRINT_STACK        

    MOV  DX, 0
    DIV  BX                 
    PUSH DX                 
    INC  CX                 
    JMP  EXTRACT_DIGITS

PRINT_STACK:
    
    CMP  CX, 0
    JE   PRINT_DONE

    POP  DX                 
    ADD  DL, '0'            
    MOV  AH, 02H            
    INT  21H
    DEC  CX
    JMP  PRINT_STACK

PRINT_DONE:
    POP  DX
    POP  CX
    POP  BX
    RET
PRINT_NUMBER ENDP

END MAIN                    
