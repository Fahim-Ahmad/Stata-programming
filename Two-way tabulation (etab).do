
* two-way tabulation

/* I train Afghan researchers and data analysts to use Stata instead of Excel for data analysis.
when i describe two way tabulation it's for some of trainees it's confusing how the numbers change when we use [,row] and [,col] options.

I decided to program a new command named etab.
In this command we don't need to use [,row] or [,col] options, instead I programmed this command to add an [, percentage()] option.
so instead of */ tab var1 var2, ro /* we can have the same result by typing */ tab var1 var2, p(var1) /* and instead of */ tab var1 var2, col /* we can write */ tab var1 var2, p(var2)


cap program drop etab
program def etab, byable(recall)
syntax varlist(max=2) [if] [in] [aw] [, * ][ p(string) ]
tokenize `varlist'
local nvar : word count `varlist'
tempvar temp
mark `temp' `if' `in' [`weight'`exp']
local weight "[`weight'`exp']"
if `nvar' == 1 {
tab `1' if `temp' `weight', `options'
}
else if `nvar' ==2 {
	if "`p'" != "" {
		if "`p'" == "`1'" {
			tab `varlist' if `temp' `weight' , ro nofreq `options'
			}
		else if "`p'" == "`2'" {
			tab `varlist'  if `temp' `weight' , col nofreq `options'
			}
     }
	if "`p'" =="" {
	tab `varlist'  if `temp' `weight', `options'
	 }
}
end

etab var1 var2
tab var1 var2

etab var1 var2, p(var1)
tab var1 var2, ro nofreq

etab var1 var2, p(var2)
tab var var2, col nofreq


* Please contact me (fyousufzai93@gmail.com) if you see any error here.
