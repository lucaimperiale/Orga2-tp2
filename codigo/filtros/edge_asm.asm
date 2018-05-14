section .data
DEFAULT REL

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = width
; 	rcx = height
; 	r8 = src_row_size
; 	r9 = dst_row_size

%define src rdi
%define dst rsi
%define altura rcx
%define anchosrc r8
%define pixelesRecorrerFila rdx
%define contadorfila r13
%define comienzoFilaSrc r11
%define comienzoFilaDst r12




section .rodata
align 16
em6: times 4 dd -6
e05: times 4 dd 2


section .text
global edge_asm
edge_asm:
;COMPLETAR
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rax
	push r11

	movdqa xmm6,[em6]

	pxor xmm7, xmm7; xmm7 = [0, 0, ..., 0]

	mov r14,anchosrc
	mov r15,anchosrc
	imul r15,(-1) ; -r8

	sub pixelesRecorrerFila,2
	;imul pixelesRecorrerFila, 4
	

	sub altura,2

	add src,1
	add dst,1

	add src, anchosrc
	add dst, anchosrc

	mov comienzoFilaDst,dst
	mov comienzoFilaSrc,src

	ciclo:
	xor contadorfila,contadorfila
	add contadorfila,16

	mov src,comienzoFilaSrc
	mov dst,comienzoFilaDst
	

	ciclofila:
	movdqu xmm0,[src] 	;muevo a xmm0 los 4 pixeles
						;RGBA|RGBA|RGBA|RGBA en bytes
	call unpack

	movdqu xmm8,[rdi+1]
	call sumarUno
	
	movdqu xmm8,[rdi+(-1)]
	call sumarUno

	movdqu xmm8,[rdi+r14]
	call sumarUno

	movdqu xmm8,[rdi+r15]
	call sumarUno

	movdqu xmm8,[rdi+r14+1]
	call sumarMitad

	movdqu xmm8,[rdi+r14-1]
	call sumarMitad

	movdqu xmm8,[rdi+r15+1]
	call sumarMitad

	movdqu xmm8,[rdi+r15-1]
	call sumarMitad

	packusdw xmm0,xmm1
	packusdw xmm2,xmm3
	packuswb xmm0,xmm2
	

	movdqu [dst],xmm0 ; lo pongo en dst

	add contadorfila,16 ;puedo leer otros 16p = 128 B
	cmp contadorfila,pixelesRecorrerFila
	jge finDeFila

	add src,16
	add dst,16

	jmp ciclofila

	finDeFila:
	sub contadorfila,16
	add src,16
	add dst,16
	add contadorfila,1


	recorrerFinDeFila:

	xor rax,rax
	xor rbx,rbx
	mov byte al,[rdi]
	imul rax,(-6)
	mov byte bl,[rdi+1]
	add rax,rbx
	mov byte bl,[rdi-1]
	add rax,rbx
	mov byte bl,[rdi+r14]
	add rax,rbx
	mov byte bl,[rdi+r15]
	add rax,rbx
	mov byte bl,[rdi+r14+1]
	shr rbx,1
	add rax,rbx
	mov byte bl,[rdi+r14-1]
	shr rbx,1
	add rax,rbx
	mov byte bl,[rdi+r15+1]
	shr rbx,1
	add rax,rbx
	mov byte bl,[rdi+r15-1]
	shr rbx,1
	add rax,rbx

	call saturate

	mov byte [rsi],al

	add contadorfila,1
	cmp contadorfila,pixelesRecorrerFila
	jg nuevaColumna

	add src,1
	add dst,1
	jmp recorrerFinDeFila


	nuevaColumna:
	
	add comienzoFilaDst,anchosrc
	add comienzoFilaSrc,anchosrc
	sub altura,1
	cmp altura,0
	jne ciclo	

	jmp fin


	fin:
	pop r11
	pop rax
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
	

saturate:
	cmp rax,255
	jg max
	cmp rax,0
	jl min
	ret

	max:
	mov rax,255
	ret
	min:
	mov rax,0
	ret


sumarUno:
	movdqu xmm9, xmm8
	punpcklbw xmm8, xmm7
	punpckhbw xmm9, xmm7

	movdqu xmm10,xmm9
	movdqu xmm9,xmm8
	movdqu xmm11,xmm10

	punpcklwd xmm8,xmm7
	punpckhwd xmm9,xmm7	
	punpcklwd xmm10,xmm7
	punpckhwd xmm11,xmm7

	paddd xmm0,xmm8
	paddd xmm1,xmm9
	paddd xmm2,xmm10
	paddd xmm3,xmm11

	ret

	
sumarMitad:
	movdqu xmm9, xmm8
	punpcklbw xmm8, xmm7
	punpckhbw xmm9, xmm7

	movdqu xmm10,xmm9
	movdqu xmm9,xmm8
	movdqu xmm11,xmm10

	punpcklwd xmm8,xmm7
	punpckhwd xmm9,xmm7	
	punpcklwd xmm10,xmm7
	punpckhwd xmm11,xmm7

	psrld xmm8,1
	psrld xmm9,1
	psrld xmm10,1
	psrld xmm11,1

	paddd xmm0,xmm8
	paddd xmm1,xmm9
	paddd xmm2,xmm10
	paddd xmm3,xmm11

	ret

unpack:
	movdqu xmm1, xmm0; xmm1 = [a15, a14, ..., a0]
	punpcklbw xmm0, xmm7; xmm1 = [0, a7, ..., 0, a0]
	punpckhbw xmm1, xmm7; xmm2 = [0, a15, ..., 0, a8]

	movdqu xmm2,xmm1
	movdqu xmm1,xmm0
	movdqu xmm3,xmm2

	punpcklwd xmm0,xmm7
	punpckhwd xmm1,xmm7	

	punpcklwd xmm2,xmm7
	punpckhwd xmm3,xmm7

	pmulld xmm0,xmm6
	pmulld xmm1,xmm6
	pmulld xmm2,xmm6
	pmulld xmm3,xmm6

	ret