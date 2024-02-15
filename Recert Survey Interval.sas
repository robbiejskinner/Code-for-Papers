/* JAN 2020 */
proc import datafile="\\i10file.vumc.org\HPW\Stevenson\Skinner\Regulatory Oversight through Pandemic\data\NH_SurveySummary_Jan2020.csv"
	out=jan2020 dbms=csv replace;
run;

/* JAN 2021 */
proc import datafile="\\i10file.vumc.org\HPW\Stevenson\Skinner\Regulatory Oversight through Pandemic\data\NH_SurveySummary_Jan2021.csv"
	out=jan2021 dbms=csv replace;
run;

/* JAN 2022 */
proc import datafile="\\i10file.vumc.org\HPW\Stevenson\Skinner\Regulatory Oversight through Pandemic\data\NH_SurveySummary_Jan2022.csv"
	out=jan2022 dbms=csv replace;
run;

/* JAN 2023 */
proc import datafile="\\i10file.vumc.org\HPW\Stevenson\Skinner\Regulatory Oversight through Pandemic\data\NH_SurveySummary_Jan2023.csv"
	out=jan2023 dbms=csv replace;
run;

data jan2023a (keep=ccn cycle survey_date statecode);
	set jan2023;
	if 'Inspection Cycle'n in (1 2);
	survey_date = input('Health Survey Date'n, YYMMDD10.);
	format survey_date YYMMDD10.;
	rename 'Federal Provider Number'n=ccn
	'Inspection Cycle'n=cycle
	'Provider State'n=statecode;
run;

data jan2022a (keep=ccn cycle survey_date statecode);
	set jan2022;
	if 'Inspection Cycle'n in (1 2);
	survey_date = input('Health Survey Date'n, YYMMDD10.);
	format survey_date YYMMDD10.;
	rename 'Federal Provider Number'n=ccn
	'Inspection Cycle'n=cycle
	'Provider State'n=statecode;
run;

data jan2021a (keep=ccn cycle survey_date statecode);
	set jan2021;
	if 'Inspection Cycle'n in (1 2);
	survey_date = input('Health Survey Date'n, YYMMDD10.);
	format survey_date YYMMDD10.;
	rename 'Federal Provider Number'n=ccn
	'Inspection Cycle'n=cycle
	'Provider State'n=statecode;
run;

data jan2020a (keep=ccn cycle survey_date statecode);
	set jan2020;
	if cycle in (1 2);
	survey_date = input(H_SURVEY_DATE, YYMMDD10.);
	format survey_date YYMMDD10.;
	rename provnum=ccn
	state=statecode;
run;

proc sort data=jan2020a; by ccn; run;
proc sort data=jan2021a; by ccn; run;
proc sort data=jan2022a; by ccn; run;
proc sort data=jan2023a; by ccn; run;

%macro eachyear(year); 
/* 91 providers only have one survey */
data onesurvey&year. jan&year.b;
	set jan&year.a;
	by ccn;
     if first.ccn and last.ccn 
          then output onesurvey&year.;
     else output jan&year.b;
run;

data jan&year.c;
	set jan&year.b;
/* create a lag date variable */
 	surveydatelag= lag(/*srvy_dt*/ survey_date);
	interval = (intck('days',survey_date,surveydatelag)) / 30.42;
	format surveydatelag yymmdd10.;
run;

data jan&year.d;
	set jan&year.c;
	by ccn;
	if last.ccn;
run;

/* testing if interval ever equals zero or is less than zero*/
/* this never happens */
data testzero&year. testlesszero&year.;
	set jan&year.d;
	if interval = 0 then output testzero&year.;
	if interval < 0 then output testlesszero&year.;
run;


proc sql;
	create table jan&year._avg as
		select mean(interval) as avginterval, statecode
	from jan&year.d
	group by statecode
	;
quit;

%mend;

%eachyear(2020);
%eachyear(2021);
%eachyear(2022);
%eachyear(2023);


proc sql;
     create table statecodes as
     select distinct statename, statecode, state
     from sashelp.zipcode;
quit;

proc sort data=statecodes; by statecode; run;
proc sort data=jan2020_avg; by statecode; run;
proc sort data=jan2021_avg; by statecode; run;
proc sort data=jan2022_avg; by statecode; run;
proc sort data=jan2023_avg; by statecode; run;


data jan2020_avg_state;
	merge statecodes jan2020_avg;
	by statecode;
	if statecode in ('FM' 'GU' 'MH' 'MP' 'PW' 'VI' ) then delete;
	Date= "January 1, 2020";
run;

data jan2021_avg_state;
	merge statecodes jan2021_avg;
	by statecode;
	if statecode in ('FM' 'GU' 'MH' 'MP' 'PW' 'VI' ) then delete;
	Date= "January 1, 2021";
run;

data jan2022_avg_state;
	merge statecodes jan2022_avg;
	by statecode;
	if statecode in ('FM' 'GU' 'MH' 'MP' 'PW' 'VI' ) then delete;
	Date= "January 1, 2022";
run;

data jan2023_avg_state;
	merge statecodes jan2023_avg;
	by statecode;
	if statecode in ('FM' 'GU' 'MH' 'MP' 'PW' 'VI' ) then delete;
	Date= "January 1, 2023";
run;

proc format;
value buckfmt
1 = '0-6'
2 = '6-12'
3 = '12-15'
4 = '15-18'
5 = '18+'
;
run;

data allyears;
	set jan2023_avg_state
	jan2022_avg_state
	jan2021_avg_state
	jan2020_avg_state;
	format 'Average Survey Interval'n buckfmt.;
	if avginterval > 0 and 
	avginterval <= 6 then 
	'Average Survey Interval'n=1;
	if avginterval > 6 and 
	avginterval <= 12 then 
	'Average Survey Interval'n=2;
	if avginterval > 12 and 
	avginterval <= 15 then 
	'Average Survey Interval'n=3;
	if avginterval > 15 and 
	avginterval <= 18 then 
	'Average Survey Interval'n=4;
	if avginterval > 18 
	then 'Average Survey Interval'n=5;
run;

proc sort data=allyears; by Date; run;


*pattern1 v=ms c=CXB3B2BF;
pattern1 v=ms c=CXBBBFAC;
pattern2 v=ms c=CXBFBFBF;
pattern3 v=ms c=CX8C8C8C;
pattern4 v=ms c=CX595959;
* use a SAS-supplied map data set (US) as both the map and response data sets;

proc gmap
map=maps.us
data=allyears 
all;
by Date;
id state;
choro 'AVERAGE SURVEY INTERVAL'n / coutline=black midpoints=2 3 4 5
nolegend;
*/ coutline=black legend=legend1;
*/ discrete coutline=black  ;
run;
quit;
