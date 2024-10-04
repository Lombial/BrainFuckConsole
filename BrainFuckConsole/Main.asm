.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode: dword
GetStdHandle proto, nStdHandle: dword 
WriteConsoleA proto, handle: dword, lpBuffer: ptr byte, nNumberOfBytesToWrite: dword, lpNumberOfBytesWritten: ptr dword, lpReserved: dword
ReadConsoleA proto, hConsoleInput: dword, lpBuffer:ptr byte, nNumberOfCharsToRead: dword, lpNumberOfCharsRead: ptr dword, pInputControl: dword
SetConsoleTextAttribute proto, hConsoleOutput: dword, wAttributes: word

.data
tabult db 10
edxarg dd ?
output db 0
voidpt dq ?
inputs db 99999 dup(0)
codeln db 99999 dup(0)
memory db 256 dup(0)
buffer db 256 dup(0)
ptrmem dd offset memory
ptrbuf dd offset buffer
syntax db '-+<>[].,'
cmdent db 'command >>> '
codent db 'code    >>> '
bytent db 'bytes   >>> '
outent db 'output  >>> '
inpent db 'input   >>> '
msgent db 'message >>> '
entlen = $ - msgent
comerr db 'Compilation error.'
errlen = $ - comerr
resetm db 'The output byte line has been reset.'
reslen = $ - resetm
titles db 'BrainFuck console developed by Lombial.' 
titlen = $ - titles 
invcmd db 'Invalid command entered!'
invlen = $ - invcmd
linecd db 'Your code has been executed.'
lineln = $ - linecd
header db 'Available commands to use:'
hdrlen = $ - header
lin1c_ db '- e'
cmdlen = $ - lin1c_
lin1d_ db ' exit the program.'
lin1dl = $ - lin1d_
lin2c_ db '- l'
lin2d_ db ' show the command list.'
lin2dl = $ - lin2d_
lin3c_ db '- r'
lin3d_ db ' reset output byte line.'
lin3dl = $ - lin3d_
lin4c_ db '- w'
lin4d_ db ' write bytes from the pointer.'
lin4dl = $ - lin4d_
lin5c_ db '- o'
lin5d_ db ' show output.'
lin5dl = $ - lin5d_
lin6c_ db '- m'
lin6d_ db ' show memory.'
lin6dl = $ - lin6d_
lin7c_ db '- p'
lin7d_ db ' set pointer position.'
lin7dl = $ - lin7d_
lin8c_ db '- c'
lin8d_ db ' write a code line.'
lin8dl = $ - lin8d_
allcmd dd offset lin1c_, offset lin2c_, offset lin3c_, offset lin4c_, offset lin5c_, offset lin6c_, offset lin7c_, offset lin8c_
alcptr dd $
alllin dd offset lin1d_, offset lin2d_, offset lin3d_, offset lin4d_, offset lin5d_, offset lin6d_, offset lin7d_, offset lin8d_
allptr dd $
alllln dd offset lin1dl, offset lin2dl, offset lin3dl, offset lin4dl, offset lin5dl, offset lin6dl, offset lin7dl, offset lin8dl
alnptr dd $
.code


main proc
	call intro
	jmp begin 

	

intro:
	call toyellow 
	mov ebx, offset titles
	mov ecx, titlen
	call writeline
	call tab
	call tobrightyellow
	mov ebx, offset header
	mov ecx, hdrlen
	call writeline
cmdlist:
    call toyellow 
	call tab
	mov edi, 0
	mov eax, -4
intro_loop:
	inc edi
	mov ebx, [alcptr + eax]
	mov ecx, cmdlen
	call write
	call togray
	mov ebx, [allptr + eax]
	mov ecx, [alnptr + eax]
	call writeline
	call toyellow
	add eax, -4
	cmp edi, 7
	jnz intro_loop
	call tab
	ret

togray:
	push ebx
	mov ebx, 8
	call setcolor
	pop ebx
	ret

toyellow:
	push ebx
	mov ebx, 6
	call setcolor
	pop ebx
	ret

tobrightyellow:
	push ebx
	mov ebx, 14
	call setcolor
	pop ebx
	ret

setcolor:
	push eax
	invoke GetStdHandle, -11
	invoke SetConsoleTextAttribute, eax, bx
	pop eax
	ret

readline:
	push eax
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset codeln, 99999, offset output, 0
	pop eax
	ret

writeline:
	call write
	call tab
	ret

write:
	push eax
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, ebx, ecx, offset edxarg, 0
	pop eax
	ret

tab:
	push ebx
	push ecx
	mov ebx, offset tabult
	mov ecx, 1
	call write
	pop ecx
	pop ebx
	ret

incptrs:
	push eax
	mov eax, ptrmem
	inc eax
	cmp eax, offset memory + 256
	jz mptrf
	jmp step1
mptrf:
	mov eax, offset memory
step1:
	mov ptrmem, eax
	mov eax, ptrbuf
	inc eax
	cmp eax, offset buffer + 256
	jz bptrf
	jmp step2
bptrf:
	mov eax, offset buffer
step2:
	mov ptrbuf, eax
	pop eax
	ret

decptrs:
	push eax
	mov eax, ptrmem 
	dec eax
	cmp eax, offset memory - 1
	jz mptrf1
	jmp step11
mptrf1:
	mov eax, offset memory + 255
step11:
	mov ptrmem, eax
	mov eax, ptrbuf
	dec eax
	cmp eax, offset buffer - 1
	jz bptrf1
	jmp step21
bptrf1:
	mov eax, offset buffer + 255
step21:
	mov ptrbuf, eax
	pop eax
	ret

compileerror:
	call showmessage
	mov ebx, 5
	call setcolor
	mov ebx, offset comerr
	mov ecx, errlen
	call writeline
	jmp begin

leavep:
	mov ebx, 7
	call setcolor
	invoke ExitProcess, ebx

showinput:
	mov ebx, 12
	call setcolor
	mov ebx, offset inpent
	jmp release
showoutput:
	mov ebx, 11
	call setcolor
	mov ebx, offset outent
	jmp release
showcode:
	mov ebx, 10
	call setcolor
	mov ebx, offset codent
	jmp release
showmessage:
	mov ebx, 13
	call setcolor
	mov ebx, offset msgent
	jmp release
showentercmd:
	call tobrightyellow
	mov ebx, offset cmdent
release:
	mov ecx, entlen
	call write
	ret

operatorsetup:
	mov ebx, ptrmem
	mov dl, [ebx]
	ret

operatorlf:
	call incptrs
	jmp returnl

operatorrg:
	call decptrs
	jmp returnl

operatorpl:
	call operatorsetup
	add dl, 1
	mov [ebx], dl
	jmp returnl
operatormn:
	call operatorsetup
	add dl, -1
	mov [ebx], dl
	jmp returnl
operatorpt:
	call operatorsetup
	mov ebx, ptrbuf
	mov [ebx], dl
	jmp returnl
operatorin:
	push eax
	push ecx
	call showinput
	mov ebx, 4
	call setcolor
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset inputs, 99999, offset output, 0
	mov ebx, ptrmem
	mov dl, [inputs]
	mov [ebx], dl
	pop ecx
	pop eax
	jmp returnl
operatorlb:
	call operatorsetup
	cmp dl, 0
	jnz returnl
	mov ebx, 0
lbloop:
	inc eax
	dec ecx
	mov dl, [eax]
	cmp dl, '['
	jnz ll
	inc ebx
ll:
	cmp dl, ']'
	jnz lbloop
	cmp ebx, 0
	jz returnl
	dec ebx
	jmp lbloop
operatorrb:
	call operatorsetup
	cmp dl, 0
	jz returnl
	mov ebx, 0
rbloop:
	dec eax
	inc ecx
	mov dl, [eax]
	cmp dl, ']'
	jnz rr
	inc ebx
rr:
	cmp dl, '['
	jnz rbloop
	cmp ebx, 0
	jz returnl
	dec ebx
	jmp rbloop






setup:
	mov ecx, 0
	mov eax, offset codeln
	mov cl, [output]
	add ecx, -3
	mov edx, 0
	ret

Ccommand:
	call showcode
	mov ebx, 2
	call setcolor
	call readline
	call setup
	cmp ecx, -1
	jz compileerror
compileloop:
	mov bl, [eax]
	cmp bl, '['
	jnz skip1
	add edx, 1
skip1:
	cmp bl, ']'
	jnz skip2
	add edx, -1
skip2:
	inc eax
	dec ecx
	cmp ecx, -1
	jnz compileloop
	cmp edx, 0
	jnz compileerror
	call setup
executeloop:
	mov bl, [eax]
	cmp bl, '>'
	jz operatorlf
	cmp bl, '<'
	jz operatorrg
	cmp bl, '+'
	jz operatorpl
	cmp bl, '-'
	jz operatormn
	cmp bl, '.'
	jz operatorpt
	cmp bl, ','
	jz operatorin
	cmp bl, '['
	jz operatorlb
	cmp bl, ']'
	jz operatorrb
returnl:
	inc eax
	dec ecx
	cmp ecx, -1
	jnz executeloop
	call showmessage
	mov ebx, 5
	call setcolor
	mov ebx, offset linecd
	mov ecx, lineln
	call writeline
	jmp begin

Rcommand:
	mov eax, offset buffer
	mov ecx, 0
	mov bl, 0
rloop:
	mov [eax], bl
	inc eax
	inc ecx
	cmp ecx, 256
	jnz rloop
	call showmessage
	mov ebx, 5
	call setcolor
	mov ebx, offset resetm
	mov ecx, reslen
	call writeline
	jmp begin

Wcommand:
	jmp begin

OCommand:
	call showoutput
	mov ebx, 3
	call setcolor
	mov ebx, offset buffer
	mov ecx, 255
	call writeline
	jmp begin

PCommand:
	call showinput
	mov ebx, 4
	call setcolor
	call readline
	
	jmp begin

BCommand:
	jmp begin

LCommand:
	call cmdlist
	jmp begin

begin:
	call showentercmd
	call toyellow
	call readline
	mov al, [codeln]
	cmp al, 'e'
	jz leavep
	cmp al, 'c'
	jz Ccommand
	cmp al, 'r'
	jz Rcommand
	cmp al, 'w'
	jz Wcommand
	cmp al, 'o'
	jz OCommand
	cmp al, 'p'
	jz PCommand
	cmp al, 'b'
	jz BCommand
	cmp al, 'l'
	jz LCommand
	call showmessage
	mov ebx, 5
	call setcolor
	mov ebx, offset invcmd
	mov ecx, invlen
	call writeline

	jmp begin
main endp
end main