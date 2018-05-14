#include <stdio.h>
#include "../tp2.h"

uchar edgyAF (uchar* p_s, int src_row_size){

	float laplace[3][3] = {{0.5,1,0.5},
					   	{1, -6,  1},
						{0.5,1,0.5}};

	float suma = 0;
	suma += (float)(*(p_s - 1 - src_row_size)) * laplace[0][0];
	suma += (float)(*(p_s - 1               )) * laplace[0][1] ;
	suma += (float)(*(p_s - 1 + src_row_size)) * laplace[0][2] ;
	suma += (float)(*(p_s     - src_row_size)) * laplace[1][0] ;
	suma += (float)(*(p_s                   )) * laplace[1][1] ;
	suma += (float)(*(p_s     + src_row_size)) * laplace[1][2] ;
	suma += (float)(*(p_s + 1 - src_row_size)) * laplace[2][0] ;
	suma += (float)(*(p_s + 1               )) * laplace[2][1] ;
	suma += (float)(*(p_s + 1 + src_row_size)) * laplace[2][2] ;

	uchar res = (suma>=0.0)?((uchar)suma): 0;
	res = (suma<=255.0)?(res): 255;

	return res;

}

void edge_c (unsigned char *src, unsigned char *dst, int width, int height, int src_row_size, int dst_row_size)
{

	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	for (int i_d = 1, i_s = 1; i_d < height-1; i_d++, i_s++) {
		for (int j_d = 1, j_s = 1; j_d < width-1; j_d++, j_s++) {
			uchar *p_d = (uchar*)&dst_matrix[i_d][j_d];
			uchar *p_s = (uchar*)&src_matrix[i_s][j_s];
			
						
			*p_d = edgyAF(p_s,src_row_size);
		}
	}

}
