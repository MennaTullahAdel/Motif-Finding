
INCLUDE Irvine32.inc
.data

bufSize = 5000
buffer byte bufSize DUP(?)
bytesRead DWORD ?
bytewritten DWORD ?
filename byte "TestCase2.txt",0
newfile byte "output.txt",0
filehandle DWORD ?
T DWORD 0
N DWORD 0
L DWORD 0
M DWORD 0
digits byte "0123456789",0

motif byte bufSize Dup(?)
results BYTE bufSize Dup(?)
tmpResults BYTE bufSize Dup(?)
noresults DWORD 0
compMut DWORD bufSize
maxMut DWORD 0
minMut DWORD 0
Smotif DWORD 0
Sseq DWORD 0
Sindex DWORD 0
linesCount DWORD 0
ebxBuff DWORD 0
newebxStore DWORD 0

.code
main PROC

	call openmyfile
	call readmyfile
	call closemyfile
	call splitmyfile
	
	call motifFinding
	
	call indexconvert
	call createmyfile
	call writetomyfile
	call closemyfile

	call printDNA

	call crlf
exit
main ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Create File;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
createmyfile PROC
	mov edx,offset newfile
	call CreateOutputFile
	mov filehandle,eax
ret
createmyfile ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Open File;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openmyfile PROC
	mov edx,offset filename
	call OpenInputfile
	mov filehandle,eax
ret
openmyfile ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Read File;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
readmyfile PROC
	mov eax,filehandle
	mov edx,offset buffer
	mov ecx,bufSize
	call ReadFromFile
	jc show_error_message
		mov bytesRead,eax
		jmp readend
	show_error_message:
		Call WriteWindowsMsg
	readend:
ret
readmyfile ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Write File;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
writetomyfile PROC
	mov eax,filehandle
	mov edx,offset tmpResults
	mov ecx,bufsize
	call WriteToFile
	JC show_error_message_2
		mov bytewritten,eax
		jmp writeend
	show_error_message_2:
		Call WriteWindowsMsg
	writeend:
ret
writetomyfile ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Close File;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
closemyfile PROC
	mov eax,filehandle
	call CloseFile
ret
closemyfile ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Split File;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
splitmyfile PROC
	mov ecx,bytesRead
	mov ebx,0
	mov esi,10
	t1:
		mov eax,0
		mov al,','
		cmp buffer[ebx],al
		je n1

	push ecx
		cld
		mov edi,offset digits
		mov ecx,lengthof digits
		movzx eax,buffer[ebx]
		repne scasb
		jne t2
			 mov eax,T
			 mul esi
			 mov T,eax
			 movzx eax,buffer[ebx]
			 sub eax,48
			 add T,eax
		t2:
		inc ebx
	pop ecx
	loop t1

	n1:		
		inc ebx
		mov eax,0
		mov al,','
		cmp buffer[ebx],al
		je l1

	push ecx
		cld
		mov edi,offset digits
		mov ecx,lengthof digits
		movzx eax,buffer[ebx]
		repne scasb
		jne n2
			 mov eax,N
			 mul esi
			 mov N,eax
			 movzx eax,buffer[ebx]
			 sub eax,48
			 add N,eax
		n2:
	pop ecx
	loop n1

	l1:
		inc ebx
		mov eax,0
		mov al,','
		cmp buffer[ebx],al
		je m1

	push ecx
		cld
		mov edi,offset digits
		mov ecx,lengthof digits
		movzx eax,buffer[ebx]
		repne scasb
		jne l2
			 mov eax,L
			 mul esi
			 mov L,eax
			 movzx eax,buffer[ebx]
			 sub eax,48
			 add L,eax
		l2:
	pop ecx
	loop l1

	m1:
		inc ebx
		mov eax,0
		mov al,','
		cmp buffer[ebx],al
		je dnaStart

	push ecx
		cld
		mov edi,offset digits
		mov ecx,lengthof digits
		movzx eax,buffer[ebx]
		repne scasb
		jne m2
			 mov eax,M
			 mul esi
			 mov M,eax
			 movzx eax,buffer[ebx]
			 sub eax,48
			 add M,eax
		m2:
	pop ecx
	loop m1
	
	dnaStart:
		inc ebx
		mov eax,0
		mov al,'='
		cmp buffer[ebx],al
		je aout
	loop dnaStart

	aout:
	inc ebx
	sub ecx,5
ret
splitmyfile ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Convert index to string;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
indexconvert PROC
	mov esi,0
	mov edi,10
	mov ebx,0
	mov ecx,T
	convertindex:
	push ecx
		mov ecx,0
		movzx eax,results[esi]
		convert:
			mov edx,0
			div edi
			add edx,48
			push edx
			inc ecx
			cmp eax,0
			jz convertend
		jmp convert
		convertend:
			pop eax
			mov tmpResults[ebx],al
			inc ebx
		loop convertend
		mov tmpResults[ebx],' '
		inc ebx
		inc esi
	pop ecx
	loop convertindex
ret
indexconvert ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;print line;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printline PROC
	cmp ebx,edi
	jne newline
		call crlf
		add edi,N
		sub dl,results[esi]
		add edx,N
		inc esi
		add dl,results[esi]
	newline:
ret
printline ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;print DNA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printDNA PROC
	mov esi,0
	mov ebx,ebxBuff
	mov edx,ebx
	add dl,results[esi]
	dec dl
	mov ecx,L
	getmotif:
		mov al,buffer[edx]
		mov motif[esi],al
		inc edx
		inc esi
	loop getmotif
	sub esi,L
	sub edx,L
	mov edi,ebxBuff
	add edi,N
	mov ecx,bytesRead
	sub ecx,ebx

	printing:
		call printline
		cmp bl,dl
		je loon1
			mov eax,white
			call SetTextColor
			jmp loon2
		loon1:
		push ecx
		push esi
			mov esi,0
			mov ecx,L
			mutloon:
				mov al,motif[esi]
				cmp al,buffer[ebx]
				jne bad
					mov eax,yellow
					jmp good
				bad:
					mov eax,gray
				good:
				call SetTextColor
				mov al,buffer[ebx]
				call writeChar
				inc ebx
				inc esi
			loop mutloon
		pop esi
		pop ecx
		sub ecx,L
		inc ecx
		jmp loonend
		loon2:
			mov al,buffer[ebx]
			call writeChar
			inc ebx
		loonend:
	loop printing

	mov eax,white
	call SetTextColor
ret
printDNA ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;motif finding;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
motifFinding PROC
	
	mov ebxBuff,ebx
	mov newebxStore,ebx
	DNA:
		mov noresults,0
		mov eax,N
		sub eax,L
		inc eax
		cmp eax,Smotif
		je finish

		inc Smotif
		mov ebx,newebxStore
		inc newebxStore
		mov esi,0
		mov ecx,L
		motif1:
			mov al,buffer[ebx]
			mov motif[esi],al
			inc ebx
			inc esi
		loop motif1
		
		mov maxMut,0
		mov linesCount,1
		allLines:
			mov ebx,ebxBuff
			mov ecx,linesCount
			nextline:
				add ebx,N
			loop nextline
			mov esi,M
			mov minMut,esi	
			inc linesCount
			mov Sseq,0
			mov Sindex,bufSize
			lineloop:
				mov eax,N
				sub eax,L
				inc eax
				cmp eax,Sseq
				je next1

				inc Sseq
				mov esi,0
				mov edi,0
				mov ecx,L
				push ebx
				match1:
					mov al,motif[esi]
					mov al,buffer[ebx]
					cmp motif[esi],al
					je match2
						inc edi
					match2:
					inc ebx
					inc esi
				loop match1
				
				cmp edi,minMut
				jae p3
					mov minMut,edi
					mov eax,Sseq
					mov Sindex,eax
					jmp p4
				p3:
				mov eax,minMut
				cmp eax,M
				jne p4
					mov eax,Sseq
					mov Sindex,eax
				p4:

				pop ebx
				inc ebx
			jmp lineloop
			next1:

			mov eax,minMut
			add maxMut,eax

			;;;;;;;;;;;;;;;;;;;;;; push here the results in tmpResults array;;;;;;;;;;;;;;;;;;;;;;;
			
			mov eax,Sindex
			cmp eax,bufSize
			je h
				mov esi,noresults
				mov tmpResults[esi],al
				inc noresults
				jmp h2
			h:
				jmp mi
			h2:

			mov eax,T
			cmp linesCount,eax
			je iterEnd

		jmp allLines
		iterEnd:
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;find the best result;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov eax,maxMut
		cmp eax,compMut
		jae mi
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;update the array;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			mov compMut,eax
			mov esi,0
			mov eax,Smotif
			mov results[esi],al
			mov ecx,noresults
			updateloop:
				mov al,tmpResults[esi]
				inc esi
				mov results[esi],al
			loop updateloop
		mi:
		
	jmp DNA
	finish:
ret
motifFinding ENDP

END main
