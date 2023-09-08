*!Created by mwg 7/2/2018
*!UPDATED 8/28 TO DETECT OS
*!UPDATED 1/7/2021 TO ADD ADDITIONAL SEED OPTION
*!UPDATED 1/15/2021 TO ADD CPATH OPTIONS
*!UPDATED 4/29/2021 to update base2 and sub2 path options
*!Updated 8/31/2021 to fix log issue
*!Updated to Github paths
*!Updated to drop some leftovers from Gibson
*!Updated 8Sep2023 to add clear all and macro drop all options
capture program drop preamble
program define preamble
	version 9.2
	syntax [anything], ///
		ROOTFolder(string) ///
		CLIENTFolder(string) ///
		[BASE(string) ///
		SUB(string) ///
		BASE2(string) ///
		SUB2(string) ///
		LOG ///
		LOGPath(string) ///
		LOGName(string) ///
		GIThub(string) ///
		MKDIR ///
		SCHeme(string) ///
		GRAPHFOnt(string) ///
		SORTseed(numlist int >0 max=1) ///
		CLEAR ///
		SEED(numlist int >0 max=1) ///
		DISCARD ///
		TRACE(string) ///
		MACRODrop ///
		]
	
//0.0 Discard
	if "`discard'"!="" {
		discard
	}
	
//0.1. Clear
	if "`clear'"!="" {
		clear *
	}
	
//0.2. installing dependencies
	cap which confirmdir
	if _rc!=0 {
		quietly ssc install confirmdir
	}
	
//0.3. Date cleanup
	global date
	global date="`c(current_date)'"
	global date=subinstr("${date}", " ", "_", .)
	
//0.4. Log checking
if (!mi("`logname'") | !mi("`logpath'")) & mi("`log'") {
	di as error "Must specify -log- option if passing a log path or log name."
	exit 170
}

//0.4. Clear
	if "`macrodrop'"!="" {
		macro drop _all
	}

//1. Checking for OS to determine base path
	//confirming rootf exists
	confirmdir `"`rootfolder'"'
	if _rc!=0 {
		di as error "Root directory `rootfolder' does not exist"
		exit 170
	}
	
	if c(os)=="MacOSX" | c(os)=="Unix" {
		global rootfolder="`rootfolder'//"
		local sf="`rootfolder'//`clientfolder'"
		global sf="`rootfolder'//`clientfolder'"	
	}	
	else {
		global rootfolder="/`rootfolder'//"	
		local sf="`rootfolder'//`clientfolder'"
		global sf="`rootfolder'//`clientfolder'"	
	}

//2. Creating folders and globals
	//Cleaning up the base path
	local newbase=subinstr("`sf'//`base'", "\", "/", .)
	global base "`newbase'"
	//Now, creating paths
	foreach x in `sub' {
		local path="`newbase'/`x'"
		if "`mkdir'"!="" { //Creating folder if MKDIR option select
			cap mkdir `"`newbase'"'
			cap mkdir `"`path'"'
			if _rc!=0 {
				di "`path': Folder already exists"
			}
		}
		
		//Creating globals
		global `x' "`path'/"
		//Confirming it worked
		confirmdir "${`x'}"
		if `r(confirmdir)'!=0 {
			di as error "Folder `x' doesn't exist. Check base path or specify -mkdir- to create."
				exit 170
		}
	}
	
//3. Now, subfolders
	//Cleaning up the base path
	local newbase2=subinstr("`sf'//`base2'", "\", "/", .)
	global base2 "`newbase2'"
	//Now, creating paths
	foreach xx in `sub2' {
		local path2="`newbase2'/`xx'"
		if "`mkdir'"!="" { //Creating folder if MKDIR option select
			cap mkdir `"`newbase2'"'
			cap mkdir `"`path2'"'
			if _rc!=0 {
				di "`path2': Folder already exists"
			}
		}
		
		//Creating globals
		global `xx'2 "`path2'/"
		//Confirming it worked
		confirmdir "${`xx'2}"
		if `r(confirmdir)'!=0 {
			di as error "Folder `xx'2 doesn't exist. Check base path or specify -mkdir- to create."
				exit 110
		}
	}

//4. Creating log file
	if "`log'"!="" {
		if "`logname'"=="" {
			di as txt "Log name not found. Using log_${date}.txt"
			local logname="log"
		}

		if "`logpath'"!="" {
			local logpath2=subinstr("`sf'//`base'//`logpath'", "\", "/", .)
			//Confirming log path exists
			confirmdir "`logpath2'"
			if _rc==170 {
				di as error "Folder `logpath2' doesn't exist."
				exit 110
			}
		}
		if "`logpath'"=="" {
			di as txt "Log path not found. Placing in current working directory: `c(pwd)'"
			local logpath2=c(pwd)		
		}	
	cap log close
	log using "`logpath2'/`logname'_${date}.txt", replace text
	}
	

//5. Schemes
	if "`scheme'"!="" {
		set scheme `scheme'
	}
	else {
	}		
	
//6. Font
	if "`graphfont'"!="" {
		graph set window fontface "`graphfont'"
		graph set window fontfacesans "`graphfont'"
	}
	else {
	}	
	
//7. Sortseed
	if !mi("`sortseed'") {
		set sortseed `sortseed'
	}
	else {
	}	
	
//8. Seed
	if !mi("`seed'") {
		set seed `seed'
	}
	else {
	}	

//9. Git
	if !mi("`github'") {
		if "`c(username)'"=="garlandm" { //confirming MBP
			global `github' "/Users/`c(username)'/GitHub/"
			confirmdir "${`github'}"
			if `r(confirmdir)'!=0 {
				di as error "Folder `github' doesn't exist. Check path."
					exit 110
			}
		}	
	}

//11. Trace
	if "`trace'"!="" {
		set trace `trace'
	}
end
	
	
	
