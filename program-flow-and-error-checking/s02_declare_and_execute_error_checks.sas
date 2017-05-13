/*
	Rules sent to governing body, must conform to rules.

	Going to use naming convention to make our lives easy
*/
%macro chk01_cylinders(src_tbl, result_prefix);

	%let lbl = '01-Cylinders must be between 3 and 12, and whole numbers';

	data &result_prefix.01_BAD_CYLINDERS(Label=&lbl);

		length check_description $100;

		SET &src_tbl.;

		IF not((3 <= cylinders <= 12) and (floor(cylinders) = cylinders)) then do;
			check_description = &lbl.;
			output;
		end;
	RUN;

%mend chk01_cylinders;

%macro chk02_msrp(src_tbl, result_prefix);

	%let lbl = '02-MSRP must be greater than 5000';

	data &result_prefix.02_BAD_MSRP(Label=&lbl);

		length check_description $100;

		SET &src_tbl.;

		IF not(MSRP >= 5000) then do;
			check_description = &lbl.;
			output;
		end;
	RUN;

%mend chk02_msrp;

%macro chk03_no_dupes(src_tbl, result_prefix);

	%let lbl = '03-Must be unique on (measure_month make model drivetrain)';

	proc sort 
		nouniquekey 
		data=&src_tbl. 
		uniqueout=_null_
		out=&result_prefix.03_NOT_UNIQUE(Label=&lbl)
	;
		by measure_month make model drivetrain;
	run;

	data &result_prefix.03_NOT_UNIQUE(Label=&lbl);

		length check_description $100;

		SET &result_prefix.03_NOT_UNIQUE;

		check_description = &lbl.;

	RUN;

%mend chk03_no_dupes;

%macro chk04_no_msrp_outliers(src_tbl, result_prefix);

	%let lbl = '04-Detect extreme MSRP outliers. MSRP in the output represents the standardized value.';

	PROC STANDARD 
		DATA=&src_tbl. MEAN=0 STD=1 
		OUT=&result_prefix.04_msrp_outlier(label=&lbl. where=(msrp ge 9))
	;
		by measure_month;
		format msrp 6.3;
		VAR msrp;
	RUN;

	data &result_prefix.04_msrp_outlier(Label=&lbl);

		length check_description $100;

		SET &result_prefix.04_msrp_outlier;

		check_description = &lbl.;

	RUN;
%mend chk04_no_msrp_outliers;

%chk01_cylinders(src_tbl=s01a_test_data, result_prefix=S02a_CHK_);
%chk02_msrp(src_tbl=s01a_test_data, result_prefix=S02a_CHK_);
%chk03_no_dupes(src_tbl=s01a_test_data, result_prefix=S02a_CHK_);
%chk04_no_msrp_outliers(src_tbl=s01a_test_data, result_prefix=S02a_CHK_);
