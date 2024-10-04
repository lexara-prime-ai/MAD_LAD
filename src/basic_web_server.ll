; Module -> Basic Web Server
; Author -> Irfan Ghat
; Year -> 2024

; ; Declare external Winsock functions
; declare i32 @WSAStartup(i16, i8*) #1
; declare i32 @WSACleanup() #1
; declare i32 @socket(i32, i32, i32) #1
; declare i32 @bind(i32, i8*, i32) #1
; declare i32 @listen(i32, i32) #1
; declare i32 @accept(i32, i8*, i32*) #1
; declare i32 @send(i32, i8*, i32, i32) #1

; ; Initialize Winsock
; define i32 @initialize_winsock() {
; entry:
;     %wsadata = alloca [64 x i8]           ; Allocate memory for WSAData structure
;     %result = call i32 @WSAStartup(i16 514, i8* %wsadata) ; Use decimal 514 for Winsock version 2.2
;     ret i32 %result
; }

; define void @cleanup_winsock() {
; entry:
;     call i32 @WSACleanup()
;     ret void
; }

; ; Create socket
; define i32 @create_socket() {
; entry:
;     %sock_fd = call i32 @socket(i32 2, i32 1, i32 0) ; AF_INET, SOCK_STREAM, IPPROTO_TCP
;     ret i32 %sock_fd
; }

; ; Bind socket (using hardcoded values for simplicity)
; define i32 @bind_socket(i32 %sock_fd) {
; entry:
;     %addr = alloca [16 x i8]               ; Memory for sockaddr_in structure
;     %ptr = bitcast [16 x i8]* %addr to i8*  ; Pointer to struct

;     ; Assume the sockaddr_in structure is filled in with port and address
;     %bind_result = call i32 @bind(i32 %sock_fd, i8* %ptr, i32 16)
;     ret i32 %bind_result
; }

; ; Listen for incoming connections
; define i32 @listen_for_connections(i32 %sock_fd) {
; entry:
;     %listen_result = call i32 @listen(i32 %sock_fd, i32 10) ; backlog of 10
;     ret i32 %listen_result
; }

; ; Accept a connection
; define i32 @accept_connection(i32 %sock_fd) {
; entry:
;     %client_fd = call i32 @accept(i32 %sock_fd, i8* null, i32* null)
;     ret i32 %client_fd
; }

; ; Send HTTP response
; define void @send_http_response(i32 %client_fd) {
; entry:
;     %response = alloca [48 x i8]
;     %resp_ptr = bitcast [48 x i8]* %response to i8*

;     ; HTTP response content: "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nHello, world!"
;     store [53 x i8] c"HTTP/1.1 200 OK\0D\0AContent-Length: 13\0D\0A\0D\0AHello, world!\00", [53 x i8]* %response

;     ; Send the response using Winsock's send()
;     call i32 @send(i32 %client_fd, i8* %resp_ptr, i32 48, i32 0)
;     ret void
; }

; ; Main function
; define i32 @main() {
; entry:
;     ; Initialize Winsock
;     %init_result = call i32 @initialize_winsock()

;     ; Check Winsock initialization result
;     %is_error = icmp ne i32 %init_result, 0
;     br i1 %is_error, label %cleanup, label %create_socket

; create_socket:
;     ; Create socket
;     %sock_fd = call i32 @create_socket()
    
;     ; Bind socket
;     %bind_result = call i32 @bind_socket(i32 %sock_fd)
    
;     ; Listen for connections
;     %listen_result = call i32 @listen_for_connections(i32 %sock_fd)
;     br label %loop

; loop:
;     ; Accept a connection
;     %client_fd = call i32 @accept_connection(i32 %sock_fd)
    
;     ; Send HTTP response
;     call void @send_http_response(i32 %client_fd)
    
;     ; Go back to accept new connections
;     br label %loop

; cleanup:
;     ; Cleanup Winsock
;     call void @cleanup_winsock()
;     ret i32 0
; }

; Declare external Winsock functions
declare i32 @WSAStartup(i16, i8*) #1
declare i32 @WSACleanup() #1
declare i32 @socket(i32, i32, i32) #1
declare i32 @bind(i32, i8*, i32) #1
declare i32 @listen(i32, i32) #1
declare i32 @accept(i32, i8*, i32*) #1
declare i32 @send(i32, i8*, i32, i32) #1
declare i32 @printf(i8*, ...) #1  ; Add printf to output debug info

@.debug_winsock_init = private unnamed_addr constant [25 x i8] c"Initializing Winsock...\0A\00"
@.debug_socket_creation = private unnamed_addr constant [23 x i8] c"Socket created: %d\0A\00"
@.debug_bind_success = private unnamed_addr constant [19 x i8] c"Bind succeeded!\0A\00"
@.debug_listen_success = private unnamed_addr constant [19 x i8] c"Listening on port\0A\00"
@.debug_client_accepted = private unnamed_addr constant [26 x i8] c"Client connection accepted!\0A\00"

; Initialize Winsock
define i32 @initialize_winsock() {
entry:
    %wsadata = alloca [64 x i8]           ; Allocate memory for WSAData structure
    %result = call i32 @WSAStartup(i16 514, i8* %wsadata) ; Use decimal 514 for Winsock version 2.2

    ; Debug: print initializing Winsock
    %debug_msg = getelementptr [25 x i8], [25 x i8]* @.debug_winsock_init, i32 0, i32 0
    call i32 @printf(i8* %debug_msg)

    ret i32 %result
}

define void @cleanup_winsock() {
entry:
    call i32 @WSACleanup()
    ret void
}

; Create socket
define i32 @create_socket() {
entry:
    %sock_fd = call i32 @socket(i32 2, i32 1, i32 0) ; AF_INET, SOCK_STREAM, IPPROTO_TCP
    
    ; Debug: print socket file descriptor
    %debug_msg = getelementptr [23 x i8], [23 x i8]* @.debug_socket_creation, i32 0, i32 0
    call i32 @printf(i8* %debug_msg, i32 %sock_fd)
    
    ret i32 %sock_fd
}

; Bind socket
define i32 @bind_socket(i32 %sock_fd) {
entry:
    %addr = alloca [16 x i8]               ; Memory for sockaddr_in structure
    %ptr = bitcast [16 x i8]* %addr to i8*  ; Pointer to struct

    ; Assume the sockaddr_in structure is filled in with port and address
    %bind_result = call i32 @bind(i32 %sock_fd, i8* %ptr, i32 16)
    
    ; Debug: print bind success
    %debug_msg = getelementptr [19 x i8], [19 x i8]* @.debug_bind_success, i32 0, i32 0
    call i32 @printf(i8* %debug_msg)

    ret i32 %bind_result
}

; Listen for incoming connections
define i32 @listen_for_connections(i32 %sock_fd) {
entry:
    %listen_result = call i32 @listen(i32 %sock_fd, i32 10) ; backlog of 10

    ; Debug: print listen success
    %debug_msg = getelementptr [19 x i8], [19 x i8]* @.debug_listen_success, i32 0, i32 0
    call i32 @printf(i8* %debug_msg)

    ret i32 %listen_result
}

; Accept a connection
define i32 @accept_connection(i32 %sock_fd) {
entry:
    %client_fd = call i32 @accept(i32 %sock_fd, i8* null, i32* null)
    
    ; Debug: client accepted
    %debug_msg = getelementptr [26 x i8], [26 x i8]* @.debug_client_accepted, i32 0, i32 0
    call i32 @printf(i8* %debug_msg)

    ret i32 %client_fd
}

; Send HTTP response
define void @send_http_response(i32 %client_fd) {
entry:
    %response = alloca [53 x i8]
    %resp_ptr = bitcast [53 x i8]* %response to i8*

    ; HTTP response content: "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nHello, world!"
    store [53 x i8] c"HTTP/1.1 200 OK\0D\0AContent-Length: 13\0D\0A\0D\0AHello, world!\00", [53 x i8]* %response

    ; Send the response using Winsock's send()
    call i32 @send(i32 %client_fd, i8* %resp_ptr, i32 53, i32 0)
    ret void
}

; Main function
define i32 @main() {
entry:
    ; Initialize Winsock
    %init_result = call i32 @initialize_winsock()

    ; Check Winsock initialization result
    %is_error = icmp ne i32 %init_result, 0
    br i1 %is_error, label %cleanup, label %create_socket

create_socket:
    ; Create socket
    %sock_fd = call i32 @create_socket()
    
    ; Bind socket
    %bind_result = call i32 @bind_socket(i32 %sock_fd)
    
    ; Listen for connections
    %listen_result = call i32 @listen_for_connections(i32 %sock_fd)
    br label %loop

loop:
    ; Accept a connection
    %client_fd = call i32 @accept_connection(i32 %sock_fd)
    
    ; Send HTTP response
    call void @send_http_response(i32 %client_fd)
    
    ; Go back to accept new connections
    br label %loop

cleanup:
    ; Cleanup Winsock
    call void @cleanup_winsock()
    ret i32 0
}

