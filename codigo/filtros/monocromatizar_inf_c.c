#define max(a, b) ((a)>(b))?(a):(b)
#include "../tp2.h"

void monocromatizar_inf_c (
	unsigned char *src, 
	unsigned char *dst, 
	int width, 
	int height, 
	int src_row_size, 
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;


	for (int i = 0; i < height; i++) {
		for (int j = 0; j < width*4; j+=4) {
			uchar *p_d = (uchar*)&dst_matrix[i][j];
			uchar *p_s = (uchar*)&src_matrix[i][j];
			
			uchar b = *p_s;
			p_s++;
			uchar g = *p_s;
			p_s++;
			uchar r = *p_s;
			p_s++;

			uchar max = max(max(b,g),r);

			*p_d = max;
			p_d++;
			*p_d = max;
			p_d++;
			*p_d = max;
			p_d++;
			*p_d = 255;
		}
	}
	
}
