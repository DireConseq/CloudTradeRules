%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - GENERIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( generic_rules, `2020-08-03 14:51:02` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the minus sign preceding the pound sign
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_read_amount_with_negative_before_pound_sign( [ ITEM ] ), [
%=======================================================================

	or( [
		[ `-`, `£`, NEGATIVE_ITEM ]

		, [ `£`, POSITIVE_ITEM ]
	] )

] )
:-
	POSITIVE_ITEM =.. [ ITEM, d ],
	NEGATIVE_ITEM =.. [ ITEM, n ]
. %end%

%=======================================================================
i_rule( gen_negativised_read_amount_with_negative_before_pound_sign( [ ITEM ] ), [
%=======================================================================

	or( [
		[ `-`, `£`, POSITIVE_ITEM ]

		, [ `£`, NEGATIVE_ITEM ]
	] )

] )
:-
	POSITIVE_ITEM =.. [ ITEM, d ],
	NEGATIVE_ITEM =.. [ ITEM, n ]
. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Count the number of lines until a match
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( gen_count_lines( [ RULE, 0 ] ), [ RULE ] ).
%=======================================================================
i_rule_cut( gen_count_lines( [ RULE, N ] ), [ line, gen_count_lines( [ RULE, M ] ), check( i_user_check( gen_add, M, 1, N ) ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPLATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_separator, [ or( [ `-`, `/`, `\\` ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remember to peek_ahead this !!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( gen_trace_line, [ dummy(s1), trace( [ gen_trace_line, dummy ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_date, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	invoice_date( f( [ begin , q(dec,1,2) , end ] ) )

	, gen_separator

	, append(
			invoice_date( f( [ begin , q(dec,1,2) , end ] ) )

			, `/`, ``
	)

	, gen_separator

	, append(
			invoice_date( f( [ begin , q(dec,2,4) , end ] ) )

			, `/`, ``
	)
] )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_prefix(50), [] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_prefix(TAB), [ q0n(anything), tab(TAB) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_start_of_phrase, [ q01( [ q0n(anything), tab ] ) ] ). % note this does not MOVE to the start of a phrase!!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_postfix(TAB), [ tab(TAB) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_postfix(50), [ newline ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_eof, [ or( [ tab, newline ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( gen_doctype, [ or( [ `invoice`, [ `credit` , q10(`note`) , set(credit_note) ] ] ) ] ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( gen_line_nothing_here( [ START, BEFORE, AFTER ] ), [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	peek_fails( nearest( START, BEFORE, AFTER ) )
] )

. %end%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( gen_line_nothing_here( [ START, END, BEFORE, AFTER ] ), [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	peek_fails( nearest( START, END, BEFORE, AFTER ) )
] )

. %end%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I_USER_CHECK routines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_checkmark, NAME ) :- i_marked_region( NAME ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_recognised_city, CITY ) :- lookup_city( CITY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_recognised_county, COUNTY ) :- lookup_county( COUNTY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_street_clue, STREET ) :- lookup_street_clue( STREET ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_company_clue, COMPANY ) :- lookup_company_clue( COMPANY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_secondary_company_clue, COMPANY ) :- lookup_secondary_company_clue( COMPANY ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_contact_clue, CONTACT ) :- lookup_contact_clue( CONTACT ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_presence, A ) :- q_sys_is_string( A ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_instantiated, A ) :- not( q_sys_var( A ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_number_to_string, A, B ) :- sys_string_number( B, A ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_add, A, B, A_plus_B ) :- sys_calculate_str_add( A, B, A_plus_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_subtract, A, B, A_minus_B ) :- sys_calculate_str_subtract( A, B, A_minus_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_multiply, A, B, A_mult_B ) :- sys_calculate_str_multiply( A, B, A_mult_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_str_divide, A, B, A_div_B ) :- sys_calculate_str_divide( A, B, A_div_B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_normalise_2dp_in_string, A, A_2dp ) :- normalise_2dp_in_string( A, A_2dp ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_eq, A, B ) :- q_sys_comp_str_eq( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_gt, A, B ) :-  q_sys_comp_str_gt( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_lt, A, B ) :-  q_sys_comp_str_lt( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_ge, A, B ) :-  q_sys_comp_str_ge( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_le, A, B ) :-  q_sys_comp_str_le( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_q_sys_comp_str_approx_equal, A, B, Tolerance ) :-  q_sys_comp_str_approx_equal( A, B, Tolerance ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_add, A, B, A_plus_B ) :- sys_calculate( A_plus_B, A + B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_subtract, A, B, A_minus_B ) :- sys_calculate( A_minus_B, A - B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_divide, A, B, A_div_B ) :- sys_calculate( A_div_B, A // B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_mod, A, B, A_mod_B ) :- sys_calculate( A_mod_B, A mod B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_2dp_mult, A, B, A_times_B ) :- sys_calculate( A_times_B, ( ( A * 100 * B ) // 1 ) / 100 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_2dp_divide, A, B, A_div_B ) :- sys_calculate( A_div_B, ( ( A * 100 ) // B ) / 100 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_average, A, B, Avg ) :- sys_calculate( Avg, ( A + B ) // 2 ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_same, A, B ) :- A = B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_different, A, B ) :- A \= B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_lt, A, B ) :- A < B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_le, A, B ) :- A =< B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_gt, A, B ) :- A > B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_ge, A, B ) :- A >= B.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_member, A, B ) :- q_sys_member( A,  B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_not_member, A, B ) :- not( q_sys_member( A,  B ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_length, A, B ) :- sys_string_length( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_trim, A, B ) :- sys_string_trim( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_number, A, B ) :- sys_string_number( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_to_lower, A, B ) :- string_to_lower( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_to_upper, A, B ) :- string_to_upper( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_string_replace, A, B, C, D ) :- string_string_replace( A, B, C, D ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_sub_string, A, B, C, D ) :- q_sys_sub_string( A, B, C, D ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_op_param, A, B ) :- qq_op_param( A, B ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_set, CNTR, VALUE ) :- sys_cntr_set( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_get, CNTR, VALUE ) :- sys_cntr_get( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_get_str, CNTR, VALUES ) :- sys_cntr_get( CNTR, VALUE ), sys_string_number( VALUES, VALUE).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_inc, CNTR, VALUE ) :- sys_cntr_inc( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_inc_str, CNTR, VALUES ) :- sys_cntr_inc( CNTR, VALUE ), sys_string_number( VALUES, VALUE).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_dec, CNTR, VALUE ) :- sys_cntr_dec( CNTR, VALUE ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_cntr_dec_str, CNTR, VALUES ) :- sys_cntr_dec( CNTR, VALUE ), sys_string_number( VALUES, VALUE).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( gen_unique_id, PREFIX, ID, ID_S )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	sys_string_atom( PREFIX_S, PREFIX ),

	sys_cntr_inc( 9, UID ),

	sys_string_number( UID_S, UID ),

	sys_strcat( PREFIX_S, UID_S, ID_S ),

	sys_string_atom( ID_S, ID )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( approx_equal_percent, A, B, P )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	sys_calculate( Tolerance, A * P / 100 )

	, i_user_check( approx_equal, A, B, Tolerance )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( approx_equal, A, B )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	i_user_check( approx_equal, A, B, 5 )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_check( approx_equal, A, B, Tolerance )
%-----------------------------------------------------------------------
:-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	sys_calculate( Diff, abs( A - B ) )

	, q_sys_comp( Diff < Tolerance )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some generic formats for regexp parsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_user_data( gen_somewhere_format( WHAT, [ p(any,0,999) , strong, q(WHAT,1,1) ] ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% best_address_match predicate should be of the form: Postcode, Address_String, Code
%
% call with check( i_user_check( best_address_match, Table_predicate_name, Postcode_found, Address_string_found, Returned_code ) )
%
%	-	Updated the Address modifier to use a match 'score' instead of direct comparison
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
best_address_match_ignore_words( [ `street`, `road` ] ).
%===============================================================================

%===============================================================================
i_user_check( best_address_match, BCFB, Dept, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	q_sys_is_string( BCFB )
	, string_to_lower( Pc, Pc_lower )
	, string_to_lower( Address, Address_lower )
	, string_to_lower( BCFB, BCFBL )
	, string_string_replace( BCFBL, ` `, `_`, BCFBRep )

	, strcat_list( [ `arco_`, BCFBRep, `_address_lookup` ], Table )

	, sys_findall( ( A, C )
		, ( q_gratabase_lookup( Table, [ Dept, Pc_lower, _, _ ], [ _, _, A1, C ], _ ), string_to_lower( A1, A1L ), sys_string_tokens( A1L, A ) )
		, Matches
	)

	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
i_user_check( best_address_match, BCFB, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	q_sys_is_string( BCFB )
	, string_to_lower( Pc, Pc_lower )
	, string_to_lower( Address, Address_lower )
	, string_to_lower( BCFB, BCFBL )
	, string_string_replace( BCFBL, ` `, `_`, BCFBRep )

	, strcat_list( [ `arco_`, BCFBRep, `_address_lookup` ], Table )

	, sys_findall( ( A, C )
		, ( q_gratabase_lookup( Table, [ _, Pc_lower, _, _ ], [ _, _, A1, C ], _ ), string_to_lower( A1, A1L ), sys_string_tokens( A1L, A ) )
		, Matches
	)

	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.


%===============================================================================
i_user_check( best_address_match, Predicate, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	q_sys_is_atom(Predicate)
	, string_to_lower( Pc, Pc_lower )

	, string_to_lower( Address, Address_lower )

	, Matcher =.. [ Predicate, Pc_lower, A1, C ]

	, sys_findall( ( A, C ), ( Matcher, sys_string_tokens( A1, A ) ), Matches )

	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
i_user_check( best_address_match, Predicate, Dept, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	string_to_lower( Pc, Pc_lower )

	, string_to_lower( Address, Address_lower )

	, string_to_lower( Dept, Dept_lower )

	, Matcher =.. [ Predicate, Dept_lower, Pc_lower, A1, C ]

	, sys_findall( ( A, C ), ( Matcher, sys_string_tokens( A1, A ) ), Matches )

	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
i_user_check( best_address_match_numeric_pc, Predicate, Pc, Address, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	  string_to_lower( Address, Address_lower )

	, Matcher =.. [ Predicate, Pc, A1, C ]

	, sys_findall( ( A, C ), ( Matcher, sys_string_tokens( A1, A ) ), Matches )

	, ( Matches = [ ( _, Match ) ] -> true ; best_address_match_fit( Address_lower, Matches, Match ) )
.

%===============================================================================
best_address_match_fit( Address, Matches, Match )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	sys_string_tokens( Address, AT1 )

	, best_address_match_ignore_words( IW )

	, compare_lists( AT1, IW, AT )

	, sys_asserta( best_address_match_fit_pattern( AT ) )

	, transform_list( best_address_match_fit_analysis, Matches, Analysed_matches )

	, sys_retract( best_address_match_fit_pattern( AT ) )

	, sys_sort( Analysed_matches, [ ( _, Match ) | _ ] )
.

%===============================================================================
best_address_match_fit_analysis( ( In, In_code ), ( Match_Score, In_code ) )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	best_address_match_fit_pattern( AT )

	, best_address_match_ignore_words( IW )	%	Unreasonable to remove them from lookup
	, compare_lists( In, IW, In_x )			%	and not the address on the doc

	, compare_lists( AT, In_x, Left )
	, compare_lists( In_x, AT, Remainder )

	, length( Left, Result )
	, length( Remainder, Rem_Result )	%	Need to know what is left

	% , sys_calculate( Test, 1 * 10 )

	, sys_calculate( Result_Coefficient, 10 * Result )	%	Worse to miss a token
	, sys_calculate( Match_Score, Result_Coefficient + Rem_Result )	%	Than to have excess in the string

	, trace( match( Match_Score ) )	%	Perfect match will score zero
.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HORIZONTAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	10/07/2014
%%%		-	Updated to use generic_item as the variable capture
%%%		-	Reducing redundancy
%%%		-	Updated so that specifying a tab length doesn't demand the 'After' parameter
%%%
%%%	-	28/08/2014
%%%		-	Updated Searching ability
%%%			-	If the use of 'at_start' at the beginning of the search then q0n(anything) will not be called
%%%
%%%	-	03/09/2014
%%%		-	Tidied the post :- Prologue
%%%			-	Removed redundancy in or statement
%%%
%%%	-	25/09/2014
%%%		-	Changed three variable version to identify through parameter instead of after
%%%
%%%	-	27/11/2014
%%%		-	Updated to allow full regular expressions to be called and identified
%%%
%%%	-	05/02/2015
%%%		-	Added a cut after the anchor endings
%%%
%%%	-	29/09/2015
%%%		-	Added an additional variable - gen_hook
%%%			-	This attempts to capture the whole hook specified so it can provide the end position as well
%%%			-	This can fail - tabs can be included
%%%
%%%	-	02/11/2015
%%%		-	Found a bug that prevented the single var variant fail if an or statement was used
%%%		-	Introduced with the end of hook usage
%%%
%%%	-	17/05/2016
%%%		-	Updated to allow you to read a string straight into a variable
%%%
%%%	-	02/07/18
%%%		-	Allow for misaligned lines within a tolerance specified by
%%%			generic_horizontal_details_vertical_tolerance( Tolerance )
%%%		-	Shorthand to 'h_details' introduced
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Single Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( h_details_cut( [ Search ] ), [ generic_horizontal_details( [ Search ] ) ] ).
%=======================================================================
i_rule( h_details( [ Search ] ), [ generic_horizontal_details( [ Search ] ) ] ).
%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search ] ), [ generic_horizontal_details( [ Search ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search ] ), [
%=======================================================================

	or( [ [ check( Skip = `skip` ), q0n(anything) ]
		, [ check( Skip = `noskip` ) ]
	] )

	, read_ahead( Search )

	, q10( tab ), read_ahead( generic_hook(w) )
	, trace( [ `Start position stored in generic_hook(start)` ] )

	, or( [ test( gen_hor_or_used )
		, [ peek_fails( test( gen_hor_or_used ) ), gen_hor_get_gen_hook( [ End ] ) ]
	] )

	, clear( gen_hor_or_used )

] )
:-
	get_skip_indicator( Search, Skip ),
	( sys_reverse( Search, [ [ ] | End ] )
		->	true

		;	sys_reverse( Search, [ End | _ ] )

		;	Search = or( _ )
			->	sys_assertz( grammar_set( gen_hor_or_used ) )

		;	q_sys_is_string( Search ), Search = End
	),
	!
.


%=======================================================================
i_rule_cut( gen_hor_get_gen_hook( [ End ] ), [
%=======================================================================

	q10( [
		gen_hook(s), back, End
		, trace( [ `Start and End positions stored in gen_hook` ] )
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Two Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( h_details_cut( [ Variable, Parameter ] ), [ generic_horizontal_details( [ Variable, Parameter ] ) ] ).
%=======================================================================
i_rule( h_details( [ Variable, Parameter ] ), [ generic_horizontal_details( [Variable, Parameter ] ) ] ).
%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Variable, Parameter ] ), [ generic_horizontal_details( [ Variable, Parameter ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Variable, Parameter ] ), [ horizontal_details( [ `no_search`, 1, Variable, Parameter, none ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Three Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( h_details_cut( [ Variable, Parameter, After ] ), [ generic_horizontal_details( [ Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( h_details( [ Search, Variable, Parameter ] ), [ generic_horizontal_details( [ Search, Variable, Parameter ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Variable, Parameter, After ] ), [ generic_horizontal_details( [ Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Variable, Parameter, After ] ), [ horizontal_details( [ `no_search`, 1, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Variable, Parameter ] ), [ horizontal_details( [ Search, 100, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Four & Five Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( h_details_cut( [ Search, Tab_Length, Variable, Parameter ] ), [ generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter ] ) ] ).
%=======================================================================
i_rule( h_details( [ Search, Tab_Length, Variable, Parameter ] ), [ generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter ] ) ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( h_details_cut( [ Search, Tab_Length, Variable, Parameter, After ] ), [ horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( h_details( [ Search, Tab_Length, Variable, Parameter, After ] ), [ horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Tab_Length, Variable, Parameter ] ), [ generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-	q_sys_is_number( Tab_Length ).
%=======================================================================

%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter ] ), [ horizontal_details( [ Search, Tab_Length, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:- q_sys_is_number( Tab_Length ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Variable, Parameter, After ] ), [ generic_horizontal_details( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Variable, Parameter, After ] ), [ horizontal_details( [ Search, 100, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule_cut( generic_horizontal_details_cut( [ Search, Tab_Length, Variable, Parameter, After ] ), [ generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ), [ horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( horizontal_details( [ Search, Tab_Length, Variable, Parameter, After ] ), [
%=======================================================================

	or( [ [ check( Skip == `skip` ), q0n(anything) ]
		, [ check( Skip == `noskip` ) ]
	] )

	, xor( [ check( Search_Ind == `none` )
			, [ check( Search_Ind == `normal` ), Search ]
	] )

	, skip_anchor_endings

	, or( [ [
			xor( [ [ check( Tab_Length >	100 ), tab( Tab_Length ) ]
				, [ check( Tab_Length < 101 ), q10( tab( Tab_Length ) ) ]
			] )

			, generic_item( [ Variable, Parameter, After ] )
		]
		, [ check( Search_Ind == `normal` )
			, peek_fails( or( [ tab( Tab_Length ), word ] ) )
			, back, gen_hor_end_check(sf1)
			, check( gen_hor_end_check(end) = End )
			, check( sys_calculate( Left, End + 3 ) )
			, check( gen_hor_end_check(y) = BeginY )
			, parent, or( [ [ line,  set( gen_hor_parent_line ) ], [ up, set( gen_hor_parent_up ) ] ] )
			, generic_line( 1, Left, 500, [ [
				read_ahead( gen_hor_begin_check(w) )
				, check( gen_hor_begin_check(start) = Begin )
				, check( sys_calculate( Diff, Begin - End ) )
				, check( Diff > 0 )
				, check( Diff < Tab_Length )
				, check( gen_hor_begin_check(y) = EndY )
				, or( [ [ check( EndY >= BeginY ), check( sys_calculate( YDiff, EndY - BeginY ) ) ]
					, [ check( EndY < BeginY ), check( sys_calculate( YDiff, BeginY - EndY ) ) ]
				] )
				, check( YDiff =< VertTol )
				, generic_item( [ Variable, Parameter, After ] )
			] ] )

			, or( [ [ test( gen_hor_parent_up ), clear( gen_hor_parent_up ) ]
				, [ test( gen_hor_parent_line )
					, line
					, clear( gen_hor_parent_line)
				]
			] )
		]
	] )

] )
:-

	get_search_indicator( Search, Search_Ind ),
	get_skip_indicator( Search, Skip ),
	( generic_horizontal_details_vertical_tolerance( VertTol ) -> true ; VertTol = 10 ),
	!
.

%=======================================================================
i_rule_cut( skip_anchor_endings, [ q(3,0, or( [ `:`, `-`, `;`, `.` ] ) ) ] ).
%=======================================================================

%=======================================================================
get_search_indicator( Search, Search_Ind )
%-----------------------------------------------------------------------
:-
	q_sys_is_string( Search )
	, Search = `no_search`
	->	Search_Ind = `none`

	;	Search_Ind = `normal`
.
%=======================================================================
get_skip_indicator( Search, Skip )
%-----------------------------------------------------------------------
:-
	( q_sys_is_list( Search )
		, Search = [ H | _ ]

		;	Search = H
	)

%	To improve efficiency in searches that want to start at the beginning of the line
	, H = at_start
	->	Skip = `noskip`

	; 	Skip = `skip`
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERIC ITEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	Bug found! 	Fixed( 04/06/2014 )
%%%		-	If the 'after' parameter was left empty then the none used as
%%%			an atom to signify the end ( and is left in to keep compatibility )
%%%			then it could be called upon to capture a word
%%%
%%%	-	28/08/2014 OPTIONAL is legacy
%%%		-	Introduced a better method to convert the old optional method into the new method
%%%		-	Tidier OR statement at the end
%%%
%%%	-	03/09/2014
%%%		-	Tidied the post :- Prologue
%%%			-	Removed redundancy in or statement
%%%
%%%	-	27/11/2014
%%%		-	Allowed use of full regular expressions within the rule (fd( _ ) and f( _ ))
%%%
%%%	-	05/02/2015
%%%		-	Introduced cuts to prevent backtracking - previously the rule will retry 2-3 times after a failure
%%%
%%%	-	15/07/2015
%%%		-	Introduced the five variable version
%%%		-	No special checking for numbers
%%%		-	Final two parameters specify the co-ordinate space the data is expected
%%%		- 	4th - co-ordinate space the start of data must be beyond
%%%		-	5th - co-ordinate space the data must end before
%%%
%%%	-	15/07/2016
%%%		-	generic_item( [ 5 params ] ) was not behaving in the same way regarding currency symbols and percentage signs
%%%
%%%	-	06/06/2016
%%%		-	Minor tweaks needed
%%%
%%%	-	21/06/2016
%%%		-	Minor tweaks to five variable variant needed
%%%
%%%	-	18/09/2018
%%%		-	Allow minor gaps between currencies and numbers
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter, Optional, Spacing ] ), [ generic_item( [ Variable, Parameter, Optional, Spacing ] ) ] ).
%=======================================================================
i_rule( generic_item( [ Variable, Parameter, Optional, Old_Spacing ] ), [
%=======================================================================

	generic_item( [ Variable, Parameter, Spacing ] )

] )
:-
	( Optional = `not`
		->	trace( `Remove 'not' from rules - obsolete and incompatible` )
			, Spacing = Old_Spacing

		;	not( Optional = `not` )
			, sys_string_atom( Optional, Atom )
			, Spacing =.. [ Atom, Old_Spacing ]

	), !

.

%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter, Spacing, Start, End ] ), [ generic_item( [ Variable, Parameter, Spacing, Start, End ] ) ] ).
%=======================================================================
i_rule( generic_item( [ Variable, Parameter, Spacing, Start, End ] ), [
%=======================================================================

	generic_item_currency( [ Currency ] )

	, Read_Variable

	, generic_item_percentage( [ Percentage ] )

	, generic_item_spacing( [ Spacing ] )

	, generic_item_check_start( [ VarStart, Start ] )

	, generic_item_check_end( [ VarEnd, End ] )

	, trace( [ Variable_Name, Variable ] )

] )
:-

	( q_sys_is_list( Parameter )
		->	Full_Param =.. [ f, Parameter ],
			Read_Variable =.. [ Variable, Full_Param ]

		;	Read_Variable =.. [ Variable, Parameter ]

	),

	sys_string_atom( Variable_Name, Variable ),

	VarStart =.. [ Variable, start ],
	VarEnd =.. [ Variable, end ],

	( q_sys_member( Parameter, [ d, n, fd( _ ), d1, n1 ] )
		->	Currency = skip_currency,
			Percentage = `%`

		;	Currency = null,
			Percentage = null
	),
	!
.

%=======================================================================
i_rule_cut( generic_item_percentage( [ null ] ), [ ] ).
%=======================================================================
i_rule( generic_item_percentage( [ `%` ] ), [ q10( `%` ) ] ).
%=======================================================================
%=======================================================================
i_rule_cut( generic_item_currency( [ null ] ), [ ] ).
%=======================================================================
i_rule_cut( generic_item_currency( [ skip_currency ] ), [ skip_currency ] ).
%=======================================================================
%=======================================================================
i_rule_cut( generic_item_spacing( [ null ] ), [ ] ).
%=======================================================================
i_rule_cut( generic_item_spacing( [ Spacing ] ), [ Spacing ] ):- Spacing \= null.
%=======================================================================
%=======================================================================
i_rule_cut( generic_item_check_start( [ _, null ] ), [ ] ).
%=======================================================================
i_rule_cut( generic_item_check_start( [ VarPos, Start ] ), [ check( VarPos > Start ) ] ):- q_sys_is_number( Start ); Start =.. [ _, Pos ], q_sys_member( Pos, [ start, end ] ).
%=======================================================================
i_rule_cut( generic_item_check_start( [ _, Start ] ), [ ] ):- not( q_sys_is_number( Start ) ), not( ( Start =.. [ _, Pos ], q_sys_member( Pos, [ start, end ] ) ) ).
%=======================================================================
%=======================================================================
i_rule_cut( generic_item_check_end( [ _, null ] ), [ ] ).
%=======================================================================
i_rule_cut( generic_item_check_end( [ VarPos, End ] ), [ check( VarPos < End ) ] ):- q_sys_is_number( End ); End =.. [ _, Pos ], q_sys_member( Pos, [ start, end ] ).
%=======================================================================
i_rule_cut( generic_item_check_end( [ _, End ] ), [ ] ):- not( q_sys_is_number( End ) ), not( ( End =.. [ _, Pos ], q_sys_member( Pos, [ start, end ] ) ) ).
%=======================================================================
%=======================================================================
i_rule_cut( generic_item_field_analysis( [ Variable, Parameter ] ),
%=======================================================================

	Rule

)
:-
	(
		% Flag - one alert is enough
		% Flag - custom disabling
		( grammar_set( datatype_alert_already_present )
			;	grammar_set( disable_datatype_alert )
		)
		->	Rule = [ ]

		% Analysis currently only relevant for amount fields
		;	( sub_atom( Variable, _, _, amount )
				;	sub_atom( Variable, _, _, total )
			),

			%	Blocks
			not( sub_atom( Variable, _, _, x ) ), % _x is common
			not( sub_atom( Variable, _, _, y ) ), % _y is less common
			not( sub_atom( Variable, _, _, hook ) ), % hook is common
			not( sub_atom( Variable, _, _, dummy ) ), % dummy - because it's a dummy
			not( sub_atom( Variable, _, _, uom ) ), % UOM Codes don't have to be numbers, line_quantity_uom_code triggered this

			(
				q_sys_member( Parameter, [ f( _ ), fd( _ ), nd( _ ), d, d1, n, c ] )
				->	!, Rule = [ ] % 'correct' variables
				;	sys_string_atom( ParameterS, Parameter ),
					sys_string_atom( VariableS, Variable ),
					get_rules_file_name( Rules ),
					strcat_list( [ Rules, ` has a numerical field captured with a non-numerical datatype - Please investigate: `, VariableS, ` captured using '`, ParameterS, `'` ], Trace ),
					Rule = [ check( alert( Trace, `0`, `hours` ) ), set( datatype_alert_already_present ) ]
			)

		;	Rule = [ ] % Inoffensive catch means that if something goes wrong the rule should always succeed

	)
.

%=======================================================================
i_rule( generic_item( [ Variable, String ] ), [ VarSet, trace( [ VarS, `has been set to`, String ] ) ] )
%-----------------------------------------------------------------------
:- q_sys_is_string( String ), sys_string_atom( VarS, Variable ), VarSet =.. [ Variable, String ].
%=======================================================================
i_rule( generic_item( [ Variable, Parameter ] ), [ generic_item_rule( [ Variable, Parameter, none ] ) ] ).
%=======================================================================
i_rule( generic_item( [ Variable, Parameter, Spacing ] ), [ generic_item_rule( [ Variable, Parameter, Spacing ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter ] ), [ generic_item_rule( [ Variable, Parameter, none ] ) ] ).
%=======================================================================
i_rule_cut( generic_item_cut( [ Variable, Parameter, Spacing ] ), [ generic_item_rule( [ Variable, Parameter, Spacing ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( generic_item_rule( [ Variable, Parameter, Spacing ] ), [
%=======================================================================

	xor( [ [ check( Numerical = `true` ), skip_currency ]

		, check( Numerical = `false` )
	] )

	, Read_Variable

	, or( [ [ check( Numerical = `true` ), q10( `%` ) ]

		, check( Numerical = `false` )
	] )

	, xor( [ [ check( Spacing_String = `VOID` )
			, Spacing

		]

		, [ check( not( Spacing_String = `none` ) )
			, check( not( Spacing_String = `VOID` ) )
			, Spacing

		]

		, check( Spacing_String = `none` )

	] )

	, trace( [ Variable_Name, Variable ] )

	, generic_item_field_analysis( [ Variable, Parameter ] )

] )
:-
	q_sys_is_atom(Variable),
	( q_sys_is_list( Parameter )
		->	Full_Param =.. [ f, Parameter ],
			Read_Variable =.. [ Variable, Full_Param ]

		;	Read_Variable =.. [ Variable, Parameter ]

	),

	( ( 	Parameter =.. [ fd | _ ]
			;	q_sys_member( Parameter, [ d, n, d1, n1 ] )
		)
		->	Numerical = `true`

		;	Numerical = `false`
	),

	sys_string_atom( Variable_Name, Variable ),

	( q_sys_is_atom( Spacing ), sys_string_atom( Spacing_String, Spacing )

		;	Spacing_String = `VOID`

	), !
.

%=======================================================================
i_rule_cut( skip_currency, [ q10( [ or( [ `$`, `£`, `€` ] ), q10( tab(100) ) ] ) ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERIC APPEND
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	15/07/2015 ( INTRODUCTION )
%%%		-	Will append a variable appropriately
%%%			[ Var, Par, After, Before Append, After Append ]
%%%
%%%	-	17/05/2016
%%%		-	Can append strings to a value
%%%			Will even back away from a newline in order to prevet unusual restriction
%%%
%%%	-	05/07/2016
%%%		-	Fix for string appending - forcing of 'back' was bad
%%%			-	Made it optional
%%%
%%%	-	29/07/2016
%%%		-	Change to display the 'appended' value
%%%			-	Feature requested for ease of tracking
%%%
%%%	-	01/12/2016
%%%		-	Changed the handling of the 'Spacing' due to issues with check attempting to force 'find_params'
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( generic_append( [ _, String, Before, After ] ), [
%=======================================================================

	generic_append_trace_values( [ String, Before, After ] )
	, fail
] )
:-
	( q_sys_var( String ); q_sys_var( Before ); q_sys_var( After ) ),
	!
.

%=======================================================================
i_rule_cut( generic_append_trace_values( [ String, Before, After ] ), [
%=======================================================================

	trace( [ `One of the values is uninstantiated:`, String, Before, After ] )
	, trace( [ `Please review the code to ensure that all values are present` ] )

] ).

%=======================================================================
i_rule( generic_append( [ Variable, String, Before, After ] ), [
%=======================================================================

	read_ahead( [
		q01( [ back, q10( back ) ] ) % Moves away from newline, which appends still fail
		, Append_Var
		, trace( [ `Appended`, Variable_Name, `with`, FullString ] )
	] )

] )
:-

	q_sys_is_string( String ),
	Read_Variable =.. [ Variable, String ],
	Append_Var =.. [ append, Read_Variable, Before, After ],
	strcat_list( [ Before, String, After ], FullString ),

	sys_string_atom( Variable_Name, Variable ),
	!
.

%=======================================================================
i_rule( generic_append( [ Variable, Parameter, Spacing, Before, After ] ), [
%=======================================================================

	Read_Variable

	, generic_item_spacing( [ Spacing ] )

	, check( gen_append_dummy = Gen_Append_Value )

	, read_ahead( [
		q01( back )
		, Append_Var
	] )
	, check( strcat_list( [ Before, Gen_Append_Value, After ], Appended_Value_Full ) )

	, trace( [ `Appended`, Variable_Name, `With`, Appended_Value_Full ] )

] )
:-
	not( q_sys_is_string( Parameter ) ),
	( q_sys_is_list( Parameter )
		->	Full_Param =.. [ f, Parameter ],
			Read_Variable =.. [ gen_append_dummy, Full_Param ]

		;	Read_Variable =.. [ gen_append_dummy, Parameter ]

	),

	Append_Value =.. [ Variable, Gen_Append_Value ],
	Append_Var =.. [ append, Append_Value, Before, After ],

	sys_string_atom( Variable_Name, Variable ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERTICAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	-	10/07/2014
%%%		-	Updated to use generic_item as the variable capture
%%%		-	Reducing redundancy
%%%		-	Updated variations that can be called:
%%%
%%%			-	Three parameter which will search for the first string
%%%				in the search to use as the anchor
%%%			-	Several new versions which don't require the 'After'
%%%				parameter
%%%
%%%	-	14/07/2014
%%%		-	Could be called 'incorrectly'
%%%		-	Updated to check and added another variety
%%%
%%%	-	25/09/2014
%%%		-	Updated the anchor-less versions to deal with or statements as the search
%%%		-	Will not cope with first item in a list being an or statement however
%%%
%%%	-	27/11/2014
%%%		-	Updated to allow full regular expressions to be called and identified
%%%
%%%	-	03/03/2015
%%%		-	Two changes
%%%			-	Introduction of ability to specify number of lines to be captured
%%%			-	Change in the way the parameters are specified for the nearest function to use
%%%
%%%	-	29/09/2014
%%%		-	Allowed modification of the rule
%%%		- 	specifying the 'start' or 'end' as 'startword' or 'endword' will cause 'nearest_word' to be used
%%%
%%%	-	02/12/2015
%%%		-	Bug with startword and endword IF used alongside tolerances
%%%
%%%	-	03/06/2015
%%%		-	Allow to look above if specified by user
%%%
%%%	-	14/07/2016
%%%		-	Ensure that the up and down aspects behave in the same way - changed to add 2 to the number of lines
%%%			q(0,0,up) will now look on the line above
%%%
%%%	-	02/07/18
%%%		-	Introduced shorthand to v_details
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Three Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( v_details_cut( [ Search, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Variable, Parameter ] ) ] ).
%=======================================================================
i_rule( v_details( [ Search, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Variable, Parameter ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Variable, Parameter ] )] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, start, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-
	( q_sys_is_list( Search )	->	Search_List = Search

		;	Search_List = [ Search ]

	)

	, search_for_string( Search_List, Anchor ), !
.

%=======================================================================
search_for_string( Search, Anchor )
%-----------------------------------------------------------------------
:-
	Search = [ Potential_Anchor | Tail ],

	( not( Potential_Anchor =.. [ or | _ ] )
		->	( q_sys_is_string( Potential_Anchor ) -> Anchor = Potential_Anchor

				; search_for_string( Tail, Anchor )

			)

		;	Potential_Anchor =.. [ or | [ Or_Lists ] ],
			search_or_list_for_anchors( Or_Lists, Anchor )
	)
.
%=======================================================================
search_or_list_for_anchors( Lists_In, Or_Out )
%-----------------------------------------------------------------------
:-
	search_lists_for_anchors( Lists_In, Anchor_List ),
	Or_Out =.. [ or | [ Anchor_List ] ]
.
%=======================================================================
search_lists_for_anchors( [ List_H | List_T ], [ Anchor_H | Anchor_T ] )
%-----------------------------------------------------------------------
:-
	( q_sys_is_list( List_H )	-> List_H_List = List_H

		;	List_H_List = [ List_H ]
	),

	search_for_string( List_H_List, Anchor_H ),

	( List_T = [ ]
		-> true

		;	search_lists_for_anchors( List_T, Anchor_T )
	)
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Four Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( v_details_cut( [ Search, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( v_details( [ Search, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------------------------
:-

	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	),

	( q_sys_is_list( Search )	->	Search_List = Search

		;	Search_List = [ Search ]

	),

	search_for_string( Search_List, Anchor ), !
.
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.
%=======================================================================

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Five Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( v_details_cut( [ Search, Anchor, Pos, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter ] ) ] ).
%=======================================================================
i_rule( v_details( [ Search, Anchor, Pos, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-	q_sys_member( Pos, [ start, end ] ).
%=======================================================================

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-	q_sys_member( Pos, [ start, end ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------------------------
:-
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.
%=======================================================================

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, start, 10, 10, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------------------------
:-
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Six Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( v_details_cut( [ Search, Anchor, Pos, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( v_details( [ Search, Anchor, Pos, Variable, Parameter, After ] ), [
%=======================================================================

	  generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter, After ] )

] ).

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Variable, Parameter, After ] ), [
%=======================================================================

	  generic_vertical_details( [ Search, Anchor, Pos, 10, 10, Variable, Parameter, After ] )

] ):- q_sys_member( Pos, [ start, end ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Seven Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( v_details_cut( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ) ] ).
%=======================================================================
i_rule( v_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_is_number( Left ), q_sys_is_number( Right ).
%=======================================================================

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------
:-	q_sys_is_number( Left ), q_sys_is_number( Right ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Eight Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( v_details_cut( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( v_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_vertical_details_cut( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ), [ generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, Pos, Left, Right, Variable, Parameter, After ] ), [
%=======================================================================

	  look_for_anchor( [ Search, Anchor ] )

	, q01( line ), look_for_detail( [ Pos, Left, Right, Variable, Parameter, After ] )

] ).

%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, LineMul, PosVar, Variable, Parameter ] ), [ generic_vertical_details( [ Search, Anchor, LineMul, PosVar, Variable, Parameter, none ] ) ] ).
%=======================================================================
i_rule( generic_vertical_details( [ Search, Anchor, LineMul, PosVar, Variable, Parameter, After ] ), [
%=======================================================================

	look_for_anchor( [ Search, Anchor ] )

	, Lines, look_for_detail( [ Pos, Left, Right, Variable, Parameter, After ] )

	, clear( generic_vertical_use_nearest_word )

] )
%-----------------------------------------------------------------------
:-
	( q_sys_member( LineMul, [ q01, q10, qn1, q1n ] )
		->	Lines =.. [ LineMul, line ]

		;	LineMul = q(LineMin,LineMax)
			->	Lines = q(LineMin,LineMax,line)

		;	LineMul = q(LineMinRaw,LineMaxRaw,up)
			->	sys_calculate( LineMin, LineMinRaw + 2 ),
				sys_calculate( LineMax, LineMaxRaw + 2 ),
				Lines = q(LineMin,LineMax,up)

		;	LineMul = q(LineMin,LineMax,line)
			->	Lines = q(LineMin,LineMax,line)

		;	( not( i_user_data( gen_vert_multiplier_traced_for( Variable ) ) )
				->	trace( [ `Line Multiplier invalid, defaulting to q01` ] ),
					sys_assertz( i_user_data( gen_vert_multiplier_traced_for( Variable ) ) )

				;	i_user_data( gen_vert_multiplier_traced_for( Variable ) )
			),
			Lines = q01(line)
	), !,

	( q_sys_member( PosVar, [ start, end ] )
		->	( not( i_user_data( anchor_traced_for( Variable ) ) )
				->	trace( [ `Only anchor point defined, defaulting tolerance` ] ),
					sys_assertz( i_user_data( anchor_traced_for( Variable ) ) )

				;	i_user_data( anchor_traced_for( Variable ) )
			),
			PosVar = Pos,
			Left = 10,
			Right = 10

		;	q_sys_member( PosVar, [ startword, endword ] )
			->	( not( i_user_data( anchor_traced_for( Variable ) ) )
					->	trace( [ `Only anchor point defined, defaulting tolerance` ] ),
						sys_assertz( i_user_data( anchor_traced_for( Variable ) ) )

					;	i_user_data( anchor_traced_for( Variable ) )
				),

				sys_string_atom( PosVarString, PosVar ),
				string_string_replace( PosVarString, `word`, ``, PosVarStringRep ),
				sys_string_atom( PosVarStringRep, Pos ),
				(grammar_set( generic_vertical_use_nearest_word )
					->	true
					;	sys_assertz( grammar_set( generic_vertical_use_nearest_word ) )
				),

				Left = 10,
				Right = 10

		;	PosVar = ( PosX, LeftX, RightX ),
			( q_sys_member( PosX, [ start, end ] )
				->	Pos = PosX

				;	q_sys_member( PosX, [ startword, endword ] )
					->	sys_string_atom( PosVarString, PosX ),
						string_string_replace( PosVarString, `word`, ``, PosVarStringRep ),
						sys_string_atom( PosVarStringRep, Pos ),
						(grammar_set( generic_vertical_use_nearest_word )
							->	true
							;	sys_assertz( grammar_set( generic_vertical_use_nearest_word ) )
						)

				;	( not( i_user_data( anchor_traced_for( Variable ) ) )
						->	trace( [ `Anchor Point in incorrect format, defaulting to start` ] ),
							sys_assertz( i_user_data( anchor_traced_for( Variable ) ) )

						;	i_user_data( anchor_traced_for( Variable ) )
					),
					Pos = start
			),

			tolerance_check( Variable, left, LeftX, Left ),
			tolerance_check( Variable, right, RightX, Right )
	), !
.

%======================================================================
tolerance_check( Variable, Side, TolIn, TolOut )
%----------------------------------------------------------------------
:-
	( q_sys_is_number(TolIn)
		->	TolIn = TolOut

		;	q_sys_is_string(TolIn),
			q_regexp_match( `^\\d+$`, TolIn, _ )
			->	sys_string_number( TolIn, TolOut )

		;	( not( i_user_data( tolerance_check( Variable, Side, TolIn ) ) )
				->	trace( [ `Tolerance invalid: `, TolIn, ` defaulting to 10` ] ),
					sys_assertz( i_user_data( tolerance_check( Variable, Side, TolIn ) ) )

				;	i_user_data( tolerance_check( Variable, Side, TolIn ) )
			),
			TolOut = 10
	),!
.
%======================================================================

%=======================================================================
i_line_rule( look_for_anchor( [ Search, Anchor ] ), [
%=======================================================================

	  q0n(anything)

	, read_ahead( Search )

	, q0n(anything), read_ahead( Anchor )

	, anchor(w)

	, trace( [ `found anchor` ] )

] ).

%=======================================================================
i_line_rule( look_for_detail( [ Pos, Left, Right, Variable, Parameter, After ] ), [
%=======================================================================

	  NearestRule

	, generic_item( [ Variable, Parameter, After ] )

] )
:-
	( grammar_set( generic_vertical_use_nearest_word )
		->	Pred = nearest_word

		;	Pred = nearest
	),
	AnchorPos =.. [ anchor, Pos ],
	NearestRule =.. [ Pred, AnchorPos, Left, Right ]
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		Gen1_parse_text_rule
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		--		Reads a paragraph of text attempting to extract data from it
%%%
%%%		-	Left and Right are the start and end points for the paragraph
%%%		-	End Line is the line after the end of the paragraph
%%%		-	Search is in case there is an anchor within the text that should be used
%%%		-	Expression is in the form [ begin, q..., end ] and will form a regular expression for identification of the desired data
%%%			-	Exception!! If there is a search or keyword before the desired data then the regular parameters can be used.
%%%
%%%		-	Bug Found	( Fixed April )
%%%			-	If the capture of the item was failed, a backtrack into the 'gen_count_lines' would be attempted
%%%			-	This resulted in it counting over a useful line - this has been wrapped in a cut to prevent the backtracking
%%%
%%%		-	Bug Found		( Fixed 04/06/2014 )
%%%			-	captured_text was unavailable if the 'Search' parameter was populated
%%%
%%%		-	10/07/2014
%%%			-	Introduced 3 variable version - just to utilise the captured_text variable
%%%
%%%		-	Bug Found		( Fixed 12/12/2014 )
%%%			-	Search Parameter removed the cut on the count so the count could be re-done if no values were found.
%%%
%%%		-	29/09/2015
%%%			-	Upon trying to capture the 'captured_text' variable it will now remove it prior. This prevents a peculiar issue
%%%				that appears when capturing lines, sometimes resulting in the text to duplicate
%%%
%%%		-	01/08/2016
%%%			-	Retab was removed in some version prior - this has been brought back. Prevents issue brought by copying an appended value
%%%
%%%		-	13/13/2017
%%%			-	Removed xor and changed to an or with conditions on both branches
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen1_parse_text_rule( [ Left, Right, End_Line ] ), [ gen1_parse_text_rule( [ Left, Right, End_Line, dummy, [ begin, q(any,1,20),end ] ] ) ] ).
%=======================================================================
i_rule( gen1_parse_text_rule( [ Left, Right, End_Line, Variable_List, Expression_List ] ), [
%=======================================================================

	  peek_ahead( count_lines_for_parse( [ End_Line, Count_less_1 ] ) )

	, check( sys_calculate( Count, Count_less_1 + 1 ) )

	, read_ahead( [

		or( [
			[ check( q_sys_is_list( Variable_List ) )
				, trace( [ `Multi Read` ] )
				, parse_text_line( Count, Left, Right, [ Variable_List, Expression_List ] )
			]

			, [ check( not( q_sys_is_list( Variable_List ) ) )
				, trace( [ `Single Read` ] )
				, parse_text_line_single( Count, Left, Right, [ Variable_List, Expression_List ] )
			]
		] )

	] )

	, capture_parse_line( Count, Left, Right )

] ).

%=======================================================================
i_rule_cut( count_lines_for_parse( [ End_Line, Count_less_1 ] ), [ line, gen_count_lines( [ End_Line, Count_less_1 ] ) ] ).
%=======================================================================
i_line_rule( capture_parse_line, [ remove( captured_text ), retab( [ 10000 ] ), captured_text(s1) ] ).
%=======================================================================
i_line_rule( parse_text_line_single( [ Variable, Expression ] ), [ parse_text_rule_single( [ Variable, Expression ] ) ] ).
%=======================================================================
i_line_rule( parse_text_line( [ Variable_List, Expression_List ] ), [ parse_text_rule( [ Variable_List, Expression_List ] ) ] ).
%=======================================================================
i_rule( parse_text_rule_single( [ Variable, Expression ] ), [
%=======================================================================

	  q0n(anything)

	, Read_Variable

	, trace( [ String, Variable ] )

] ):-

	  Full_Exp =.. [ f, Expression ]
	, Read_Variable =.. [ Variable, Full_Exp ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_rule( parse_text_rule( [ [ V_H | V_T ], [ E_H | E_T ] ] ), [
%=======================================================================

	  q0n(anything)

	, Read_Variable

	, trace( [ String, V_H ] )

	, parse_text_rule( [ V_T, E_T ] )

] ):-

	  Full_Exp =.. [ f, E_H ]
	, Read_Variable =.. [ V_H, Full_Exp ]
	, sys_string_atom( String, V_H )
.

%=======================================================================
i_rule( parse_text_rule( [ [ ], [ ] ] ), [ ] ).
%=======================================================================

%=======================================================================
i_rule( gen1_parse_text_rule( [ Left, Right, End_Line, Search_List, Variable_List, Expression_List ] ), [
%=======================================================================

	  peek_ahead( count_lines_for_parse( [ End_Line, Count_less_1 ] ) )

	, check( sys_calculate( Count, Count_less_1 + 1 ) )

	, read_ahead( [

		xor( [ [ check( q_sys_is_list( Variable_List ) ), trace( [ `Multi Read` ] )

				, parse_text_line( Count, Left, Right, [ Search_List, Variable_List, Expression_List ] )

			]

			, [ trace( [ `Single Read` ] )

				, parse_text_line_single( Count, Left, Right, [ Search_List, Variable_List, Expression_List ] )

			]

		] )

	] )

	, capture_parse_line( Count, Left, Right )

] ).

%=======================================================================
i_line_rule( parse_text_line_single( [ Search, Variable, Expression ] ), [ parse_text_rule_single( [ Search, Variable, Expression ] ) ] ).
%=======================================================================
i_line_rule( parse_text_line( [ Search_List, Variable_List, Expression_List ] ), [
%=======================================================================

	  parse_text_rule( [ Search_List, Variable_List, Expression_List ] )

] ).

%=======================================================================
i_rule( parse_text_rule_single( [ Search, Variable, Expression ] ), [
%=======================================================================

	  q0n(anything)

	, Search

	, Read_Variable

	, trace( [ String, Variable ] )

] ):-
	( q_sys_is_list( Expression )

		->	  Full_Exp =.. [ f, Expression ]
				, Read_Variable =.. [ Variable, Full_Exp ]

		;	  q_sys_is_atom( Expression )
			, Read_Variable =.. [ Variable, Expression ]

	)
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_rule( parse_text_rule( [ [ S_H | S_T ], [ V_H | V_T ], [ E_H | E_T ] ] ), [
%=======================================================================

	  q0n(anything)

	, S_H

	, Read_Variable

	, trace( [ String, V_H ] )

	, parse_text_rule( [ S_T, V_T, E_T ] )

] ):-
	( q_sys_is_list( E_H )

		->	  Full_Exp =.. [ f, E_H ]
				, Read_Variable =.. [ V_H, Full_Exp ]

		;	  q_sys_is_atom( E_H )
			, Read_Variable =.. [ V_H, E_H ]

	)
	, sys_string_atom( String, V_H )
.

%=======================================================================
i_rule( parse_text_rule( [ [ ], [ ], [ ] ] ), [ ] ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		Generic Invoice Line
%%%
%%%		11/07/2014
%%%		-	Initial Implementation
%%%			To only be used on well spaced things
%%%			-	generic_item_cut used to prevent numbers backtracking into
%%%				decimals to encourage capture of other variables
%%%
%%%		-	Added append function
%%%
%%%		05/02/2014
%%%		-	Tidied logic - made q10 and q01 take more affect
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( gen1_invoice_line( [ List_of_Vars ] ), [
%=======================================================================

	  gen1_invoice_line_rule( [ List_of_Vars ] )

] ).

%=======================================================================
i_rule( gen1_invoice_line_rule( [ [ ] ] ), [ newline, trace( [ `Finished Line` ] ) ] ).
%=======================================================================
i_rule( gen1_invoice_line_rule( [ List_of_Vars ] ), [
%=======================================================================

	  intelligent_line_item_read( [ H ] )

	, gen1_invoice_line_rule( [ T ] )

] ):-

	List_of_Vars = [ H | T ]
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [
%=======================================================================

	  generic_item_cut( [ H, Parameter, q10( tab ) ] )

] ):-

	  q_sys_is_atom( H )
	, sys_string_atom( String, H )

	, check_for_parameter( String, Parameter )

.

check_for_parameter( Variable, Parameter ):-

	  (	q_sys_sub_string( Variable, _, _, `date` )	->	Parameter = date

		;	q_sys_sub_string( Variable, _, _, `uom` )	->	Parameter = s1

		;	q_sys_member( Number, [ `amount`, `total`, `rate`, `vat`, `net`, `line_quantity` ] )
			, q_sys_sub_string( Variable, _, _, Number )
			->	Parameter = d

		;	Parameter = s

	), !
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [ H ] ):- q_sys_is_string( H ).
%=======================================================================

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [
%=======================================================================

	append( Append_Var, ` `, `` ), q10( tab )

	, trace( [ `Appended: `, String ] )

] ):-

	H = ( append, Variable )

	, q_sys_is_atom( Variable )
	, sys_string_atom( String, Variable )

	, check_for_parameter( String, Parameter )
	, Append_Var =.. [ Variable, Parameter ]
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [
%=======================================================================

	Capture

] ):-

	H = ( Q, Variable )
	, q_sys_member( Q, [ q10, q01 ] )

	, q_sys_is_atom( Variable )
	, sys_string_atom( String, Variable )

	, check_for_parameter( String, Parameter )

	, Capture =.. [ Q, generic_item( [ Variable, Parameter, q10( tab ) ] ) ]
.

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [
%=======================================================================

	generic_item_cut( [ Variable, Parameter, q10( tab ) ] )

] ):- H = ( Variable, Parameter ).

%=======================================================================
i_rule( intelligent_line_item_read( [ H ] ), [
%=======================================================================

	Capture

] ):-
	H = ( Q, Variable, Parameter )
	, q_sys_member( Q, [ q10, q01 ] )
	, Capture =.. [ Q, generic_item_cut( [ Variable, Parameter, q10( tab ) ] ) ]
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		Gramatica Month Lookup
%%%
%%%		23-10-2014
%%%		-	Allows control of all the dates and formats
%%%			-	Will look into turning it into a table
%%%			-	Keep track of ALL changes here!
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


i_short_month(1,M) :- ( i_date_language( french ), M = `janv` ; i_date_language( spanish ), M = `ene` ; M = `jan` ).
i_short_month(2,M) :- ( i_date_language( french ), ( M = `févr` ; M = `fév` ; M = `fev` ) ; i_date_language( swedish ), M = `febr` ; M = `feb` ).
i_short_month(3,M) :- ( i_date_language( dutch ), M = `mrt` ; i_date_language( french ), M = `mars` ; i_date_language( german ), ( M = `mär` ; M = `mrz` ; M = `März` ) ; i_date_language( swedish ), M = `mars` ; M = `mar` ).
i_short_month(4,M) :- ( i_date_language( french ), ( M = `avril`; M = `avr` ) ; i_date_language( spanish ), M = `abr` ; M = `apr` ).
i_short_month(5,M) :- ( i_date_language( dutch ), M = `mei` ; i_date_language( french ), M = `mai` ; i_date_language( german ), M = `mai` ; i_date_language( swedish ), M = `maj` ; i_date_language( norwegian ), M = `mai` ; M = `may` ).
i_short_month(6,M) :- ( i_date_language( french ), M = `juin` ; i_date_language( swedish ), M = `juni` ; M = `jun` ).
i_short_month(7,M) :- ( i_date_language( french ), ( M = `juil`; M = `jul` ) ; i_date_language( swedish ), M = `juli` ; M = `jul` ).
i_short_month(8,M) :- ( i_date_language( french ), ( M = `août` ; M = `aoû`; M = `aou` ) ; i_date_language( spanish ), M = `ago` ; M = `aug` ).
i_short_month(9,`sept`).
i_short_month(9,`sep`).
i_short_month(10,M) :- ( i_date_language( dutch ), M = `okt` ; i_date_language( german ), M = `okt` ; i_date_language( swedish ), M = `okt` ; i_date_language( danish ), M = `okt` ; i_date_language( norwegian ), M = `okt` ; M = `oct` ).
i_short_month(11,`nov`).
i_short_month(12,M) :- ( i_date_language( french ), M = `déc` ; i_date_language( spanish ), M = `dic` ; i_date_language( german ), M = `dez` ; i_date_language( norwegian ), M = `des` ; M = `dec` ).

i_long_month(1,M) :- ( i_date_language( dutch ), M = `januari` ; i_date_language( french ), M = `janvier` ; i_date_language( spanish ), M = `enero` ; i_date_language( german ), M = `januar` ; i_date_language( swedish ), M = `januari` ; i_date_language( danish ), M = `januar` ; i_date_language( norwegian ), M = `januar` ; M = `january` ).
i_long_month(2,M) :- ( i_date_language( dutch ), M = `februari` ; i_date_language( french ), ( M = `février`; M = `fevrier` ) ; i_date_language( spanish ), M = `febrero` ; i_date_language( german ), M = `februar` ; i_date_language( swedish ), M = `februari` ; i_date_language( danish ), M = `februar` ; i_date_language( norwegian ), M = `februar` ; M = `february` ).
i_long_month(3,M) :- ( i_date_language( dutch ), ( M = `maart` ) ; i_date_language( french ), M = `mars` ; i_date_language( spanish ), M = `marzo` ; i_date_language( german ), ( M = `märz` ; M = `marz` ) ; i_date_language( swedish ), M = `mars` ; i_date_language( danish ), M = `marts` ; i_date_language( norwegian ), M = `mars` ; M = `march` ).
i_long_month(4,M) :- ( i_date_language( french ), M = `avril` ; i_date_language( spanish ), M = `abril` ; M = `april` ).
i_long_month(5,M) :- ( i_date_language( dutch ), M = `mei` ; i_date_language( french ), M = `mai` ; i_date_language( spanish ), M = `mayo` ; i_date_language( german ), M = `mai` ; i_date_language( swedish ), M = `maj` ; i_date_language( danish ), M = `maj` ; i_date_language( norwegian ), M = `mai` ; M = `may` ).
i_long_month(6,M) :- ( i_date_language( dutch ), M = `juni` ; i_date_language( french ), M = `juin` ; i_date_language( spanish ), M = `junio` ; i_date_language( german ), M = `juni` ; i_date_language( swedish ), M = `juni` ; i_date_language( danish ), M = `juni` ; i_date_language( norwegian ), M = `juni`  ; M = `june` ).
i_long_month(7,M) :- ( i_date_language( dutch ), M = `juli` ; i_date_language( french ), M = `juillet` ; i_date_language( spanish ), M = `julio` ; i_date_language( german ), M = `juli` ; i_date_language( swedish ), M = `juli` ; i_date_language( danish ), M = `juli` ; i_date_language( norwegian ), M = `juli` ; M = `july` ).
i_long_month(8,M) :- ( i_date_language( dutch ), M = `augustus` ; i_date_language( french ), ( M = `août` ; M = `aout` ) ; i_date_language( spanish ), M = `agosto` ; i_date_language( swedish ), M = `augusti` ; M = `august` ).
i_long_month(9,M) :- ( i_date_language( french ), M = `septembre` ; i_date_language( spanish ), M = `septiembre` ; M = `september` ).
i_long_month(10,M) :- ( i_date_language( dutch ), M = `oktober` ; i_date_language( french ), M = `octobre` ; i_date_language( spanish ), M = `octubre` ; i_date_language( german ), M = `oktober` ; i_date_language( swedish ), M = `oktober` ; i_date_language( danish ), M = `oktober` ; i_date_language( norwegian ), M = `oktober` ;  M = `october` ).
i_long_month(11,M) :- ( i_date_language( french ), M = `novembre` ; i_date_language( spanish ), M = `noviembre` ; M = `november` ).
i_long_month(12,M) :- ( i_date_language( french ), ( M = `décembre` ; M = `decembre` ) ; i_date_language( spanish ), M = `diciembre` ; i_date_language( german ), M = `dezember` ;  i_date_language( norwegian ), M = `desember` ; M = `december` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC LINE
%%%
%%%		23-07-2014
%%%		-	Initial Implementation
%%%			-	Simply allows for a line rule to be called within a line
%%%			-	Should not be used to avoid typing out line rules of
%%%				higher complexity
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( generic_line( [ Line ] ), [ Line ] ).
%=======================================================================
i_line_rule_cut( generic_line_cut( [ Line ] ), [ Line ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC DESCR APPEND
%%%
%%%		23-09-2014
%%%		-	Initial Implementation
%%%			-	For appending a sentence to a line description
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( generic_descr_append, [
%=======================================================================

	with(line_descr), generic_append( [ line_descr, s1, newline, ` `, `` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC PROCESS RULE
%%%
%%%		01-09-2014
%%%		-	Initial Implementation
%%%			-	For identifying 'junk', statements and documents that require forwarding.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( generic_process_rule( [ Rule, N, Action ] ), [
%=======================================================================

	check( not( q_sys_var(Action) ) )

	, q(0,N,line), Rule

	, or( [

		[ check( Action = `forward` )

			, set( forward_document ), trace( [ `forward_document` ] )

		]

		, [ check( Action = `junk` )

			, set( chain, `junk` ), trace( [ `junk` ] )

		]

		, [ check( Action = `statement` )

			, set( statement ), set( i_analyse_statement )
			, set( i_analyse_statement_correspondence )
			, document_type( `Statement` )
			, trace( [ `statement` ] )

		]

		, [ check( Action = `correspond` )

			, set( correspond ), set( i_analyse_correspondence )
			, set( i_analyse_statement_correspondence )
			, document_type( `Correspondence` )
			, trace( [ `correspond` ] )

		]

	] )

	, set( do_not_process ), trace( [ `Setting 'do_not_process' flag` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN SUPPLIER
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For setting the supplier details from the i_rule_list
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_supplier( [ Name, Postcode, VAT_Number ] ), [
%=======================================================================

	supplier_party(Name)

	, sender_name(Name)

	, supplier_postcode(Postcode)

	, supplier_vat_number(VAT_Number)

] ).

%=======================================================================
i_rule( gen_supplier( [ Name, Postcode ] ), [
%=======================================================================

	supplier_party(Name)

	, sender_name(Name)

	, supplier_postcode(Postcode)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN CAPTURE
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For capturing a variable from the i_rule_list using generic_horizontal_details
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_capture( [ Number_of_Lines, Search, Length_of_tab, Variable, Type, After ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_horizontal_details( [ Search, Length_of_tab, Variable, Type, After ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture( [ Search, Length_of_tab, Variable, Type, After ] ), [
%=======================================================================

	q0n(line)

	, generic_horizontal_details( [ Search, Length_of_tab, Variable, Type, After ] )

] ):- not( q_sys_is_number( Search ) ).

%=======================================================================
i_rule( gen_capture( [ Number_of_Lines, Search, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_horizontal_details( [ Search, Param_2, Param_3, Param_4 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture( [ Search, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	q0n(line)

	, generic_horizontal_details( [ Search, Param_2, Param_3, Param_4 ] )

] ):- not( q_sys_is_number( Search ) ).

%=======================================================================
i_rule( gen_capture( [ Number_of_Lines, Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_horizontal_details( [ Param_1, Param_2, Param_3 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture( [ Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	q0n(line)

	, generic_horizontal_details( [ Param_1, Param_2, Param_3 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%=======================================================================
i_rule( gen_capture( [ Number_of_Lines, Variable, Type ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_horizontal_details( [ Variable, Type ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture( [ Variable, Type ] ), [
%=======================================================================

	q0n(line)

	, generic_horizontal_details( [ Variable, Type ] )

] ):- not( q_sys_is_number( Variable ) ).

%=======================================================================
i_rule( gen_capture( [ Number_of_Lines, Param_1 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_horizontal_details( [ Param_1 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture( [ Param_1 ] ), [
%=======================================================================

	q0n(line)

	, generic_horizontal_details( [ Param_1 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN CAPTURE UP
%%%
%%%		24-08-2015
%%%		-	Initial Implementation
%%%			-	For capturing a variable from the i_rule_list using generic_horizontal_details
%%%			-	Does UP from the bottom of the page
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_capture_up( [ Number_of_Lines, Search, Length_of_tab, Variable, Type, After ] ), [
%=======================================================================

	last_line, q(0,Number_of_Lines,up)

	, generic_horizontal_details( [ Search, Length_of_tab, Variable, Type, After ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture_up( [ Search, Length_of_tab, Variable, Type, After ] ), [
%=======================================================================

	last_line, q0n(up)

	, generic_horizontal_details( [ Search, Length_of_tab, Variable, Type, After ] )

] ):- not( q_sys_is_number( Search ) ).

%=======================================================================
i_rule( gen_capture_up( [ Number_of_Lines, Search, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	last_line, q(0,Number_of_Lines,up)

	, generic_horizontal_details( [ Search, Param_2, Param_3, Param_4 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture_up( [ Search, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	last_line, q0n(up)

	, generic_horizontal_details( [ Search, Param_2, Param_3, Param_4 ] )

] ):- not( q_sys_is_number( Search ) ).

%=======================================================================
i_rule( gen_capture_up( [ Number_of_Lines, Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	last_line, q(0,Number_of_Lines,up)

	, generic_horizontal_details( [ Param_1, Param_2, Param_3 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture_up( [ Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	last_line, q0n(up)

	, generic_horizontal_details( [ Param_1, Param_2, Param_3 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%=======================================================================
i_rule( gen_capture_up( [ Number_of_Lines, Variable, Type ] ), [
%=======================================================================

	last_line, q(0,Number_of_Lines,up)

	, generic_horizontal_details( [ Variable, Type ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture_up( [ Variable, Type ] ), [
%=======================================================================

	last_line, q0n(up)

	, generic_horizontal_details( [ Variable, Type ] )

] ):- not( q_sys_is_number( Variable ) ).

%=======================================================================
i_rule( gen_capture_up( [ Number_of_Lines, Param_1 ] ), [
%=======================================================================

	last_line, q(0,Number_of_Lines,up)

	, generic_horizontal_details( [ Param_1 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_capture_up( [ Param_1 ] ), [
%=======================================================================

	last_line, q0n(up)

	, generic_horizontal_details( [ Param_1 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN VERT CAPTURE
%%%
%%%		06-11-2014
%%%		-	Initial Implementation
%%%			-	For capturing a variable from the i_rule_list using generic_vertical_details
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_vert_capture( [ Number_of_Lines, Search, Hook, Position, Left, Right, Variable, Type, After ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_vertical_details( [ Search, Hook, Position, Left, Right, Variable, Type, After ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_vert_capture( [ Search, Hook, Position, Left, Right, Variable, Type, After ] ), [
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ Search, Hook, Position, Left, Right, Variable, Type, After ] )

] ):- not( q_sys_is_number( Search ) ).

%=======================================================================
i_rule( gen_vert_capture( [ Number_of_Lines, Param_1, Param_2, Param_3, Param_4, Param_5, Param_6, Param_7 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6, Param_7 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6, Param_7 ] ), [
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6, Param_7 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%=======================================================================
i_rule( gen_vert_capture( [ Number_of_Lines, Param_1, Param_2, Param_3, Param_4, Param_5, Param_6 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6 ] ), [
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5, Param_6 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%=======================================================================
i_rule( gen_vert_capture( [ Number_of_Lines, Param_1, Param_2, Param_3, Param_4, Param_5 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4, Param_5 ] ), [
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4, Param_5 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%=======================================================================
i_rule( gen_vert_capture( [ Number_of_Lines, Param_1, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3, Param_4 ] ), [
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3, Param_4 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%=======================================================================
i_rule( gen_vert_capture( [ Number_of_Lines, Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	q(0,Number_of_Lines,line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3 ] )

] ):- q_sys_is_number( Number_of_Lines ).

%=======================================================================
i_rule( gen_vert_capture( [ Param_1, Param_2, Param_3 ] ), [
%=======================================================================

	q0n(line)

	, generic_vertical_details( [ Param_1, Param_2, Param_3 ] )

] ):- not( q_sys_is_number( Param_1 ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN SECTION
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For defining a generic section from the i_rule_list
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( gen_section( [ Rule_1, Rule_2, Rule_3 ] ), [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ Rule_1, Rule_2, Rule_3, line ] )

	] )

] ).

%=======================================================================
i_section( gen_section( [ Rule_1, Rule_2 ] ), [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ Rule_1, Rule_2, line ] )

	] )

] ).

%=======================================================================
i_section( gen_section( [ Rule_1 ] ), [
%=======================================================================

	line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ Rule_1, line ] )

	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN SECTION 2
%%%
%%%		29-10-2014
%%%		-	Initial Implementation
%%%			-	For defining a second generic section from the i_rule_list
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( gen_section_2( [ Rule_1, Rule_2, Rule_3 ] ), [
%=======================================================================

	line_header_line_2

	, qn0( [ peek_fails(line_end_line_2)

		, or( [ Rule_1, Rule_2, Rule_3, line ] )

	] )

] ).

%=======================================================================
i_section( gen_section_2( [ Rule_1, Rule_2 ] ), [
%=======================================================================

	line_header_line_2

	, qn0( [ peek_fails(line_end_line_2)

		, or( [ Rule_1, Rule_2, line ] )

	] )

] ).

%=======================================================================
i_section( gen_section_2( [ Rule_1 ] ), [
%=======================================================================

	line_header_line_2

	, qn0( [ peek_fails(line_end_line_2)

		, or( [ Rule_1, line ] )

	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN BEOF
%%%
%%%		11-12-2014
%%%		-	or( [ at_start, tab ] )
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_beof, [ or( [ at_start, tab ] ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GENERIC NO
%%%
%%%		05-02-2015
%%%		-	Captures a number into a variable and traces it out
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( generic_no( [ Variable, Param, After ] ), [
%=======================================================================

	Read_Variable, After, trace( [ Variable_Name, Variable ] )

] )
:-
	q_sys_is_atom( Variable ),
	not( q_sys_var( Param ) ),
	q_sys_member( Param, [ d, n, d1 ] ),

	Read_Variable =.. [ Variable, Param ],

	sys_string_atom( Variable_Name, Variable ),

	!
.

%=======================================================================
i_rule( generic_no( [ Variable, Param ] ), [
%=======================================================================

	Read_Variable, trace( [ Variable_Name, Variable ] )

] )
:-
	q_sys_is_atom( Variable ),
	not( q_sys_var( Param ) ),
	q_sys_member( Param, [ d, n ] ),

	Read_Variable =.. [ Variable, Param ],

	sys_string_atom( Variable_Name, Variable ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		CHECK FOR REVERSE PUNCTUATION
%%%
%%%		06-03-2015
%%%		-	For capturing numbers that may or may not reverse punctuation
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_reverse_punctuation( [ Variable, Param, After ] ), [
%=======================================================================

		q10( [ read_ahead( [ 
			or( [ 
				generic_item_currency( [ Currency ] )
				, [
					check( q_sys_member( Param, [ c ] ) )
					, dummy_currency(f( [ begin, q(other("-"),0,1), q( [ alpha, other ],1,1 ), end ] ))
				]
			] )
			, numeric(f([ begin, q(other("-"),0,1), q([dec,other(".")],0,10), q(other(","),1,1), q(dec,1,2), q(other("-"),0,1), end ]))
			] )

			, set( reverse_punctuation_in_numbers )

			, trace( [ `Reversed punctuation` ] )

		] )

		, check( not( q_sys_var( Param ) ) )
		, check( q_sys_member( Param, [ d, n, d1, c ] ) )

		, generic_item( [ Variable, Param, After ] )

		, clear( reverse_punctuation_in_numbers )

] ).

%=======================================================================
i_rule( check_for_reverse_punctuation( [ Variable, Param ] ), [
%=======================================================================

		q10( [ read_ahead( [ 
			or( [ 
				generic_item_currency( [ Currency ] )
				, [
					check( q_sys_member( Param, [ c ] ) )
					, dummy_currency(f( [ begin, q(other("-"),0,1), q( [ alpha, other ],1,1 ), end ] ))
				]
			] )
			, numeric(f([ begin, q(other("-"),0,1), q([dec,other(".")],0,10), q(other(","),1,1), q(dec,1,2), q(other("-"),0,1), end ])) 
			] )

			, set( reverse_punctuation_in_numbers )

			, trace( [ `Reversed punctuation` ] )

		] )

		, check( not( q_sys_var( Param ) ) )
		, check( q_sys_member( Param, [ d, n, d1, c ] ) )

		, generic_item( [ Variable, Param ] )

		, clear( reverse_punctuation_in_numbers )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		CHECK FOR REVERSE PUNCTUATION
%%%
%%%		06-03-2015
%%%		-	For capturing numbers that may or may not reverse punctuation
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_reverse_punctuation_with_apostrophe( [ Variable, After ] ), [
%=======================================================================

		q10( [ read_ahead( numeric(f([ begin, q(other("-"),0,1), q([dec,other("'")],0,10), q(other(","),1,1), q(dec,2,2), q(other("-"),0,1), end ])) )

			, set( reverse_punctuation_in_numbers )

			, trace( [ `Reversed punctuation` ] )

		] )



		, generic_item( [ apostrophe_number, s1 ] )

		, check(string_string_replace(apostrophe_number, `'`, `.`, Final ) )

		, generic_item( [ Variable, Final, After ] )

		, clear( reverse_punctuation_in_numbers )

] ).

%=======================================================================
i_rule( check_for_various_reverse_punctuation( [ Variable ] ), [
%=======================================================================

		q10( [ or( [ [ read_ahead( numeric(f([ begin, q(other("-"),0,1), q([dec,other("'")],0,10), q([other(","),other(".") ],1,1), q(dec,2,2), q(other("-"),0,1), end ])) ), set( apostrophe_found ) ]

				,  [ read_ahead( numeric(f([ begin, q(other("-"),0,1), q([dec,other(".")],0,10), q([other(","),other(".") ],1,1), q(dec,2,2), q(other("-"),0,1), end ])) ), set( full_stop_found) ] 

		] )

			, trace( [ `Found reverse punctuation` ] )

		] )

		, generic_item( [ reverse_number, s1 ] )

		, or( [ [ test( apostrophe_found ), check( strip_string2_from_string1( reverse_number, `'`, Final )) ]
			, [ test( full_stop_found ), check( strip_string2_from_string1( reverse_number, `.`, Final ))  ]

		] )
		
		, check( string_string_replace(Final, `,`, `.`, FinalN))

		, generic_item( [ Variable, FinalN ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN CLEAN AND EXTRACT FROM STRING
%%%
%%%		28-09-2015
%%%		-	For extracting values from a captured string (usually the
%%%			purchase order number) before validating them. Will split
%%%			the string up by spaces then by special characters.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
i_user_check( gen_clean_and_extract_from_string, Sentence_in, First_character_to_split_by, Second_characters_to_split_by, Word_out )
%-----------------------------------------------------------------------
:-
	sys_string_split( Sentence_in, First_character_to_split_by, Word_List ),
	q_sys_member( Word, Word_List ),
	q_sys_is_list( Second_characters_to_split_by ),
	sys_stringlist_concat( Second_characters_to_split_by, ``, Characters_string ),
	strip_string2_from_string1( Word, Characters_string, Word_out )

	;

	strip_string2_from_string1( Sentence_in, First_character_to_split_by, Sentence_stripped ),
	turn_specials_to_spaces( Sentence_stripped, Sentence_spaced, Second_characters_to_split_by ),
	sys_string_split( Sentence_spaced, ` `, Word_List ),
	q_sys_member( Word_out, Word_List )
.

%-----------------------------------------------------------------------
i_user_check( gen_clean_and_extract_from_string, Sentence_in, Word_out ):- i_user_check( gen_clean_and_extract_from_string, Sentence_in, ` `, [ `-`, `.`, `,`, `;`, `:`, `_`, `/`, `\\`, `*`, `(`, `)`, `[`, `]`, `{`, `}`, `#`, `~`, `@`, `'`, `?`, `>`, `<`, `&`, `^`, `%`, `$`, `€`, `£`, `"`, `!`, `¬`, `|`, `+`, `=` ], Word_out ).
%-----------------------------------------------------------------------

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
turn_specials_to_spaces( String_in, String_out, [ H | T ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	string_string_replace( String_in, H, ` `, String_replaced ),
	(
		T = [ ] -> !, String_replaced = String_out
		;
		turn_specials_to_spaces( String_replaced, String_out, T )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN CLEAN AND EXTRACT ALL FROM STRING
%%%
%%%		25-01-2019
%%%		-	For extracting all values in a particular format from a 
%%%			captured string (usually the purchase order number). Will
%%%			split the string up by spaces then by special characters.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
i_user_check( gen_clean_and_extract_all_from_string, Sentence_In, RegExp, List_Out ):- i_user_check( gen_clean_and_extract_all_from_string, Sentence_In, [ `-`, `.`, `,`, `;`, `:`, `_`, `/`, `\\`, `*`, `(`, `)`, `[`, `]`, `{`, `}`, `#`, `~`, `@`, `'`, `?`, `>`, `<`, `&`, `^`, `%`, `$`, `€`, `£`, `"`, `!`, `¬`, `|`, `+`, `=` ], RegExp, List_Out ).
%-----------------------------------------------------------------------
i_user_check( gen_clean_and_extract_all_from_string, Sentence_In, Characters_to_Clean, RegExp, List_Out )
%-----------------------------------------------------------------------
:-
	sys_string_split( Sentence_In, ` `, Word_List ),

	clean_up_word_list( Characters_to_Clean, RegExp, Word_List, [ ], List_Out )

	;

	strip_string2_from_string1( Sentence_In, ` `, Sentence_In_Stripped ),

	turn_specials_to_spaces( Sentence_In_Stripped, Sentence_In_Spaced, Characters_to_Clean ),

	sys_string_split( Sentence_In_Spaced, ` `, Word_List ),

	clean_up_word_list( [ ], RegExp, Word_List, [ ], List_Out )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clean_up_word_list( _, _, [ ], List_Out, List_Out ):- !, List_Out \= [ ].
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clean_up_word_list( Characters_to_Clean, RegExp, [ First_Word | Remaining_Words ], Initial_List, List_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	q_sys_is_list( Characters_to_Clean ),

	sys_stringlist_concat( Characters_to_Clean, ``, Characters_String ),

	strip_string2_from_string1( First_Word, Characters_String, First_Word_Stripped ),

	(
		q_regexp_match( RegExp, First_Word_Stripped, _ ),

		sys_append( Initial_List, [ First_Word_Stripped ], Updated_List )

		;

		not( q_regexp_match( RegExp, First_Word_Stripped, _ ) ),

		Initial_List = Updated_List

	),

	clean_up_word_list( Characters_to_Clean, RegExp, Remaining_Words, Updated_List, List_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		SUM STRING LIST
%%%
%%%		28-01-2016
%%%		-	For calculating the sum of a list of string values
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
i_user_check( sum_string_list, List_of_values, Sum ):- sum_values( `0`, List_of_values, Sum ).
%-----------------------------------------------------------------------
sum_values( Initial_value, [ ], Initial_value ).
%-----------------------------------------------------------------------
sum_values( Initial_value, [ H | T ], Sum_of_values )
%-----------------------------------------------------------------------
:-
	(
		not( q_sys_var( H ) ),

		(
			q_sys_is_string( H ),

			(
				sys_string_number( H, _ ),
				sys_calculate_str_add( Initial_value, H, Sum ),

				(
					T = [ ],
					!,
					Sum = Sum_of_values

					;

					!,
					sum_values( Sum, T, Sum_of_values )

				)

				;

				trace( `List contains a value which is not a number!` ),
				!,
				fail

			)

			;

			trace( `List contains a value which is not a string!` ),
			!,
			fail

		)

		;

		trace( `List contains a variable that does not have a value!` ),
		!,
		fail

	),

	!
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN VAT CODE
%%%
%%%		01-03-2017
%%%		-	for adding VAT rates and VAT codes
%%%			written as gen_vat_code( [ [ `A` , `20` , `B` , `0` ] ] ) e.t.c
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_vat_code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_vat_code( [ [ [ ] ] ] ), [ fail ] ).
%=======================================================================
i_rule( gen_vat_code( [ [ _ ] ] ), [ fail ] ).
%=======================================================================
i_rule( gen_vat_code( [ [ ID, Rate | Tail ] ] ), [

	or( [ [ ID, generic_item( [ line_vat_rate, Rate ] ) ]
		, gen_vat_code( [ Tail ] )
	] )

] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN CHARGE LINE
%%%
%%%		07-03-2017
%%%		-	creates an invoice line which can be manually named
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_charge_line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_rule_cut( gen_charge_line( [ INPUT, NUMBER ] ), [ gen_charge_line( [ INPUT, NUMBER, none, `Miscellaneous Charge` ] ) ] ).
%=======================================================================
i_rule_cut( gen_charge_line( [ INPUT, NUMBER, FR_AFTER ] ), [ gen_charge_line( [ INPUT, NUMBER, FR_AFTER, `Miscellaneous Charge` ] ) ] ).
%=======================================================================
%=======================================================================
i_rule_cut( gen_charge_line( [ INPUT , NUMBER , FR_AFTER , DESCRIP ] ), [
%=======================================================================

	generic_horizontal_details( [ [ INPUT ] , NUMBER , line_net_amount , d , FR_AFTER ] )

	, generic_item( [ line_descr , DESCRIP ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN INVOICE NUMBER
%%%
%%%		25/07/2018 11:48:55
%%%		-	shortcut rule for word variations of invoice number.
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_invoice_number, [ or( [ [ test( credit_note ), gen_credit_keywords ], gen_invoice_keywords ] ), or( [ gen_invoice_second_keyword, `note` ] ) ] ).
%=======================================================================
i_rule( gen_invoice_keywords, [ or( [ `invoice`, `inv`, `document`, `doc` ] ) ] ).
%=======================================================================
i_rule( gen_credit_keywords, [ or( [ [ `credit`, `note` ], `credit` ] ) ] ).
%=======================================================================
i_rule( gen_invoice_second_keyword, [
%=======================================================================

    skip_anchor_endings
    , or( [ `number`, `no`, `#`, `num`, `nr`, `ref`, `reference` ] )
    , skip_anchor_endings

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN INVOICE DATE
%%%
%%%		25/07/2018 11:57:06
%%%		-	shortcut rule for word variations of invoice date.
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_invoice_date, [ or( [ [ or( [ gen_invoice_keywords, `tax` ] ), gen_invoice_date_second_keyword ], [ gen_beof, `date` ] ] ) ] ).
%=======================================================================
i_rule( gen_invoice_date_second_keyword, [
%=======================================================================

    skip_anchor_endings
    , or( [ `date`, `point` ] )
    , skip_anchor_endings

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		GEN ORDER NUMBER
%%%
%%%		25/07/2018 11:57:40
%%%		-	shortcut rule for word variations of order number.
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( gen_order_number, [ or( [ [ gen_order_first_keyword, gen_invoice_second_keyword ], [ `purchase`, `order` ] ] ) ] ).
%=======================================================================
i_rule( gen_order_first_keyword, [ or( [ `order`, `po`, `your` ] ) ] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%		REVERSE PUNCTUATION generic_horizontal_details
%%%
%%%		30/7/2020
%%%		-	a new function generic_horizontal_details_rp that checks for reverse punctuation
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Three Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_horizontal_details_rp_cut( [ Variable, Parameter, After ] ), [ generic_horizontal_details_rp( [ Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details_rp( [ Variable, Parameter, After ] ), [ horizontal_details_rp( [ `no_search`, 1, Variable, Parameter, After ] ) ] )
%-----------------------------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%=======================================================================
i_line_rule( generic_horizontal_details_rp( [ Search, Variable, Parameter ] ), [ horizontal_details_rp( [ Search, 100, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-
%=======================================================================
	( q_sys_member( Parameter, [ d, n, s, s1, sf, w, wf, w1, pc, date ] )

		;	Parameter =.. [ H | _ ],
			q_sys_member( H, [ f, fd ] )

		; 	q_sys_is_list( Parameter ),
			q_sys_member( RegExp, Parameter ),
			q_sys_member( RegExp, [ begin, end, q( _ ), p( _ ) ] )
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Four & Five Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( generic_horizontal_details_rp_cut( [ Search, Tab_Length, Variable, Parameter ] ), [ generic_horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:-	q_sys_is_number( Tab_Length ).
%=======================================================================

%=======================================================================
i_line_rule( generic_horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter ] ), [ horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter, none ] ) ] )
%-----------------------------------------------------------------------
:- q_sys_is_number( Tab_Length ).
%=======================================================================

%=======================================================================
i_rule_cut( generic_horizontal_details_rp_cut( [ Search, Variable, Parameter, After ] ), [ generic_horizontal_details_rp( [ Search, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details_rp( [ Search, Variable, Parameter, After ] ), [ horizontal_details_rp( [ Search, 100, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_rule_cut( generic_horizontal_details_rp_cut( [ Search, Tab_Length, Variable, Parameter, After ] ), [ generic_horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================
i_line_rule( generic_horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter, After ] ), [ horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter, After ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( horizontal_details_rp( [ Search, Tab_Length, Variable, Parameter, After ] ), [
%=======================================================================

	or( [ [ check( Skip == `skip` ), q0n(anything) ]
		, [ check( Skip == `noskip` ) ]
	] )

	, xor( [ check( Search_Ind == `none` )
			, [ check( Search_Ind == `normal` ), Search ]
	] )

	, skip_anchor_endings

	, or( [ [
			xor( [ [ check( Tab_Length >	100 ), tab( Tab_Length ) ]
				, [ check( Tab_Length < 101 ), q10( tab( Tab_Length ) ) ]
			] )

			, check_for_reverse_punctuation( [ Variable, Parameter, After ] )
		]
		, [ check( Search_Ind == `normal` )
			, peek_fails( or( [ tab( Tab_Length ), word ] ) )
			, back, gen_hor_end_check(sf1)
			, check( gen_hor_end_check(end) = End )
			, check( sys_calculate( Left, End + 3 ) )
			, check( gen_hor_end_check(y) = BeginY )
			, parent, or( [ [ line,  set( gen_hor_parent_line ) ], [ up, set( gen_hor_parent_up ) ] ] )
			, generic_line( 1, Left, 500, [ [
				read_ahead( gen_hor_begin_check(w) )
				, check( gen_hor_begin_check(start) = Begin )
				, check( sys_calculate( Diff, Begin - End ) )
				, check( Diff > 0 )
				, check( Diff < Tab_Length )
				, check( gen_hor_begin_check(y) = EndY )
				, or( [ [ check( EndY >= BeginY ), check( sys_calculate( YDiff, EndY - BeginY ) ) ]
					, [ check( EndY < BeginY ), check( sys_calculate( YDiff, BeginY - EndY ) ) ]
				] )
				, check( YDiff =< VertTol )
				, check_for_reverse_punctuation( [ Variable, Parameter, After ] )
			] ] )

			, or( [ [ test( gen_hor_parent_up ), clear( gen_hor_parent_up ) ]
				, [ test( gen_hor_parent_line )
					, line
					, clear( gen_hor_parent_line)
				]
			] )
		]
	] )

] )
:-

	get_search_indicator( Search, Search_Ind ),
	get_skip_indicator( Search, Skip ),
	( generic_horizontal_details_vertical_tolerance( VertTol ) -> true ; VertTol = 10 ),
	!
.
