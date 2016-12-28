/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: Wednesday, December 28, 2016     TIME: 5:17:23 PM
PROJECT: Auto_Lease_Master5
PROJECT PATH: /sbg/warehouse/risk/forecast/dev/data04/Model-NMAExecution/SBNA/Solvency/Retail/Sandbox/TestMigration/AutoLease_CCAR_11Mar/Auto_Lease_Master5.egp
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=ACTIVEX;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HtmlBlue
    STYLESHEET=(URL="file:///C:/sso/sfw/sas/940/SASEnterpriseGuide/7.1/Styles/HtmlBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   START OF NODE: 00_Configure   */
%LET _CLIENTTASKLABEL='00_Configure';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='/sbg/warehouse/risk/forecast/dev/data04/Model-NMAExecution/SBNA/Solvency/Retail/Sandbox/TestMigration/AutoLease_CCAR_11Mar/Auto_Lease_Master5.egp';
%LET _CLIENTPROJECTNAME='Auto_Lease_Master5.egp';
%LET _SASPROGRAMFILE=;

/*ADDING A NEW COMMENT TO INDICATE START OF THE PROGRAM*/
GOPTIONS ACCESSIBLE;
/*******************************************************************************************************************************************************/
/* Program Name: 00_Configure.sas*/
/* Model Implementer(s): Yifan Zhu,  Eswar Gutlapalli, and Michael DeSimone*/
/* Model Developer: TBD*/
/* Description: Configuration File for Residential Implementation Tool*/
/* Creation Date: 2/4/2016*/
/* Modification Date: 3/3/2016*/
/* Change History*/
/* 2-15-2016: Enhanced Macro Call Looping */
/* 2-15-2016: Moved Interim Results Displays to Program 17 for Improved Efficiency and Single Review Point */
/* 2-15-2016: Fixed Defect in Minivan "csubmake_Routan & csubmake_Sedona" variables */
/* 2-23-2016: Auto Insurance Contributor File Split and CSV File Output*/
/* 3-3-2016: Back-out Auto Insurance Contributor File Split, Output CSV Files for All Contrib Files, Remove Hardcoded MDRM Code, Add Cap Mgmt Checker and Addt'l Checker*/
/* 3-8-2016: Stress "ST" Scenario Logic for Grand Cherokee and Ram 1500*/
/*******************************************************************************************************************************************************/
*;
OPTIONS SOURCE SOURCE2 SYMBOLGEN MPRINT MLOGIC LINESIZE=MAX MINOPERATOR NOQUOTELENMAX;
%GLOBAL BASEPATH RUNID EFFDATE FOREDATE MVAR AutoData RESVAL CONT_SFX Num_Scen SCEN_LST SCENO_LST;

* Beginning Of User Specified Parameters;
	%LET BASEPATH = /sbg/warehouse/risk/forecast/dev/data04/Model-NMAExecution/SBNA/Solvency/Retail/Sandbox/TestMigration/AutoLease_CCAR_11Mar; /*IMPORTANT: Change when copying project to new location - The Base Path (Top Level Path) for the Model Data Directory Structure*/
	%LET RUNID = SBNA; /*Used to Identify a Model Execution (No Impact to Model Logic) - MAX 8 Characters - Appended to DATASET Names*/
	%LET EFFDATE = 3Q16; /*Used to Identify the Effective Date of The Model (No Impact to Model Logic) - MAX 4 Characters - Appended to DATASET Names*/
	%LET FOREDATE ='31JUL2016'd; /*Defines the Contributor File Starting PeriodDate in insurance part*/
	%LET MVAR= Period FCBC_US FMUVIM_US FSDEBT_US; /*Macro-Economic Variables Desired*/
	%LET AutoData= ccar_lease_data_final_dec; /*Auto Lease Data from LIBNAME RDMDATA (See Below)*/
	%LET RESVAL = &BASEPATH./report; /*Location for Residual Analysis*/
	%LET CONT_SFX =SB_Retail_Loss; /*Standard Suffix for Contributor Files*/
	%LET MDRM1 = IIN008; /*MDRM Code for Auto Lease Gain on Sale */
	%LET MDRM2 = SNQ950; /*MDRM Code for Auto Repossession Fees */
	%LET MDRM3 = SNQ948; /*MDRM Code for RVI and Chrysler Loss Shares */
	/* Added on 11Mar2016 based on the actual deductibles information */
	%LET Deductible2014=34165183; 
	%LET Deductible2015=6515057; 
	/* END */
	* NOTE: The Following 4 Entries Must Be Entered to Be Consistent for the Scenario ID, Scenario, and MacroEconomic Libraries;
	%LET Num_Scen = 3; /*Enter the Number of Non-Dummy (i.e,, Actual) Scenarios to be Consistent with SCEN_LST and  SCENO_LST*/
	* Enter Exactly 2 Character Scenario IDs Separated by "|" - The 1st Entries are the Non-Dummy Entries - Use Dummies, If Required;
	%LET SCEN_LST= BA|AD|SA;
	* Enter Up To 30 Character Scenario Names - The 1st Entries are the Non-Dummy Entries - Use Dummies, If Required;
	%LET SCENO_LST=Base|Adverse|SevAdv;
* End Of User Specified Parameters;
* Beginning Of Library and FileName Specifications;
	*External from Model Libraries;;
	* Enter LIBNAMES for MacroEconomic Series Directories - Use Dummies If Required - LIBNAME Format Macro<<ID>>, where ID is the Scenario Identifier in SCEN_LST;
	LIBNAME MacroBA "/sbg/warehouse/risk/forecast/dev/data03/INPUT_DATA/macroVariables/MidCycle2016/TO_BE_REVIEWED/MC_Base/National_and_Regional" access=readonly;	
	LIBNAME MacroAD "/sbg/warehouse/risk/forecast/dev/data03/INPUT_DATA/macroVariables/MidCycle2016/TO_BE_REVIEWED/MC_Adverse/National_and_Regional" access=readonly;	
	LIBNAME MacroSA "/sbg/warehouse/risk/forecast/dev/data03/INPUT_DATA/macroVariables/MidCycle2016/TO_BE_REVIEWED/MC_SA/National_and_Regional" access=readonly;	
	LIBNAME RDMDATA "/sbg/warehouse/risk/clrghouse/dev/data03/cart_ey/2015_12_EY/SCUSA/SCUSA_Seg+Y14A" access=readonly;
	LIBNAME SEG "/sbg/warehouse/risk/forecast/dev/data04/Model-NMAExecution/SBNA/Solvency/Retail/Sandbox/TestMigration/AutoLease_CCAR_11Mar/data/coeffs" access=readonly;
*Internal Project Library;
	OPTIONS DLCREATEDIR; /* This Option Automatically Craetes Directories in the LIBNAMES if They Do Not Already Exist*/
	LIBNAME REF1 "&BASEPATH./reference"; /*Model Reference Data*/
	LIBNAME INPUT1 "&BASEPATH./input"; /*Model Input Data*/
	LIBNAME OUTPUT1 "&BASEPATH./output"; /*Model Output Data*/
	LIBNAME REPORT1 "&BASEPATH./report"; /*Model Report Data*/

DATA _NULL_;
	SL="&SCEN_LST.";
	SLO="&SCENO_LST.";
	ARRAY SCN{&Num_Scen.} $2.;
	ARRAY SCNO{&Num_Scen.} $30.;
	* Parse SCEN_LST for Scenario ID (e.g., BL, SA, IC);
	DO I=1 to &Num_Scen.;
		SCN{I} = SCAN(SL, I,'|');
		CALL symput(vname(SCN{I}),SCN{I});
	END;
	* Parse SCENO_LST for Sceario Name (e.g., MidCycle2015Base, MidCycle2015SeverelyAdverse, ICAAP2015);
	 DO J = 1 TO &Num_Scen.;
 		SCNO{J} = SCAN(SLO,J,'|');
		CALL symput(vname(SCNO{J}),SCNO{J});
 	END;
	DROP I J SL SLO;
RUN;
* Create Scenario Dependent Directories for Final Contributor Files;
libname final1 "&BASEPATH./report/01_final_&SCN1.";
libname final2 "&BASEPATH./report/02_final_&SCN2.";
libname final3 "&BASEPATH./report/03_final_&SCN3.";
OPTIONS NODLCREATEDIR;
* CSV File Directories;
%LET CSVLC1 = &BASEPATH./report/01_final_&SCN1.;
%LET CSVLC2 = &BASEPATH./report/02_final_&SCN2.;
%LET CSVLC3 = &BASEPATH./report/03_final_&SCN3.;
* Dates Derivation Global Macro Variables;
Data _NULL_;
%GLOBAL FC_END;
* Derive Dates from Global Macro Variable FOREDATE;
FORMAT FC_END_DT DATE9.;
* Plus 27 Months;
FC_END_DT=intnx('month',&FOREDATE.,26,'end');
CALL symput('FC_END', FC_END_DT);
run;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
