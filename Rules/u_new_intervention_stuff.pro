%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA
% CONFIGURATION FILE - U_NEW_INTERVENTION_STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( u_new_intervention_stuff, `01/04/2019 11:25:29` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET CONNECTION HEADER LEVEL CODES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_initialise_rule( [
%=======================================================================

	trace( [ `Acquiring Connection Header Level Codes` ] )

	, check( i_user_check( get_header_level_values, Rules, Values ) )

	, q10( [ Values ] )

	, set( got_header_level_codes )

] )
:-
	not( grammar_set( got_header_level_codes ) ),
	
	(
		get_rules_file_name( RulesRaw ),

		string_to_lower( RulesRaw, RulesL ),

		string_string_replace( RulesL, `.pro`, ``, Rules )
		
		;
		
		chained_to( Rules )
		
	)
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
i_user_check( get_header_level_values, Rules, Values )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	connection_lookup_table( List_of_Rules, List_of_Values ),
	
	sys_string_split( List_of_Rules, `,`, Rules_List ),
	
	q_sys_member( Rules, Rules_List ),
	
	sys_findall(
		( Variable, Value ),
		(
			q_sys_member( ( Variable, Value ), List_of_Values ),
			not( sub_atom( Variable, 1, _, line_ ) ),
			Value \= ``
		),
		List_of_Header_Values_Raw
	),
	
	i_force_list( List_of_Header_Values_Raw, List_of_Header_Values ),
	
	List_of_Header_Values \= [ ],
	
	get_values( List_of_Header_Values, Values ),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_values( [ ], Values ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_values( [ ( Variable, Value ) | Remaining_Values ], [ Read, Trace | Remaining_Reads ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	Read =..[ Variable, Value ],
	
	sys_string_atom( Var_String, Variable ),
	
	Trace =.. [ trace, [ Var_String, Value ] ]

	-> get_values( Remaining_Values, Remaining_Reads )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GET CONNECTION LINE LEVEL CODES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_line_fields_first( LID ):- i_analyse_connection_line_values( LID ).
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_connection_line_values( LID )
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	(
		get_rules_file_name( RulesRaw ),
		
		string_to_lower( RulesRaw, RulesL ),
		
		string_string_replace( RulesL, `.pro`, ``, Rules )
		
		;
		
		chained_to( Rules )

		;

		i_user_data( rules_file_name( Rules ) )
		
	),

	connection_lookup_table( Rules, List_of_Values ),
	
	!,
	
	sys_findall(
		( Variable, Value ),
		(
			q_sys_member( ( Variable, Value ), List_of_Values ),
			sub_atom( Variable, 1, _, line_ ),
			Value \= ``
		),
		List_of_Line_Values_Raw
	),
	
	i_force_list( List_of_Line_Values_Raw, List_of_Line_Values ),
	
	populate_connection_line_values( LID, List_of_Line_Values ),
	
	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
populate_connection_line_values( LID, [ ] ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
populate_connection_line_values( LID, [ ( Variable, Value ) | Remaining_Values ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		not( result( _, LID, Variable, _ ) ),
		
		assertz_derived_data( LID, Variable, Value, i_insert_connection_line_value )
		
		;
		
		true
		
	)
	
	-> populate_connection_line_values( LID, Remaining_Values )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CREDIT NOTE DOCUMENT SCENARIO
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_invoice_fields_first:- i_analyse_credit_note_values.
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_credit_note_values
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	document_scenario( `Credit Note`, _, _, Action, _, _, _, _, _, _, _, Dependency ),

	sys_call( Dependency ),

	q_sys_member( Action, [ `Process With Negative Values`, `Process With Positive Values` ] ),

	check_and_invert_values( Action, invoice, [ total_net, total_invoice, total_vat ] ),

	!
.

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_line_fields_first( LID ):- i_analyse_credit_note_line_values( LID ).
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_credit_note_line_values( LID )
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	document_scenario( `Credit Note`, _, _, Action, _, _, _, _, _, _, _, Dependency ),
	
	sys_call( Dependency ),

	not( grammar_set( invert_nothing ) ),
	
	grammar_set( invert_everything ),
	
	(
		Action = `Process With Negative Values`,
	
		check_and_invert_values( Action, LID, [ line_unit_amount, line_net_amount, line_vat_amount, line_total_amount ] )
		
		;
		
		Action = `Process With Positive Values`,
		
		(
			result( _, LID, line_unit_amount, Unit ),
			
			(
				q_sys_comp_str_ge( Unit, `0` ),
			
				check_and_invert_values( Action, LID, [ line_quantity, line_net_amount, line_vat_amount, line_total_amount ] )
				
				;
				
				q_sys_comp_str_lt( Unit, `0` ),
				
				check_and_invert_values( Action, LID, [ line_unit_amount, line_net_amount, line_vat_amount, line_total_amount ] )
				
			)
			
			;
			
			result( _, LID, line_quantity, Quantity ),
			
			(
				q_sys_comp_str_ge( Quantity, `0` ),
			
				check_and_invert_values( Action, LID, [ line_unit_amount, line_net_amount, line_vat_amount, line_total_amount ] )
				
				;
				
				q_sys_comp_str_lt( Quantity, `0` ),
				
				check_and_invert_values( Action, LID, [ line_quantity, line_net_amount, line_vat_amount, line_total_amount ] )
				
			)
			
			;
			
			check_and_invert_values( Action, LID, [ line_net_amount, line_vat_amount, line_total_amount ] )
			
		)
		
	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
check_and_invert_values( Action, Type, [ ] ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
check_and_invert_values( Action, Type, [ H | T ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	not( grammar_set( invert_nothing ) ),
	
	(
		not( result( _, Type, H, _ ) ) -> true

		;

		result( _, Type, H, Value ),

		(
			grammar_set( invert_everything )

			;

			(
				Action = `Process With Negative Values`,
				
				q_sys_comp_str_gt( Value, `0` )
				
				;
				
				Action = `Process With Positive Values`,
				
				q_sys_comp_str_gt( `0`, Value )
				
			),

			sys_assertz( grammar_set( invert_everything ) )

			;

			sys_assertz( grammar_set( invert_nothing ) )

		),

		not( grammar_set( invert_nothing ) ),

		sys_calculate_str_multiply( Value, `-1`, InvertedValue ),

		sys_retractall( result( _, Type, H, Value ) ),

		assertz_derived_data( Type, H, InvertedValue, variable_inverted )

	),

	check_and_invert_values( Action, Type, T )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ACTION REJECTIONS, FORWARDS & DELETIONS BEFORE SENDING TO INTERVENTION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_enquire_first:- i_analyse_document_errors___.
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_document_errors___
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	not( grammar_set( ignore_enquire ) ),
	
	not( result( _, _, force_result, `success` ) ),
	
	trace( `CHECKING FOR AUTO FAILURES` ),

	get_header_level_data_item_failures( List_of_Header_Level_Data_Item_Failures ),

	get_line_level_data_item_failures( List_of_Line_Level_Data_Item_Failures ),

	get_document_scenario_failures( List_Of_Document_Scenario_Failures ),

	sys_append( List_of_Header_Level_Data_Item_Failures, List_of_Line_Level_Data_Item_Failures, List_of_Data_Item_Failures ),

	sys_append( List_of_Data_Item_Failures, List_Of_Document_Scenario_Failures, List_of_Failures ),

	List_of_Failures \= [ ],

	!,
	
	beginning_text( Beginning_Text ),

	sys_findall(
		Error_Text,
		(
			q_sys_member( ( _, _, _, _, _, Error_Description_Text ), List_of_Failures ),
			strcat_list( [ Error_Description_Text, `<br><br>` ], Error_Text )
		),
		List_of_Error_Texts
	),
	
	sys_stringlist_concat( List_of_Error_Texts, ``, Document_Error_Text_No_Breaks ),
	
	string_string_replace( Document_Error_Text_No_Breaks, `
`, `<br>`, Document_Error_Text ),

	q_sys_member( ( Action, Email_Address, Result, Sub_Result, Error_Header_Text, _ ), List_of_Failures ),
	
	strcat_list( [ `Document Not Processed - `, Error_Header_Text ], Subject ),

	(
		Action = `Reject to Supplier`,
		trace( `***Result: Failed - Reject to Supplier***` ),

		sys_assertz( grammar_set( i_analyse_return_to_sender ) ),
		
		remaining_rejection_text( Remaining_Rejection_Text ),
		
		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Rejection_Text ], Return_Email_Body ),
		
		assertz_derived_data( invoice, return_email_body, Return_Email_Body, i_insert_return_email_body ),
		
		assertz_derived_data( invoice, return_email_subject, Subject, i_insert_return_email_subject )

		;

		Action = `Forward to Email Address`,
		trace( `***Result: Failed - Forward to Email Address***` ),

		sys_assertz( grammar_set( i_analyse_forward_to_address ) ),
		
		remaining_forward_text( Remaining_Forward_Text ),
		
		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Forward_Text ], Forward_Email_Body ),
		
		assertz_derived_data( invoice, forward_email_body, Forward_Email_Body, i_insert_forward_email_body ),

		assertz_derived_data( invoice, forward_email, Email_Address, i_insert_forward_email ),
		
		assertz_derived_data( invoice, forward_email_subject, Subject, i_insert_forward_email_subject )

		;

		Action = `Delete`,
		trace( `***Result: Failed - Delete Document***` ),

		sys_assertz( grammar_set( i_analyse_junk_flag ) )

	),

	assertz_derived_data( invoice, force_result, Result, i_force_result ),

	assertz_derived_data( invoice, force_sub_result, Sub_Result, i_force_sub_result ),

	sys_assertz( grammar_set( ignore_enquire ) ),
	
	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_header_level_data_item_failures( List_of_Header_Level_Data_Item_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		( Action, Email_Address, `failed`, Sub_Result, Error_Header_Text, Error_Description_Text ),
		(
			required_data_item( Data_Item_Name, _, _, _, Rules_Intervention, Action, Email_Address, Error_Description_Text, _, Variable, Dependency ),
			(
				Rules_Intervention \= `Yes`
				;
				Rules_Intervention = `Yes`,
				(
					not( qq_op_param( rules_intervention_role, _ ) )
					;
					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
				),
				i_test_indicator
			),
			sys_call( Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			not( result( _, invoice, Var, _ ) ),
			q_sys_member( Action, [ `Reject to Supplier`, `Forward to Email Address`, `Delete` ] ),
			strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),
			strcat_list( [ `Missing `, Data_Item_Name ], Error_Header_Text ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		List_of_Data_Item_Failures_Raw
	),
	
	i_force_list( List_of_Data_Item_Failures_Raw, List_of_Header_Level_Data_Item_Failures ),
	
	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_failures( List_of_Line_Level_Data_Item_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		( Action, Email_Address, `failed`, Sub_Result, Error_Header_Text, Error_Description_Text ),
		(
			required_data_item( Data_Item_Name, _, _, _, Rules_Intervention, Action, Email_Address, Error_Description_Text, _, Variable, Dependency ),
			q_sys_member( Action, [ `Reject to Supplier`, `Forward to Email Address`, `Delete` ] ),
			(
				Rules_Intervention \= `Yes`
				;
				Rules_Intervention = `Yes`,
				(
					not( qq_op_param( rules_intervention_role, _ ) )
					;
					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
				),
				i_test_indicator
			),
			sys_call( Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			sys_findall(
				LID_String,
				(
					result( _, LID, _, _ ),
					sys_string_number( LID_String, LID ),
					not( result( _, LID, line_type, _ ) ),
					not( result( _, LID, Var, _ ) ),
					not( grammar_set( `auto fail`, Variable, LID_String ) ),
					sys_assertz( grammar_set( `auto fail`, Variable, LID_String ) )
				),
				List_of_Line_Numbers_Raw
			),
			i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
			List_of_Line_Numbers \= [ ],
			sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
			strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),
			strcat_list( [ `Missing `, Data_Item_Name, ` at lines `, Missing_At_Lines ], Error_Header_Text ),
			not( grammar_set( `auto fail`, Variable ) ),
			sys_assertz( grammar_set( `auto fail`, Variable ) ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		List_of_Data_Item_Failures_Raw
	),
	
	i_force_list( List_of_Data_Item_Failures_Raw, List_of_Line_Level_Data_Item_Failures ),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_failures( List_Of_Document_Scenario_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		( Action_Final, Email_Address, Result, Sub_Result, Scenario, Error_Description_Text ),
		(
			document_scenario( Scenario, _, Rules_Intervention, Action, Email_Address, _, Error_Description_Text, _, _, _, _, Dependency ),
			(
				Rules_Intervention \= `Yes`
				;
				Rules_Intervention = `Yes`,
				(
					not( qq_op_param( rules_intervention_role, _ ) )
					;
					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
				),
				i_test_indicator
			),
			sys_call( Dependency ),
			(
				q_sys_member( Action, [ `Reject to Supplier`, `Forward to Email Address`, `Delete` ] ),
				Action_Final = Action
				;
				Action = `N/A`,
				Action_Final = `Reject to Supplier`
			),
			document_reason_lookup( Scenario, Result, Sub_Result, _, _ ),
			not( grammar_set( `auto fail`, Scenario ) ),
			sys_assertz( grammar_set( `auto fail`, Scenario ) ),
			trace( [ Scenario ] )
		),
		List_Of_Document_Scenario_Failures_Raw
	),
	
	i_force_list( List_Of_Document_Scenario_Failures_Raw, List_Of_Document_Scenario_Failures ),
	
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ACTION FLAG AS FAIL AND POSTS BEFORE SENDING TO INTERVENTION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_enquire_first:- i_analyse_flag_as_fail_and_posts___.
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_flag_as_fail_and_posts___
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	not( grammar_set( ignore_enquire ) ),
	
	not( result( _, _, force_result, `success` ) ),

	trace( `CHECKING FOR FLAG AS FAIL AND POSTS` ),

	get_header_level_data_item_flag_as_fail_and_posts( Header_Level_Data_Item_List ),

	get_line_level_data_item_flag_as_fail_and_posts( Line_Level_Data_Item_List ),

	get_document_scenario_flag_as_fail_and_posts( Document_Scenario_List ),

	(
		(
			q_sys_member( Sub_Result, Header_Level_Data_Item_List )

			;

			q_sys_member( Sub_Result, Line_Level_Data_Item_List )

			;

			q_sys_member( Sub_Result, Document_Scenario_List )

		),

		assertz_derived_data( invoice, force_result, `failed`, i_force_failed ),

		assertz_derived_data( invoice, force_sub_result, Sub_Result, i_force_sub_result ),

		sys_assertz( grammar_set( i_analyse_flag_as_fail_and_post ) ),

		trace( `***Result: Flag As Fail and Post***` )

		;

		Header_Level_Data_Item_List = [ ],
		
		Line_Level_Data_Item_List = [ ],

		Document_Scenario_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_header_level_data_item_flag_as_fail_and_posts( Header_Level_Data_Item_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		Sub_Result,
		(
			required_data_item( _, _, _, _, Rules_Intervention, `Flag As Fail and Post`, _, _, _, Variable, Dependency ),
			(
				Rules_Intervention \= `Yes`
				;
				Rules_Intervention = `Yes`,
				(
					not( qq_op_param( rules_intervention_role, _ ) )
					;
					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
				),
				i_test_indicator
			),
			sys_call( Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			not( result( _, invoice, Var, _ ) ),
			strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		Header_Level_Data_Item_List_Raw
	),
	
	i_force_list( Header_Level_Data_Item_List_Raw, Header_Level_Data_Item_List ),
	
	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_flag_as_fail_and_posts( Line_Level_Data_Item_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		Sub_Result,
		(
			required_data_item( _, _, _, _, Rules_Intervention, `Flag As Fail and Post`, _, _, _, Variable, Dependency ),
			(
				Rules_Intervention \= `Yes`
				;
				Rules_Intervention = `Yes`,
				(
					not( qq_op_param( rules_intervention_role, _ ) )
					;
					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
				),
				i_test_indicator
			),
			sys_call( Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			sys_findall(
				LID_String,
				(
					result( _, LID, _, _ ),
					sys_string_number( LID_String, LID ),
					not( result( _, LID, line_type, _ ) ),
					not( result( _, LID, Var, _ ) ),
					not( grammar_set( `auto fail`, Variable, LID_String ) ),
					sys_assertz( grammar_set( `auto fail`, Variable, LID_String ) )
				),
				List_of_Line_Numbers_Raw
			),
			i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
			List_of_Line_Numbers \= [ ],
			strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),
			not( grammar_set( `auto fail`, Variable ) ),
			sys_assertz( grammar_set( `auto fail`, Variable ) ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		Line_Level_Data_Item_List_Raw
	),
	
	i_force_list( Line_Level_Data_Item_List_Raw, Line_Level_Data_Item_List ),
	
	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_flag_as_fail_and_posts( Document_Scenario_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		Sub_Result,
		(
			document_scenario( Scenario, _, Rules_Intervention, `Flag As Fail and Post`, _, _, _, _, _, _, _, Dependency ),
			(
				Rules_Intervention \= `Yes`
				;
				Rules_Intervention = `Yes`,
				(
					not( qq_op_param( rules_intervention_role, _ ) )
					;
					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
				),
				i_test_indicator
			),
			sys_call( Dependency ),
			document_reason_lookup( Scenario, _, Sub_Result, _, _ ),
			not( grammar_set( `auto fail`, Scenario ) ),
			sys_assertz( grammar_set( `auto fail`, Scenario ) ),
			trace( [ Scenario ] )
		),
		Document_Scenario_List_Raw
	),
	
	i_force_list( Document_Scenario_List_Raw, Document_Scenario_List ),
	
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MISSED DATA ITEMS CONDITION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
missed_data_items_condition
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	not( i_error_empty ),
	not( i_error_pdf_error ),
	not( i_error_unsupported_file_type ),
	not( i_error_too_big ),
	not( grammar_set( i_analyse_statement_correspondence ) ),

	sys_findall(
		( Variable, Method ),
		(
			required_data_item( _, _, _, _, _, _, _, _, Method, Variable, _ ),
			q_sys_member( Method, [ `Rules (Mapped)`, `Both Rules & p_` ] ),
			Variable \= `sender_name`
		),
		List_of_Variables
	),
	
	check_all_data_items_are_missing( List_of_Variables ),
	
	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
check_all_data_items_are_missing( [ ] ):- fail.
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
check_all_data_items_are_missing( [ ( Variable, Method ) | Remaining_Items ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_atom( Variable, Var ),

	(
		Method == `Rules (Mapped)`,
		i_error_missing_data_item( Var )
		;
		Method == `Both Rules & p_`,
		(
			i_error_missing_data_item( Var )
			;
			not( i_error_missing_data_item( Var ) ),
			not( grammar_set( `mapped in rules`, Variable ) )
		)
	),

	!,
	
	(
		Remaining_Items = [ ],
		!
		
		;
		
		!,
		check_all_data_items_are_missing( Remaining_Items )
		
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LOOKUPS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MANDATORY VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
required_data_item( `Sender Name`, `Insert name of the connection to the customer.`, `Never`, ``, `No`, `Process as normal`, `N/A`, ``, `Rules (Hard-Coded)`, `sender_name`, ( true ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOCUMENT RESULT LOOKUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
document_reason_lookup( `Not On Project`, `failed`, `i_analyse_not_on_project`, `Document Not Processed - Supplier/Customer Not On Project`, `not_on_project_text` ).
document_reason_lookup( `PDF Error`, `failed`, `i_analyse_pdf_error`, `Document Not Processed - PDF Error`, `pdf_error_text` ).
document_reason_lookup( `Unsupported File Type`, `failed`, `i_analyse_unsupported_file_type`, `Document Not Processed - Unsupported File Type`, `unsupported_file_type_text` ).
document_reason_lookup( `Image Document`, `failed`, `i_analyse_image_document`, `Document Not Processed - Image Document`, `pdf_error_text` ).
document_reason_lookup( `New Layout`, `failed`, `i_analyse_new_format`, `Document Not Processed - New Layout`, `new_format_text` ).
document_reason_lookup( `Statement/Correspondence`, `failed`, `i_analyse_statement_correspondence`, `Document Not Processed - Non-Invoice Document`, `statement_correspondence_text` ).
document_reason_lookup( `Body of Email`, `failed`, `i_analyse_body`, `Document Not Processed - Email With No Attachments`, `body_text` ).
document_reason_lookup( `Unsupported Format`, `failed`, `i_analyse_unsupported_format`, `Document Not Processed - Unsupported Format`, `unsupported_format` ).

document_reason_lookup( `Unrecognised/Failed to Map Any Data`, `failed`, `i_analyse_unrecognised`, `Document Not Processed - Unrecognised`, `unrecognised_text` ).
document_reason_lookup( `Credit Note`, `failed`, `i_analyse_credit_note`, `Document Not Processed - Credit Note`, `credit_note_text` ).
document_reason_lookup( `Duplicate`, `failed`, `duplicate_invoice`, `Document Not Processed - Duplicate Invoice`, `duplicate_invoice_text` ).
document_reason_lookup( `Date Older Than X Days`, `failed`, `over_x_days_old`, `Document Not Processed - Date Older Than Allowance`, `over_x_days_old_text` ).
document_reason_lookup( `Date More Than X Days in the Future`, `failed`, `future_dated`, `Document Not Processed - Future Dated`, `future_dated_text` ).
document_reason_lookup( `Zero Value Document`, `failed`, `i_analyse_zero_value_invoice`, `Document Not Processed - Zero Value Invoice`, `zero_value_invoice_text` ).
document_reason_lookup( `Zero Value Line`, `failed`, `i_analyse_zero_value_line`, `Document Not Processed - Zero Value Line`, `zero_value_line_text` ).
document_reason_lookup( `Positive & Negative Lines`, `failed`, `i_analyse_positive_and_negative_lines`, `Document Not Processed - Positive & Negative Lines`, `positive_and_negative_lines_text` ).
document_reason_lookup( `No Lines`, `failed`, `i_analyse_no_line_items`, `Document Not Processed - No Line Items`, `no_lines_text` ).
document_reason_lookup( `Quantity Times Unit Amount Not Equal to Net Amount`, `failed`, `i_analyse_quantity_unit_and_net_amounts_inconsistent`, `Document Not Processed - Inconsistent Quantity, Unit & Net Amount`, `inconsistent_quantity_unit_and_net_amount_text` ).
document_reason_lookup( `Invoice With Negative Totals`, `failed`, `i_analyse_negative_totals`, `Document Not Processed - Invoice With Negative Totals`, `negative_totals_text` ).
document_reason_lookup( `Sum of Line Net Amounts Not Equal to Total Net Amount`, `failed`, `i_analyse_sum_discrepancy`, `Document Not Processed - Sum of Lines Not Equal To Totals`, `total_discrepancy_text` ).
document_reason_lookup( `Sum of Line Gross Amounts Not Equal to Total Gross Amount`, `failed`, `i_analyse_sum_discrepancy`, `Document Not Processed - Sum of Lines Not Equal To Totals`, `total_discrepancy_text` ).
document_reason_lookup( `Totals Do Not Add Up`, `failed`, `i_analyse_invoice_totals_inconsistent`, `Document Not Processed - Totals Do Not Add Up`, `inconsistent_totals_text` ).

document_reason_lookup( `order_number`, `failed`, `i_analyse_missing_order_number`, `Document Not Processed - Missing/Invalid Purchase Order Number`, `missing_order_number_text` ).
document_reason_lookup( `invoice_number`, `failed`, `i_analyse_missing_invoice_number`, `Document Not Processed - Missing/Invalid Invoice Number`, `missing_invoice_no_text` ).
document_reason_lookup( `invoice_date`, `failed`, `i_analyse_missing_invoice_date`, `Document Not Processed - Missing/Invalid Date`, `missing_date_text` ).
document_reason_lookup( `total_net`, `failed`, `i_analyse_missing_total_net`, `Document Not Processed - Missing/Invalid Totals`, `missing_totals_text` ).
document_reason_lookup( `total_vat`, `failed`, `i_analyse_missing_total_vat`, `Document Not Processed - Missing/Invalid Totals`, `missing_totals_text` ).
document_reason_lookup( `total_invoice`, `failed`, `i_analyse_missing_total_invoice`, `Document Not Processed - Missing/Invalid Totals`, `missing_totals_text` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MONTH LOOKUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
month_lookup( `01`, `January` ).
month_lookup( `02`, `February` ).
month_lookup( `03`, `March` ).
month_lookup( `04`, `April` ).
month_lookup( `05`, `May` ).
month_lookup( `06`, `June` ).
month_lookup( `07`, `July` ).
month_lookup( `08`, `August` ).
month_lookup( `09`, `September` ).
month_lookup( `10`, `October` ).
month_lookup( `11`, `November` ).
month_lookup( `12`, `December` ).
