
INCLUDE Irvine32.inc
.data

arr BYTE 50 DUP(?)
arr2 BYTE 50 DUP(?)
letters BYTE "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",0
bool DWORD 0

array BYTE 100 DUP(?)
col DWORD 0
row DWORD 0
message BYTE "Enter array size: ",0

.code
main PROC
	
	call q4
	
	call crlf
exit
main ENDP

q1 PROC
	
	mov edx,offset arr
	mov ecx,lengthof arr	
	call readString
	
	mov ecx,eax
	mov esi,0
	mov edi,0
	mov edx,0
	l:
		mov al,' '
		movzx ebx,arr[esi]
		cmp bl,al
		je l2
			inc bool
			push ebx
			inc edi
			jmp ls
		l2:
		mov ebx,0
		cmp bool,ebx
		je l3
			mov ebx,ecx
			mov ecx,edi
			l4:
				mov eax,0
				pop eax
				mov arr[edx],al
				inc edx
			loop l4
			inc edx
			mov ecx,ebx
			mov edi,0
			mov bool,0
			jmp ls
		l3:
			mov arr[edx],al
			inc edx
		ls:
		inc esi
	loop l

	mov ebx,0
	cmp bool,ebx
	je p
	mov ebx,ecx
	mov ecx,edi
	l5:
		mov eax,0
		pop eax
		mov arr[edx],al
		inc edx
	loop l5
	inc edx
	mov ecx,ebx
	mov edi,0
	p:
	mov edx,offset arr
	call writeString

ret
q1 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Q2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

q2 PROC
	mov edx,offset arr
	mov ecx,lengthof arr	
	call readString
	
	mov ecx,eax
	mov esi,0
	mov ebx,0
	mov edx,0
	l:
	push ecx
		cld
		mov edi,offset letters
		mov ecx,lengthof letters
		movzx eax,arr[esi]
		repne scasb
		jne next
			inc ebx
			mov edx,bool
			mov al,arr[esi]
			mov arr2[edx],al
			inc bool
			jmp next2
		next:
			mov eax,0
			cmp ebx,eax
			je next2

			mov edx,offset arr2
			add edx,bool
			sub edx,ebx
			call writeString
			call crlf
			mov ebx,0
		next2:
		inc esi
	pop ecx
	loop l

ret
q2 ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Q3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ques3 PROC
	mov edx,offset arr
	mov ecx,lengthof arr	
	call readString
	mov ecx,eax

	mov esi,0
	mov edi,1
	mov ebx,ecx
	tt1:
		cmp edi,ebx
		jae tch
		
		push ecx
		mov ecx,ebx
		
		sub ecx,edi
		tt2:
			mov al,' '
			call writeChar
		loop tt2
		
		mov esi,0
		mov ecx,edi
		mov eax,0
		cmp ecx,eax
		jle tt23
		tt3:
			mov al,arr[esi]
			call writeChar
			inc esi
		loop tt3
		tt23:
		call crlf
		inc edi

		pop ecx
	loop tt1
	tch:

	mov edx,offset arr
	call writeString
	call crlf

	mov esi,1
	mov ecx,ebx
	dec ecx
	ntt:
		mov edx,offset arr
		add edx,esi
		call writeString
		call crlf
		inc esi
	loop ntt

ret
ques3 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; q4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
q4 PROC
	mov edx,offset message
	call writeString
	call readInt
	mov row,eax
	call readInt
	mov col,eax

	
ret
q4 ENDP


END main
