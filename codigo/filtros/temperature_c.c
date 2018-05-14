
#include <math.h>
#include "../tp2.h"


bool between(unsigned int val, unsigned int a, unsigned int b)
{
	return a <= val && val <= b;
}

bgra_t temperatura (bgra_t *p_s){

	bgra_t res;
	int suma;
	suma = (int)p_s->b + (int)p_s->r + (int)p_s->g;
	suma = suma /3;

	
	if(suma<32){
		res.r = 0;
		res.g = 0;
		res.b = 128 + suma * 4;
		res.a = p_s -> a;
	}
	else if(32<=suma && suma < 96){
		res.r = 0;
		res.g = (suma - 32) * 4;
		res.b = 255;
		res.a = p_s -> a;
	}
	else if(96<=suma && suma < 160){
		res.r = (suma - 96) * 4;
		res.g = 255;
		res.b = 255 - (suma - 96) * 4;
		res.a = p_s -> a;
	}
	else if(160<=suma && suma < 224){
		res.r = 255;
		res.g = 255 - (suma - 160) * 4;
		res.b = 0;
		res.a = p_s -> a;
	}
	else{
		res.r = 255 - (suma - 224) *4;
		res.g = 0;
		res.b = 0;
		res.a = p_s -> a;
	}
	return res;
}


void temperature_c    (
	unsigned char *src,
	unsigned char *dst,
	int width,
	int height,
	int src_row_size,
	int dst_row_size)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	for (int i_d = 0, i_s = 0; i_d < height; i_d++, i_s++) {
		for (int j_d = 0, j_s = 0; j_d < width; j_d++, j_s++) {
			bgra_t *p_d = (bgra_t*)&dst_matrix[i_d][j_d*4];
			bgra_t *p_s = (bgra_t*)&src_matrix[i_s][j_s*4];
			
			*p_d = temperatura(p_s);
		}
	}

}
