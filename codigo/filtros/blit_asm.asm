;void blit_c (
;unsigned char *src,    == rdi
;unsigned char *dst,	== rsi
;int w,					== rdx
;int h,					== rcx
;int src_row_size,		== r8
;int dst_row_size,		== r9
;unsigned char *blit,	== rsp + 16 24
;int bw,				== rsp + 24 32
;int bh,				== rsp + 32 40
;int b_row_size)		== rsp + 40 48








section .rodata
DEFAULT REL

violeta: times 4 dd 0xffff00ff


section .text


global blit_asm


blit_asm:
	push rbp
	mov rbp, rsp
	push r13

	mov r10, r8 ;
	imul r10, [rsp + 40]  ; con estas 2 lineas deberia conseguir la cantidad de pixeles de TODAS las filas que tienen en alguna parte la imagen de peron
	;mov r13, rcx
	mov r11, rcx 
	imul r11, r8 ;con estas 2 lineas deberia conseguir la cantidad TOTAL de pixeles de la imagen source y la imagen destino
	; ahora bien si hago la resta tendria todos los pixeles en los cuales puedo copiar directamente de la imagen source a la destino sin preocuparme por la imagen de peron y despues puedo ver de
	; trabajar con el resto

	mov rcx, r11
	sub rcx, r10

	add rdi, rcx
	add rsi, rcx

	;ciclo1:  ; este ciclo solamente me va a copiar exactamente igual todos los pixeles que vienen antes de la image de peron
	;	movdqu xmm0,[rdi]
	;	movdqu [rsi],xmm0
	;	add rdi, 16 ; igual abajo
	;	add rsi, 16 ; hasta aca tengo copiadas todas los pixeles de la imagen por debajo de donde empezaria la peron en el final
	;	sub rcx, 16 ; esto ahora vale 0
	;	jg ciclo1
	


	;mov r13, rdx ;
	;sub r13, [rsp + 24] ;
	;mov rdx, r13 ; con estas 3 consigo la cantidad de pixeles
	mov r9, [rsp + 24]
	mov rcx, r10 ; este va a ser mi contador del ciclo grande, este me va a decir cuando termine de recorrer todos los pixeles
	mov r11, r8
	sub r11, [rsp + 48]; antes del blit 
	;sub r11, 12
	ciclogrande:
		mov r13, [rsp + 48] ; durante blit
		;sub r13, 4
		add rdi, r11
		add rsi, r11
		sub rcx, r11


		;ciclochico:
		;movdqu xmm0,[rdi]
		;movdqu [rsi],xmm0
		;add rdi, 16 ; igual abajo
		;add rsi, 16 ; hasta aca tengo copiadas todas los pixeles de la imagen por debajo de donde empezaria la peron en el final
		;sub r11, 16 ; esto ahora vale 0
		;sub rcx, 16
		;cmp r11, 0
		;jg ciclochico
		blit:
		movdqu xmm0, [r9]
		movdqu xmm5, [violeta]
		pcmpeqd xmm0, xmm5
		movdqu xmm1, [rdi]
		movdqu xmm2, [r9]
		pblendvb xmm2, xmm1
		movdqu [rsi],xmm2
		add rdi, 16
		add rsi, 16
		add r9, 16
		sub r13, 16
		sub rcx, 16
		cmp r13, 4
		jg blit
		jmp blit2
		cont:
		cmp rcx, 0
		jle end
		jmp ciclogrande
		blit2:
		;add rsi, 4
		;add rdi, 4
		;add r9, 4
		;sub rcx,4
		xor r10,r10
		mov r10d, [r9]
		mov r8d, 0xffff00ff
		cmp r10d,r8d
		jne pxel1
		mov r10d, [rdi]
		pxel1:
		mov [rsi], r10d
		add rsi, 4
		add rdi, 4
		add r9, 4
		sub rcx,4
		jmp cont


		end:
	pop r13
	pop rbp
	ret
