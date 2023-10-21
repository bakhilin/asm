section .text

%define element 0

%macro colon 2
	%ifstr %1
		%ifid %2 
			%2:
			dq element
			db %1, 0 
			%define element %2
		%else
			%err "Incorrect lable"
		%endif
	%else
		%err "This field should be string type!"
	%endif
%endmacro 

