# $Id: mmult.awk $
#
# usage: awk -f mmult.awk file1 file2
# will compute matrix multiplication file1 x file2
# file1 must have as many columns as file2 has rows 
# If file1 contains an n x p matrix and file2 a p x m matrix,
# the result will be an m x n matrix (i.e., the result is transposed)
#

# Store first file into matrix A
NR==FNR {
    for (i=1; i<=NF; i++)
    {
    	A[NR,i] = $i
    }
    
    p = NF
   	n = NR
   	
    next
}

# Process records in second file
# precondition: p == NR
{
    for (i = 1; i <= NF; i++)
    {
    	sum = 0
        for (j = 1; j <= n; j++)
        {
        	sum += A[i,j] * $i
        }

        printf sum FS
    }

    print ""
}
