BEGIN { i = 0 }
{
 	if (! /SENDER/ )
	{
		printf "%f%s",  $(column), OFS
# $12
		if ((NR-1) % evaluations == 0)
		{
			print ORS
		}
	}
}
