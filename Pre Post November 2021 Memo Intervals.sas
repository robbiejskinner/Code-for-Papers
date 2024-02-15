/*  
*/
/*********************************************************************/

data prov2023 (keep=ccn sff_status overall_rating) ;
	set NH_ProviderInfo_Nov2023;
	rename 'cms certification number (ccn)'n=ccn
	'Special Focus Status'n=sff_status
	'Overall Rating'n=overall_rating;
run;

data prov2021 (keep=ccn sff_status overall_rating) ;
	set NH_ProviderInfo_Oct2021;
	rename 'Federal Provider Number'n=ccn
	'Special Focus Status'n=sff_status
	'Overall Rating'n=overall_rating;
run;

/* First Step: Create separate data tables for 2023 and 2021 versions of the 
provider groups: Non-SFFs, SFFs, SFF Candidates, 1-Star Facilities,
5-Star Facilities, Facilities with Recent IJ Surveys */

/* Facilities with Recent IJ Surveys 2023 */
proc sort data='Last 3 Years of IJs Per Facility'n;
	by ccn;
run;

proc sort data=prov2023;
	by ccn;
run;

data IJProviders2023 (drop=survey_date);
	merge 'Last 3 Years of IJs Per Facility'n (in=a) prov2023 (in=b);
	by ccn;
	if a and b;
run;
proc sort data=IJProviders2023 out=IJProviders2023a nodupkey;
	by ccn;
run;

/* Facilities with Recent IJ Surveys 2021 */
proc sort data='LAST 3 YEARS OF IJS PER FAC_0000'n;
	by ccn;
run;

proc sort data=prov2021;
	by ccn;
run;

data IJProviders2021 (drop=survey_date);
	merge 'LAST 3 YEARS OF IJS PER FAC_0000'n (in=a) prov2021 (in=b);
	by ccn;
	if a and b;
run;
proc sort data=IJProviders2021 out=IJProviders2021a nodupkey;
	by ccn;
run;

/* Non-SFFs 2023 */
data nonSFFs_2023;
	set prov2023;
	if sff_status = '';
	if ccn = '' then delete;
run;


/* Non-SFFs 2021 */
data nonSFFs_2021;
	set prov2021;
	if sff_status = '';
	if ccn = '' then delete;
run;


/* SFFs 2023 */
data SFFs_2023;
	set prov2023;
	if sff_status = 'SFF';
	if ccn = '' then delete;
run;


/* SFFs 2021 */
data SFFs_2021;
	set prov2021;
	if sff_status = 'SFF';
	if ccn = '' then delete;
run;


/* SFF Candidates 2023 */
data SFFCandidates_2023;
	set prov2023;
	if sff_status = 'SFF Candidate';
	if ccn = '' then delete;
run;


/* SFF Candidates 2021 */
data SFFCandidates_2021;
	set prov2021;
	if sff_status = 'SFF Candidate';
	if ccn = '' then delete;
run;


/* 1-Star 2023 */
data _1Star_2023;
	set prov2023;
	if overall_rating = 1;
	if ccn = '' then delete;
run;

/* 1-Star 2021 */
data _1Star_2021;
	set prov2021;
	if overall_rating = 1;
	if ccn = '' then delete;
run;


/* 5-Star 2023 */
data _5Star_2023;
	set prov2023;
	if overall_rating = 5;
	if ccn = '' then delete;
run;

/* 5-Star 2021 */
data _5Star_2021;
	set prov2021;
	if overall_rating = 5;
	if ccn = '' then delete;
run;




/************************************************/

data surveydates2023a (keep=ccn cycle survey_date type);
	set NH_SurveyDates_Nov2023;
	if 'Survey Cycle'n in (1 2);
	if 'Type of Survey'n = "Health Standard";
/*	survey_date = input('Survey Date'n, YYMMDD10.);*/
/*	format survey_date YYMMDD10.;*/
	rename 'CMS Certification Number (CCN)'n=ccn
	'Survey Cycle'n=cycle
	'Type of Survey'n=type
	'Survey Date'n=survey_date;
run;

data surveydates2021a (keep=ccn cycle survey_date type);
	set NH_SurveyDates_Oct2021;
	if 'Survey Cycle'n in (1 2);
	if 'Type of Survey'n = "Health Standard";
/*	survey_date = input('Survey Date'n, YYMMDD10.);*/
/*	format survey_date YYMMDD10.;*/
	rename 'Federal Provider Number'n=ccn
	'Survey Cycle'n=cycle
	'Type of Survey'n=type
	'Survey Date'n=survey_date;
run;


/*******************************************/
/* Create 2023 Survey Files */
proc sort data=_5Star_2023; by ccn; run;
proc sort data=_1Star_2023; by ccn; run;
proc sort data=SFFCandidates_2023; by ccn; run;
proc sort data=SFFs_2023; by ccn; run;
proc sort data=nonSFFs_2023; by ccn; run;
proc sort data=IJProviders2023; by ccn; run;

proc sort data=surveydates2023a; by ccn; run;

data _5Star_2023surveys;
	merge surveydates2023a (in=a) _5Star_2023 (in=b);
	by ccn;
	if a and b;
run;
data _1Star_2023surveys;
	merge surveydates2023a (in=a) _1Star_2023 (in=b);
	by ccn;
	if a and b;
run;
data SFFCandidates_2023surveys;
	merge surveydates2023a (in=a) SFFCandidates_2023 (in=b);
	by ccn;
	if a and b;
run;
data SFFs_2023surveys;
	merge surveydates2023a (in=a) SFFs_2023 (in=b);
	by ccn;
	if a and b;
run;
data nonSFFs_2023surveys;
	merge surveydates2023a (in=a) nonSFFs_2023 (in=b);
	by ccn;
	if a and b;
run;
data IJProviders2023surveys;
	merge surveydates2023a (in=a) IJProviders2023a (in=b);
	by ccn;
	if a and b;
run;

/*******************************************/
/* Create 2021 Survey Files */
proc sort data=_5Star_2021; by ccn; run;
proc sort data=_1Star_2021; by ccn; run;
proc sort data=SFFCandidates_2021; by ccn; run;
proc sort data=SFFs_2021; by ccn; run;
proc sort data=nonSFFs_2021; by ccn; run;
proc sort data=IJProviders2021; by ccn; run;

proc sort data=surveydates2021a; by ccn; run;

data _5Star_2021surveys;
	merge surveydates2021a (in=a) _5Star_2021 (in=b);
	by ccn;
	if a and b;
run;
data _1Star_2021surveys;
	merge surveydates2021a (in=a) _1Star_2021 (in=b);
	by ccn;
	if a and b;
run;
data SFFCandidates_2021surveys;
	merge surveydates2021a (in=a) SFFCandidates_2021 (in=b);
	by ccn;
	if a and b;
run;
data SFFs_2021surveys;
	merge surveydates2021a (in=a) SFFs_2021 (in=b);
	by ccn;
	if a and b;
run;
data nonSFFs_2021surveys;
	merge surveydates2021a (in=a) nonSFFs_2021 (in=b);
	by ccn;
	if a and b;
run;
data IJProviders2021surveys;
	merge surveydates2021a (in=a) IJProviders2021a (in=b);
	by ccn;
	if a and b;
run;


/***************************************************/

%macro year_file(file,type,year); 

data onesurvey&type.&year. &file.&year.surveysb;
	set &file.&year.surveys;
	by ccn;
     if first.ccn and last.ccn 
          then output onesurvey&type.&year.;
     else output &file.&year.surveysb;
run;

data &file.&year.surveysc;
	set &file.&year.surveysb;
/* create a lag date variable */
 	surveydatelag= lag(/*srvy_dt*/ survey_date);
	interval = (intck('days',survey_date,surveydatelag)) / 30.42;
	format surveydatelag yymmdd10.;
run;

data &file.&year.surveysd;
	set &file.&year.surveysc;
	by ccn;
	if last.ccn;
run;

/* testing if interval ever equals zero or is less than zero*/
/* this never happens */
data testzero&type.&year. testlesszero&type.&year.;
	set &file.&year.surveysd;
	if interval = 0 then output testzero&type.&year.;
	if interval < 0 then output testlesszero&type.&year.;
run;


proc sql;
	create table &file.&year.surveys_avg as
		select mean(interval) as avginterval, "&file." as type,
		&year. as year
	from &file.&year.surveysd
	;
quit;

%mend;

%year_file(IJProviders,IJ,2021);
%year_file(IJProviders,IJ,2023);

%year_file(_5star_,_5star,2021);
%year_file(_5star_,_5star,2023);

%year_file(_1star_,_1star,2021);
%year_file(_1star_,_1star,2023);

%year_file(SFFCandidates_,SFFCandidates,2021);
%year_file(SFFCandidates_,SFFCandidates,2023);

%year_file(SFFs_,SFFs,2021);
%year_file(SFFs_,SFFs,2023);

%year_file(nonSFFs_,nonSFFs,2021);
%year_file(nonSFFs_,nonSFFs,2023);


data allappended;
	set sffs_2023surveys_avg sffs_2021surveys_avg
	nonsffs_2023surveys_avg nonsffs_2021surveys_avg
	sffcandidates_2023surveys_avg sffcandidates_2021surveys_avg
	_1star_2023surveys_avg _1star_2021surveys_avg
	_5star_2023surveys_avg _5star_2021surveys_avg
	IJProviders2023surveys_avg IJProviders2021surveys_avg;
run;