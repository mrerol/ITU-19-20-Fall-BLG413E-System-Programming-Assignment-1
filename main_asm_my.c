#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int cross_correlation_asm_full1(int* arr_1, int size_1, int* arr_2, int size_2, int* output, int output_size);
int cross_correlation_asm_full(int* arr_1, int size_1, int* arr_2, int size_2, int* output, int output_size);
void rvereseArray(int arr[], int start, int end) ;

int main()
{
    int numberOfArrays;
    char buffer[100] = {0};
    
    int** arrays;
    int* arraySizes;
    int lineCount = 0;
    int i, j;
    
    const char arrayFileName[] = "arrays.txt";
    FILE* arrayFile = fopen(arrayFileName, "r");
    if (arrayFile == NULL)
    {
        fprintf(stderr, "Unable to open file %s!\n", arrayFileName);
        return 1;
    }
    
    
    //  read number of arrays
    fgets(buffer, 100, arrayFile);
    sscanf(buffer, "%d", &numberOfArrays);
    printf("%s contains %d arrays\n", arrayFileName, numberOfArrays);
    
    
    //  allocate memory for arrays
    arrays = malloc(numberOfArrays * sizeof(int*));
    if (arrays == NULL)
    {
        fprintf(stderr, "Unable to allocate memory for arrays!\n");
        return 3;
    }
    //  and array sizes
    arraySizes = malloc(numberOfArrays * sizeof(int));
    if (arraySizes == NULL)
    {
        fprintf(stderr, "Unable to allocate memory for arrays!\n");
        return 4;
    }
    
    
    //  read array file line by line
    for (lineCount = 0; lineCount < numberOfArrays; ++lineCount)
    {
        char* tok;
        int numberCount = 0;
        char tokenBuffer[100] = {0};
        int j;
        
        
        //  read line into buffer
        fgets(buffer, 100, arrayFile);
        
        //  count amount of numbers in the line string
        strcpy(tokenBuffer, buffer);
        tok = strtok(tokenBuffer, " \t\n");
        while (tok != NULL)
        {
            ++numberCount;
            tok = strtok(NULL, " \t\n");
        }
        //printf("Found %d numbers in line %d\n", numberCount, lineCount);
        arraySizes[lineCount] = numberCount;
        
        
        //  allocate memory for arrays[lineCount]
        arrays[lineCount] = malloc(numberCount * sizeof(int));
        if (arrays[lineCount] == NULL)
        {
            fprintf(stderr, "Unable to allocate memory for array %d\n", lineCount);
            return 2;
        }
        
        //  read numbers
        strcpy(tokenBuffer, buffer);
        tok = strtok(tokenBuffer, " \t\n");
        j = 0;
        while (tok != NULL)
        {
            sscanf(tok, "%d", &(arrays[lineCount][j]));
            tok = strtok(NULL, " \t\n");
            ++j;
        }
        
    }
    fclose(arrayFile);
    
    
    
    //  print all readed arrays
    printf("\n\n");
    printf("--- Arrays ---\n");
    for (i = 0; i < numberOfArrays; ++i)
    {
        int j = 0;
        for (j = 0; j < arraySizes[i]; ++j)
        {
            printf("%d ", arrays[i][j]);
        }
        printf("\n");
    }
    
    
    
    
    
    //  open an output file
    FILE* outputFile = fopen("cross_correlation_output_c.txt", "w");
    if (outputFile == NULL)
    {
        fprintf(stderr, "Unable to open output file for correlations!\n");
        return 4;
    }
    
    //  calculate result of all cross correlations
    //and write to output file
    for (i = 0; i < numberOfArrays-1; ++i)
    {
        for (j = i+1; j < numberOfArrays; ++j)
        {
            int output_size = arraySizes[i] + arraySizes[j] - 1;
            int* output = malloc(output_size * sizeof(int));
            int nonzeroCount = cross_correlation_asm_full1(arrays[i], arraySizes[i], arrays[j], arraySizes[j], output, output_size);

            //  write output to file
            int k = 0;
            for (k = 0; k < output_size; ++k)
            {
                fprintf(outputFile, "%d ", output[k]);
            }
            fprintf(outputFile, "\n");
            
            
            //  write number of nonzero elements
            fprintf(outputFile, "%d\n", nonzeroCount);
            
            
            //  deallocate output
            free(output);

        }
    }
    fclose(outputFile);
    
    
    //  deallocate 
    for (i = 0; i < numberOfArrays; ++i)
    {
        free(arrays[i]);
    }
    free(arrays);
    free(arraySizes);
            
    
    return 0;
}

int cross_correlation_asm_full1(int* arr_1, int size_1, int* arr_2, int size_2, int* output, int output_size){
	

	int nonzero_count = 0;
	int *long_arr = arr_2;
	int *short_arr = arr_1;
	int size1 = size_2;
	int size2 = size_1;
	
	if(size_1 >= size_2){
		long_arr = arr_1;
		short_arr = arr_2;
		size1 = size_1;
		size2 = size_2;

	}

	int counter_arr = 1;
	int output_counter = 0;
	int temp = 0;
	int i;
	int counter_temp=0;
	
	// first part
	while(counter_arr < size2){
		temp = 0;
		for(i = size2 - output_counter - 1 ; i < size2 ; i++){
			temp += short_arr[i] * long_arr[counter_temp];
			counter_temp++;
		}
		counter_temp=0;
		if(temp!=0)
			nonzero_count++;
		output[output_counter] = temp;
		output_counter++;
		counter_arr++;	
	}
	
	// middle part
	int middle_counter = 0;
	while(counter_arr <= size1 ){
		temp = 0;
		counter_temp = middle_counter;
		for(i = 0; i < size2; i++){
			temp += long_arr[counter_temp]*short_arr[i];
			counter_temp++;
		}
		middle_counter++;
		if(temp!=0)
			nonzero_count++;
		output[output_counter] = temp;
		output_counter++;
		counter_arr++;
	}
	
	// last part
	counter_arr = size2 - 1;
	while(counter_arr > 0){
		temp = 0;
		counter_temp = middle_counter;
		for(i = 0; i < counter_arr; i++){
			temp += long_arr[counter_temp]*short_arr[i];
			counter_temp++;
		}
		middle_counter++;
		if(temp!=0)
			nonzero_count++;
		output[output_counter] = temp;
		output_counter++;
		counter_arr--;
	}
	
	if(size_1<size_2){
		rvereseArray(output, 0, output_size-1);
		//reverse the output
		//for(i=0;i<output_size;i++)
			//push the stack 
		//while(i<outputsize){
			//output[output_size-1] = pop
		//output_size--;
		//}
	}
	return nonzero_count;	
}
/* Function to reverse arr[] from start to end*/
void rvereseArray(int arr[], int start, int end) 
{ 
    int temp; 
    while (start < end) 
    { 	
        temp = arr[start];    
        arr[start] = arr[end]; 
        arr[end] = temp; 
        start++; 
        end--; 
    }    
}  
