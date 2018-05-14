; void ondas_asm (
; 	unsigned char *src,
; 	unsigned char *dst,
; 	int width,
; 	int height,
; 	int src_row_size,
;   int dst_row_size,
;	int x0,
;	int y0
; );

; Parámetros:
; 	rdi = src
; 	rsi = dst
; 	rdx = width
; 	rcx = height
; 	r8 = src_row_size
; 	r9 = dst_row_size
;   rbp + 16 = x0
; 	rbp + 24 = y0


%define A xmm8
%define B xmm9
%define C xmm10
%define E xmm11
%define X xmm7
%define Y xmm6
%define X0 xmm5
%define Y0 xmm4
%define auxt1 Xmm12
%define auxt3 Xmm13
%define auxt5 Xmm14
%define auxt7 Xmm15

extern ondas_c

global ondas_asm


section .rodata

f1: times 4 dd 1.0
fn35: times 4 dd -35.0 ; radio
f64: times 4 dd 64.0 ; wavelenght
f34: times 4 dd 3.4 ; trainwidth
fn1: times 4 dd -1.0
f2: times 4 dd 2.0
fpi: times 4 dd 3.1415 ; pi
fnpi: times 4 dd -3.1415 ; -pi
fn5040: times 4 dd -5040.0
f120: times 4 dd 120.0
fn6: times 4 dd -6.0
i4: times 4 dd 4
i1: times 4 dd 1
i0: times 4 dd 0
;i1234: dd 0x04000000030000000200000001000000
i0123: dd 0,1,2,3
section .text

ondas_asm:
	;; TODO: Implementar

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14

	xor r12,r12
	xor r13,r13
	mov r14,r8
	movdqu X, [i0123] ; x = 1,2,3,4
	movdqu Y, [i0] ; y = 0,0,0,0




	pxor xmm5,xmm5
	pxor xmm4,xmm4


	mov r8d, [rbp + 16]
	pinsrd X0, r8d,0
	pinsrd X0, r8d,1
	pinsrd X0, r8d,2
	pinsrd X0, r8d,3
	mov r8d, [rbp + 24]
	pinsrd Y0, r8d,0
	pinsrd Y0, r8d,1
	pinsrd Y0, r8d,2
	pinsrd Y0, r8d,3




	;mov r13, 0
	ciclogrande:
	movdqu X, [i0123] ; x = 1,2,3,4
	mov r12, r14 ; r12 = row_size
	;mov r10, rdi ; r10 = rdi
	;mov r11, rsi ; r11 = rsi
	;add r10, r13 ; esto me va a definir la posicion de memoria del source, cada vez que termino una fila le sumo row_size y empiezo la siguiente
	;add r11, r13 ; lo mismo q arriba pero con destino 
		ciclochico:
		call profundidad ; B = prof * 64
		movdqu xmm0, [rdi]  ;xmm1 = rdi
		pxor xmm15,xmm15

		call unpack ;me deja cada componente en xmm0,xmm1,xmm2,xmm3

		cvtps2dq B,B

		pextrd r13d,B,0

		pinsrd xmm15,r13d,0
		pinsrd xmm15,r13d,1
		pinsrd xmm15,r13d,2

		paddd xmm0,xmm15

		pextrd r13d,B,1

		pinsrd xmm15,r13d,0
		pinsrd xmm15,r13d,1
		pinsrd xmm15,r13d,2

		paddd xmm1,xmm15

		pextrd r13d,B,2

		pinsrd xmm15,r13d,0
		pinsrd xmm15,r13d,1
		pinsrd xmm15,r13d,2

		paddd xmm2,xmm15

		pextrd r13d,B,3

		pinsrd xmm15,r13d,0
		pinsrd xmm15,r13d,1
		pinsrd xmm15,r13d,2

		paddd xmm3,xmm15

		packusdw xmm0,xmm1
		packusdw xmm2,xmm3
		packuswb xmm0,xmm2
		

		movdqu [rsi],xmm0


		movdqu xmm3, [i4]
		paddd X, xmm3
		sub r12, 16
		add rdi, 16
		add rsi, 16
		cmp r12, 0
		jg ciclochico
		;add r13, r8
		movdqu xmm3, [i1]
		paddd Y, xmm3
		sub rcx, 1
		cmp rcx, 0
		jg ciclogrande



	;push qword [rbp + 16]
	;call ondas_c
	pop r14
	pop r13
	pop r12
	pop rbp

	ret



psin_taylor:
	movdqu auxt1, C ; auxt1 = t
	movdqu auxt3, C ; auxt3 = t
	mulps auxt3, auxt1 ; 
	mulps auxt3, auxt1 ; auxt3 = t^3
	movdqu auxt5, auxt3 ; auxt5 = t^3
	mulps auxt5, auxt1 
	mulps auxt5, auxt1 ; auxt5 = t^5
	movdqu auxt7, auxt5 ; auxt7 = t^5
	mulps auxt7, auxt1
	mulps auxt7, auxt1 ; auxt7 = t^7
	movdqu E, [fn6]
	divps auxt3, E ; auxt3 = t^3 / 6
	movdqu E, [f120]
	divps auxt5, E ; auxt5 = t^5 / 120
	movdqu E, [fn5040]
	divps auxt7, E ; auxt7 = t^7 / 5040
	addps auxt1, auxt3 ; t - t^3/6
	addps auxt1, auxt5 ; t - t^3/6 + t^5 / 120
	addps auxt1, auxt7 ; t - t^3/6 + t^5 / 120 - t^7 / 5040
	movdqu B, A
	mulps B, auxt1 ; B = a * ( t - t^3/6 + t^5 / 120 - t^7 / 5040 )
	ret



profundidad: 
	movdqu A, X ; A = X
	movdqu B, Y ; B = Y 
	psubd A, X0 ; dx = X - X0 
	psubd B, Y0 ; dy = Y - Y0
	cvtdq2ps A,A
	cvtdq2ps B,B
	mulps A, A ; dx^2 = X^2
	mulps B, B ; dy^2 = Y^2
	addps A, B ; dxy = X^2 + Y^2
	sqrtps A, A ; sqrt (dxy)
	movdqu B, [fn35] ; B = -radio
	addps A, B ; (dxy + (-radius))
	movdqu B, [f64] ; B = wavelenght
	divps  A, B ; r = (dxy - radius)/wavelenght
	movdqu C, A ; C = r (esto lo voy a necesitar despues asi)
	movdqu B, [f34]; B = trainwidht
	divps A, B ; A = r/trainwidht
	mulps A, A ; A = (r/trainwidht)^2
	movdqu B, [f1] ; B = 1
	addps A, B ; A = 1 + (r/trainwidht)^2
	divps B, A ; B = a = 1/ (1 + (r/trainwidht)^2)
	movdqu A, B ; A = a (dhu)

	call floor
	
	subps C, B ; C = (r - floor(r))
	movdqu B, [f2] ; B = 2
	mulps C, B ; C = (r - floor(r)) * 2
	movdqu B, [fpi]; B = pi 
	mulps C, B ;C = (r - floor(r)) * 2 * pi
	movdqu B, [fnpi] ; B = -pi
	addps C, B ; C = t = (r - floor(r)) * 2 * pi - pi
	; C = t (lo necesito) B = -pi (puedo usarlo) A = a (lo necesito) D = (-1) (puedo usarlo)
	call psin_taylor
	; C = t B = prof  A = a D = (-1)
	movdqu E,[f64] ; D = 64
	mulps B, E ; prof * 64 (ya hago la multiplicacion aca y devuelvo directamente todo junto)
	; C = t B = prof * 64 (valor a devolver)  A = a D = (-1)

	ret



unpack:
	movdqu xmm1, xmm0; xmm1 = [a15, a14, ..., a0]
	punpcklbw xmm0, xmm15; xmm1 = [0, a7, ..., 0, a0]
	punpckhbw xmm1, xmm15; xmm2 = [0, a15, ..., 0, a8]

	movdqu xmm2,xmm1
	movdqu xmm1,xmm0
	movdqu xmm3,xmm2

	punpcklwd xmm0,xmm15
	punpckhwd xmm1,xmm15

	punpcklwd xmm2,xmm15
	punpckhwd xmm3,xmm15

	ret


floor: ;tengo en C el r, tengo que devolver el floor(r) en B, no puedo tocar A, puedo tocar E

	pxor xmm15,xmm15
	movdqu E,C
	movdqu B,C

	cmpps E,xmm15,1
	movdqu xmm0,E
	movdqu E,C

	movdqu B,[f1]
	subps E,B
	movdqu B,C

	blendvps B,E

	cvttps2dq B,B
	cvtdq2ps B,B

	ret


	


	


