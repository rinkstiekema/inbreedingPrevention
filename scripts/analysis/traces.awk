#!/bin/awk
BEGIN{
PROCINFO["sorted_in"] = "@ind_num_asc"
}

/position/{
    traces[$3] = traces[$3] $2 " " $4 " " $5 "\n"
}

END {
    for (i in traces) 
        printf("%s\n\n",traces[i]);
}
    
