; Module -> Basic Math Operations.
; Author -> Irfan Ghat
; Year -> 2024

; Define a method to print the result to the console.
declare i32 @printf(i8*, ...)

; Define a <global> variable to contain our result.
@.str = constant [12 x i8] c"Result: %d\0A\00"

; Define entrypoint for our program.
define i32 @main() {
entry:
    ; Define prefix data.
    %lhs = alloca i32, align 4
    %rhs = alloca i32, align 4
    %result = alloca i32, align 4

    ; Define and initialize integer stores.
    store i32 33, i32* %lhs, align 4, !nontemporal !index
    store i32 36, i32* %rhs, align 4, !nontemporal !index
    
    ; Read from memory.
    %lhs_val = load i32, i32* %lhs, align 4
    %rhs_val = load i32, i32* %rhs, align 4

    ; Create and store the result.
    %result = add i32 %lhs_val, %rhs_val

}



