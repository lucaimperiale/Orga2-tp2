#include <math.h>

#include "../tp2.h"

#define PI 			3.1415
#define RADIUS 		35
#define WAVELENGTH 	64
#define TRAINWIDTH 	3.4

uchar saturar( int prof)
{
	if (prof > 255)
	{
		return (uchar)255;
	}
	if (prof < 0)
	{
		return (uchar)0;
	}
	return (uchar)prof;
}


bgra_t ondear (bgra_t *p_s, float prof)
{
	bgra_t res;
	res.r = saturar (p_s -> r +(int) (prof * 64));
	res.g = saturar (p_s -> g + (int) (prof * 64));
	res.b = saturar (p_s -> b + (int) (prof * 64));
	res.a = p_s -> a;
	return res;
}



float sin_taylor (float x) {
	float x_3 = x*x*x;
	float x_5 = x*x*x*x*x;
	float x_7 = x*x*x*x*x*x*x;

	return x-(x_3/6.0)+(x_5/120.0)-(x_7/5040.0);
}

float profundidad (int x, int y, int x0, int y0) {
	float dx = x - x0;
	float dy = y - y0;

	float dxy = sqrt(dx*dx+dy*dy);

	float r = (dxy-RADIUS)/WAVELENGTH ;
	float k = r-floor(r);
	float a = 1.0/(1.0+(r/TRAINWIDTH)*(r/TRAINWIDTH));

	float t = k*2*PI-PI;

	float s_taylor = sin_taylor(t);

	float prof = a * s_taylor;

	return prof;
}

void ondas_c (
	unsigned char *src,
	unsigned char *dst,
	int width,
	int height,
	int src_row_size,
	int dst_row_size,
	int x0,
	int y0
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	for (int i = 0; i < height; i++)
	{
		for (int j = 0; j < width; j++)
		 {
		 	bgra_t *p_d = (bgra_t*)&dst_matrix[i][j*4];
		 	bgra_t *p_s = (bgra_t*)&src_matrix[i][j*4];
		 	float prof = profundidad(j,i,x0,y0);
		 	*p_d = ondear(p_s,prof);


		 }
	}
	
}


