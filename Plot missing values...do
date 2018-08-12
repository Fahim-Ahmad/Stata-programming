
						* Plot missing values 

/* Since there is no command in Stata to plot missing values in a dataset, I decided to progrm my own command.
I named this command [missplot], the syntax of missplot is:

missplot varlist [if] [in], list

*/

* let's use studentsurvey data from stat website
webuse studentsurvey, clear

* to visualize missing values in all variables
missplot *

* to visualize missing values if age if greater thatn 18
missplot * if age>18

* to visualize missing values in first 50 observations
missplot * in 1/50

* to visulize missing values in all variables and display list of total number of missing value in each variable 
missplot *, list


* Codes

cap program drop missplot
program def missplot 
syntax [varlist] [if] [in] [, list ]
qui {
snapshot save
local snap = `r(snapshot)'
tempvar temp
mark `temp' `if' `in' 
keep if `temp'
keep `varlist'
foreach i of varlist * {
cap confirm string variable `i'
if _rc==0 {
replace `i'="0" if `i'!=""
replace `i'="1" if `i'==""
destring `i', replace
}
else if _rc!=0 {
recode `i' (.=1)(else = 0)
}
sum `i'
if `r(mean)' == 0 {
drop `i' 
}
}
des
if `r(k)' == 0 {
dis as text in red ". No missing values found"
snapshot restore `snap'
snapshot erase `snap'
exit
}
else 
{
ds
rename (*) (miss*)
gen id = _n
reshape long miss, i(id) j(vars, "string")
}
lab def miss 1"Missing values" 0"Non-missing values"
lab val miss miss
tabplot miss var, showval sep(miss) bar1(bfcolor(blue*0.3 blcolor(blue))) bar2(blcolor(red) bfcolor(red*0.3)) xtitle("") ytitle("") subtitle("Counts")
}
if "`list'" ~= "" {
collapse (count) miss if miss==1, by(vars)
gsort -miss
list , noobs
}
else 
{
snapshot restore `snap'
snapshot erase `snap'
exit 
}
end



