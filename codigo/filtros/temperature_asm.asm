global temperature_asm

section .data



section .rodata

cond31: dd 31,31,31,31
cond32: dd 32,32,32,32
cond95: dd 95,95,95,95
cond96: dd 96,96,96,96
cond159: dd 159,159,159,159
cond160: dd 160,160,160,160
cond223: dd 223,223,223,223
cond224: dd 224,224,224,224

rojo: times 4 dd 0xff0000
verde:times 4 dd 0x00ff00
azul: times 4 dd 0x0000ff
negro:times 4 dd 0x000000
blanco:times 4 dd 0xffffff



e3: dd 3,3,3,3
e4: dd 4,4,4,4
e128: dd 128,128,128,128
e255: dd 255,255,255,255
e94: dd 94,94,94,94
e96: dd 96,96,96,96
e32: dd 32,32,32,32
e224: dd 224,224,224,224
e1: db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255

cond5: dd 75,75,75,75





section .text
;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

temperature_asm:
    push rbp
	mov rbp, rsp

	push r13

    imul rcx,r8 ;cant bytes que tengo que recorrer
	
    movdqu xmm8,[e3]
    cvtdq2ps xmm8,xmm8

    pxor xmm7,xmm7
    

	ciclo:	
	movdqu xmm0,[rdi] 	;muevo a xmm0 los 4 pixeles
	movdqu xmm1,xmm0	;RGBA|RGBA|RGBA|RGBA en bytes
	movdqu xmm2,xmm0
	movdqu xmm3,xmm0

	pslld xmm0,3*8	
    psrld xmm0,3*8
	pslld xmm1,2*8	
	psrld xmm1,3*8
	pslld xmm2,1*8	
	psrld xmm2,3*8

    paddd xmm2,xmm1     ; obtengo la suma de los 3 componentes
    paddd xmm0,xmm2     ; como un dword (4 pixeles)

    cvtdq2ps xmm0,xmm0  ;convierto para poder dividir

    divps xmm0,xmm8 

    cvttps2dq xmm0,xmm0 ;vuelvo a int, truncando

    movdqu xmm4,xmm0 ; la copio aca para tenerla fija temperaura fija
    movdqu xmm1,xmm3 ; src

   
    movdqu xmm2,[cond31]    ;creo una mascara para cada pixel
    pcmpgtd xmm0,xmm2       ;con la cond que sea <32
    movdqu xmm2,[e1]        ;
    pxor xmm0,xmm2          ;

    
    
    ;32t;      128 + t * 4, 0,0 
    movdqu xmm5,xmm4        ;voy generando el pixel que
    pslld xmm5,2            ;deberia reemplazar en la dst
    movdqu xmm6,[e128]      ;que depende de la temp
    paddd xmm5,xmm6         ;

    movdqu xmm6,xmm1        ;le agrego el alfa de la src
    psrld xmm6,3*8          ;si tuviese
    pslld xmm6,3*8          ;
    paddw xmm5,xmm6         ;

    pblendvb xmm3,xmm5      ;blendeo el pixel que genere con
                            ;el que voy a poner al final en la dst
                            ;(no voy a pisarlo en las otras condiciones,
                            ;porque se supone que solo va a entrar a una)
                               
    
    movdqu xmm0,xmm4        ;creo otra mascara
    movdqu xmm2,[cond95]    ;con cond <96
    pcmpgtd xmm0,xmm2       ;
    movdqu xmm2,[e1]        ;
    pxor xmm0,xmm2          ;

    movdqu xmm6,xmm4        ;hago otra en xmm6
    movdqu xmm2,[cond32]    ;con cond >=32
    pcmpgtd xmm2,xmm6       ;
    movdqu xmm6,xmm2        ;
    movdqu xmm2,[e1]        ;
    pxor xmm6,xmm2          ;

    pand xmm0,xmm6          ;hago un and entre las 2, asi 
                            ;consigo los pixeles que tienen
                            ;una temp que esta en ese rango


    ;32t96;    255,(t-32) * 4, 0 

    movdqu xmm5,[e255]      ;hago el mismo proceso de antes

    movdqu xmm2,xmm4
    movdqu xmm6,[e32]
    psubd xmm2,xmm6
    pslld xmm2,2
    pslld xmm2,8

    paddb xmm5,xmm2    

    movdqu xmm6,xmm1
    psrld xmm6,3*8
    pslld xmm6,3*8
    paddw xmm5,xmm6

    pblendvb xmm3,xmm5

    movdqu xmm0,xmm4
    movdqu xmm2,[cond159]    
    pcmpgtd xmm0,xmm2
    movdqu xmm2,[e1]
    pxor xmm0,xmm2

    movdqu xmm6,xmm4
    movdqu xmm2,[cond96]
    pcmpgtd xmm2,xmm6
    movdqu xmm6,xmm2
    movdqu xmm2,[e1]
    pxor xmm6,xmm2

    pand xmm0,xmm6
    
    ;96t160;    255 - (t-96) * 4, 255, (t-96) * 4

    movdqu xmm5,xmm4
    movdqu xmm2,[e96]
    psubd xmm5,xmm2
    pslld xmm5,2
    pslld xmm5,8*2

    movdqu xmm2,[e255]
    pslld xmm2,8
    paddb xmm5,xmm2
    

    movdqu xmm2,xmm4
    movdqu xmm6,[e96]
    psubd xmm2,xmm6
    pslld xmm2,2
    movdqu xmm6,[e255]
    psubd xmm6,xmm2
    movdqu xmm2,xmm6

    paddb xmm5,xmm2


    movdqu xmm6,xmm1
    psrld xmm6,3*8
    pslld xmm6,3*8
    paddw xmm5,xmm6

    pblendvb xmm3,xmm5

    movdqu xmm0,xmm4
    movdqu xmm2,[cond223]    
    pcmpgtd xmm0,xmm2
    movdqu xmm2,[e1]
    pxor xmm0,xmm2

    movdqu xmm6,xmm4
    movdqu xmm2,[cond160]
    pcmpgtd xmm2,xmm6
    movdqu xmm6,xmm2
    movdqu xmm2,[e1]
    pxor xmm6,xmm2

    pand xmm0,xmm6
    

    ;160t224;   0,255 - (t-160) * 4, 255
    
    movdqu xmm5,xmm4
    movdqu xmm6,[cond160]
    psubd xmm5,xmm6
    pslld xmm5,2
    movdqu xmm6,[e255]
    psubd xmm6,xmm5
    movdqu xmm5,xmm6
    pslld xmm5,8

    movdqu xmm2,[e255]
    pslld xmm2,8*2

    paddb xmm5,xmm2
    

    movdqu xmm6,xmm1
    psrld xmm6,3*8
    pslld xmm6,3*8
    paddw xmm5,xmm6

    pblendvb xmm3,xmm5

    movdqu xmm0,xmm4
    movdqu xmm2,[cond224]    
    pcmpgtd xmm2,xmm0
    movdqu xmm0,xmm2
    movdqu xmm2,[e1]
    pxor xmm0,xmm2



    ;224t;     0,0, 255 - (t-224)*4

    movdqu xmm5,xmm4
    movdqu xmm6,[e224]
    psubd xmm5,xmm6
    pslld xmm5,2
    movdqu xmm6,[e255]
    psubd xmm6,xmm5
    movdqu xmm5,xmm6
    pslld xmm5,8*2

    movdqu xmm6,xmm1
    psrld xmm6,3*8
    pslld xmm6,3*8
    paddw xmm5,xmm6

    pblendvb xmm3,xmm5

    movdqu [rsi],xmm3   ;le agrego el pixel que fui blendeando
                        ;a la dst

    

    add rdi, 16     ;voy a los siguientes 4 pixeles
	add rsi, 16     ;
	sub rcx, 16     ;resto en la cant que me falta recorrer

	jg ciclo        
        
    pop r13

	pop rbp
    ret
