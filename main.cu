// Filter Analyzer
// Phil Alcorn
// September 18, 2025

// nvcc main.cu -o temp

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SLOPE -3.010299956639811952137388947244930267681898814621085413104


/***** ***** ***** STRUCTS ***** ***** *****/
typedef struct  
{
	float r_main=0;
	float resistor[6] = {0, 0, 0, 0, 0, 0};
	float capacitor[6] = {0, 0, 0, 0, 0, 0};

} Circuit;
/***** ***** ***** GLOBALS ***** ***** *****/

float* RESISTORS_CPU;
float* CAPACITORS_CPU;

float* RESISTORS_GPU;
float* CAPACITORS_GPU;

int NUM_TEST_FREQUENCIES = 1000;
float MIN_TEST_FREQUENCY = 10;
float MAX_TEST_FREQUENCY = 40000;

const int THREAD_WIDTH = 32;
const int THREAD_HEIGHT =32;
dim3 grid_size;
dim3 block_size;

/***** ***** ***** FUNCITON PROTOTYPES ***** ***** *****/
int get_length_f(float* array);
int fill_array_f(float** destination, const char* file);
void print_array_f(float* arr, int length);
int generate_test_frequencies(float** freq_array, 
							  int num_tests, 
							  float f_min, 
							  float f_max);

// Returns the slope 
float  __device__ evaluate(Circuit c);

void __global__ set_up_devices();


int main() 
{

	int length = fill_array_f(&RESISTORS_CPU, "resistors.txt");
	// print_array_f(RESISTORS_CPU, length);
	
	printf("\n");

	length = fill_array_f(&CAPACITORS_CPU, "capacitors.txt");
	// print_array_f(CAPACITORS_CPU, length);

	float* test_frequencies;

	length = generate_test_frequencies(&test_frequencies, 
									   NUM_TEST_FREQUENCIES, 
									   MIN_TEST_FREQUENCY, 
									   MAX_TEST_FREQUENCY);

	//print_array_f(test_frequencies, length);

	free(test_frequencies);

	free(RESISTORS_CPU);
	free(CAPACITORS_CPU);
	cudaFree(RESISTORS_GPU);
	cudaFree(CAPACITORS_GPU);
}


int get_length_f(float* array) {  return sizeof(array)/sizeof(array[0]);  };

int fill_array_f(float** destination, const char* file) 
{
	FILE *file_pointer = fopen(file, "r");
	if (!file_pointer) {  perror("fopen"); exit(1);  }
	
	char line[64];
	int capacity =16; // initial size
	int count = 0;
	float *arr = (float*)malloc(capacity * sizeof(float));
	if (!arr) {  exit(1);  }


	while (fgets(line, sizeof(line), file_pointer) != NULL) 
	{
		// Assign the array if necessary
		if (count > capacity) 
		{
			capacity += 16;
			float* tmp = (float*)realloc(arr, capacity * sizeof(float));
			arr = tmp;
		}

		arr[count] = strtof(line, NULL);
		count++;
	}
	// Set the address of our destination pointer to be the address of the array
	// we just created
	*destination = arr; 
	return count;
}

void print_array_f(float* arr, int length) 
{
	for (int i = 0; i < length; i++ )
	{
		printf("Position: %d, Value: %f\n", i, arr[i]);
	}
}


// Need to map the threads to the capacitors in the y direction 
// and the resistors in the x direction. 
//
// The formula for mapping the components is as follows:
// x = threadIdx.x, length is number of discrete resistor values.
// R0 = x % length
// R1 = (x/length) % length
// R2 = (x/length^2) % length
// R2 = (x/length^3) % length
//
void __global__ set_up_devices(dim3* gs, dim3 bs, int c_length, int r_length) 
{
	// Set up number of stuff 
}

float __device__ evaluate(float* resistors, 
						  int r_length, 
						  float* capacitors, 
						  int c_length) 
{
	
	float slope = 0;
	Circuit c;
	c.r_main=10000;
	#pragma unroll 10
	for (int i=0; i<r_length; i++)
	{
		c.resistor[i] = threadIdx.x % r_length;
	}
	return slope;
}


// Want to generate a logarithmically spaced array of frequences 
// from 10Hz to 4kHz (a decade before to a decade after)
int generate_test_frequencies(float** freq_array, 
							  int num_tests, 
							  float f_min, 
							  float f_max)
{
	float* arr = (float*)malloc(sizeof(float) * num_tests);
	for (int i =0; i< num_tests; i++)
	{
		// Make a test frequency
		arr[i] = f_min * pow((f_max/f_min), (float)i/(float)(num_tests-1));
	}

	*freq_array = arr;
	return num_tests;	
}






