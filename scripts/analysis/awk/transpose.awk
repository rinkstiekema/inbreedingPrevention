{
	for(j=1; j<=NF; j++)
	{
		arr[j] = arr[j] OFS $j
	}
	
	nrLines = nrLines < NF ? NF : nrLines;
}
END {
	for(i = 1; i <= nrLines; i++)
		print arr[i]
}
