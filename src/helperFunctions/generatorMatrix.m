function PC = generatorMatrix(n,k,Error_corr)

if n == 64 && (k == 2 || k == 3) && Error_corr == 0
    PC = ...
        [1	1	1	1	0	0	0	0	1	1	1	1	0	0	0	0	1	1	1	1	0	0	0	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
        1	1	1	1	0	0	0	0	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	1	1	1	1	1	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	1	1	0	1	1	0	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	1	1	0	0	1	1	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	1	0	0	0	0	0	0	0	0	0	0	0	1	0	1	0	0	1	0	1	0	1	0	0	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        0	1	1	0	1	0	0	1	1	0	0	1	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	1	0	1	0	0	1	1	0	1	0	1	0	1	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        0	1	1	0	1	0	0	1	1	0	0	1	0	1	1	0	1	0	0	1	0	1	1	0	0	1	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	0	1	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	1	1	0	1	1	0	0	1	0	1	1	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	;
        1	1	0	0	1	1	0	0	0	0	0	0	0	0	0	1	1	1	0	0	1	1	0	1	0	0	0	0	0	0	0	1	1	0	0	0	0	1	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	;
        1	0	1	0	1	0	1	0	0	0	0	0	0	0	0	1	1	0	1	0	1	0	1	1	0	0	0	0	0	1	0	0	1	0	1	0	0	0	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	;
        0	1	1	0	1	0	0	1	0	0	0	0	0	0	0	0	1	0	0	1	0	1	1	1	0	0	0	0	0	1	0	0	1	0	0	1	0	1	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	;
        1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	;
        1	1	0	0	0	0	0	0	1	1	0	0	0	0	0	0	1	1	0	0	0	0	0	0	1	1	0	0	0	0	1	1	1	1	0	0	1	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	;
        1	0	1	0	0	0	0	0	1	0	1	0	0	0	0	0	1	0	1	0	0	0	0	0	1	0	1	1	0	0	1	0	1	0	1	0	1	0	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	;
        0	1	1	0	0	0	0	0	1	0	0	1	0	0	0	0	1	0	0	1	0	0	0	0	0	1	1	1	0	0	1	0	1	1	0	1	0	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	;
        1	0	0	0	1	0	0	0	1	0	0	0	1	0	0	1	1	0	0	0	1	0	0	1	1	0	0	0	1	0	1	0	1	0	0	0	1	0	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	;
        0	1	0	0	1	0	0	0	1	0	0	0	0	1	0	0	1	0	0	0	0	1	0	1	0	1	0	0	1	0	1	0	1	1	0	0	0	1	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	;
        0	0	1	0	1	0	0	0	1	0	0	0	0	0	1	0	1	0	0	0	0	0	1	1	0	0	1	1	1	1	1	0	1	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	;
        0	0	0	1	0	1	1	1	0	1	1	1	1	1	1	1	0	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1];
elseif n == 8 && k == 2 && Error_corr == 0
    PC = ...
        [1    0     1     0     0     0     0     0;
        1     1     0     1     0     0     0     0;
        1     1     0     0     1     0     0     0;
        0     1     0     0     0     1     0     0;
        1     0     0     0     0     0     1     0;
        0     1     0     0     0     0     0     1];
elseif n == 63 && k == 1 && Error_corr == 0
    PC = hammgen(6);
elseif n == 31 && k == 1 && Error_corr == 0
    PC = hammgen(5);
elseif n == 15 && k == 1 && Error_corr == 0
    PC = hammgen(4);
elseif n == 15 && k == 1 && Error_corr == 1
    PC = mod( gen2par(hammgen(3))' * hammgen(4),2);
elseif n == 15 && (k == 2 || k == 3) && Error_corr == 0
    PC = ...
       [1     1     0     1     1     0     0     0     0     0     0     0     0     0     0;
        1     0     1     1     0     1     0     0     0     0     0     0     0     0     0;
        0     1     1     1     0     0     1     0     0     0     0     0     0     0     0;
        1     1     1     0     0     0     0     1     0     0     0     0     0     0     0;
        1     1     0     0     0     0     0     0     1     0     0     0     0     0     0;
        1     0     1     0     0     0     0     0     0     1     0     0     0     0     0;
        0     1     1     0     0     0     0     0     0     0     1     0     0     0     0;
        1     0     0     1     0     0     0     0     0     0     0     1     0     0     0;
        0     1     0     1     0     0     0     0     0     0     0     0     1     0     0;
        0     0     1     1     0     0     0     0     0     0     0     0     0     1     0;
        1     1     1     1     0     0     0     0     0     0     0     0     0     0     1];
elseif n == 32 && (k == 2 || k == 3) && Error_corr == 0
    PC = ...
       [1	0	1	0	1	0	1	0	1	0	1	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;	
        1	0	0	1	0	1	1	0	0	1	1	0	1	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0;	
        1	1	0	0	1	1	0	0	1	1	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0;	
        1	1	1	1	0	0	0	0	0	0	0	0	0	1	1	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0;	
        1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0;	
        1	1	0	0	1	1	0	1	0	0	0	0	0	0	1	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0;	
        1	0	1	0	1	0	1	1	0	0	0	0	0	1	1	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0;	
        1	0	0	1	0	1	1	1	0	0	0	0	0	1	0	1	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0;	
        1	1	1	1	0	0	0	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0;	
        1	1	0	0	0	0	0	0	1	1	0	1	0	0	1	1	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0;	
        1	0	1	0	0	0	0	0	1	0	1	1	0	1	1	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0;	
        1	0	0	1	0	0	0	0	0	1	1	1	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0;	
        1	0	0	0	1	0	0	1	1	0	0	1	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0;	
        1	0	0	0	0	1	0	1	0	1	0	1	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0;	
        1	0	0	0	0	0	1	1	0	0	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0;	
        0	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1];
elseif n == 32 && (k == 2 || k == 3) && Error_corr == 1
    PC = ...
        [1	1	0	0	0	0	0	0	0	1	1	1	1	0	0	1	1	0	0	1	0	1	1	0	0	1	1	1	1	1	0	0;
        1	1	1	0	1	0	1	1	0	1	0	1	0	1	1	1	0	1	0	0	1	0	1	1	0	0	1	1	1	1	1	0;
        1	1	0	0	0	1	1	0	0	0	1	0	0	0	1	0	1	0	1	1	0	0	1	1	1	1	1	0	0	0	1	1;
        0	1	1	1	0	0	0	0	0	1	1	0	0	1	0	1	0	1	0	1	1	0	0	1	1	1	1	1	0	0	0	1;
        0	1	1	1	0	1	1	0	1	0	1	0	0	0	0	1	0	0	1	0	1	1	0	0	1	1	1	1	1	0	0	0;
        1	0	1	0	1	0	1	0	1	0	1	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
        1	0	0	1	0	1	1	0	0	1	1	0	1	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0;
        1	1	0	0	1	1	0	0	1	1	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
        1	1	1	1	0	0	0	0	0	0	0	0	0	1	1	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0;
        1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0;
        1	1	0	0	1	1	0	1	0	0	0	0	0	0	1	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0;
        1	0	1	0	1	0	1	1	0	0	0	0	0	1	1	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0;
        1	0	0	1	0	1	1	1	0	0	0	0	0	1	0	1	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0;
        1	1	1	1	0	0	0	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0;
        1	1	0	0	0	0	0	0	1	1	0	1	0	0	1	1	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0;
        1	0	1	0	0	0	0	0	1	0	1	1	0	1	1	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0;
        1	0	0	1	0	0	0	0	0	1	1	1	0	1	0	1	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0;
        1	0	0	0	1	0	0	1	1	0	0	1	1	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0;
        1	0	0	0	0	1	0	1	0	1	0	1	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0;
        1	0	0	0	0	0	1	1	0	0	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0;
        0	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1];
elseif (n == 23 && k == 3 && Error_corr == 0)
    PC = ...
        [0	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0;
        1	1	1	0	1	1	1	0	0	0	1	0	0	1	0	0	0	0	0	0	0	0	0;
        1	1	0	1	1	1	0	0	0	1	0	1	0	0	1	0	0	0	0	0	0	0	0;
        1	0	1	1	1	0	0	0	1	0	1	1	0	0	0	1	0	0	0	0	0	0	0;
        1	1	1	1	0	0	0	1	0	1	1	0	0	0	0	0	1	0	0	0	0	0	0;
        1	1	1	0	0	0	1	0	1	1	0	1	0	0	0	0	0	1	0	0	0	0	0;
        1	1	0	0	0	1	0	1	1	0	1	1	0	0	0	0	0	0	1	0	0	0	0;
        1	0	0	0	1	0	1	1	0	1	1	1	0	0	0	0	0	0	0	1	0	0	0;
        1	0	0	1	0	1	1	0	1	1	1	0	0	0	0	0	0	0	0	0	1	0	0;
        1	0	1	0	1	1	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	1	0;
        1	1	0	1	1	0	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1];
else
    fprintf('PC is not assigned\n');
end