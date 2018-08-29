
						* Plot missing values 

/* Someone asked me how to plot missing values in a list of variables in a dataset.
I can do it using visdat package in R, but since there is no command in Stata to plot missing values in a dataset, I decided to program my own command.

I named this command "missplot". The syntax of missplot is:
missplot varlist [if] [in], [options]

You can define below options:
	. graph(bar)   -> to visulize missing vlaues in bar chart.
	. graph(pie)   -> to visualize missing vlaues in pie chart.
*/

* Codes
cap program drop missplot
program def missplot
syntax [varlist] [if] [in] , graph(string)
tempvar temp
mark `temp' `if' `in' 
qui {
snapshot save
local snap = `r(snapshot)'

keep if `temp'
keep `varlist'
foreach i of varlist * {
gen miss`i'=(missing(`i'))
drop `i'
}
gen id=_n
reshape long miss, i(id) j(vars, "string")
}
if "`graph'"=="pie" {
graph pie, over(miss) plabel(_all sum) legend(order(1 "Non-missing values" 2 "Missing values")) by(, plegend(on)) by(vars)
}
else if "`graph'" == "bar"{
graph bar (count), over(miss) ascategory asyvars bar(1, fcolor(navy)) bar(2, fcolor(maroon)) blabel(bar, size(small) position(base)) by(, note("1= Missing values,  0 = Non-missing values")) scheme(s2gcolor) by(vars)
}
else if "`graph'" !="bar" | "`graph'" !="pie" {
dis as error "option graph() incorrectly specified"
}
snapshot restore `snap'
snapshot erase `snap'
end

* let's use studentsurvey data from stata website
webuse studentsurvey, clear

* to visualize missing values in all variables
missplot *, graph(bar)
missplot *, graph(pie)

* to visualize missing values if age if greater thatn 18
missplot * if age>18, graph(bar)
missplot * if age>18, graph(pie)

* to visualize missing values in first 50 observations
missplot * in 1/50, graph(bar)
missplot * in 1/50, graph(pie)

