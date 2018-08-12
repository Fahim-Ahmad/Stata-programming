
* duration between dates

clear
input str10(sd ed)
"08/16/2005" "09/25/2012"
"08/01/2006" "12/27/2010"
"10/01/2017" "09/15/2018"
"05/25/2010" "12/25/2016"
"06/12/2010" "11/25/2017"
"10/01/2000" "01/01/2010"
"06/25/2003" "12/27/2009"
"06/15/2011" "09/25/2015"
"08/22/2002" "12/23/2013"
end
lab var sd "Start date"
lab var ed "End date"

							*** Part one
							
* generate startdate which is equal to sd variable and has date format
gen startdate=date(sd, "MDY")
format %d startdate
* generate enddate which is equal to ed variables and has date format
gen enddate=date(ed, "MDY")
format %d enddate

* difference in days
gen diff=enddate-startdate
* difference in years
replace diff=(enddate-startdate)/365

							*** Part two
							
* program your own command to calculate difference between two dates, and store the average, minimum, and maximum difference into scalars

cap program drop du
program def du , rclass
gen `1'=((date(`2', "`4'"))-(date(`3', "`4'")))/365
cap sum `i'
return scalar N = `r(N)'
return scalar MEAN = `r(mean)'
return scalar MIN = `r(min)'
return scalar MAX = `r(max)'
end

drop startdate enddate diff
du duration ed sd "MDY"
return list

