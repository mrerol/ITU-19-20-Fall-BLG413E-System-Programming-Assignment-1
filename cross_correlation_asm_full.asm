segment .text
global cross_correlation_asm_full

cross_correlation_asm_full:
    push ebp
    mov  ebp,esp
	sub esp, 44 ; there are 11 local variables
	;stack 
	;int middle_counter
	;int counter_temp
	;int i
	;int temp
	;int output_counter
	;int counter_arr 
	;int size2
	;int size1
	;int *short_arr
	;int *long_arr
	;int nonzero_count
	;ebp
	;return address
	;int* arr_1
	;int size_1
	;int* arr_2
	;int size_2
	;int* output
	;int output_size
	
	mov dword [ebp-4], 0 ; int nonzero_count = 0;

	mov eax, [ebp+16]
	mov dword [ebp-8], eax ; int *long_arr = arr_2;
	
	mov eax, [ebp+8]
	mov dword [ebp-12], eax ; int *short_arr = arr_1;
	
	mov eax, [ebp+20]	
	mov dword [ebp-16], eax ; int size1 = size_2;
	
	mov eax, [ebp+12]
	mov dword [ebp-20], eax  ; int size2 = size_1;
	
	mov eax, [ebp+12]
	cmp eax, [ebp+20] 
	jae cond1 ;if(size_1 >= size_2) 
	jmp cond2 ;if(size_1 < size_2) 
	
cond1:
	mov eax, [ebp+8]
	mov dword [ebp-8], eax ; long_arr = arr_1;
	
	mov eax, [ebp+16]
	mov dword [ebp-12], eax ; short_arr = arr_2;
	
	mov eax, [ebp+12]	
	mov dword [ebp-16], eax ; size1 = size_1;
	
	mov eax, [ebp+20]
	mov dword [ebp-20], eax  ; size2 = size_2;
	
cond2:	
	
	mov dword [ebp-24], 1 ; int counter_arr = 1;
	mov dword [ebp-28], 0 ; int output_counter = 0;
	mov dword [ebp-32], 0 ; int temp = 0;
	mov dword [ebp-36], 0 ; int i;
	mov dword [ebp-40], 0 ; int counter_temp=0;
	mov dword [ebp-44], 0 ; int middle_counter = 0;
	
	;first part
loop1:	
	mov eax, [ebp-24] 		; eax = counter_arr
	cmp eax, [ebp-20] 		; if(counter_arr < size2) 
	jb cond3 				; true
	jmp cond4 				; false
cond3:	
	mov dword [ebp-32], 0 	; temp = 0;
	mov eax, [ebp-20] 		; eax = size2 
	sub eax, [ebp-28]		; eax -= output_counter
	dec eax					; eax--
	mov dword [ebp-36], eax	; i = size2 - output_counter - 1 
loop11:
	mov eax, [ebp-36]
	cmp eax, [ebp-20] 		; if (i < size2)
	jb cond5				;true
	jmp cond6				;false
cond5:	
	mov eax, 4				; 4 byte
	mov ecx, [ebp-36]		; ecx = i
	mul ecx					; 4byte* i
	mov edx, [ebp-12] 		; edx = &short_arr
	add edx, eax			; edx = short_arr + i
	mov ecx, [edx]			; ecx = short_arr[i]
	mov eax, 4				; 4 byte
	mov edx, [ebp-40]		; edx = counter_temp
	mul edx					; 4byte* counter_temp
	mov edx, [ebp-8] 		; edx = &long_arr
	add edx, eax			; edx = long_arr + counter_temp
	mov eax, [edx]			; eax = long_arr[counter_temp]
	mul ecx					; short_arr[i] * long_arr[counter_temp];
	mov ecx, [ebp-32]		; ecx = temp
	add ecx, eax
	mov dword [ebp-32], ecx	; temp += short_arr[i] * long_arr[counter_temp];
	mov eax, [ebp-40] 		; counter_temp++;	
	inc eax					; counter_temp++;	
	mov dword [ebp-40], eax ; counter_temp++;
	mov eax, [ebp-36] 		; i++
	inc eax					; i++
	mov dword [ebp-36], eax ; i++
	jmp loop11
cond6:	
	mov dword [ebp-40], 0 	;counter_temp=0;
	mov eax, 0
	cmp eax, [ebp-32] 		;if(temp!=0)
	je cond7  				;false
	mov eax, [ebp-4] 		;nonzero_count++;
	inc eax					;nonzero_count++;	
	mov dword [ebp-4], eax	;nonzero_count++;
cond7:	
	mov eax, 4				; 4 byte
	mov ecx, [ebp-28]
	mul ecx	 				; 4byte* i
	mov edx, [ebp+24] 		; edx = &output
	add edx, eax			; edx = output[output_counter]
	mov ecx, [ebp-32]		; ecx = temp
	mov dword [edx], ecx	; output[output_counter] = temp;
	mov eax, [ebp-28] 		; output_counter++;
	inc eax					; output_counter++;
	mov dword [ebp-28], eax ; output_counter++;
	mov dword eax, [ebp-24] ; counter_arr++;	
	inc eax					; counter_arr++;	
	mov dword [ebp-24], eax ; counter_arr++;	
	jmp loop1
cond4:	

	;middle part
loop2:	
	mov eax, [ebp-24] 		; eax = counter_arr
	cmp eax, [ebp-16] 		; if(counter_arr <= size1) 
	jbe cond8				; true
	jmp cond9 				; false
cond8:	
	mov dword [ebp-32], 0 	; temp = 0;
	mov eax, [ebp-44] 		; eax = middle_counter
	mov dword [ebp-40], eax ; counter_temp = middle_counter;
	mov dword [ebp-36], 0	; i = 0
loop21:
	mov eax, [ebp-36]		; eax = i
	cmp eax, [ebp-20] 		; if (i < size2)
	jb cond10				;true
	jmp cond11				;false
cond10:	
	mov eax, 4				; 4 byte
	mov ecx, [ebp-36]		; ecx = i
	mul ecx					; 4byte* i
	mov edx, [ebp-12] 		; edx = &short_arr
	add edx, eax			; edx = short_arr + i
	mov ecx, [edx]			; ecx = short_arr[i]
	mov eax, 4				; 4 byte
	mov edx, [ebp-40]		; edx = counter_temp
	mul edx					; 4byte* counter_temp
	mov edx, [ebp-8] 		; edx = &long_arr
	add edx, eax			; edx = long_arr + counter_temp
	mov eax, [edx]			; eax = long_arr[counter_temp]
	mul ecx					; short_arr[i] * long_arr[counter_temp];
	mov ecx, [ebp-32]		; ecx = temp
	add ecx, eax
	mov dword [ebp-32], ecx	; temp += short_arr[i] * long_arr[counter_temp];
	mov eax, [ebp-40] 		; counter_temp++;	
	inc eax					; counter_temp++;	
	mov dword [ebp-40], eax ; counter_temp++;
	mov eax, [ebp-36] 		; i++
	inc eax					; i++
	mov dword [ebp-36], eax ; i++
	jmp loop21
cond11:	
	mov eax,[ebp-44]		; eax = middle_counter
	inc eax					; middle_counter++
	mov [ebp-44],eax		; middle_counter++
	mov eax, 0
	cmp eax, [ebp-32] 		;if(temp!=0)
	je cond12  				;false
	mov eax, [ebp-4] 		;nonzero_count++;
	inc eax					;nonzero_count++;	
	mov dword [ebp-4], eax	;nonzero_count++;
cond12:	
	mov eax, 4				; 4 byte
	mov ecx, [ebp-28]
	mul ecx	 				; 4byte* i
	mov edx, [ebp+24] 		; edx = &output
	add edx, eax			; edx = output[output_counter]
	mov ecx, [ebp-32]		; ecx = temp
	mov dword [edx], ecx	; output[output_counter] = temp;
	mov eax, [ebp-28] 		; output_counter++;
	inc eax					; output_counter++;
	mov dword [ebp-28], eax ; output_counter++;
	mov dword eax, [ebp-24] ; counter_arr++;	
	inc eax					; counter_arr++;	
	mov dword [ebp-24], eax ; counter_arr++;	
	jmp loop2
cond9:		

	;last part
	mov eax, [ebp-20]		; eax = size2
	dec eax					; size2-1
	mov dword [ebp-24], eax	;counter_arr = size2 - 1;
loop3:	
	mov eax, [ebp-24] 		; eax = counter_arr
	cmp eax, 0 				; if(counter_arr > 0) 
	ja cond13				; true
	jmp cond14				; false
cond13:	
	mov dword [ebp-32], 0 	; temp = 0;
	mov eax, [ebp-44] 		; eax = middle_counter
	mov dword [ebp-40], eax ; counter_temp = middle_counter;
	mov dword [ebp-36], 0	; i = 0
loop31:
	mov eax, [ebp-36]
	cmp eax, [ebp-24] 		; if (i < counter_arr)
	jb cond15				;true
	jmp cond16				;false
cond15:	
	mov eax, 4				; 4 byte
	mov ecx, [ebp-36]		; ecx = i
	mul ecx					; 4byte* i
	mov edx, [ebp-12] 		; edx = &short_arr
	add edx, eax			; edx = short_arr + i
	mov ecx, [edx]			; ecx = short_arr[i]
	mov eax, 4				; 4 byte
	mov edx, [ebp-40]		; edx = counter_temp
	mul edx					; 4byte* counter_temp
	mov edx, [ebp-8] 		; edx = &long_arr
	add edx, eax			; edx = long_arr + counter_temp
	mov eax, [edx]			; eax = long_arr[counter_temp]
	mul ecx					; short_arr[i] * long_arr[counter_temp];
	mov ecx, [ebp-32]		; ecx = temp
	add ecx, eax
	mov dword [ebp-32], ecx	; temp += short_arr[i] * long_arr[counter_temp];
	mov eax, [ebp-40] 		; counter_temp++;	
	inc eax					; counter_temp++;	
	mov dword [ebp-40], eax ; counter_temp++;
	mov eax, [ebp-36] 		; i++
	inc eax					; i++
	mov dword [ebp-36], eax ; i++
	jmp loop31
cond16:	
	mov eax,[ebp-44]		; eax = middle_counter
	inc eax					; middle_counter++
	mov [ebp-44],eax		; middle_counter++
	mov eax, 0
	cmp eax, [ebp-32] 		;if(temp!=0)
	je cond17  				;false
	mov eax, [ebp-4] 		;nonzero_count++;
	inc eax					;nonzero_count++;	
	mov dword [ebp-4], eax	;nonzero_count++;
cond17:	
	mov eax, 4				; 4 byte
	mov ecx, [ebp-28]
	mul ecx	 				; 4byte* i
	mov edx, [ebp+24] 		; edx = &output
	add edx, eax			; edx = output[output_counter]
	mov ecx, [ebp-32]		; ecx = temp
	mov dword [edx], ecx	; output[output_counter] = temp;
	mov eax, [ebp-28] 		; output_counter++;
	inc eax					; output_counter++;
	mov dword [ebp-28], eax ; output_counter++;
	mov eax, [ebp-24] 		; counter_arr--;	
	dec eax					; counter_arr--;	
	mov dword [ebp-24], eax ; counter_arr--;	
	jmp loop3
cond14:		
	;reverse output
	mov eax, [ebp+12]
	cmp eax, [ebp+20] 	; if(size_1<size_2)
	jb cond18
	jmp cond19
cond18:	
	mov dword [ebp-36], 0	; i = 0
loop4:	
	mov eax, [ebp-36]		; eax = i
	cmp eax, [ebp+28]		; i < output_size	
	jb cond20				;true
	jmp cond21				;false
cond20:
	mov eax, 4				; 4 byte
	mov ecx, [ebp-36]		; ecx = i
	mul ecx					; 4byte* i
	mov edx, [ebp+24] 		; edx = &output
	add edx, eax			; edx = output + i
	mov ecx, [edx]			; ecx = output[i]
	push ecx
	mov eax, [ebp-36] 		; i++
	inc eax					; i++
	mov dword [ebp-36], eax ; i++
	jmp loop4
cond21:	
	mov dword [ebp-36], 0	; i = 0
loop5:	
	mov eax, [ebp-36]		; eax = i
	cmp eax, [ebp+28]		; i < output_size	
	jb cond22				;true
	jmp cond19				;false
cond22:
	mov eax, 4				; 4 byte
	mov ecx, [ebp-36]		; ecx = i
	mul ecx					; 4byte* i
	mov ecx, [ebp+24] 		; edx = &output
	add ecx, eax			; ecx = output + i
	pop eax
	mov [ecx], eax
	mov eax, [ebp-36] 		; i++
	inc eax					; i++
	mov dword [ebp-36], eax ; i++
	jmp loop5
	
cond19:	
    mov eax,[ebp-4] 	; return nonzero_count; 
    
	mov esp, ebp
    pop  ebp
    ret
