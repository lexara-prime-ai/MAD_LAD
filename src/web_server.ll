; Module -> Basic Web Server
; Author -> Irfan Ghat
; Year -> 2024

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
@.debug_socket_creation = private unnamed_addr constant [20 x i8] c"Socket created: %d\0A\00"
@.debug_bind_success = private unnamed_addr constant [17 x i8] c"Bind succeeded!\0A\00"
@.debug_listen_success = private unnamed_addr constant [19 x i8] c"Listening on port\0A\00"
@.debug_client_accepted = private unnamed_addr constant [29 x i8] c"Client connection accepted!\0A\00"
@.debug_bind_failed = private unnamed_addr constant [14 x i8] c"Bind failed!\0A\00"

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

; htons implementation to convert host byte order to network byte order
define i16 @htons(i16 %port) {
entry:
    %shifted = lshr i16 %port, 8              ; Shift 8 bits to the right
    %masked = and i16 %port, 255              ; Mask lower 8 bits
    %network_order = shl i16 %masked, 8       ; Shift lower bits to high
    %result = or i16 %network_order, %shifted ; Combine both parts
    ret i16 %result
}

; Bind socket
define i32 @bind_socket(i32 %sock_fd) {
entry:
    %addr = alloca [16 x i8]               ; Memory for sockaddr_in structure
    %ptr = bitcast [16 x i8]* %addr to i8*  ; Pointer to struct

    ; Set sin_family to AF_INET (2)
    %sin_family_ptr = getelementptr [16 x i8], [16 x i8]* %addr, i32 0, i32 0
    %sin_family_cast = bitcast i8* %sin_family_ptr to i16*
    store i16 2, i16* %sin_family_cast

    ; Set sin_port to htons(8888)
    %htons_port = call i16 @htons(i16 8888)  ; Convert 8888 to network byte order
    %sin_port_ptr = getelementptr [16 x i8], [16 x i8]* %addr, i32 0, i32 2
    %sin_port_cast = bitcast i8* %sin_port_ptr to i16*
    store i16 %htons_port, i16* %sin_port_cast

    ; Set sin_addr to INADDR_ANY (0)
    %sin_addr_ptr = getelementptr [16 x i8], [16 x i8]* %addr, i32 0, i32 4
    %sin_addr_cast = bitcast i8* %sin_addr_ptr to i32*
    store i32 0, i32* %sin_addr_cast

    ; Call bind function
    %bind_result = call i32 @bind(i32 %sock_fd, i8* %ptr, i32 16)
    
    ; Check bind result
    %is_bind_error = icmp ne i32 %bind_result, 0
    br i1 %is_bind_error, label %bind_failed, label %bind_success

bind_failed:
    ; Debug: print bind failed
    %fail_msg = getelementptr [22 x i8], [22 x i8]* @.debug_bind_failed, i32 0, i32 0
    call i32 @printf(i8* %fail_msg)
    ret i32 -1

bind_success:
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

    ; HTTP response content: "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nAre you YouTuber?"
    store [57 x i8] c"HTTP/1.1 200 OK\0D\0AContent-Length: 13\0D\0A\0D\0AAre you YouTuber?\00", [57 x i8]* %response

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

