INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 5000
.data
header byte "ENCRYPTION AND DECRYPTION", 0
buffer BYTE BUFFER_SIZE DUP(?)
text_filename BYTE 80 DUP(0)
text_fileHandle HANDLE ?
encrypted_filename BYTE "encrypted.txt", 0
encrypted_fileHandle HANDLE ?
decrypted_filename BYTE "decrypted.txt", 0
decrypted_filehandle HANDLE ?
ciphertext byte BUFFER_SIZE dup(?)
plaintext byte BUFFER_SIZE dup(?)
text_length dword ?


.code
main PROC

Menu:

;*-----------Horizontal Line Border----------*

mov  dl,26 ;column
mov  dh,23  ;row
call Gotoxy
mov ecx, 40

lp:
	mov al, '^'
	call writechar
	loop lp

mov ecx, 40
mov  dl,26 ;column
mov  dh,2  ;row
call Gotoxy

lp1:				
	mov al, '^'
	call writechar
	inc dl
	loop lp1
	
;*-----------Vertical Line Border--------------*

mov ecx, 22

lp2:					
	mov  dl,25 ;column
	call Gotoxy
	mov al, '^'
	call writechar
	mov  dl,65 ;column
	call Gotoxy
	mov al, '^'
	call writechar
	inc dh
	loop lp2



;*---------Display Menu----------*

mov  dl,32  ;column
mov  dh,4  ;row
call Gotoxy

mov edx, offset header
call writestring
call crlf

mov ecx, 25
mov  dl,32  ;column
mov  dh,5  ;row
call Gotoxy

lp3:
	mov al, '='
	call writechar
	loop lp3

mov  dl,30  ;column
mov  dh,8  ;row
call Gotoxy

mWrite <"[1] CIESER ENCRYPTION",0dh,0ah>

call crlf
call crlf
mov  dl,30  ;column
mov  dh,11  ;row
call Gotoxy

mWrite <"[2] ROT13 ENCRYPTION",0dh,0ah>

call crlf
call crlf
mov  dl,30  ;column
mov  dh,14  ;row
call Gotoxy

mWrite <"[3] CIESER DECRYPTION",0dh,0ah>

call crlf
call crlf
mov  dl,30  ;column
mov  dh,17  ;row
call Gotoxy

mWrite <"[4] ROT13 DECRYPTION",0dh,0ah>

call crlf
call crlf
mov  dl,30  ;column
mov  dh,20  ;row
call Gotoxy

mWrite <"[5] EXIT",0dh,0ah>

call crlf
call crlf
mov  dl,25  ;column
mov  dh,24  ;row
call Gotoxy

mWrite <"Enter your choice: ",0dh,0ah>

mov  dl,45  ;column
mov  dh,24  ;row
call Gotoxy
call readint

mov dl, 0
mov dh, 0
call gotoxy
call clrscr

;*------------Selecting Function from menu------------*

cmp eax, 1
je ceiser_encryption

cmp eax, 2
je rot_13_encryption

cmp eax, 3
je ceiser_decryption

cmp eax, 4
je rot_13_decryption

cmp eax, 5
je Exit_process


;*----------Cieser Encryption Function---------*

ceiser_encryption:

;*-----------User enters file name-----------*

mWrite <"Enter an input filename: ",0dh,0ah>
mov edx,OFFSET text_filename
mov ecx,SIZEOF text_filename
call ReadString

;*------------Open file for input------------*

mov edx,OFFSET text_filename
call OpenInputFile
mov text_fileHandle,eax
push eax

;*-------------Error checking----------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok1; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*----------Read file into buffer-------------*

file_ok1:
	mov edx,OFFSET buffer
	mov ecx,BUFFER_SIZE
	call ReadFromFile
	pop eax
	call CloseFile 

;*---------Counting Length of text-------------*

mov ebx, OFFSET buffer
mov ecx, 0

count_length1:
	mov al, [ebx]
	cmp al, 0
	je end_length1
	inc ebx
	inc ecx
	jmp count_length1

end_length1:
	mov text_length, ecx
	mov esi, offset ciphertext
	mov ebx, offset buffer
	mov ecx, text_length

;*-------Applying Cieser Encryption----------*

cieser_enc_loop:
	mov al, [ebx]
	cmp al, ' '
	je end_cieser_enc_loop
	cmp al, '.'
	je end_cieser_enc_loop
	cmp al, 'z'
	je cieser_enc_dec
	cmp al, 'Z'
	je cieser_enc_dec
	cmp al, 'y'
	je cieser_enc_dec
	cmp al, 'Y'
	je cieser_enc_dec
	cmp al, 'x'
	je cieser_enc_dec
	cmp al, 'X'
	je cieser_enc_dec
	add al, 3
	jmp end_cieser_enc_loop

	cieser_enc_dec:
		sub al, 23	
		jmp end_cieser_enc_loop

	end_cieser_enc_loop:
		mov [esi], al
		inc esi
		inc ebx
		loop cieser_enc_loop

;*---------Displaying Message------------*

mWrite <"FILE ENCRYPTED SUCCESSFULLY.",0dh,0ah>

;*----------Create a new text file----------*

mov edx,OFFSET encrypted_filename
call CreateOutputFile
mov encrypted_fileHandle,eax
push eax

;*----------Error checking------------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok2; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*-------Write buffer to output file-------*

file_ok2:
	mov eax, encrypted_fileHandle
	mov edx,OFFSET ciphertext
	mov ecx, text_length
	call WriteToFile
	pop eax
	call CloseFile
	call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process


;*------------Cieser Decryption Function---------*

ceiser_decryption:

;*-----------User enters file name-----------*

mWrite <"Enter an input filename: ",0dh,0ah>
mov edx,OFFSET encrypted_filename
mov ecx,SIZEOF encrypted_filename
call ReadString

;*---------Open file for input-------------*

mov edx,OFFSET encrypted_filename
call OpenInputFile
mov encrypted_fileHandle,eax
push eax

;*------------Error checking-----------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok3; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*-----------Read file into buffer-----------*

file_ok3:
	mov edx,OFFSET buffer
	mov ecx, BUFFER_SIZE
	call ReadFromFile
	pop eax
	call CloseFile 

;*------Counting Text Length----------------*

mov ebx, OFFSET buffer
mov ecx, 0

count_length2:
	mov al, [ebx]
	cmp al, 0
	je end_length2
	inc ebx
	inc ecx
	jmp count_length2

end_length2:
	mov text_length, ecx
	mov ebx, offset buffer
	mov esi, offset plaintext
	mov ecx, text_length


;*--------Applying Cieser Decryption------------*

cieser_dec_loop:
	mov al, [ebx]
	cmp al, ' '
	je end_cieser_dec_loop
	cmp al, '.'
	je end_cieser_dec_loop
	cmp al, 'a'
	je cieser_dec_inc
	cmp al, 'A'
	je cieser_dec_inc
	cmp al, 'b'
	je cieser_dec_inc
	cmp al, 'B'
	je cieser_dec_inc
	cmp al, 'c'
	je cieser_dec_inc
	cmp al, 'C'
	je cieser_dec_inc
	sub al, 3
	jmp end_cieser_dec_loop

	cieser_dec_inc:
		add al, 23	
		jmp end_cieser_dec_loop

	end_cieser_dec_loop:
		mov [esi], al
		inc esi
		inc ebx
		loop cieser_dec_loop

;*-------Displaying Message------------*
		
mWrite <"FILE DECRYPTED SUCCESSFULLY.",0dh,0ah>

;*---------Create a new text file-------*

mov edx,OFFSET decrypted_filename
call CreateOutputFile
mov decrypted_filehandle,eax
push eax

;*-----------Error checking-------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok4; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*--------Write buffer to output file--------*

file_ok4:
	mov eax,decrypted_filehandle
	mov edx,OFFSET plaintext
	mov ecx, text_length
	call WriteToFile
	pop eax
	call CloseFile
	call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process


;*----------Rot13 Encryption Function--------------*

rot_13_encryption:

;*--------User enters file name-------------*

mWrite <"Enter an input filename: ",0dh,0ah>
mov edx,OFFSET text_filename
mov ecx,SIZEOF text_filename
call ReadString

;*------------Open file for input----------*

mov edx,OFFSET text_filename
call OpenInputFile
mov text_fileHandle,eax
push eax

;*------------Error checking----------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok5; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*------------Read file into buffer------------*

file_ok5:
	mov edx,OFFSET buffer
	mov ecx,BUFFER_SIZE
	call ReadFromFile
	pop eax
	call CloseFile 

;*----------Counting Text Length-----------------*

mov ebx, OFFSET buffer
mov ecx, 0

count_length3:
	mov al, [ebx]
	cmp al, 0
	je end_length3
	inc ebx
	inc ecx
	jmp count_length3

end_length3:
	mov text_length, ecx
	mov esi, offset ciphertext
	mov ebx, offset buffer
	mov ecx, text_length

;*-------Applying Rot13 Encryption------------*

rot13_enc_loop:
	mov ax, 0
	mov al, [ebx]
	cmp al, ' '
	je end_rot13_enc_loop
	cmp al, '.'
	je end_rot13_enc_loop
	push ecx
	cmp al, 90
	jg lowercase

	sub al, 'A'
	add al, 13
	mov ch, 26
	div ch
	mov al, ah
	add al, 'A'
	pop ecx
	jmp end_rot13_enc_loop

	lowercase:
		sub al, 'a'
		add al, 13
		mov ch, 26
		div ch
		mov al, ah
		add al, 'a'
		pop ecx

	end_rot13_enc_loop:
		mov [esi], al
		inc esi
		inc ebx
		loop rot13_enc_loop

;*----------Displaying Message------------*

mWrite <"FILE ENCRYPTED SUCCESSFULLY.",0dh,0ah>

;*-----------Create a new text file---------------*

mov edx,OFFSET encrypted_filename
call CreateOutputFile
mov encrypted_fileHandle,eax
push eax

;*------------Error checking-------------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok6; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*------------Write buffer to output file------------*

file_ok6:
	mov eax, encrypted_fileHandle
	mov edx,OFFSET ciphertext
	mov ecx, text_length
	call WriteToFile
	pop eax
	call CloseFile
	call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process



;*-----------Rot13 Decryption Function-----------*

rot_13_decryption:

;*----------User enters file name-----------*

mWrite <"Enter an input filename: ",0dh,0ah>
mov edx,OFFSET encrypted_filename
mov ecx,SIZEOF encrypted_filename
call ReadString

;*----------Open file for input---------------*

mov edx,OFFSET encrypted_filename
call OpenInputFile
mov encrypted_fileHandle,eax
push eax

;*-----------Error checking----------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok7; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*-----------Read file into buffer----------*

file_ok7:
	mov edx,OFFSET buffer
	mov ecx,BUFFER_SIZE
	call ReadFromFile
	pop eax
	call CloseFile 

;*----------Counting Text Length-----------------*

mov ebx, OFFSET buffer
mov ecx, 0

count_length4:
	mov al, [ebx]
	cmp al, 0
	je end_length4
	inc ebx
	inc ecx
	jmp count_length4

end_length4:
	mov text_length, ecx
	mov esi, offset plaintext
	mov ebx, offset buffer
	mov ecx, text_length

;*-----------Applying Rot13 Decryption--------------*

rot13_dec_loop:
	mov ax, 0
	mov al, [ebx]
	cmp al, ' '
	je end_rot13_dec_loop
	cmp al, '.'
	je end_rot13_dec_loop
	push ecx
	cmp al, 91
	jl uppercase

	sub al, 'a'
	add al, 13
	mov ch, 26
	div ch
	mov al, ah
	add al, 'a'
	pop ecx
	jmp end_rot13_dec_loop

	uppercase:
		sub al, 'A'
		add al, 13
		mov ch, 26
		div ch
		mov al, ah
		add al, 'A'
		pop ecx

	end_rot13_dec_loop:
		mov [esi], al
		inc esi
		inc ebx
		loop rot13_dec_loop


;*----------Displaying Message------------*

mWrite <"FILE DECRYPTED SUCCESSFULLY.",0dh,0ah>

;*------------Create a new text file------------*

mov edx,OFFSET decrypted_filename
call CreateOutputFile
mov decrypted_fileHandle,eax
push eax

;*-------------Error checking--------------------*

cmp eax, INVALID_HANDLE_VALUE; Found an error?
jne file_ok8; No: skip
mWrite <"Invalid file name.",0dh,0ah>
call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*-----------Write buffer to output file---------*

file_ok8:
	mov eax, decrypted_fileHandle
	mov edx,OFFSET plaintext
	mov ecx, text_length
	call WriteToFile
	pop eax
	call CloseFile
	call crlf

;*--------Checking whether to go to menu or to exit program------------*

mWrite <"press 1 key to go back to menu or else press 0",0dh,0ah>
call readint
call clrscr
cmp eax, 1
je menu
jmp Exit_process

;*----------Terminating Program------------*

Exit_process:
	call clrscr
	mWrite < "Group Members: ",0dh,0ah>
	mWrite < "--------------",0dh,0ah>
	call crlf
	mWrite < "Abdullah Naeem (20K-0496)",0dh,0ah>
	mWrite < "Muhammad Aamir (20K-0357)",0dh,0ah>
	invoke ExitProcess,0 

main endp
exit
END main