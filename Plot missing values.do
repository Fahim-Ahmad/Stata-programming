/*
						 Plot missing values 

In Stata, there isn’t any command to visualize missing values in a list of variables.
However, you can do it manually by following several steps. For example, replace all variables into dummy, reshape it from wide into long format, then plot it.
Instead, I suggest to program your own command. It simplifies your work and eliminates repetitive tasks. You get better at programming too.

Here is how I programmed a new command to visualize number of missing and non-missing values.
I named this command "missplot". The syntax of missplot is:

missplot varlist [if] [in], [options]

You can define below options:
	. graph(bar)   -> to visulize missing vlaues in bar chart.
	. graph(pie)   -> to visualize missing vlaues in pie chart.
	
	. n(frequency) -> Graph of frequencies within each categories.
	. n(percent)   -> Graph of percent of frequencies within categories.
			  The default is [n(frequency)]
			  
	. all	       -> Specifies that all variables should be plotted, regardless of whether they contain missing values.
			The default of is to omit variables from the plot if they have no missing values	
*/

* Codes
cap program drop missplot
program def missplot
syntax [varlist] [if] [in] [, graph(string) n(string) all]
tempvar temp
mark `temp' `if' `in' 
qui {
	snapshot save
	local snap = `r(snapshot)'
	keep if `temp'
	keep `varlist'

		if "`all'"!="" {
* change all variables into dummy
			foreach i of varlist * {
			gen miss`i'=(missing(`i'))
			drop `i'
			}
		}
		else if "`all'"=="" {	
			foreach i of varlist * {
			gen miss`i'=(missing(`i'))
			sum miss`i'
				if `r(max)'==0 {
				drop miss`i'
				}
			drop `i'
			}	
		}
* reshape the data from wide into long format
	cap drop id
	gen id=_n
	reshape long miss, i(id) j(vars, "string")
}
* visualize missing and non-missing values
** in a pie chart
	if "`graph'"=="pie" {
		if "`graph'"=="pie" & "`n'"!="" {
			if "`graph'"=="pie" & "`n'"=="percent" {
			graph pie, over(miss) plabel(_all percent) legend(order(1 "Non-missing values" 2 "Missing values")) by(, plegend(on)) by(vars)
			}
			else if "`graph'"=="pie" & "`n'"=="frequency" {
			graph pie, over(miss) plabel(_all sum) legend(order(1 "Non-missing values" 2 "Missing values")) by(, plegend(on)) by(vars)
			}
			else if "`graph'" == "pie" & ("`n'" != "frequency" | "`n'" != "percent") {
			dis as error "option n() incorrectly specified"		
			}
		}
		else if "`graph'"=="pie" {
		graph pie, over(miss) plabel(_all sum) legend(order(1 "Non-missing values" 2 "Missing values")) by(, plegend(on)) by(vars)
		}
	}
** in a bar chart:
	else if "`graph'" == "bar" {		
		if "`graph'" == "bar" & "`n'" != "" {		
			if "`graph'" == "bar" & "`n'" == "percent" {
			graph bar , over(miss) by(vars) ascategory asyvars bar(1, fcolor(navy)) bar(2, fcolor(maroon)) blabel(bar, size(small) position(base)) scheme(s2gcolor) by(vars) legend(order(1 "Non-missing values" 2 "Missing values"))
			}
			else if "`graph'" == "bar" & "`n'" == "frequency" {
			graph bar (count) , over(miss) by(vars) ascategory asyvars bar(1, fcolor(navy)) bar(2, fcolor(maroon)) blabel(bar, size(small) position(base)) scheme(s2gcolor) by(vars) legend(order(1 "Non-missing values" 2 "Missing values"))
			}
			else if "`graph'" == "bar" & ("`n'" != "frequency" | "`n'" != "percent") {
			dis as error "option n() incorrectly specified"
			}
		}		
		else if "`graph'" == "bar" {
		graph bar (count), over(miss) ascategory asyvars bar(1, fcolor(navy)) bar(2, fcolor(maroon)) blabel(bar, size(small) position(base)) scheme(s2gcolor) by(vars) legend(order(1 "Non-missing values" 2 "Missing values"))
		}
	}
* display error message if the option [,graph()] in incorrectly specified
	else if "`graph'" !="bar" | "`graph'" !="pie" {
	dis as error "option graph() incorrectly specified"
}
snapshot restore `snap'
snapshot erase `snap'
end

* let's use studentsurvey data from stata website
webuse studentsurvey, clear

* Example 1. to visualize all missing and non-missing values
missplot *, graph(bar)
missplot *, graph(bar) all 
missplot *, graph(bar) n(frequency)
missplot *, graph(bar) n(frequency) all
missplot *, graph(bar) n(percent)
missplot *, graph(bar) n(percent) all

missplot *, graph(pie)
missplot *, graph(pie) all
missplot *, graph(pie) n(frequency)
missplot *, graph(pie) n(frequency) all
missplot *, graph(pie) n(percent)
missplot *, graph(pie) n(percent) all

* to visualize missing and non-missing values if age if greater thatn 18
missplot * if age>18, graph(bar)
missplot * if age>18, graph(bar) all
missplot * if age>18, graph(bar) n(frequency)
missplot * if age>18, graph(bar) n(frequency) all
missplot * if age>18, graph(bar) n(percent)
missplot * if age>18, graph(bar) n(percent) all

missplot * if age>18, graph(pie)
missplot * if age>18, graph(pie) all
missplot * if age>18, graph(pie) n(frequency)
missplot * if age>18, graph(pie) n(frequency) all
missplot * if age>18, graph(pie) n(percent) 
missplot * if age>18, graph(pie) n(percent) all

* to visualize missing and non-missing values in first 50 observations
missplot * in 1/50, graph(bar)
missplot * in 1/50, graph(bar) all
missplot * in 1/50, graph(bar) n(frequency)
missplot * in 1/50, graph(bar) n(frequency) all
missplot * in 1/50, graph(bar) n(percent)
missplot * in 1/50, graph(bar) n(percent) all 

missplot * in 1/50, graph(pie)
missplot * in 1/50, graph(pie) all
missplot * in 1/50, graph(pie) n(frequency)
missplot * in 1/50, graph(pie) n(frequency) all
missplot * in 1/50, graph(pie) n(percent)
missplot * in 1/50, graph(pie) n(percent) all
