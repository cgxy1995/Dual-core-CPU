#include <stdio.h>
int ray[100]={ 0x087d, 0x5fcb, 0xa41a, 0x4109, 0x4522, 0x700f, 0x766d, 0x6f60, 0x8a5e, 0x9580, 0x70a3, 0xaea9, 0x711a, 0x6f81, 0x8f9a, 0x2584, 0xa599, 0x4015, 0xce81, 0xf55b, 0x399e, 0xa23f, 0x3588, 0x33ac, 0xbce7, 0x2a6b, 0x9fa1, 0xc94b, 0xc65b, 0x0068, 0xf499, 0x5f71, 0xd06f, 0x14df, 0x1165, 0xf88d, 0x4ba4, 0x2e74, 0x5c6f, 0xd11e, 0x9222, 0xacdb, 0x1038, 0xab17, 0xf7ce, 0x8a9e, 0x9aa3, 0xb495, 0x8a5e, 0xd859, 0x0bac, 0xd0db, 0x3552, 0xa6b0, 0x727f, 0x28e4, 0xe5cf, 0x163c, 0x3411, 0x8f07, 0xfab7, 0x0f34, 0xdabf, 0x6f6f, 0xc598, 0xf496, 0x9a9a, 0xbd6a, 0x2136, 0x810a, 0xca55, 0x8bce, 0x2ac4, 0xddce, 0xdd06, 0xc4fc, 0xfb2f, 0xee5f, 0xfd30, 0xc540, 0xd5f1, 0xbdad, 0x45c3, 0x708a, 0xa359, 0xf40d, 0xba06, 0xbace, 0xb447, 0x3f48, 0x899e, 0x8084, 0xbdb9, 0xa05a, 0xe225, 0xfb0c, 0xb2b2, 0xa4db, 0x8bf9, 0x12f7}; 

/*ONLY CHANGE THE CODE IN THIS FILE*/
void my_qsort (int*, int , int );
int main(int argc, char *argv[])
{
 // sscanf(argv[1],"%d",&n);
 //array = (int*)malloc(n*sizeof(int));


  int i;
	
  my_qsort(ray,0,99);
  for (i=0; i<100; i++){
    printf("%x\n",ray[i]);
  }  	
  return 0;
}

void init_mid (int array[], int a, int b)
{
        int mid, tmp;
	mid = (a + b) / 2;
	 if (array[a] < array[mid])
	{
		if (array[a] < array[b])
		{
			if (array[mid] < array[b]) //a mid b
			{
				tmp = array[mid];
				array[mid] = array[b];
				array[b] = tmp;
			}
			else //a b mid
			{
			}
		}
		else //b a mid
		{
			tmp = array[a];
			array[a] = array[b];
			array[b] = tmp;
		}
	}
	else
	{
		if (array[a] < array[b]) //mid a b
		{
			tmp = array[a];
			array[a] = array[b];
			array[b] = tmp;
		}
		else
		{
			if (array[mid] < array[b]) //mid b a
			{
			}
			else //b mid a
			{
				tmp = array[mid];
				array[mid] = array[b];
				array[b] = tmp;
			}
		}
		}
}

void my_qsort (int array[], int a, int b)
{
        int bit = 0;
	int mid, p, q, tmp, i, j;
	if (b - a <= 24)
	{
		for (i = a + 1; i <= b; i++)
		{
			tmp = array[i];
			j = i - 1;
			while (array[j] > tmp && j >= a)
			{
				array[j + 1] = array[j];
				array[j] = tmp;
				j--;
			}
		}
		return;
	}
	init_mid (array, a, b);
	p = q = a;
	mid = array[b];
	while (q != b)
	{
		if (bit)
			bit = 0;
		else
			bit = 1;
		if (array[q] < mid + bit)
		{
			tmp = array[p];
			array[p] = array[q];
			array[q] = tmp;
			p++;
		}
		q++;
	}
	array[b] = array[p];
	array[p] = mid;
	my_qsort (array, a, p - 1);
	my_qsort (array, p + 1, b);
}





