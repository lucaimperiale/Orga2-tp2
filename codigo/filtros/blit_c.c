#include <stdio.h>
#include "../tp2.h"


bgra_t blitz (bgra_t *p_s)
{
	bgra_t res;
	res.r = p_s -> r;
	res.g = p_s -> g;
	res.b = p_s -> b;
	res.a = p_s -> a;
	return res;
}





void blit_c (unsigned char *src, unsigned char *dst, int w, int h, int src_row_size, int dst_row_size, unsigned char *blit, int bw, int bh, int b_row_size) 
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	unsigned char (*blit_matrix)[b_row_size] = (unsigned char (*)[b_row_size]) blit;

	for (int i_d = 0, i_s = 0, i_b = 0; i_d < h; i_d++, i_s++)
	{
		for (int j_d = 0, j_s = 0, j_b = 0; j_d < w; j_d++, j_s++)
		 {
			if (i_s >= (h - bh) && j_s  >= (w - bw) )
			{
				bgra_t *p_d = (bgra_t*)&dst_matrix[i_d][j_d*4];
				bgra_t *p_b = (bgra_t*)&blit_matrix[i_b][j_b*4];
				bgra_t *p_s = (bgra_t*)&src_matrix[i_s][j_s*4];
				if (p_b -> r == 255 && p_b -> g == 0 && p_b -> b == 255)
				{
					*p_d = blitz(p_s);
				}
				else
				{
					*p_d = blitz(p_b);	
				}
					j_b ++;
			}
			else
			{
			bgra_t *p_d = (bgra_t*)&dst_matrix[i_d][j_d*4];
			bgra_t *p_s = (bgra_t*)&src_matrix[i_s][j_s*4];
			*p_d = blitz(p_s);	
			}

		}
		if (i_s >= (h - bh))
			{
				i_b ++;
			}
		//i_b ++;
	}
}
