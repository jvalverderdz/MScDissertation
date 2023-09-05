*1_aux_wald_baseline.do
*This auxiliary Dofile computes Wald Tests for Baseline Regressions

clear

*****Wages
if $y == 1 {
	set obs 6
	gen model = ""
	gen wald = .
	gen pvalue = .

	local i = 1
	foreach model in baseline baseline_plus fbaseline fbaseline_plus ibaseline ibaseline_plus {
		estimates restore `model'
		
		mat BB = e(b)
		mat VV = e(V)
		
		mat B = (BB[1,1], BB[1,3])
		mat V = (VV[1,1], VV[3,1] \ VV[3,1], VV[3,3])
		mat VInv = inv(V)
		mat Bt = B'
		
		mat W = B*VInv
		mat W = W*Bt
		scalar Wald = W[1,1]
		
		scalar chi2pvalue = chi2tail(2, Wald)
		
		
		replace model = "`model'" in `i'
		replace wald = Wald in `i'
		replace pvalue = chi2pvalue in `i'
		
		local i = `i' + 1
	}

	export excel "$output\regressions\WaldTests_Baseline.xlsx", firstrow(var) replace

}

*****Unemployment

if $y == 2 {
	set obs 2
	gen model = ""
	gen wald = .
	gen pvalue = .

	local i = 1
	foreach model in ubaseline ubaseline_plus {
		estimates restore `model'
		
		mat BB = e(b)
		mat VV = e(V)
		
		mat B = (BB[1,1], BB[1,3])
		mat V = (VV[1,1], VV[3,1] \ VV[3,1], VV[3,3])
		mat VInv = inv(V)
		mat Bt = B'
		
		mat W = B*VInv
		mat W = W*Bt
		scalar Wald = W[1,1]
		
		scalar chi2pvalue = chi2tail(2, Wald)
		
		
		replace model = "`model'" in `i'
		replace wald = Wald in `i'
		replace pvalue = chi2pvalue in `i'
		
		local i = `i' + 1
	}
	
	export excel "$output\regressions\WaldTests_UBaseline.xlsx", firstrow(var) replace
	
}

 