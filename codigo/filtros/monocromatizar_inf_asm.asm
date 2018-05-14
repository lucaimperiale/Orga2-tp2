; void monocromatizar_inf_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int width,
; 	int height,
; 	int src_row_size,
; 	int dst_row_size
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = width
; 	rcx = height
; 	r8 = src_row_size
; 	r9 = dst_row_size

extern monocromatizar_inf_c

global monocromatizar_inf_asm 


section .rodata

mascara: db 0x03,0x03,0x03,0xFF,0x07,0x07,0x07,0xFF,0x0B,0x0B,0x0B,0xFF,0x0F,0x0F,0x0F,0xFF

section .text

monocromatizar_inf_asm:
	;; TODO: Implementar
	push rbp
	mov rbp, rsp

	push r13

	imul rcx,r8 ;cant bytes que tengo que recorrer
	
	ciclo:	
	movdqu xmm0,[rdi] 	;muevo a xmm0 los 4 pixeles
	movdqu xmm1,xmm0	;RGBA|RGBA|RGBA|RGBA en bytes
	movdqu xmm2,xmm0
	movdqu xmm3,xmm0

	pslld xmm0,3*8	;RGBA|RGBA|RGBA|RGBA --> 000R|000R|000R|000R
	psrld xmm1,1*8	;RGBA|RGBA|RGBA|RGBA --> GBA0|0GBA|0GBA|0GBA
	pslld xmm1,3*8	;GBA0|0GBA|0GBA|0GBA --> 000G|000G|000G|000G
	psrld xmm2,2*8	;RGBA|RGBA|RGBA|RGBA --> BA00|BA00|BA00|BA00
	pslld xmm2,3*8	;BA00|BA00|BA00|BA00 --> 000B|000B|000B|000B

	pmaxud xmm1,xmm2 ; queda 000(max(G,B))|...
	pmaxud xmm0,xmm1 ; queda 000(max(max(G,B),R))|...

	movdqu xmm7,[mascara]
	
	pshufb xmm0,xmm7 ; la mascara me copia el valor 3 veces en cada dw M = max MMM0|MMM0|MMM0|MMM0

	pmaxub xmm3,xmm0 ; le hago un max con el registro original por si algun byte tenia A

	movdqu [rsi],xmm3 ; lo pongo en dst

	add rdi, 16
	add rsi, 16
	sub rcx, 16

	jg ciclo	; ciclo en la img

	pop r13
	pop rbp
	ret


