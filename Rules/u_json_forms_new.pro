%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - U_JSON_FORMS_NEW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( u_json_forms_new, `20/12/2019 15:12:45` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 20/12/2019 15:12:45 - Not in sync with beta. Not in sync with test.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_trace_lists.

i_rules_file( `manual error conditions.pro` ).
i_rules_file( `u_new_intervention_stuff.pro` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% COMPLETION FORM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

completion_form( Form )
:-
	i_initial_completion_form( Initial_Form ),

	json_register( Initial_Form, F0 ),

	sys_findall(
		( Data_Item_Name, Variable, Value_Final ),
		(
			required_data_item( Data_Item_Name, _, _, _, _, _, _, _, _, Variable, _ ),
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			(
				result( _, invoice, Var, Value )
				;
				not( result( _, invoice, Var, _ ) ),
				Value = ``
			),
			strip_string2_from_string1( Value, ````, Value_2 ),
			string_string_replace( Value_2, `\\`, `/`, Value_Final ),
			(
				input_field_is_multiple( Var )
				;
				not( input_field_is_multiple( Var ) ),
				not( grammar_set( `completion`, Variable ) ),
				sys_assertz( grammar_set( `completion`, Variable ) )
			)
		),
		List_of_Header_Data_Items_Raw
	),

	i_force_list( List_of_Header_Data_Items_Raw, List_of_Header_Data_Items ),

	create_header_variable_group_based_on_list( F0, List_of_Header_Data_Items, F1 ),

	!,

	sys_findall(
		( Data_Item_Name, Variable ),
		(
			required_data_item( Data_Item_Name, _, _, _, _, _, _, _, _, Variable, _ ),
			q_sys_sub_string( Variable, 1, _, `line_` )
		),
		List_of_Line_Data_Items_Raw
	),

	i_force_list( List_of_Line_Data_Items_Raw, List_of_Line_Data_Items ),

	create_line_variable_group_based_on_list( F1, List_of_Line_Data_Items, F2 ),

	!,

	sys_findall(
		( LID, Variable, Value_Final ),
		(
			required_data_item( _, _, _, _, _, _, _, _, _, Variable, _ ),
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			result( _, LID, Var, Value ),
			strip_string2_from_string1( Value, ````, Value_2 ),
			string_string_replace( Value_2, `\\`, `/`, Value_Final )
		),
		List_of_Line_Item_Values_Raw
	),

	i_force_list( List_of_Line_Item_Values_Raw, List_of_Line_Item_Values ),

	!,

	fill_in_existing_line_values( F2, List_of_Line_Item_Values, Form ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INTERVENTION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_enquire_first:- i_analyse_intervention_forms___.
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_intervention_forms___
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	(
		i_check_answered_rules_intervention_form,

		i_generate_initial_customer_intervention_form

		;

		i_check_answered_customer_intervention_form,

		i_generate_initial_rules_intervention_form

		;

		i_generate_initial_rules_intervention_form,

		i_generate_initial_customer_intervention_form

	),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ANALYSE ANSWERED FORMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANALYSE ANSWERED RULES INTERVENTION FORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_check_answered_rules_intervention_form
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	q_enquire_form( `rules_intervention_form`, Answered_Form ),
	trace( [ `ANSWERED RULES INTERVENTION FORM` ] ),
	json_trace( Answered_Form ),
	!,

	i_initial_intervention_form( Form ),

	json_register( Form, F0 ),

	json_get_header_values( Answered_Form, Values_List ),

	json_set_header_values( F0, Values_List, F1 ),

	!,

	json_get( Answered_Form, `questions[0].value`, Form_Rules ),

	(
		not( chained_to( Form_Rules ) ),

		Form_Rules = Rules

		;

		get_rules_file_name( Rules_file_name ),

		sys_string_length( Rules_file_name, L ),

		sys_calculate( L4, L - 4 ),

		q_sys_sub_string( Rules_file_name, 1, L4, Current_Rules ),

		Current_Rules = Rules
	
	),

	add_text_question( `Rules:`, Rules, `rules_file_name`, F1, F2 ),

	!,

	sys_findall(
		Scenario_Option,
		(
			document_scenario_dropdown( Scenario, Action, Email_Address, _ ),
			(
				Action = `Reject to Supplier`,
				(
					result( _, invoice, return_email, Email )
					;
					not( result( _, invoice, return_email, _ ) ),
					i_mail( from, Email )
				),
				strcat_list( [ `return to `, Email ], Action_Text )
				;
				Action = `Forward to Email Address`,
				strcat_list( [ `forward to `, Email_Address ], Action_Text )
				;
				Action = `Flag As Fail and Post`,
				Action_Text = `flag as a fail and post`
				;
				Action = `Delete`,
				Action_Text = `delete document`
			),
			strcat_list( [ Scenario, ` (`, Action_Text, `)` ], Scenario_Option ),
			not( grammar_set( `quick action`, `rules`, Scenario ) ),
			sys_assertz( grammar_set( `quick action`, `rules`, Scenario ) )
		),
		Scenario_Option_List_Raw
	),

	i_force_list( Scenario_Option_List_Raw, Scenario_Option_List ),

	(
		Scenario_Option_List = [ ],

		F2 = F3

		;

		Scenario_Option_List \= [ ],

		sys_append( [ `` ], Scenario_Option_List, Scenario_Option_List_Final ),

		add_list_question( `Quick Action:`, ``, `Quick Action`, Scenario_Option_List_Final, F2, F3 )

	),

	!,

	json_get_answered_data_item_questions_that_are_still_required( Answered_Form, Answered_Header_Level_Items_List ),

	create_data_items_questions_based_on_list( F3, Answered_Header_Level_Items_List, F4 ),

	!,

	json_get_answered_line_level_data_item_questions_that_are_still_required( Answered_Form, Answered_Line_Level_Items_List ),

	create_line_level_data_items_questions_based_on_list( F4, Answered_Line_Level_Items_List, F5 ),
	
	!,

	json_get_answered_document_scenario_questions_that_are_still_required( Answered_Form, Answered_Document_Scenarios_List ),

	create_document_scenario_questions_based_on_list( F5, Answered_Document_Scenarios_List, F6 ),

	!,

	json_get_list_values( Answered_Form, `ignored_rules_intervention_questions`, Ignored_Rules_Intervention_Questions_List ),

	get_new_ignored_rules_intervention_questions( Answered_Form, Ignored_Rules_Intervention_Questions_List, Answered_Header_Level_Items_List, Answered_Line_Level_Items_List, Answered_Document_Scenarios_List, New_Ignored_Rules_Intervention_Questions_List ),

	add_list( `ignored_rules_intervention_questions`, New_Ignored_Rules_Intervention_Questions_List, F6, F7 ),

	sys_append( Ignored_Rules_Intervention_Questions_List, New_Ignored_Rules_Intervention_Questions_List, Final_Ignored_Rules_Intervention_Questions_List ),

	sys_retractall( i_user_data( ignored_rules_intervention_questions( _ ) ) ),

	sys_asserta( i_user_data( ignored_rules_intervention_questions( Final_Ignored_Rules_Intervention_Questions_List ) ) ),

	!,

	json_get_list_values( Answered_Form, `ignored_customer_intervention_questions`, Final_Ignored_Customer_Intervention_Questions_List ),

	sys_asserta( i_user_data( ignored_customer_intervention_questions( Final_Ignored_Customer_Intervention_Questions_List ) ) ),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Mandatory_Condition, Action, Email_Address, Variable, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, Email_Address, _, _, Variable, Dependency ),
			sys_call( Dependency ),
			any_lines_present,
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			not( result( _, invoice, Var, _ ) ),
			not( q_sys_member( ( Data_Item_Name, _, _, _, _, Variable, _ ), Answered_Header_Level_Items_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Rules_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Customer_Intervention_Questions_List ) ),
			(
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				Rules_Intervention = `Yes`,
				q_sys_member( Action, [ `Will Never Be Missing`, `Flag As Fail and Post`, `Reject to Supplier`, `Forward to Email Address`, `Send to Customer Intervention` ] ),
				(
					qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),
					not( missed_data_items_condition )
					;
					not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) )
				),
				(
					grammar_set( blank_rules_questions )
					;
					not( grammar_set( blank_rules_questions ) ),
					sys_assertz( grammar_set( blank_rules_questions ) )
				)
				;
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
				not( missed_data_items_condition ),
				Action = `Send to Customer Intervention`
			),
			not( grammar_set( `rules`, Variable ) ),
			sys_assertz( grammar_set( `rules`, Variable ) ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		Header_Level_Items_List_Raw
	),

	i_force_list( Header_Level_Items_List_Raw, Header_Level_Items_List ),

	(
		Header_Level_Items_List = [ ],

		F7 = F8,
		trace( [ `No missing header level data items` ] )

		;

		create_data_items_questions_based_on_list( F7, Header_Level_Items_List, F8 )

	),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, Action, Email_Address, Variable, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, Email_Address, _, _, Variable, Dependency ),
			any_lines_present,
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			sys_findall(
				LID_String,
				(
					result( _, LID, _, _ ),
					sys_string_number( LID_String, LID ),
					not( grammar_set( `tested_line_variable_rules`, Variable, LID ) ),
					sys_assertz( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_call( Dependency ),
					sys_retract( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_assertz( grammar_set( `tested_line_variable_rules`, Variable, LID ) ),
					(
						not( result( _, LID, line_type, _ ) ),
						not( result( _, LID, Var, _ ) ),
						not( grammar_set( `rules`, Variable, LID_String ) ),
						sys_assertz( grammar_set( `rules`, Variable, LID_String ) )
						;
						fail
					)
				),
				List_of_Line_Numbers_Raw
			),
			i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
			List_of_Line_Numbers \= [ ],
			sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
			not( q_sys_member( ( Data_Item_Name, _, _, _, _, _, Variable, _ ), Answered_Line_Level_Items_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Rules_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Customer_Intervention_Questions_List ) ),
			(
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				Rules_Intervention = `Yes`,
				q_sys_member( Action, [ `Will Never Be Missing`, `Flag As Fail and Post`, `Reject to Supplier`, `Forward to Email Address`, `Send to Customer Intervention` ] ),
				(
					qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),
					not( missed_data_items_condition )
					;
					not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) )
				),
				(
					grammar_set( blank_rules_questions )
					;
					not( grammar_set( blank_rules_questions ) ),
					sys_assertz( grammar_set( blank_rules_questions ) )
				)
				;
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
				not( missed_data_items_condition ),
				Action = `Send to Customer Intervention`
			),
			not( grammar_set( `rules`, Variable ) ),
			sys_assertz( grammar_set( `rules`, Variable ) ),
			strcat_list( [ `Missing `, Variable, ` at lines `, Missing_At_Lines ], Trace ),
			trace( [ Trace ] )
		),
		Line_Level_Items_List_Raw
	),

	i_force_list( Line_Level_Items_List_Raw, Line_Level_Items_List ),

	(
		Line_Level_Items_List = [ ],

		F8 = F9,
		trace( [ `No missing line level data items` ] )

		;

		create_line_level_data_items_questions_based_on_list( F8, Line_Level_Items_List, F9 )

	),

	!,

	sys_findall(
		( Scenario, Description, Question_ID, Question_Type, Question_Options, Question_Ignore, `Rules`, `` ),
		(
			document_scenario( Scenario, _, Rules_Intervention, Action, _, _, Description, Question_ID, Question_Type, Question_Options, Question_Ignore, Dependency ),
			sys_call( Dependency ),
			not( q_sys_member( ( Scenario, _, Question_ID, _, _, _, _ ), Answered_Document_Scenarios_List ) ),
			not( q_sys_member( Scenario, Final_Ignored_Rules_Intervention_Questions_List ) ),
			not( q_sys_member( Scenario, Final_Ignored_Customer_Intervention_Questions_List ) ),
			not( grammar_set( `rules`, Scenario ) ),
			(
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				Rules_Intervention = `Yes`,
				(
					grammar_set( blank_rules_questions )
					;
					not( grammar_set( blank_rules_questions ) ),
					sys_assertz( grammar_set( blank_rules_questions ) )
				)
				;
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
				Action = `Send to Customer Intervention`
			),
			sys_assertz( grammar_set( `rules`, Scenario ) ),
			trace( [ Scenario ] )
		),
		Document_Scenarios_List_Raw
	),

	i_force_list( Document_Scenarios_List_Raw, Document_Scenarios_List ),

	(
		Document_Scenarios_List = [ ],

		F9 = F10,
		trace( [ `No document scenarios` ] )

		;

		create_document_scenario_questions_based_on_list( F9, Document_Scenarios_List, F10 )

	),

	!,

	sys_retractall( i_user_data( rules_intervention_form( _ ) ) ),

	!,

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	json_set_cut( F10, `role`, Rules_Intervention_Role, F11 ),

	json_set_cut( Answered_Form, `role`, Rules_Intervention_Role, Answered_Form_Role ),

	!,

	(
		action_pressed_buttons( F11 )

		;

		action_rules_filename_change( F11 ),

		sys_asserta( i_user_data( rules_intervention_form( F11 ) ) )

		;

		action_document_scenario_dropdown( Answered_Form_Role )

		;

		action_failures( Answered_Form_Role )

		;

		action_transfers( Answered_Form_Role, Transferred_Intervention_Questions_List ),

		add_list( `transferred_intervention_questions`, Transferred_Intervention_Questions_List, F11, F12 ),

		json_get_list_values( F12, `transferred_intervention_questions`, Transferred_Intervention_Questions_List_Final ),

		sys_asserta( i_user_data( transferred_intervention_questions( Transferred_Intervention_Questions_List_Final ) ) ),

		sys_asserta( i_user_data( rules_intervention_form( F12 ) ) )

		;

		action_blank_questions( F11 ),

		sys_asserta( i_user_data( rules_intervention_form( F11 ) ) ),

		(
			grammar_set( blank_rules_questions ),

			sys_assertz( grammar_set( force_rules_intervention ) )

			;

			true

		)

		;

		action_flag_as_fail_and_posts( Answered_Form_Role ),

		trace( `RULES INTERVENTION FORM COMPLETE` ),

		sys_asserta( i_user_data( rules_intervention_form( F11 ) ) )

	),

	trace( `FINISHED ANALYSING RULES INTERVENTION FORM` ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANALYSE ANSWERED CUSTOMER INTERVENTION FORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_check_answered_customer_intervention_form
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	(
		q_enquire_form( `customer_intervention_form`, Answered_Form )
		;
		q_enquire_form( Form_Name, Answered_Form ),
		q_sys_sub_string( Form_Name, _, _, `customer_intervention_form` )
	),
	trace( [ `ANSWERED CUSTOMER INTERVENTION FORM` ] ),
	json_trace( Answered_Form ),
	!,

	json_get_header_values( Answered_Form, Values_List ),

	i_initial_intervention_form( Form ),

	json_register( Form, F0 ),

	json_set_header_values( F0, Values_List, F1 ),

	!,

	json_get_answered_data_item_questions_that_are_still_required( Answered_Form, Answered_Header_Level_Items_List ),

	create_customer_data_items_questions_based_on_list( F1, Answered_Header_Level_Items_List, F2 ),

	!,

	json_get_answered_line_level_data_item_questions_that_are_still_required( Answered_Form, Answered_Line_Level_Items_List ),

	create_customer_line_level_data_items_questions_based_on_list( F2, Answered_Line_Level_Items_List, F3 ),

	!,

	json_get_answered_document_scenario_questions_that_are_still_required( Answered_Form, Answered_Document_Scenarios_List ),

	create_document_scenario_questions_based_on_list( F3, Answered_Document_Scenarios_List, F4 ),

	!,

	json_get_list_values( Answered_Form, `ignored_customer_intervention_questions`, Ignored_Customer_Intervention_Questions_List ),

	get_new_ignored_customer_intervention_questions( Answered_Form, Ignored_Customer_Intervention_Questions_List,  Answered_Header_Level_Items_List, Answered_Line_Level_Items_List, Answered_Document_Scenarios_List, New_Ignored_Customer_Intervention_Questions_List ),

	add_list( `ignored_customer_intervention_questions`, New_Ignored_Customer_Intervention_Questions_List, F4, F5 ),

	sys_append( Ignored_Customer_Intervention_Questions_List, New_Ignored_Customer_Intervention_Questions_List, Final_Ignored_Customer_Intervention_Questions_List ),

	sys_retractall( i_user_data( ignored_customer_intervention_questions( _ ) ) ),

	sys_asserta( i_user_data( ignored_customer_intervention_questions( Final_Ignored_Customer_Intervention_Questions_List ) ) ),

	!,

	json_get_list_values( Answered_Form, `ignored_rules_intervention_questions`, Final_Ignored_Rules_Intervention_Questions_List ),

	sys_asserta( i_user_data( ignored_rules_intervention_questions( Final_Ignored_Rules_Intervention_Questions_List ) ) ),

	!,

	json_get_list_values( Answered_Form, `transferred_intervention_questions`, Final_Transferred_Intervention_Questions_List ),

	sys_asserta( i_user_data( transferred_intervention_questions( Final_Transferred_Intervention_Questions_List ) ) ),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Mandatory_Condition, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, _, _, _, Variable, Dependency ),
			sys_call( Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			not( result( _, invoice, Var, _ ) ),
			not( q_sys_member( ( Data_Item_Name, _, _, _ ), Answered_Header_Level_Items_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Rules_Intervention_Questions_List ) ),
			(
				(
					q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List )
					;
					not( q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List ) ),
					Rules_Intervention \= `Yes`
					;
					not( q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List ) ),
					Rules_Intervention = `Yes`,
					(
						not( qq_op_param( rules_intervention_role, _ ) )
						;
						qq_op_param( rules_intervention_role, RI_Role ),
						q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
					),
					i_test_indicator
				),
				Action = `Send to Customer Intervention`,
				(
					grammar_set( blank_customer_questions )
					;
					not( grammar_set( blank_customer_questions ) ),
					sys_assertz( grammar_set( blank_customer_questions ) )
				)
				;
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				not( q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List ) ),
				Rules_Intervention = `Yes`
			),
			not( grammar_set( `customer`, Variable ) ),
			sys_assertz( grammar_set( `customer`, Variable ) ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		Header_Level_Items_List_Raw
	),

	i_force_list( Header_Level_Items_List_Raw, Header_Level_Items_List ),

	(
		Header_Level_Items_List = [ ],

		F5 = F6,
		trace( [ `No missing header level data items` ] )

		;

		create_customer_data_items_questions_based_on_list( F5, Header_Level_Items_List, F6 )

	),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, _, _, _, Variable, Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			sys_findall(
				LID_String,
				(
					result( _, LID, _, _ ),
					sys_string_number( LID_String, LID ),
					not( grammar_set( `tested_line_variable_customer`, Variable, LID ) ),
					sys_assertz( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_call( Dependency ),
					sys_retract( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_assertz( grammar_set( `tested_line_variable_customer`, Variable, LID ) ),
					(
						not( result( _, LID, line_type, _ ) ),
						not( result( _, LID, Var, _ ) ),
						not( grammar_set( `customer`, Variable, LID_String ) ),
						sys_assertz( grammar_set( `customer`, Variable, LID_String ) )
						;
						fail
					)
				),
				List_of_Line_Numbers_Raw
			),
			i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
			List_of_Line_Numbers \= [ ],
			sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
			not( q_sys_member( ( Data_Item_Name, _, _, _, _ ), Answered_Line_Level_Items_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Final_Ignored_Rules_Intervention_Questions_List ) ),
			(
				(
					q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List )
					;
					not( q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List ) ),
					Rules_Intervention \= `Yes`
					;
					not( q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List ) ),
					Rules_Intervention = `Yes`,
					(
						not( qq_op_param( rules_intervention_role, _ ) )
						;
						qq_op_param( rules_intervention_role, RI_Role ),
						q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
					),
					i_test_indicator
				),
				Action = `Send to Customer Intervention`,
				(
					grammar_set( blank_customer_questions )
					;
					not( grammar_set( blank_customer_questions ) ),
					sys_assertz( grammar_set( blank_customer_questions ) )
				)
				;
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				not( q_sys_member( Data_Item_Name, Final_Transferred_Intervention_Questions_List ) ),
				Rules_Intervention = `Yes`
			),
			not( grammar_set( `customer`, Variable ) ),
			sys_assertz( grammar_set( `customer`, Variable ) ),
			strcat_list( [ `Missing `, Variable, ` at lines `, Missing_At_Lines ], Trace ),
			trace( [ Trace ] )
		),
		Line_Level_Items_List_Raw
	),

	i_force_list( Line_Level_Items_List_Raw, Line_Level_Items_List ),

	(
		Line_Level_Items_List = [ ],

		F6 = F7,
		trace( [ `No missing line level data items` ] )

		;

		create_customer_line_level_data_items_questions_based_on_list( F6, Line_Level_Items_List, F7 )

	),

	!,

	sys_findall(
		( Scenario, Description, Question_ID, Question_Type, `Ignore error`, Question_Ignore, `Customer`, `` ),
		(
			document_scenario( Scenario, _, Rules_Intervention, Action, _, _, Description, Question_ID, Question_Type, _, Question_Ignore, Dependency ),
			sys_call( Dependency ),
			not( q_sys_member( ( Scenario, _, Question_ID, _, _, _, _ ), Answered_Document_Scenarios_List ) ),
			not( q_sys_member( Scenario, Final_Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Scenario, Final_Ignored_Rules_Intervention_Questions_List ) ),
			not( grammar_set( `customer`, Scenario ) ),
			(
				(
					q_sys_member( Scenario, Final_Transferred_Intervention_Questions_List )
					;
					not( q_sys_member( Scenario, Final_Transferred_Intervention_Questions_List ) ),
					Rules_Intervention \= `Yes`
					;
					not( q_sys_member( Scenario, Final_Transferred_Intervention_Questions_List ) ),
					Rules_Intervention = `Yes`,
					(
						not( qq_op_param( rules_intervention_role, _ ) )
						;
						qq_op_param( rules_intervention_role, RI_Role ),
						q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
					),
					i_test_indicator
				),
				Action = `Send to Customer Intervention`,
				(
					grammar_set( blank_customer_questions )
					;
					not( grammar_set( blank_customer_questions ) ),
					sys_assertz( grammar_set( blank_customer_questions ) )
				)
				;
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				not( q_sys_member( Scenario, Final_Transferred_Intervention_Questions_List ) ),
				Rules_Intervention = `Yes`
			),
			sys_assertz( grammar_set( `customer`, Scenario ) ),
			trace( [ Scenario ] )
		),
		Document_Scenarios_List_Raw
	),

	i_force_list( Document_Scenarios_List_Raw, Document_Scenarios_List ),

	!,

	(
		Document_Scenarios_List = [ ],

		F7 = F8,
		trace( [ `No document scenarios` ] )

		;

		create_document_scenario_questions_based_on_list( F7, Document_Scenarios_List, F8 )

	),

	!,

	sys_findall(
		Scenario_Option,
		(
			document_scenario_dropdown( Scenario, Action, Email_Address, _ ),
			(
				Action = `Reject to Supplier`,
				(
					result( _, invoice, return_email, Email )
					;
					not( result( _, invoice, return_email, _ ) ),
					i_mail( from, Email )
				),
				strcat_list( [ `return to `, Email ], Action_Text )
				;
				Action = `Forward to Email Address`,
				strcat_list( [ `forward to `, Email_Address ], Action_Text )
				;
				Action = `Flag As Fail and Post`,
				Action_Text = `flag as a fail and post`
				;
				Action = `Delete`,
				Action_Text = `delete document`
			),
			strcat_list( [ Scenario, ` (`, Action_Text, `)` ], Scenario_Option ),
			not( grammar_set( `quick action`, `customer`, Scenario ) ),
			sys_assertz( grammar_set( `quick action`, `customer`, Scenario ) )
		),
		Scenario_Option_List_Raw
	),

	i_force_list( Scenario_Option_List_Raw, Scenario_Option_List ),

	(
		Scenario_Option_List = [ ],

		F8 = F9

		;

		Scenario_Option_List \= [ ],

		sys_append( [ `` ], Scenario_Option_List, Scenario_Option_List_Final ),

		add_list_question( `Quick Action:`, ``, `Quick Action`, Scenario_Option_List_Final, F8, F9 )

	),

	!,

	sys_retractall( i_user_data( customer_intervention_form( _ ) ) ),

	!,

	qq_op_param( customer_name, Customer_Intervention_Role ),

	json_set_cut( F9, `role`, Customer_Intervention_Role, F10 ),

	json_set_cut( F10, `name`, `customer_intervention_form`, F11 ),

	json_set_cut( Answered_Form, `role`, Customer_Intervention_Role, Answered_Form_Role ),

	json_set_cut( Answered_Form_Role, `name`, `customer_intervention_form`, Answered_Form_Name ),

	!,

	(
		action_pressed_buttons( F11 )

		;

		action_document_scenario_dropdown( Answered_Form_Name )

		;

		action_blank_questions( F11 ),

		sys_asserta( i_user_data( customer_intervention_form( F11 ) ) ),

		(
			grammar_set( blank_customer_questions ),

			sys_assertz( grammar_set( force_customer_intervention ) )

			;

			true

		)

		;

		action_flag_as_fail_and_posts( Answered_Form_Name ),

		trace( `CUSTOMER INTERVENTION FORM COMPLETE` ),

		sys_asserta( i_user_data( customer_intervention_form( F11 ) ) )

	),

	trace( `FINISHED ANALYSING CUSTOMER INTERVENTION FORM` ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GENERATE INITIAL INTERVENTION FORMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE INITIAL RULES INTERVENTION FORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_generate_initial_rules_intervention_form
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	(
		result( _, invoice, return_email, From )

		;

		i_mail( from, From )

	),

	i_config_param( smtp_from, Send_From ),

	(
		i_user_data( ignored_rules_intervention_questions( Ignored_Rules_Intervention_Questions_List ) )

		;

		Ignored_Rules_Intervention_Questions_List = [ ]

	),

	!,

	(
		i_user_data( ignored_customer_intervention_questions( Ignored_Customer_Intervention_Questions_List ) )

		;

		Ignored_Customer_Intervention_Questions_List = [ ]

	),

	!,

	(
		i_user_data( transferred_intervention_questions( Transferred_Intervention_Questions_List ) )

		;

		Transferred_Intervention_Questions_List = [ ]

	),

	!,

	(
		qq_op_param( customer_forward_address_list, Forward_Address_List_Raw )

		;

		Forward_Address_List_Raw = [ ]

	),

	!,

	(
		q_sys_is_list( Forward_Address_List_Raw ),
		Forward_Address_List = Forward_Address_List_Raw

		;

		q_sys_is_string( Forward_Address_List_Raw ),

		(
			q_sys_sub_string( Forward_Address_List_Raw, _, _, `,` ),

			sys_string_split( Forward_Address_List_Raw, `,`, Forward_Address_List  )

			;

			Forward_Address_List = [ Forward_Address_List_Raw ]

		)

	),

	!,

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	(
		qq_op_param( default_rts_email_subject, RTS_Email_Subject )

		;

		RTS_Email_Subject = ``

	),

	!,

	(
		qq_op_param( default_forward_email_subject, Forward_Email_Subject )

		;

		Forward_Email_Subject = ``

	),

	!,

	populate_initial_intervention( `rules_intervention_form`, Rules_Intervention_Role, Ignored_Rules_Intervention_Questions_List, Ignored_Customer_Intervention_Questions_List, Transferred_Intervention_Questions_List, `The system has detected the below potential rules-based errors. Please see details on the right for instructions on how to action them.`, `If there are any errors that cannot be fixed by amending the rules, please select the fail option for each one and click the submit button. Otherwise, amend the rules for each error and click the submit button once the rules have been successfully updated. If the rules require changing, please enter the name of the new set of rules in the 'Rules' box and click the submit button.`, RTS_Email_Subject, Forward_Email_Subject, [ From ], Send_From, Forward_Address_List, F0 ),
	trace( `GENERATING INITIAL RULES INTERVENTION FORM` ),

	get_rules_file_name( Rules_file_name ),

	sys_string_length( Rules_file_name, L ),

	sys_calculate( L4, L - 4 ),

	q_sys_sub_string( Rules_file_name, 1, L4, Rules ),

	add_text_question( `Rules:`, Rules, `rules_file_name`, F0, F1 ),

	!,

	sys_findall(
		Scenario_Option,
		(
			document_scenario_dropdown( Scenario, Action, Email_Address, _ ),
			(
				Action = `Reject to Supplier`,
				(
					result( _, invoice, return_email, Email )
					;
					not( result( _, invoice, return_email, _ ) ),
					i_mail( from, Email )
				),
				strcat_list( [ `return to `, Email ], Action_Text )
				;
				Action = `Forward to Email Address`,
				strcat_list( [ `forward to `, Email_Address ], Action_Text )
				;
				Action = `Flag As Fail and Post`,
				Action_Text = `flag as a fail and post`
				;
				Action = `Delete`,
				Action_Text = `delete document`
			),
			strcat_list( [ Scenario, ` (`, Action_Text, `)` ], Scenario_Option ),
			not( grammar_set( `quick action`, `rules`, Scenario ) ),
			sys_assertz( grammar_set( `quick action`, `rules`, Scenario ) )
		),
		Scenario_Option_List_Raw
	),

	i_force_list( Scenario_Option_List_Raw, Scenario_Option_List ),

	(
		Scenario_Option_List = [ ],

		F1 = F2

		;

		Scenario_Option_List \= [ ],

		sys_append( [ `` ], Scenario_Option_List, Scenario_Option_List_Final ),

		add_list_question( `Quick Action:`, ``, `Quick Action`, Scenario_Option_List_Final, F1, F2 )

	),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Mandatory_Condition, Action, Email_Address, Variable, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, Email_Address, _, _, Variable, Dependency ),
			sys_call( Dependency ),
			any_lines_present,
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			not( result( _, invoice, Var, _ ) ),
			not( q_sys_member( Data_Item_Name, Ignored_Rules_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
			(
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				Rules_Intervention = `Yes`,
				q_sys_member( Action, [ `Will Never Be Missing`, `Flag As Fail and Post`, `Reject to Supplier`, `Forward to Email Address`, `Send to Customer Intervention` ] ),
				(
					qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),
					not( missed_data_items_condition )
					;
					not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) )
				),
				(
					grammar_set( force_rules_intervention )
					;
					not( grammar_set( force_rules_intervention ) ),
					sys_assertz( grammar_set( force_rules_intervention ) )
				)
				;
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
				not( missed_data_items_condition ),
				Action = `Send to Customer Intervention`
			),
			not( grammar_set( `rules`, Variable ) ),
			sys_assertz( grammar_set( `rules`, Variable ) ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		Header_Level_Items_List_Raw
	),

	i_force_list( Header_Level_Items_List_Raw, Header_Level_Items_List ),

	!,

	(
		Header_Level_Items_List = [ ],

		F2 = F3,
		trace( [ `No missing header level data items` ] )

		;

		create_data_items_questions_based_on_list( F2, Header_Level_Items_List, F3 )

	),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, Action, Email_Address, Variable, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, Email_Address, _, _, Variable, Dependency ),
			any_lines_present,
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			sys_findall(
				LID_String,
				(
					result( _, LID, _, _ ),
					sys_string_number( LID_String, LID ),
					not( grammar_set( `tested_line_variable_rules`, Variable, LID ) ),
					sys_assertz( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_call( Dependency ),
					sys_retract( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_assertz( grammar_set( `tested_line_variable_rules`, Variable, LID ) ),
					(
						not( result( _, LID, line_type, _ ) ),
						not( result( _, LID, Var, _ ) ),
						not( grammar_set( `rules`, Variable, LID_String ) ),
						sys_assertz( grammar_set( `rules`, Variable, LID_String ) )
						;
						fail
					)
				),
				List_of_Line_Numbers_Raw
			),
			i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
			List_of_Line_Numbers \= [ ],
			sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
			not( q_sys_member( Data_Item_Name, Ignored_Rules_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
			(
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				Rules_Intervention = `Yes`,
				q_sys_member( Action, [ `Will Never Be Missing`, `Flag As Fail and Post`, `Reject to Supplier`, `Forward to Email Address`, `Send to Customer Intervention` ] ),
				(
					qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),
					not( missed_data_items_condition )
					;
					not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) )
				),
				(
					grammar_set( force_rules_intervention )
					;
					not( grammar_set( force_rules_intervention ) ),
					sys_assertz( grammar_set( force_rules_intervention ) )
				)
				;
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
				not( missed_data_items_condition ),
				Action = `Send to Customer Intervention`
			),
			not( grammar_set( `rules`, Variable ) ),
			sys_assertz( grammar_set( `rules`, Variable ) ),
			strcat_list( [ `Missing `, Variable, ` at lines `, Missing_At_Lines ], Trace ),
			trace( [ Trace ] )
		),
		Line_Level_Items_List_Raw
	),

	i_force_list( Line_Level_Items_List_Raw, Line_Level_Items_List ),

	!,

	(
		Line_Level_Items_List = [ ],

		F3 = F4,
		trace( [ `No missing line level data items` ] )

		;

		create_line_level_data_items_questions_based_on_list( F3, Line_Level_Items_List, F4 )

	),

	!,

	sys_findall(
		( Scenario, Description, Question_ID, Question_Type, Question_Options, Question_Ignore, `Rules`, `` ),
		(
			document_scenario( Scenario, _, Rules_Intervention, Action, _, _, Description, Question_ID, Question_Type, Question_Options, Question_Ignore, Dependency ),
			sys_call( Dependency ),
			not( q_sys_member( Scenario, Ignored_Rules_Intervention_Questions_List ) ),
			not( q_sys_member( Scenario, Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Scenario, Transferred_Intervention_Questions_List ) ),
			not( grammar_set( `rules`, Scenario ) ),
			(
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				Rules_Intervention = `Yes`,
				(
					grammar_set( force_rules_intervention )
					;
					not( grammar_set( force_rules_intervention ) ),
					sys_assertz( grammar_set( force_rules_intervention ) )
				)
				;
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
				Action = `Send to Customer Intervention`
			),
			sys_assertz( grammar_set( `rules`, Scenario ) ),
			trace( [ Scenario ] )
		),
		Document_Scenarios_List_Raw
	),

	i_force_list( Document_Scenarios_List_Raw, Document_Scenarios_List ),

	!,

	(
		Document_Scenarios_List = [ ],

		F4 = F5,
		trace( [ `No document scenarios` ] )

		;

		create_document_scenario_questions_based_on_list( F4, Document_Scenarios_List, F5 )

	),

	!,

	sys_findall(
		Error_Text,
		(
			(
				document_scenario( _, _, _, Action, _, _, Error_Description_Text, Question_ID, _, _, _, Dependency ),
				Question_ID \= `Unrecognised`,
				sys_call( Dependency )
				;
				required_data_item( Data_Item_Name, _, Mandatory, _, _, Action, _, Error_Description_Text, _, Variable, Dependency ),
				sys_call( Dependency ),
				any_lines_present,
				(
					qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),
					not( missed_data_items_condition )
					;
					not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) )
				),
				not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
				Mandatory \= `Never`,
				sys_string_atom( Variable, Var ),
				not( result( _, invoice, Var, _ ) )
				;
				required_data_item( Data_Item_Name, _, Mandatory, _, _, Action, _, Error_Description_Text_Beginning, _, Variable, Dependency ),
				sys_call( Dependency ),
				any_lines_present,
				(
					qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),
					not( missed_data_items_condition )
					;
					not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) )
				),
				q_sys_sub_string( Variable, 1, _, `line_` ),
				Mandatory \= `Never`,
				sys_string_atom( Variable, Var ),
				sys_findall(
					LID_String,
					(
						result( _, LID, _, _ ),
						sys_string_number( LID_String, LID ),
						not( result( _, LID, line_type, _ ) ),
						not( result( _, LID, Var, _ ) ),
						not( grammar_set( `rules email`, Variable, LID_String ) ),
						sys_assertz( grammar_set( `rules email`, Variable, LID_String ) )
					),
					List_of_Line_Numbers_Raw
				),
				i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
				List_of_Line_Numbers \= [ ],
				sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
				strcat_list( [ Error_Description_Text_Beginning, ` This is missing for the following lines: `, Missing_At_Lines, `.` ], Error_Description_Text ),
				not( grammar_set( `rules email`, Variable ) ),
				sys_assertz( grammar_set( `rules email`, Variable ) )
			),
			q_sys_member( Action, [ `Reject to Supplier`, `Forward to Email Address`, `Delete`, `Send to Customer Intervention` ] ),
			strcat_list( [ Error_Description_Text, `\n\n` ], Error_Text )
		),
		List_of_Error_Texts_Raw
	),

	i_force_list( List_of_Error_Texts_Raw, List_of_Error_Texts ),

	!,

	(
		List_of_Error_Texts = [ ],

		F5 = F7

		;

		List_of_Error_Texts \= [ ],

		sys_stringlist_concat( List_of_Error_Texts, ``, Document_Error_Text ),

		beginning_text( Beginning_Text_Raw ),
		string_string_replace( Beginning_Text_Raw, `<br>`, `\n`, Beginning_Text ),

		remaining_forward_text( Remaining_Forward_Text_Raw ),
		string_string_replace( Remaining_Forward_Text_Raw, `<br>
`, `<br>`, Remaining_Forward_Text_1 ),
		string_string_replace( Remaining_Forward_Text_1, `<br>`, `\n`, Remaining_Forward_Text ),

		remaining_rejection_text( Remaining_Rejection_Text_Raw ),
		string_string_replace( Remaining_Rejection_Text_Raw, `<br>
`, `<br>`, Remaining_Rejection_Text_1 ),
		string_string_replace( Remaining_Rejection_Text_1, `<br>`, `\n`, Remaining_Rejection_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Forward_Text ], Forward_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Rejection_Text ], Rejection_Text ),

		json_set_cut( F5, `forward_email_body`, Forward_Text, F6 ),

		json_set_cut( F6, `return_to_sender_email_body`, Rejection_Text, F7 )

	),

	!,

	sys_asserta( i_user_data( rules_intervention_form( F7 ) ) ),
	trace( `FINISHED GENERATING INITIAL RULES INTERVENTION FORM` ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE INITIAL CUSTOMER INTERVENTION FORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_generate_initial_customer_intervention_form
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	(
		result( _, invoice, return_email, From )

		;

		i_mail( from, From )

	),

	i_config_param( smtp_from, Send_From ),

	qq_op_param( customer_name, Role ),

	(
		i_user_data( ignored_rules_intervention_questions( Ignored_Rules_Intervention_Questions_List ) )

		;

		Ignored_Rules_Intervention_Questions_List = [ ]

	),

	!,

	(
		i_user_data( ignored_customer_intervention_questions( Ignored_Customer_Intervention_Questions_List ) )

		;

		Ignored_Customer_Intervention_Questions_List = [ ]

	),

	!,

	(
		i_user_data( transferred_intervention_questions( Transferred_Intervention_Questions_List ) )

		;

		Transferred_Intervention_Questions_List = [ ]

	),

	!,

	(
		qq_op_param( customer_forward_address_list, Forward_Address_List_Raw )

		;

		Forward_Address_List_Raw = [ ]

	),

	!,

	(
		q_sys_is_list( Forward_Address_List_Raw ),
		Forward_Address_List = Forward_Address_List_Raw

		;

		q_sys_is_string( Forward_Address_List_Raw ),

		(
			q_sys_sub_string( Forward_Address_List_Raw, _, _, `,` ),

			sys_string_split( Forward_Address_List_Raw, `,`, Forward_Address_List  )

			;

			Forward_Address_List = [ Forward_Address_List_Raw ]

		)

	),

	!,

	(
		qq_op_param( default_rts_email_subject, RTS_Email_Subject )

		;

		RTS_Email_Subject = ``

	),

	!,

	(
		qq_op_param( default_forward_email_subject, Forward_Email_Subject )

		;

		Forward_Email_Subject = ``

	),

	!,

	populate_initial_intervention( `customer_intervention_form`, Role, Ignored_Rules_Intervention_Questions_List, Ignored_Customer_Intervention_Questions_List, Transferred_Intervention_Questions_List, `The system has detected the below potential errors with this document. Please see details on the right for instructions on how to action them.`, `The system has detected some potential errors with this document. Before continuing, please consider whether any of the following document scenarios have occurred: [Supplier/Customer Not On Project] [Document sent in an unsupported format, such as an image PDF] [Document with a different layout to the one currently configured] [Document is a statement or some other correspondence] [Document is the body of an email that was sent with no attachments] If any of these scenarios have occurred, please action accordingly, using the 'Quick Action' dropdown list below. If none of these scenarios have occurred, please consider the below potential errors that the system has detected and action each one accordingly:`, RTS_Email_Subject, Forward_Email_Subject, [ From ], Send_From, Forward_Address_List, F0 ),
	trace( `GENERATING INITIAL CUSTOMER INTERVENTION FORM` ),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Mandatory_Condition, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, _, _, _, Variable, Dependency ),
			sys_call( Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
			sys_string_atom( Variable, Var ),
			not( result( _, invoice, Var, _ ) ),
			not( q_sys_member( Data_Item_Name, Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Ignored_Rules_Intervention_Questions_List ) ),
			(
				(
					q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List )
					;
					not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
					Rules_Intervention \= `Yes`
					;
					not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
					Rules_Intervention = `Yes`,
					(
						not( qq_op_param( rules_intervention_role, _ ) )
						;
						qq_op_param( rules_intervention_role, RI_Role ),
						q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
					),
					i_test_indicator
				),
				Action = `Send to Customer Intervention`,
				(
					grammar_set( force_customer_intervention )
					;
					not( grammar_set( force_customer_intervention ) ),
					sys_assertz( grammar_set( force_customer_intervention ) )
				)
				;
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
				Rules_Intervention = `Yes`
			),
			not( grammar_set( `customer`, Variable ) ),
			sys_assertz( grammar_set( `customer`, Variable ) ),
			strcat_list( [ `Missing `, Variable ], Trace ),
			trace( [ Trace ] )
		),
		Header_Level_Items_List_Raw
	),

	i_force_list( Header_Level_Items_List_Raw, Header_Level_Items_List ),

	!,

	(
		Header_Level_Items_List = [ ],

		F0 = F1,
		trace( [ `No missing header level data items` ] )

		;

		create_customer_data_items_questions_based_on_list( F0, Header_Level_Items_List, F1 )

	),

	!,

	sys_findall(
		( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, `` ),
		(
			required_data_item( Data_Item_Name, Mapping_Logic, Mandatory, Mandatory_Condition, Rules_Intervention, Action, _, _, _, Variable, Dependency ),
			any_lines_present,
			not( missed_data_items_condition ),
			q_sys_sub_string( Variable, 1, _, `line_` ),
			sys_string_atom( Variable, Var ),
			sys_findall(
				LID_String,
				(
					result( _, LID, _, _ ),
					sys_string_number( LID_String, LID ),
					not( grammar_set( `tested_line_variable_customer`, Variable, LID ) ),
					sys_assertz( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_call( Dependency ),
					sys_retract( grammar_set( `testing_line_variable`, Variable, LID ) ),
					sys_assertz( grammar_set( `tested_line_variable_customer`, Variable, LID ) ),
					(
						not( result( _, LID, line_type, _ ) ),
						not( result( _, LID, Var, _ ) ),
						not( grammar_set( `customer`, Variable, LID_String ) ),
						sys_assertz( grammar_set( `customer`, Variable, LID_String ) )
						;
						fail
					)
				),
				List_of_Line_Numbers_Raw
			),
			i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
			List_of_Line_Numbers \= [ ],
			sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
			not( q_sys_member( Data_Item_Name, Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Data_Item_Name, Ignored_Rules_Intervention_Questions_List ) ),
			(
				(
					q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List )
					;
					not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
					Rules_Intervention \= `Yes`
					;
					not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
					Rules_Intervention = `Yes`,
					(
						not( qq_op_param( rules_intervention_role, _ ) )
						;
						qq_op_param( rules_intervention_role, RI_Role ),
						q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
					),
					i_test_indicator
				),
				Action = `Send to Customer Intervention`,
				(
					grammar_set( force_customer_intervention )
					;
					not( grammar_set( force_customer_intervention ) ),
					sys_assertz( grammar_set( force_customer_intervention ) )
				)
				;
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
				Rules_Intervention = `Yes`
			),
			not( grammar_set( `customer`, Variable ) ),
			sys_assertz( grammar_set( `customer`, Variable ) ),
			strcat_list( [ `Missing `, Variable, ` at lines `, Missing_At_Lines ], Trace ),
			trace( [ Trace ] )
		),
		Line_Level_Items_List_Raw
	),

	i_force_list( Line_Level_Items_List_Raw, Line_Level_Items_List ),

	!,

	(
		Line_Level_Items_List = [ ],

		F1 = F2,
		trace( [ `No missing line level data items` ] )

		;

		create_customer_line_level_data_items_questions_based_on_list( F1, Line_Level_Items_List, F2 )

	),

	!,

	sys_findall(
		( Scenario, Description, Question_ID, Question_Type, `Ignore error`, Question_Ignore, `Customer`, `` ),
		(
			document_scenario( Scenario, _, Rules_Intervention, Action, _, _, Description, Question_ID, Question_Type, _, Question_Ignore, Dependency ),
			sys_call( Dependency ),
			not( q_sys_member( Scenario, Ignored_Customer_Intervention_Questions_List ) ),
			not( q_sys_member( Scenario, Ignored_Rules_Intervention_Questions_List ) ),
			not( grammar_set( `customer`, Scenario ) ),
			(
				(
					q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List )
					;
					not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
					Rules_Intervention \= `Yes`
					;
					not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
					Rules_Intervention = `Yes`,
					(
						not( qq_op_param( rules_intervention_role, _ ) )
						;
						qq_op_param( rules_intervention_role, RI_Role ),
						q_sys_sub_string( RI_Role, _, _, `CloudTrade` )
					),
					i_test_indicator
				),
				Action = `Send to Customer Intervention`,
				(
					grammar_set( force_customer_intervention )
					;
					not( grammar_set( force_customer_intervention ) ),
					sys_assertz( grammar_set( force_customer_intervention ) )
				)
				;
				(
					not( i_test_indicator )
					;
					i_test_indicator,
					qq_op_param( rules_intervention_role, RI_Role ),
					not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )
				),
				not( q_sys_member( Data_Item_Name, Transferred_Intervention_Questions_List ) ),
				Rules_Intervention = `Yes`
			),
			sys_assertz( grammar_set( `customer`, Scenario ) ),
			trace( [ Scenario ] )
		),
		Document_Scenarios_List_Raw
	),

	i_force_list( Document_Scenarios_List_Raw, Document_Scenarios_List ),

	!,

	(
		Document_Scenarios_List = [ ],

		F2 = F3,
		trace( [ `No document scenarios` ] )

		;

		create_document_scenario_questions_based_on_list( F2, Document_Scenarios_List, F3 )

	),

	!,

	sys_findall(
		Error_Text,
		(
			(
				document_scenario( _, _, _, Action, _, _, Error_Description_Text, Question_ID, _, _, _, Dependency ),
				Action = `Send to Customer Intervention`,
				sys_call( Dependency )
				;
				required_data_item( Data_Item_Name, _, Mandatory, _, _, Action, _, Error_Description_Text, _, Variable, Dependency ),
				sys_call( Dependency ),
				Action = `Send to Customer Intervention`,
				not( missed_data_items_condition ),
				any_lines_present,
				not( q_sys_sub_string( Variable, 1, _, `line_` ) ),
				Mandatory \= `Never`,
				sys_string_atom( Variable, Var ),
				not( result( _, invoice, Var, _ ) )
				;
				required_data_item( Data_Item_Name, _, Mandatory, _, _, Action, _, Error_Description_Text_Beginning, _, Variable, Dependency ),
				sys_call( Dependency ),
				Action = `Send to Customer Intervention`,
				not( missed_data_items_condition ),
				any_lines_present,
				q_sys_sub_string( Variable, 1, _, `line_` ),
				Mandatory \= `Never`,
				sys_string_atom( Variable, Var ),
				sys_findall(
					LID_String,
					(
						result( _, LID, _, _ ),
						sys_string_number( LID_String, LID ),
						not( result( _, LID, line_type, _ ) ),
						not( result( _, LID, Var, _ ) ),
						not( grammar_set( `customer email`, Variable, LID_String ) ),
						sys_assertz( grammar_set( `customer email`, Variable, LID_String ) )
					),
					List_of_Line_Numbers_Raw
				),
				i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),
				List_of_Line_Numbers \= [ ],
				sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),
				strcat_list( [ Error_Description_Text_Beginning, ` This is missing for the following lines: `, Missing_At_Lines, `.` ], Error_Description_Text ),
				not( grammar_set( `customer email`, Variable ) ),
				sys_assertz( grammar_set( `customer email`, Variable ) )
			),
			strcat_list( [ Error_Description_Text, `\n\n` ], Error_Text )
		),
		List_of_Error_Texts_Raw
	),

	i_force_list( List_of_Error_Texts_Raw, List_of_Error_Texts ),

	!,

	(
		List_of_Error_Texts = [ ],

		F3 = F5

		;

		List_of_Error_Texts \= [ ],

		sys_stringlist_concat( List_of_Error_Texts, ``, Document_Error_Text ),

		beginning_text( Beginning_Text_Raw ),
		string_string_replace( Beginning_Text_Raw, `<br>`, `\n`, Beginning_Text ),

		remaining_forward_text( Remaining_Forward_Text_Raw ),
		string_string_replace( Remaining_Forward_Text_Raw, `<br>
`, `<br>`, Remaining_Forward_Text_1 ),
		string_string_replace( Remaining_Forward_Text_1, `<br>`, `\n`, Remaining_Forward_Text ),

		remaining_rejection_text( Remaining_Rejection_Text_Raw ),
		string_string_replace( Remaining_Rejection_Text_Raw, `<br>
`, `<br>`, Remaining_Rejection_Text_1 ),
		string_string_replace( Remaining_Rejection_Text_1, `<br>`, `\n`, Remaining_Rejection_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Forward_Text ], Forward_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Rejection_Text ], Rejection_Text ),

		json_set_cut( F3, `forward_email_body`, Forward_Text, F4 ),

		json_set_cut( F4, `return_to_sender_email_body`, Rejection_Text, F5 )

	),

	!,

	sys_findall(
		Scenario_Option,
		(
			document_scenario_dropdown( Scenario, Action, Email_Address, _ ),
			(
				Action = `Reject to Supplier`,
				(
					result( _, invoice, return_email, Email )
					;
					not( result( _, invoice, return_email, _ ) ),
					i_mail( from, Email )
				),
				strcat_list( [ `return to `, Email ], Action_Text )
				;
				Action = `Forward to Email Address`,
				strcat_list( [ `forward to `, Email_Address ], Action_Text )
				;
				Action = `Flag As Fail and Post`,
				Action_Text = `flag as a fail and post`
				;
				Action = `Delete`,
				Action_Text = `delete document`
			),
			strcat_list( [ Scenario, ` (`, Action_Text, `)` ], Scenario_Option ),
			not( grammar_set( `quick action`, `customer`, Scenario ) ),
			sys_assertz( grammar_set( `quick action`, `customer`, Scenario ) )
		),
		Scenario_Option_List_Raw
	),

	i_force_list( Scenario_Option_List_Raw, Scenario_Option_List ),

	!,

	(
		Scenario_Option_List = [ ],

		F5 = F6

		;

		Scenario_Option_List \= [ ],

		sys_append( [ `` ], Scenario_Option_List, Scenario_Option_List_Final ),

		add_list_question( `Quick Action:`, ``, `Quick Action`, Scenario_Option_List_Final, F5, F6 )

	),

	!,

	sys_asserta( i_user_data( customer_intervention_form( F6 ) ) ),
	trace( `FINISHED GENERATING CUSTOMER INTERVENTION FORM` ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SET INTERVENTION FORMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_analyse_enquire_last :- i_set_intervention_forms___.
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
i_set_intervention_forms___
%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:-
	not( grammar_set( ignore_enquire ) ),

	not( result( _, _, force_result, `success` ) ),

	instance( Instance ),

	string_to_upper( Instance, Instance_U ),

	not( q_sys_sub_string( Instance_U, _, _, `DBG` ) ),

	(
		grammar_set( force_customer_intervention )

		;

		grammar_set( force_rules_intervention )

	),

	sys_retractall( result( _, invoice, enquiry_role, _ ) ),

	completion_form( Completion_Form ),

	(
		i_user_data( customer_intervention_form( Customer_Form ) ),

		insert_completion_into_intervention( Customer_Form, Customer_Form_Final, Completion_Form ),

		json_get( Customer_Form_Final, `role`, Customer_Role ),

		set_enquire_form( Customer_Form_Final ),
		trace( [ `CUSTOMER INTERVENTION FORM` ] ),
		json_trace( Customer_Form_Final ),

		(
			qq_op_param( customer_intervention_role_list, Roles_List ),

			set_forms_for_additional_roles( Customer_Form_Final, Customer_Role, Roles_List )
			
			;

			true

		)

		;

		true

	),

	!,

	(
		i_user_data( rules_intervention_form( Rules_Form ) ),

		(
			i_mail( subject, `Mitie Submission` ),

			insert_completion_into_intervention( Rules_Form, Rules_Form_Final, Completion_Form )

			;

			Rules_Form_Final = Rules_Form

		),

		json_get( Rules_Form, `role`, Rules_Role ),

		set_enquire_form( Rules_Form_Final ),
		trace( [ `RULES INTERVENTION FORM` ] ),
		json_trace( Rules_Form_Final )

		;

		true

	),

	!,

	(
		qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ),

		(
			grammar_set( force_rules_intervention ),

			(
				not( i_test_indicator )

				;

				i_test_indicator,
				qq_op_param( rules_intervention_role, RI_Role ),
				not( q_sys_sub_string( RI_Role, _, _, `CloudTrade` ) )

			),

			Rules_Role = Role,
			trace( [ `SENDING TO RULES INTERVENTION` ] )

			;

			Customer_Role = Role,
			trace( [ `SENDING TO CUSTOMER INTERVENTION` ] )

		)

		;
		
		not( qq_op_param( prioritise_rules_intervention_over_customer_intervention, true ) ),

		(
			(
				grammar_set( force_customer_intervention )

				;

				(
					not( qq_op_param( rules_intervention_role, _ ) )

					;

					qq_op_param( rules_intervention_role, RI_Role ),
					q_sys_sub_string( RI_Role, _, _, `CloudTrade` )

				),

				i_test_indicator

			),

			Customer_Role = Role,
			trace( [ `SENDING TO CUSTOMER INTERVENTION` ] )

			;

			Rules_Role = Role,
			trace( [ `SENDING TO RULES INTERVENTION` ] )

		)
	
	),

	assertz_derived_data( invoice, enquiry_role, Role, i_analyse_enquiry_role ),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_forms_for_additional_roles( _, _, [ ] ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_forms_for_additional_roles( Form_In, Customer_Role, [ Role | Remaining_Roles ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		Customer_Role \= Role,
		
		json_clone( Form_In, F0 ),

		json_set_cut( F0, `role`, Role, F1 ),

		string_to_lower( Role, Role_1 ),
		strip_string2_from_string1( Role_1, `\\|,<.>/?;:'@#~]}[{=+-)(*&^%$£"!`, Role_2 ),
		string_string_replace( Role_2, ` `, `_`, Role_Edited ),
		strcat_list( [ `zcustomer_intervention_form_`, Role_Edited ], Form_Name ),
		
		json_set_cut( F1, `name`, Form_Name, F2 ),

		set_enquire_form( F2 ),
		trace( [ `SET FORM FOR ROLE:`, Role ] )

		;

		Customer_Role = Role

	),

	set_forms_for_additional_roles( Form_In, Customer_Role, Remaining_Roles )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POPULATE INITIAL INTERVENTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
populate_initial_intervention( Name, Role, Ignored_Rules_Intervention_Questions_List, Ignored_Customer_Intervention_Questions_List, Transferred_Intervention_Questions_List, Reason, Long_Reason, Return_To_Sender_Email_Subject, Forward_Email_Subject, From_Address_List, Send_From, Forward_List, Form )
%-----------------------------------------------------------------------
:-
	i_initial_intervention_form( Initial_Form ),

	json_register( Initial_Form, F0 ),

	json_set_cut( F0, `name`, Name, F1 ),

	json_set_cut( F1, `role`, Role, F2 ),

	add_list( `ignored_rules_intervention_questions`, Ignored_Rules_Intervention_Questions_List, F2, F3 ),

	add_list( `ignored_customer_intervention_questions`, Ignored_Customer_Intervention_Questions_List, F3, F4 ),

	add_list( `transferred_intervention_questions`, Transferred_Intervention_Questions_List, F4, F5 ),

	json_set_cut( F5, `reason`, Reason, F6 ),

	json_set_cut( F6, `long_reason`, Long_Reason, F7 ),

	add_list( `selected_return_to_sender_addresses`, From_Address_List, F7, F8 ),

	add_list( `selected_forward_addresses`, Forward_List, F8, F9 ),

	json_set_cut( F9, `from_address`, Send_From, F10 ),

	json_set_cut( F10, `return_to_sender_email_subject`, Return_To_Sender_Email_Subject, F11 ),

	json_set_cut( F11, `forward_email_subject`, Forward_Email_Subject, F12 ),

	add_list( `return_to_sender_address_options`, From_Address_List, F12, F13 ),

	add_list( `forward_address_options`, Forward_List, F13, Form )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_list( Array_name, [ ], FORM, FORM ).
%-----------------------------------------------------------------------
add_list( Array_name, [ First_entry | Rest_of_list ], Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_add_array_entry( Form_In, Array_name, First_entry, Form_Updated )

	-> add_list( Array_name, Rest_of_list, Form_Updated, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD TEXT QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_text_question( Question_Text_Value, Question_Value_Value, Question_ID_Value, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_add_array_entry_object( Form_In, `questions`, F1 ),

	json_array_count( Form_In, `questions`, Count ),
	sys_string_number( Count_String, Count ),

	strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
	json_set_cut( F1, Question_Type, `text_box`, F2 ),

	strcat_list( [ `questions[`, Count_String, `].text` ], Question_Text_Field ),
	json_set_cut( F2, Question_Text_Field, Question_Text_Value, F3 ),

	strcat_list( [ `questions[`, Count_String, `].value` ], Question_Value_Field ),
	json_set_cut( F3, Question_Value_Field, Question_Value_Value, F4 ),

	strcat_list( [ `questions[`, Count_String, `].id` ], Question_ID_Field ),
	json_set_cut( F4, Question_ID_Field, Question_ID_Value, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD TEXT QUESTION WITH DATE PICKER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_text_question_with_date_picker( Question_Text_Value, Question_Value_Value, Question_ID_Value, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_add_array_entry_object( Form_In, `questions`, F1 ),

	json_array_count( Form_In, `questions`, Count ),
	sys_string_number( Count_String, Count ),

	strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
	json_set_cut( F1, Question_Type, `text_box`, F2 ),

	strcat_list( [ `questions[`, Count_String, `].text` ], Question_Text_Field ),
	json_set_cut( F2, Question_Text_Field, Question_Text_Value, F3 ),

	strcat_list( [ `questions[`, Count_String, `].value` ], Question_Value_Field ),
	json_set_cut( F3, Question_Value_Field, Question_Value_Value, F4 ),

	strcat_list( [ `questions[`, Count_String, `].id` ], Question_ID_Field ),
	json_set_cut( F4, Question_ID_Field, Question_ID_Value, F5 ),

	strcat_list( [ `questions[`, Count_String, `].attributes` ], Question_Attributes_Field ),
	json_set_object( F5, Question_Attributes_Field, F6 ),

	strcat_list( [ `questions[`, Count_String, `].attributes.type` ], Attributes_Type_Field ),
	json_set_cut( F6, Attributes_Type_Field, `date`, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD LIST QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_list_question( Question_Text_Value, Question_Value_Value, Question_ID_Value, Question_Options_List, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_add_array_entry_object( Form_In, `questions`, F1 ),

	json_array_count( Form_In, `questions`, Count ),
	sys_string_number( Count_String, Count ),

	strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
	json_set_cut( F1, Question_Type, `drop_down_list`, F2 ),

	strcat_list( [ `questions[`, Count_String, `].text` ], Question_Text_Field ),
	json_set_cut( F2, Question_Text_Field, Question_Text_Value, F3 ),

	strcat_list( [ `questions[`, Count_String, `].value` ], Question_Value_Field ),
	json_set_cut( F3, Question_Value_Field, Question_Value_Value, F4 ),

	strcat_list( [ `questions[`, Count_String, `].id` ], Question_ID_Field ),
	json_set_cut( F4, Question_ID_Field, Question_ID_Value, F5 ),

	strcat_list( [ `questions[`, Count_String, `].options` ], Question_Options_Field ),
	json_set_array( F5, Question_Options_Field, F6 ),

	add_list( Question_Options_Field, Question_Options_List, F6, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD HEADER LEVEL DATA ITEM TABULAR LIST QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_header_level_data_item_tabular_list_question( Data_Item_Name, Variable, Mapping_Logic, Value, Options, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Question_Questions_Rows ),

		Form_In = F9

		;

		json_add_array_entry_object( Form_In, `questions`, F1 ),

		json_array_count( Form_In, `questions`, Count ),
		sys_string_number( Count_String, Count ),

		strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
		json_set_cut( F1, Question_Type, `section`, F2 ),

		strcat_list( [ `questions[`, Count_String, `].title` ], Question_Title ),
		json_set_cut( F2, Question_Title, `Failed to map the below header level data items:`, F3 ),

		strcat_list( [ `questions[`, Count_String, `].questions` ], Question_Questions ),
		json_set_array( F3, Question_Questions, F4 ),

		json_add_array_entry_object( F4, Question_Questions, F5 ),

		strcat_list( [ Question_Questions, `[0].question_type` ], Question_Questions_Question_Type ),
		json_set_cut( F5, Question_Questions_Question_Type, `table`, F6 ),

		strcat_list( [ Question_Questions, `[0].headings` ], Question_Questions_Headings ),
		json_set_array( F6, Question_Questions_Headings, F7 ),

		add_list( Question_Questions_Headings, [ `Data Item Name`, `Variable`, `Mapping Logic`, `Action` ], F7, F8 ),

		strcat_list( [ Question_Questions, `[0].rows` ], Question_Questions_Rows ),
		json_set_array( F8, Question_Questions_Rows, F9 )

	),

	json_add_array_entry_object( F9, Question_Questions_Rows, F10 ),

	json_array_count( F9, Question_Questions_Rows, Rows_Count ),
	sys_string_number( Rows_Count_String, Rows_Count ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].question_type` ], Question_Questions_Rows_Question_Type ),
	json_set_cut( F10, Question_Questions_Rows_Question_Type, `table_row`, F11 ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].cells` ], Question_Questions_Rows_Cells ),
	json_set_array( F11, Question_Questions_Rows_Cells, F12 ),

	json_add_array_entry_object( F12, Question_Questions_Rows_Cells, F13 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].question_type` ], Question_Questions_Rows_Cells_Question_Type_0 ),
	json_set_cut( F13, Question_Questions_Rows_Cells_Question_Type_0, `table_cell`, F14 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].value` ], Question_Questions_Rows_Cells_Value_0 ),
	json_set_cut( F14, Question_Questions_Rows_Cells_Value_0, Data_Item_Name, F15 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].editable` ], Question_Questions_Rows_Cells_Editable_0 ),
	json_set_boolean( F15, Question_Questions_Rows_Cells_Editable_0, `false`, F16 ),

	json_add_array_entry_object( F16, Question_Questions_Rows_Cells, F17 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].question_type` ], Question_Questions_Rows_Cells_Question_Type_1 ),
	json_set_cut( F17, Question_Questions_Rows_Cells_Question_Type_1, `table_cell`, F18 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].value` ], Question_Questions_Rows_Cells_Value_1 ),
	json_set_cut( F18, Question_Questions_Rows_Cells_Value_1, Variable, F19 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].editable` ], Question_Questions_Rows_Cells_Editable_1 ),
	json_set_boolean( F19, Question_Questions_Rows_Cells_Editable_1, `false`, F20 ),

	json_add_array_entry_object( F20, Question_Questions_Rows_Cells, F21 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
	json_set_cut( F21, Question_Questions_Rows_Cells_Question_Type_2, `table_cell_popover`, F22 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].text` ], Question_Questions_Rows_Cells_Question_Text_2 ),
	json_set_cut( F22, Question_Questions_Rows_Cells_Question_Text_2, Mapping_Logic, F23 ),

	json_add_array_entry_object( F23, Question_Questions_Rows_Cells, F24 ),

	(
		not( required_data_item( Data_Item_Name, _, _, _, `No`, `Send to Customer Intervention`, _, _, _, Variable, _ ) ),

		strcat_list( [ Question_Questions_Rows_Cells, `[3].question_type` ], Question_Questions_Rows_Cells_Question_Type_3 ),
		json_set_cut( F24, Question_Questions_Rows_Cells_Question_Type_3, `table_cell_drop_down_list`, F25 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[3].value` ], Question_Questions_Rows_Cells_Value_3 ),
		json_set_cut( F25, Question_Questions_Rows_Cells_Value_3, Value, F26 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[3].options` ], Question_Questions_Rows_Cells_Options_3 ),
		json_set_array( F26, Question_Questions_Rows_Cells_Options_3, F27 ),

		add_list( Question_Questions_Rows_Cells_Options_3, Options, F27, Form_Out )

		;

		required_data_item( Data_Item_Name, _, _, _, `No`, `Send to Customer Intervention`, _, _, _, Variable, _ ),

		strcat_list( [ Question_Questions_Rows_Cells, `[3].question_type` ], Question_Questions_Rows_Cells_Question_Type_3 ),
		json_set_cut( F24, Question_Questions_Rows_Cells_Question_Type_3, `table_cell`, F25 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[3].value` ], Question_Questions_Rows_Cells_Value_3 ),
		json_set_cut( F25, Question_Questions_Rows_Cells_Value_3, `Only customer can action.`, F26 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[3].editable` ], Question_Questions_Rows_Cells_Editable_3 ),
		json_set_boolean( F26, Question_Questions_Rows_Cells_Editable_3, `false`, Form_Out )

	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD LINE LEVEL DATA ITEM TABULAR LIST QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_line_level_data_item_tabular_list_question( Data_Item_Name, Variable, Mapping_Logic, Missing_At_Lines, Value, Options, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Question_Questions_Rows ),

		Form_In = F9

		;

		json_add_array_entry_object( Form_In, `questions`, F1 ),

		json_array_count( Form_In, `questions`, Count ),
		sys_string_number( Count_String, Count ),

		strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
		json_set_cut( F1, Question_Type, `section`, F2 ),

		strcat_list( [ `questions[`, Count_String, `].title` ], Question_Title ),
		json_set_cut( F2, Question_Title, `Failed to map the below line level data items:`, F3 ),

		strcat_list( [ `questions[`, Count_String, `].questions` ], Question_Questions ),
		json_set_array( F3, Question_Questions, F4 ),

		json_add_array_entry_object( F4, Question_Questions, F5 ),

		strcat_list( [ Question_Questions, `[0].question_type` ], Question_Questions_Question_Type ),
		json_set_cut( F5, Question_Questions_Question_Type, `table`, F6 ),

		strcat_list( [ Question_Questions, `[0].headings` ], Question_Questions_Headings ),
		json_set_array( F6, Question_Questions_Headings, F7 ),

		add_list( Question_Questions_Headings, [ `Data Item Name`, `Variable`, `Mapping Logic`, `Missing At Lines`, `Action` ], F7, F8 ),

		strcat_list( [ Question_Questions, `[0].rows` ], Question_Questions_Rows ),
		json_set_array( F8, Question_Questions_Rows, F9 )

	),

	json_add_array_entry_object( F9, Question_Questions_Rows, F10 ),

	json_array_count( F9, Question_Questions_Rows, Rows_Count ),
	sys_string_number( Rows_Count_String, Rows_Count ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].question_type` ], Question_Questions_Rows_Question_Type ),
	json_set_cut( F10, Question_Questions_Rows_Question_Type, `table_row`, F11 ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].cells` ], Question_Questions_Rows_Cells ),
	json_set_array( F11, Question_Questions_Rows_Cells, F12 ),

	json_add_array_entry_object( F12, Question_Questions_Rows_Cells, F13 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].question_type` ], Question_Questions_Rows_Cells_Question_Type_0 ),
	json_set_cut( F13, Question_Questions_Rows_Cells_Question_Type_0, `table_cell`, F14 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].value` ], Question_Questions_Rows_Cells_Value_0 ),
	json_set_cut( F14, Question_Questions_Rows_Cells_Value_0, Data_Item_Name, F15 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].editable` ], Question_Questions_Rows_Cells_Editable_0 ),
	json_set_boolean( F15, Question_Questions_Rows_Cells_Editable_0, `false`, F16 ),

	json_add_array_entry_object( F16, Question_Questions_Rows_Cells, F17 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].question_type` ], Question_Questions_Rows_Cells_Question_Type_1 ),
	json_set_cut( F17, Question_Questions_Rows_Cells_Question_Type_1, `table_cell`, F18 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].value` ], Question_Questions_Rows_Cells_Value_1 ),
	json_set_cut( F18, Question_Questions_Rows_Cells_Value_1, Variable, F19 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].editable` ], Question_Questions_Rows_Cells_Editable_1 ),
	json_set_boolean( F19, Question_Questions_Rows_Cells_Editable_1, `false`, F20 ),

	json_add_array_entry_object( F20, Question_Questions_Rows_Cells, F21 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
	json_set_cut( F21, Question_Questions_Rows_Cells_Question_Type_2, `table_cell_popover`, F22 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].text` ], Question_Questions_Rows_Cells_Question_Text_2 ),
	json_set_cut( F22, Question_Questions_Rows_Cells_Question_Text_2, Mapping_Logic, F23 ),

	json_add_array_entry_object( F23, Question_Questions_Rows_Cells, F24 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[3].question_type` ], Question_Questions_Rows_Cells_Question_Type_3 ),
	json_set_cut( F24, Question_Questions_Rows_Cells_Question_Type_3, `table_cell`, F25 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[3].value` ], Question_Questions_Rows_Cells_Value_3 ),
	json_set_cut( F25, Question_Questions_Rows_Cells_Value_3, Missing_At_Lines, F26 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[3].editable` ], Question_Questions_Rows_Cells_Editable_3 ),
	json_set_boolean( F26, Question_Questions_Rows_Cells_Editable_3, `false`, F27 ),

	json_add_array_entry_object( F27, Question_Questions_Rows_Cells, F28 ),

	(
		not( required_data_item( Data_Item_Name, _, _, _, `No`, `Send to Customer Intervention`, _, _, _, Variable, _ ) ),

		strcat_list( [ Question_Questions_Rows_Cells, `[4].question_type` ], Question_Questions_Rows_Cells_Question_Type_4 ),
		json_set_cut( F28, Question_Questions_Rows_Cells_Question_Type_4, `table_cell_drop_down_list`, F29 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[4].value` ], Question_Questions_Rows_Cells_Value_4 ),
		json_set_cut( F29, Question_Questions_Rows_Cells_Value_4, Value, F30 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[4].options` ], Question_Questions_Rows_Cells_Options_4 ),
		json_set_array( F30, Question_Questions_Rows_Cells_Options_4, F31 ),

		add_list( Question_Questions_Rows_Cells_Options_4, Options, F31, Form_Out )

		;

		required_data_item( Data_Item_Name, _, _, _, `No`, `Send to Customer Intervention`, _, _, _, Variable, _ ),

		strcat_list( [ Question_Questions_Rows_Cells, `[4].question_type` ], Question_Questions_Rows_Cells_Question_Type_4 ),
		json_set_cut( F28, Question_Questions_Rows_Cells_Question_Type_4, `table_cell`, F29 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[4].value` ], Question_Questions_Rows_Cells_Value_4 ),
		json_set_cut( F29, Question_Questions_Rows_Cells_Value_4, `Only customer can action.`, F30 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[4].editable` ], Question_Questions_Rows_Cells_Editable_4 ),
		json_set_boolean( F30, Question_Questions_Rows_Cells_Editable_4, `false`, Form_Out )

	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD CUSTOMER HEADER LEVEL DATA ITEM TABULAR LIST QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_customer_header_level_data_item_tabular_list_question( Data_Item_Name, Mapping_Logic, Value, Options, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Question_Questions_Rows ),

		Form_In = F9

		;

		json_add_array_entry_object( Form_In, `questions`, F1 ),

		json_array_count( Form_In, `questions`, Count ),
		sys_string_number( Count_String, Count ),

		strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
		json_set_cut( F1, Question_Type, `section`, F2 ),

		strcat_list( [ `questions[`, Count_String, `].title` ], Question_Title ),
		json_set_cut( F2, Question_Title, `Failed to map the below header level data items:`, F3 ),

		strcat_list( [ `questions[`, Count_String, `].questions` ], Question_Questions ),
		json_set_array( F3, Question_Questions, F4 ),

		json_add_array_entry_object( F4, Question_Questions, F5 ),

		strcat_list( [ Question_Questions, `[0].question_type` ], Question_Questions_Question_Type ),
		json_set_cut( F5, Question_Questions_Question_Type, `table`, F6 ),

		strcat_list( [ Question_Questions, `[0].headings` ], Question_Questions_Headings ),
		json_set_array( F6, Question_Questions_Headings, F7 ),

		add_list( Question_Questions_Headings, [ `Data Item Name`, `Mapping Logic`, `Action` ], F7, F8 ),

		strcat_list( [ Question_Questions, `[0].rows` ], Question_Questions_Rows ),
		json_set_array( F8, Question_Questions_Rows, F9 )

	),

	json_add_array_entry_object( F9, Question_Questions_Rows, F10 ),

	json_array_count( F9, Question_Questions_Rows, Rows_Count ),
	sys_string_number( Rows_Count_String, Rows_Count ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].question_type` ], Question_Questions_Rows_Question_Type ),
	json_set_cut( F10, Question_Questions_Rows_Question_Type, `table_row`, F11 ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].cells` ], Question_Questions_Rows_Cells ),
	json_set_array( F11, Question_Questions_Rows_Cells, F12 ),

	json_add_array_entry_object( F12, Question_Questions_Rows_Cells, F13 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].question_type` ], Question_Questions_Rows_Cells_Question_Type_0 ),
	json_set_cut( F13, Question_Questions_Rows_Cells_Question_Type_0, `table_cell`, F14 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].value` ], Question_Questions_Rows_Cells_Value_0 ),
	json_set_cut( F14, Question_Questions_Rows_Cells_Value_0, Data_Item_Name, F15 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].editable` ], Question_Questions_Rows_Cells_Editable_0 ),
	json_set_boolean( F15, Question_Questions_Rows_Cells_Editable_0, `false`, F16 ),

	json_add_array_entry_object( F16, Question_Questions_Rows_Cells, F17 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].question_type` ], Question_Questions_Rows_Cells_Question_Type_1 ),
	json_set_cut( F17, Question_Questions_Rows_Cells_Question_Type_1, `table_cell_popover`, F18 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].text` ], Question_Questions_Rows_Cells_Question_Text_1 ),
	json_set_cut( F18, Question_Questions_Rows_Cells_Question_Text_1, Mapping_Logic, F19 ),

	json_add_array_entry_object( F19, Question_Questions_Rows_Cells, F20 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
	json_set_cut( F20, Question_Questions_Rows_Cells_Question_Type_2, `table_cell_drop_down_list`, F21 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].value` ], Question_Questions_Rows_Cells_Value_2 ),
	json_set_cut( F21, Question_Questions_Rows_Cells_Value_2, Value, F22 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].options` ], Question_Questions_Rows_Cells_Options_2 ),
	json_set_array( F22, Question_Questions_Rows_Cells_Options_2, F23 ),

	add_list( Question_Questions_Rows_Cells_Options_2, Options, F23, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD CUSTOMER LINE LEVEL DATA ITEM TABULAR LIST QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_customer_line_level_data_item_tabular_list_question( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Value, Options, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Question_Questions_Rows ),

		Form_In = F9

		;

		json_add_array_entry_object( Form_In, `questions`, F1 ),

		json_array_count( Form_In, `questions`, Count ),
		sys_string_number( Count_String, Count ),

		strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
		json_set_cut( F1, Question_Type, `section`, F2 ),

		strcat_list( [ `questions[`, Count_String, `].title` ], Question_Title ),
		json_set_cut( F2, Question_Title, `Failed to map the below line level data items:`, F3 ),

		strcat_list( [ `questions[`, Count_String, `].questions` ], Question_Questions ),
		json_set_array( F3, Question_Questions, F4 ),

		json_add_array_entry_object( F4, Question_Questions, F5 ),

		strcat_list( [ Question_Questions, `[0].question_type` ], Question_Questions_Question_Type ),
		json_set_cut( F5, Question_Questions_Question_Type, `table`, F6 ),

		strcat_list( [ Question_Questions, `[0].headings` ], Question_Questions_Headings ),
		json_set_array( F6, Question_Questions_Headings, F7 ),

		add_list( Question_Questions_Headings, [ `Data Item Name`, `Mapping Logic`, `Missing At Lines`, `Action` ], F7, F8 ),

		strcat_list( [ Question_Questions, `[0].rows` ], Question_Questions_Rows ),
		json_set_array( F8, Question_Questions_Rows, F9 )

	),

	json_add_array_entry_object( F9, Question_Questions_Rows, F10 ),

	json_array_count( F9, Question_Questions_Rows, Rows_Count ),
	sys_string_number( Rows_Count_String, Rows_Count ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].question_type` ], Question_Questions_Rows_Question_Type ),
	json_set_cut( F10, Question_Questions_Rows_Question_Type, `table_row`, F11 ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].cells` ], Question_Questions_Rows_Cells ),
	json_set_array( F11, Question_Questions_Rows_Cells, F12 ),

	json_add_array_entry_object( F12, Question_Questions_Rows_Cells, F13 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].question_type` ], Question_Questions_Rows_Cells_Question_Type_0 ),
	json_set_cut( F13, Question_Questions_Rows_Cells_Question_Type_0, `table_cell`, F14 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].value` ], Question_Questions_Rows_Cells_Value_0 ),
	json_set_cut( F14, Question_Questions_Rows_Cells_Value_0, Data_Item_Name, F15 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].editable` ], Question_Questions_Rows_Cells_Editable_0 ),
	json_set_boolean( F15, Question_Questions_Rows_Cells_Editable_0, `false`, F16 ),

	json_add_array_entry_object( F16, Question_Questions_Rows_Cells, F17 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].question_type` ], Question_Questions_Rows_Cells_Question_Type_1 ),
	json_set_cut( F17, Question_Questions_Rows_Cells_Question_Type_1, `table_cell_popover`, F18 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].text` ], Question_Questions_Rows_Cells_Question_Text_1 ),
	json_set_cut( F18, Question_Questions_Rows_Cells_Question_Text_1, Mapping_Logic, F19 ),

	json_add_array_entry_object( F19, Question_Questions_Rows_Cells, F20 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
	json_set_cut( F20, Question_Questions_Rows_Cells_Question_Type_2, `table_cell`, F21 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].value` ], Question_Questions_Rows_Cells_Value_2 ),
	json_set_cut( F21, Question_Questions_Rows_Cells_Value_2, Missing_At_Lines, F22 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[2].editable` ], Question_Questions_Rows_Cells_Editable_2 ),
	json_set_boolean( F22, Question_Questions_Rows_Cells_Editable_2, `false`, F23 ),

	json_add_array_entry_object( F23, Question_Questions_Rows_Cells, F24 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[3].question_type` ], Question_Questions_Rows_Cells_Question_Type_3 ),
	json_set_cut( F24, Question_Questions_Rows_Cells_Question_Type_3, `table_cell_drop_down_list`, F25 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[3].value` ], Question_Questions_Rows_Cells_Value_3 ),
	json_set_cut( F25, Question_Questions_Rows_Cells_Value_3, Value, F26 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[3].options` ], Question_Questions_Rows_Cells_Options_3 ),
	json_set_array( F26, Question_Questions_Rows_Cells_Options_3, F27 ),

	add_list( Question_Questions_Rows_Cells_Options_3, Options, F27, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD DOCUMENT SCENARIO TABULAR LIST QUESTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_document_scenario_tabular_list_question( Scenario, Description, Value, Options, Ignore, Role, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	(
		json_find_first_container( Form_In, `title`, `Detected the below document errors:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Question_Questions_Rows ),

		Form_In = F9

		;

		json_add_array_entry_object( Form_In, `questions`, F1 ),

		json_array_count( Form_In, `questions`, Count ),
		sys_string_number( Count_String, Count ),

		strcat_list( [ `questions[`, Count_String, `].question_type` ], Question_Type ),
		json_set_cut( F1, Question_Type, `section`, F2 ),

		strcat_list( [ `questions[`, Count_String, `].title` ], Question_Title ),
		json_set_cut( F2, Question_Title, `Detected the below document errors:`, F3 ),

		strcat_list( [ `questions[`, Count_String, `].questions` ], Question_Questions ),
		json_set_array( F3, Question_Questions, F4 ),

		json_add_array_entry_object( F4, Question_Questions, F5 ),

		strcat_list( [ Question_Questions, `[0].question_type` ], Question_Questions_Question_Type ),
		json_set_cut( F5, Question_Questions_Question_Type, `table`, F6 ),

		strcat_list( [ Question_Questions, `[0].headings` ], Question_Questions_Headings ),
		json_set_array( F6, Question_Questions_Headings, F7 ),

		add_list( Question_Questions_Headings, [ `Scenario`, `Description`, `Action` ], F7, F8 ),

		strcat_list( [ Question_Questions, `[0].rows` ], Question_Questions_Rows ),
		json_set_array( F8, Question_Questions_Rows, F9 )

	),

	json_add_array_entry_object( F9, Question_Questions_Rows, F10 ),

	json_array_count( F9, Question_Questions_Rows, Rows_Count ),
	sys_string_number( Rows_Count_String, Rows_Count ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].question_type` ], Question_Questions_Rows_Question_Type ),
	json_set_cut( F10, Question_Questions_Rows_Question_Type, `table_row`, F11 ),

	strcat_list( [ Question_Questions_Rows, `[`, Rows_Count_String, `].cells` ], Question_Questions_Rows_Cells ),
	json_set_array( F11, Question_Questions_Rows_Cells, F12 ),

	json_add_array_entry_object( F12, Question_Questions_Rows_Cells, F13 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].question_type` ], Question_Questions_Rows_Cells_Question_Type_0 ),
	json_set_cut( F13, Question_Questions_Rows_Cells_Question_Type_0, `table_cell`, F14 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].value` ], Question_Questions_Rows_Cells_Value_0 ),
	json_set_cut( F14, Question_Questions_Rows_Cells_Value_0, Scenario, F15 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[0].editable` ], Question_Questions_Rows_Cells_Editable_0 ),
	json_set_boolean( F15, Question_Questions_Rows_Cells_Editable_0, `false`, F16 ),

	json_add_array_entry_object( F16, Question_Questions_Rows_Cells, F17 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].question_type` ], Question_Questions_Rows_Cells_Question_Type_1 ),
	json_set_cut( F17, Question_Questions_Rows_Cells_Question_Type_1, `table_cell_popover`, F18 ),

	strcat_list( [ Question_Questions_Rows_Cells, `[1].text` ], Question_Questions_Rows_Cells_Question_Text_1 ),
	json_set_cut( F18, Question_Questions_Rows_Cells_Question_Text_1, Description, F19 ),

	json_add_array_entry_object( F19, Question_Questions_Rows_Cells, F20 ),

	(
		Ignore = `Allow`,

		(
			Role = `Rules`,

			document_scenario( Scenario, _, `No`, `Send to Customer Intervention`, _, _, _, _, _, _, _, _ ),

			strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
			json_set_cut( F20, Question_Questions_Rows_Cells_Question_Type_2, `table_cell`, F21 ),

			strcat_list( [ Question_Questions_Rows_Cells, `[2].value` ], Question_Questions_Rows_Cells_Value_2 ),
			json_set_cut( F21, Question_Questions_Rows_Cells_Value_2, `Only customer can action.`, F22 ),

			strcat_list( [ Question_Questions_Rows_Cells, `[2].editable` ], Question_Questions_Rows_Cells_Editable_2 ),
			json_set_boolean( F22, Question_Questions_Rows_Cells_Editable_2, `false`, Form_Out )

			;

			strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
			json_set_cut( F20, Question_Questions_Rows_Cells_Question_Type_2, `table_cell_drop_down_list`, F21 ),

			strcat_list( [ Question_Questions_Rows_Cells, `[2].value` ], Question_Questions_Rows_Cells_Value_2 ),
			json_set_cut( F21, Question_Questions_Rows_Cells_Value_2, Value, F22 ),

			strcat_list( [ Question_Questions_Rows_Cells, `[2].options` ], Question_Questions_Rows_Cells_Options_2 ),
			json_set_array( F22, Question_Questions_Rows_Cells_Options_2, F23 ),

			add_list( Question_Questions_Rows_Cells_Options_2, Options, F23, Form_Out )

		)

		;

		Ignore \= `Allow`,

		strcat_list( [ Question_Questions_Rows_Cells, `[2].question_type` ], Question_Questions_Rows_Cells_Question_Type_2 ),
		json_set_cut( F20, Question_Questions_Rows_Cells_Question_Type_2, `table_cell`, F21 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[2].value` ], Question_Questions_Rows_Cells_Value_2 ),
		json_set_cut( F21, Question_Questions_Rows_Cells_Value_2, `This error cannot be ignored.`, F22 ),

		strcat_list( [ Question_Questions_Rows_Cells, `[2].editable` ], Question_Questions_Rows_Cells_Editable_2 ),
		json_set_boolean( F22, Question_Questions_Rows_Cells_Editable_2, `false`, Form_Out )

	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD HEADER VARIABLE GROUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_caption_name_and_value_to_object( Object_Reference, Caption, Name, Value, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_add_array_entry_object( Form_In, Object_Reference, F1 ),

	json_array_count( Form_In, Object_Reference, Count ),
	sys_string_number( Count_String, Count ),

	strcat_list( [ Object_Reference, `[`, Count_String, `].caption` ], Caption_Field ),
	json_set_cut( F1, Caption_Field, Caption, F2 ),

	strcat_list( [ Object_Reference, `[`, Count_String, `].name` ], Name_Field ),
	json_set_cut( F2, Name_Field, Name, F3 ),

	strcat_list( [ Object_Reference, `[`, Count_String, `].value` ], Value_Field ),
	json_set_cut( F3, Value_Field, Value, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD LINE TEMPLATE GROUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_line_template_group( List_of_Line_Data_Items, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_add_array_entry_object( Form_In, `group`, F1 ),

	json_array_count( Form_In, `group`, Count ),
	sys_string_number( Count_String, Count ),

	strcat_list( [ `group[`, Count_String, `].caption` ], Caption_Field ),
	json_set_cut( F1, Caption_Field, `Line Items`, F2 ),

	strcat_list( [ `group[`, Count_String, `].group` ], Group_Field ),
	json_set_array( F2, Group_Field, F3 ),

	json_add_array_entry_object( F3, Group_Field, F4 ),

	strcat_list( [ Group_Field, `[0].caption` ], Group_Caption_Field ),
	json_set_cut( F4, Group_Caption_Field, `Line`, F5 ),

	strcat_list( [ Group_Field, `[0].min` ], Group_Min_Field ),
	json_set_int( F5, Group_Min_Field, `0`, F6 ),

	strcat_list( [ Group_Field, `[0].max` ], Group_Max_Field ),
	json_set_int( F6, Group_Max_Field, `999`, F7 ),

	strcat_list( [ Group_Field, `[0].line_template` ], Group_Line_Template_Field ),
	json_set_array( F7, Group_Line_Template_Field, F8 ),

	create_line_template_from_list( F8, Group_Line_Template_Field, List_of_Line_Data_Items, F9 ),

	strcat_list( [ Group_Field, `[0].group` ], Group_Group_Field ),
	json_set_array( F9, Group_Group_Field, Form_Out )
.

create_line_template_from_list( Form, Object_Reference, [ ], Form ).
create_line_template_from_list( Form_In, Object_Reference, [ ( Name, Variable ) | Remaining_Items ], Form_Out )

:-
	add_caption_name_and_value_to_object( Object_Reference, Name, Variable, ``, Form_In, Form_Updated )

	-> create_line_template_from_list( Form_Updated, Object_Reference, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD LINE VALUE TO COMPLETION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
add_line_value_to_completion( LID, Variable, Value, Form_In, Form_Out )
%-----------------------------------------------------------------------
:-
	json_find_first_container( Form_In, `caption`, `Line`, Line_Object_Reference ),

	strcat_list( [ Line_Object_Reference, `.group` ], Line_Group_Array_Reference ),
	json_array_count( Form_In, Line_Group_Array_Reference, Count ),
	sys_string_number( Count_String, Count ),

	sys_string_number( LID_String, LID ),

	(
		q_sys_comp_str_le( LID_String, Count_String ),

		Form_In = F1

		;

		add_extra_line_arrays( LID_String, Count_String, Line_Group_Array_Reference, Form_In, F1 )

	),

	sys_calculate( Array_Number, LID - 1 ),
	sys_string_number( Array_Number_String, Array_Number ),

	strcat_list( [ Line_Group_Array_Reference, `[`, Array_Number_String, `].`, Variable ], Line_Group_Variable_Field ),
	json_set_cut( F1, Line_Group_Variable_Field, Value, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE HEADER VARIABLE GROUP BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_header_variable_group_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_header_variable_group_based_on_list( Form_In, [ ( Name, Variable, Value ) | Remaining_Items ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	add_caption_name_and_value_to_object( `group`, Name, Variable, Value, Form_In, Form_Updated )

	-> create_header_variable_group_based_on_list( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE LINE VARIABLE GROUP BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_line_variable_group_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_line_variable_group_based_on_list( Form_In, List_of_Line_Data_Items, Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	add_line_template_group( List_of_Line_Data_Items, Form_In, Form_Updated )

	-> create_header_variable_group_based_on_list( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILL IN EXISTING LINE VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
fill_in_existing_line_values( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
fill_in_existing_line_values( Form_In, [ ( LID, Variable, Value ) | Remaining_Items ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	add_line_value_to_completion( LID, Variable, Value, Form_In, Form_Updated )

	-> fill_in_existing_line_values( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LIST VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_list_values( Form, Array_Name, Array_Value_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_array_count( Form, Array_Name, Count ),

	json_get_list_function( Form, Array_Name, 0, Count, [ ], Array_Value_List )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_list_function( Form, Array_Name, Count, Count, Options_List, Options_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_list_function( Form, Array_Name, Initial_Count, Count, Initial_List, Options_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Array_Name, `[`, Initial_Count_String, `]` ], Array_Field ),
	json_get( Form, Array_Field, Value ),

	sys_append( Initial_List, [ Value ], Updated_List ),

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> json_get_list_function( Form, Array_Name, Count_Plus_One, Count, Updated_List, Options_List )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD EXTRA LINE ARRAYS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
add_extra_line_arrays( LID_String, Count_String, Line_Group_Array_Reference, Form_In, Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_calculate_str_subtract( LID_String, Count_String, Number_of_Required_Arrays )

	-> add_extra_line_arrays_function( Line_Group_Array_Reference, `0`, Number_of_Required_Arrays, Form_In, Form_Out )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
add_extra_line_arrays_function( Line_Group_Array_Reference, Count, Count, Form, Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
add_extra_line_arrays_function( Line_Group_Array_Reference, Initial_Count, Count, Form_In, Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_add_array_entry_object( Form_In, Line_Group_Array_Reference, Form_Updated ),

	sys_calculate_str_add( Initial_Count, `1`, Count_Plus_One )

	-> add_extra_line_arrays_function( Line_Group_Array_Reference, Count_Plus_One, Count, Form_Updated, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET HEADER VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_header_values( Form, [ Form_Name, Form_Answered, Form_Ignored_Rules_Intervention_Questions_List, Form_Ignored_Customer_Intervention_Questions_List, Form_Transferred_Intervention_Questions_List, Form_Role, Form_Reason, Form_Long_Reason, Form_From_Address, Form_Return_To_Sender, Form_Forward, Form_Unrecognised, Form_Junk, Form_RTS_Address_Options_List, Form_Selected_RTS_Address_List, Form_Forward_Address_Options_List, Form_Selected_Forward_Address_List, Form_RTS_Email_Subject, Form_Forward_Email_Subject, Form_RTS_Email_Body, Form_Forward_Email_Body ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form, `name`, Form_Name ),

	json_get( Form, `answered`, Form_Answered ),

	json_get_list_values( Form, `ignored_rules_intervention_questions`, Form_Ignored_Rules_Intervention_Questions_List ),

	json_get_list_values( Form, `ignored_customer_intervention_questions`, Form_Ignored_Customer_Intervention_Questions_List ),

	json_get_list_values( Form, `transferred_intervention_questions`, Form_Transferred_Intervention_Questions_List ),

	json_get( Form, `role`, Form_Role ),

	json_get( Form, `reason`, Form_Reason ),

	json_get( Form, `long_reason`, Form_Long_Reason ),

	json_get( Form, `from_address`, Form_From_Address ),

	json_get( Form, `return_to_sender`, Form_Return_To_Sender ),

	json_get( Form, `forward`, Form_Forward ),

	json_get( Form, `unrecognised`, Form_Unrecognised ),

	json_get( Form, `junk`, Form_Junk ),

	json_get_list_values( Form, `return_to_sender_address_options`, Form_RTS_Address_Options_List ),

	json_get_list_values( Form, `selected_return_to_sender_addresses`, Form_Selected_RTS_Address_List ),

	json_get_list_values( Form, `forward_address_options`, Form_Forward_Address_Options_List ),

	json_get_list_values( Form, `selected_forward_addresses`, Form_Selected_Forward_Address_List ),

	json_get( Form, `return_to_sender_email_subject`, Form_RTS_Email_Subject ),

	json_get( Form, `forward_email_subject`, Form_Forward_Email_Subject ),

	json_get( Form, `return_to_sender_email_body`, Form_RTS_Email_Body ),

	json_get( Form, `forward_email_body`, Form_Forward_Email_Body )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET HEADER VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_set_header_values( Form_In, [ Form_Name, Form_Answered, Form_Ignored_Rules_Intervention_Questions_List, Form_Ignored_Customer_Intervention_Questions_List, Form_Transferred_Intervention_Questions_List, Form_Role, Form_Reason, Form_Long_Reason, Form_From_Address, Form_Return_To_Sender, Form_Forward, Form_Unrecognised, Form_Junk, Form_RTS_Address_Options_List, Form_Selected_RTS_Address_List, Form_Forward_Address_Options_List, Form_Selected_Forward_Address_List, Form_RTS_Email_Subject, Form_Forward_Email_Subject, Form_RTS_Email_Body, Form_Forward_Email_Body ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_set_cut( Form_In, `name`, Form_Name, F1 ),

	json_set_boolean( F1, `answered`, `false`, F2 ),

	add_list( `ignored_rules_intervention_questions`, Form_Ignored_Rules_Intervention_Questions_List, F2, F3 ),

	add_list( `ignored_customer_intervention_questions`, Form_Ignored_Customer_Intervention_Questions_List, F3, F4 ),

	add_list( `transferred_intervention_questions`, Form_Transferred_Intervention_Questions_List, F4, F5 ),

	json_set_cut( F5, `role`, Form_Role, F6 ),

	json_set_cut( F6, `reason`, Form_Reason, F7 ),

	json_set_cut( F7, `long_reason`, Form_Long_Reason, F8 ),

	json_set_cut( F8, `from_address`, Form_From_Address, F9 ),

	json_set_boolean( F9, `return_to_sender`, Form_Return_To_Sender, F10 ),

	json_set_boolean( F10, `forward`, Form_Forward, F11 ),

	json_set_boolean( F11, `unrecognised`, Form_Unrecognised, F12 ),

	json_set_boolean( F12, `junk`, Form_Junk, F13 ),

	add_list( `return_to_sender_address_options`, Form_RTS_Address_Options_List, F13, F14 ),

	add_list( `selected_return_to_sender_addresses`, Form_Selected_RTS_Address_List, F14, F15 ),

	add_list( `forward_address_options`, Form_Forward_Address_Options_List, F15, F16 ),

	add_list( `selected_forward_addresses`, Form_Selected_Forward_Address_List, F16, F17 ),

	json_set_cut( F17, `return_to_sender_email_subject`, Form_RTS_Email_Subject, F18 ),

	json_set_cut( F18, `forward_email_subject`, Form_Forward_Email_Subject, F19 ),

	json_set_cut( F19, `return_to_sender_email_body`, Form_RTS_Email_Body, F20 ),

	json_set_cut( F20, `forward_email_body`, Form_Forward_Email_Body, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ANSWERED DATA ITEM QUESTIONS THAT ARE STILL REQUIRED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_data_item_questions_that_are_still_required( Form_In, Answered_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		json_get_answered_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, 0, Count, [ ], Answered_Questions_List )

		;

		Answered_Questions_List = [ ]
	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, Count, Count, Answered_Questions_List, Answered_Questions_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Answered_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Question_Variable ),
	json_get( Form_In, Question_Variable, Data_Item_Name ),

	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Question_Value )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Question_Value )

	),

	json_get( Form_In, Question_Value, Value ),

	(
		Value \= ``, Value \= `This error cannot be ignored.`, Value \= `Only customer can action.`,

		required_data_item( Data_Item_Name, Mapping_Logic, _, Mandatory_Condition, _, Action, Email_Address, _, _, Variable, Dependency ),

		sys_call( Dependency ),

		sys_string_atom( Variable, Var ),

		not( result( _, invoice, Var, _ ) ),

		(
			Role = Rules_Intervention_Role,

			sys_append( Initial_List, [ ( Data_Item_Name, Mapping_Logic, Mandatory_Condition, Action, Email_Address, Variable, Value ) ], Updated_list )

			;

			Role \= Rules_Intervention_Role,

			sys_append( Initial_List, [ ( Data_Item_Name, Mapping_Logic, Mandatory_Condition, Value ) ], Updated_list )

		)

		;

		Initial_List = Updated_list

	),

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> json_get_answered_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_list, Answered_Questions_List )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ANSWERED LINE LEVEL DATA ITEM QUESTIONS THAT ARE STILL REQUIRED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_line_level_data_item_questions_that_are_still_required( Form_In, Answered_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		json_get_answered_line_level_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, 0, Count, [ ], Answered_Questions_List )

		;

		Answered_Questions_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_line_level_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, Count, Count, Answered_Questions_List, Answered_Questions_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_line_level_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Answered_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Question_Variable ),
	json_get( Form_In, Question_Variable, Data_Item_Name ),

	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[4].value` ], Question_Value )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Question_Value )

	),

	json_get( Form_In, Question_Value, Value ),

	(
		Value \= ``, Value \= `This error cannot be ignored.`, Value \= `Only customer can action.`,

		required_data_item( Data_Item_Name, Mapping_Logic, _, Mandatory_Condition, _, Action, Email_Address, _, _, Variable, Dependency ),

		sys_call( Dependency ),

		sys_string_atom( Variable, Var ),

		sys_findall(
			LID_String,
			(
				result( _, LID, _, _ ),
				sys_string_number( LID_String, LID ),
				not( result( _, LID, Var, _ ) ),
				(
					Role = Rules_Intervention_Role,
					not( grammar_set( `answered rules`, Variable, LID_String ) ),
					sys_assertz( grammar_set( `answered rules`, Variable, LID_String ) )
					;
					Role \= Rules_Intervention_Role,
					not( grammar_set( `answered customer`, Variable, LID_String ) ),
					sys_assertz( grammar_set( `answered customer`, Variable, LID_String ) )
				)
			),
			List_of_Line_Numbers_Raw
		),

		i_force_list( List_of_Line_Numbers_Raw, List_of_Line_Numbers ),

		List_of_Line_Numbers \= [ ],

		remove_flags_set_in_sys_findall( Role, Variable, List_of_Line_Numbers ),

		sys_stringlist_concat( List_of_Line_Numbers, `, `, Missing_At_Lines ),

		(
			Role = Rules_Intervention_Role,

			sys_append( Initial_List, [ ( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, Action, Email_Address, Variable, Value ) ], Updated_list )

			;

			Role \= Rules_Intervention_Role,

			sys_append( Initial_List, [ ( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, Value ) ], Updated_list )

		)

		;

		Initial_List = Updated_list

	),

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> json_get_answered_line_level_data_item_questions_that_are_still_required_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_list, Answered_Questions_List )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
remove_flags_set_in_sys_findall( Role, Variable, [ ] ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
remove_flags_set_in_sys_findall( Role, Variable, [ Line_Number | Remaining_Line_Numbers ] )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	(
		Role = Rules_Intervention_Role,

		sys_retract( grammar_set( `answered rules`, Variable, Line_Number ) )

		;

		Role \= Rules_Intervention_Role,

		sys_retract( grammar_set( `answered customer`, Variable, Line_Number ) )

	)

	-> remove_flags_set_in_sys_findall( Role, Variable, Remaining_Line_Numbers )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ANSWERED DOCUMENT SCENARIO QUESTIONS THAT ARE STILL REQUIRED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_document_scenario_questions_that_are_still_required( Form_In, Answered_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Detected the below document errors:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		json_get_answered_document_scenario_questions_that_are_still_required_function( Form_In, Rows_Reference, 0, Count, [ ], Answered_Questions_List )

		;

		Answered_Questions_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_document_scenario_questions_that_are_still_required_function( Form_In, Rows_Reference, Count, Count, Answered_Questions_List, Answered_Questions_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
json_get_answered_document_scenario_questions_that_are_still_required_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Answered_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Question_Scenario ),
	json_get( Form_In, Question_Scenario, Scenario ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Question_Value ),
	json_get( Form_In, Question_Value, Value ),

	(
		Value \= ``, Value \= `This error cannot be ignored.`, Value \= `Only customer can action.`,

		document_scenario( Scenario, _, _, _, _, _, Description, Question_ID, Question_Type, Question_Options, Question_Ignore, Dependency ),

		sys_call( Dependency ),

		json_get( Form_In, `role`, Role ),

		(
			qq_op_param( rules_intervention_role, Rules_Intervention_Role )

			;

			Rules_Intervention_Role = `CloudTrade`

		),

		!,

		(
			Role = Rules_Intervention_Role,

			Question_Options = Question_Options_Final,

			Question_Role = `Rules`

			;

			Role \= Rules_Intervention_Role,

			`Ignore error` = Question_Options_Final,

			Question_Role = `Customer`

		),

		sys_append( Initial_List, [ ( Scenario, Description, Question_ID, Question_Type, Question_Options_Final, Question_Ignore, Question_Role, Value ) ], Updated_list )

		;

		Initial_List = Updated_list

	),

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> json_get_answered_document_scenario_questions_that_are_still_required_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_list, Answered_Questions_List )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET NEW IGNORED RULES INTERVENTION QUESTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_new_ignored_rules_intervention_questions( Answered_Form, Ignored_Rules_Intervention_Questions_List, Answered_Header_Level_Items_List, Answered_Line_Level_Items_List, Answered_Document_Scenarios_List, New_Ignored_Rules_Intervention_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		Data_Item_Name,
		(
			q_sys_member( ( Data_Item_Name, _, _, _, _, _, `Ignore error` ), Answered_Header_Level_Items_List ),
			not( q_sys_member( Data_Item_Name, Ignored_Rules_Intervention_Questions_List ) )
		),
		New_Ignored_Header_Level_Rules_Intervention_Data_Item_Questions_List_Raw
	),

	i_force_list( New_Ignored_Header_Level_Rules_Intervention_Data_Item_Questions_List_Raw, New_Ignored_Header_Level_Rules_Intervention_Data_Item_Questions_List ),

	!,

	sys_findall(
		Data_Item_Name,
		(
			q_sys_member( ( Data_Item_Name, _, _, _, _, _, _, `Ignore error` ), Answered_Line_Level_Items_List ),
			not( q_sys_member( Data_Item_Name, Ignored_Rules_Intervention_Questions_List ) )
		),
		New_Ignored_Line_Level_Rules_Intervention_Data_Item_Questions_List_Raw
	),

	i_force_list( New_Ignored_Line_Level_Rules_Intervention_Data_Item_Questions_List_Raw, New_Ignored_Line_Level_Rules_Intervention_Data_Item_Questions_List ),

	!,

	sys_findall(
		Scenario,
		(
			q_sys_member( ( Scenario, _, _, _, _, _, _, `Ignore error` ), Answered_Document_Scenarios_List ),
			not( q_sys_member( Scenario, Ignored_Rules_Intervention_Questions_List ) )
		),
		New_Ignored_Rules_Intervention_Document_Scenario_Questions_List_Raw
	),

	i_force_list( New_Ignored_Rules_Intervention_Document_Scenario_Questions_List_Raw, New_Ignored_Rules_Intervention_Document_Scenario_Questions_List ),

	!,

	sys_append( New_Ignored_Header_Level_Rules_Intervention_Data_Item_Questions_List, New_Ignored_Line_Level_Rules_Intervention_Data_Item_Questions_List, New_Ignored_Rules_Intervention_Data_Item_Questions_List ),

	sys_append( New_Ignored_Rules_Intervention_Data_Item_Questions_List, New_Ignored_Rules_Intervention_Document_Scenario_Questions_List, New_Ignored_Rules_Intervention_Questions_List ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET NEW IGNORED RULES INTERVENTION QUESTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_new_ignored_customer_intervention_questions( Answered_Form, Ignored_Customer_Intervention_Questions_List,  Answered_Header_Level_Items_List, Answered_Line_Level_Items_List, Answered_Document_Scenarios_List, New_Ignored_Customer_Intervention_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_findall(
		Data_Item_Name,
		(
			q_sys_member( ( Data_Item_Name, _, _, `Ignore error` ), Answered_Header_Level_Items_List ),
			not( q_sys_member( Data_Item_Name, Ignored_Customer_Intervention_Questions_List ) )
		),
		New_Ignored_Header_Level_Customer_Intervention_Data_Item_Questions_List_Raw
	),

	i_force_list( New_Ignored_Header_Level_Customer_Intervention_Data_Item_Questions_List_Raw, New_Ignored_Header_Level_Customer_Intervention_Data_Item_Questions_List ),

	!,

	sys_findall(
		Data_Item_Name,
		(
			q_sys_member( ( Data_Item_Name, _, _, _, `Ignore error` ), Answered_Line_Level_Items_List ),
			not( q_sys_member( Data_Item_Name, Ignored_Customer_Intervention_Questions_List ) )
		),
		New_Ignored_Line_Level_Customer_Intervention_Data_Item_Questions_List_Raw
	),

	i_force_list( New_Ignored_Line_Level_Customer_Intervention_Data_Item_Questions_List_Raw, New_Ignored_Line_Level_Customer_Intervention_Data_Item_Questions_List ),

	!,

	sys_findall(
		Scenario,
		(
			q_sys_member( ( Scenario, _, _, _, _, _, _, `Ignore error` ), Answered_Document_Scenarios_List ),
			not( q_sys_member( Scenario, Ignored_Customer_Intervention_Questions_List ) )
		),
		New_Ignored_Customer_Intervention_Document_Scenario_Questions_List_Raw
	),

	i_force_list( New_Ignored_Customer_Intervention_Document_Scenario_Questions_List_Raw, New_Ignored_Customer_Intervention_Document_Scenario_Questions_List ),

	!,

	sys_append( New_Ignored_Header_Level_Customer_Intervention_Data_Item_Questions_List, New_Ignored_Line_Level_Customer_Intervention_Data_Item_Questions_List, New_Ignored_Customer_Intervention_Data_Items_Questions_List ),

	sys_append( New_Ignored_Customer_Intervention_Data_Items_Questions_List, New_Ignored_Customer_Intervention_Document_Scenario_Questions_List, New_Ignored_Customer_Intervention_Questions_List ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION PRESSED BUTTONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_pressed_buttons( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get_header_values( Form_In, [ _, _, _, _, _, _, _, _, _, Form_Return_To_Sender, Form_Forward, _, Form_Junk, _, Form_Selected_RTS_Address_List, _, Form_Selected_Forward_Address_List, Form_RTS_Email_Subject, Form_Forward_Email_Subject, Form_RTS_Email_Body, Form_Forward_Email_Body ] ),

	(
		Form_Junk = `True`,

		sys_assertz( grammar_set( i_analyse_junk_flag ) ),

		assertz_derived_data( invoice, force_result, `defect`, i_force_defect ),

		assertz_derived_data( invoice, force_sub_result, `i_analyse_junk_flag`, i_force_sub_result ),
		trace( `***Intervention Result: Junk***` )

		;

		Form_Return_To_Sender = `True`,

		sys_retractall( result( _, invoice, return_email, _ ) ),

		sys_stringlist_concat( Form_Selected_RTS_Address_List, `,`, RTS_Addr ),

		assertz_derived_data( invoice, return_email, RTS_Addr, i_analyse_return_email ),

		assertz_derived_data( invoice, return_email_subject, Form_RTS_Email_Subject, i_analyse_return_email_subject ),

		string_string_replace( Form_RTS_Email_Body, `
`, `<br>`, Form_RTS_Email_Body_Final ),
		assertz_derived_data( invoice, return_email_body, Form_RTS_Email_Body_Final, i_analyse_return_email_body ),

		assertz_derived_data( invoice, force_result, `failed`, i_force_failed ),

		assertz_derived_data( invoice, force_sub_result, `return_to_sender`, i_force_sub_result ),

		sys_assertz( grammar_set( i_analyse_return_to_sender ) ),
		trace( `***Intervention Result: Return to Sender***` )

		;

		Form_Forward = `True`,

		sys_retractall( result( _, invoice, forward_email, _ ) ),

		sys_stringlist_concat( Form_Selected_Forward_Address_List, `,`, Forward_Addr ),

		assertz_derived_data( invoice, forward_email, Forward_Addr, i_analyse_forward_email ),

		assertz_derived_data( invoice, forward_email_subject, Form_Forward_Email_Subject, i_analyse_forward_email_subject ),

		string_string_replace( Form_Forward_Email_Body, `
`, `<br>`, Form_Forward_Email_Body_Final ),
		assertz_derived_data( invoice, forward_email_body, Form_Forward_Email_Body_Final, i_analyse_forward_email_body ),

		assertz_derived_data( invoice, force_result, `failed`, i_force_failed ),

		assertz_derived_data( invoice, force_sub_result, `forward_to_address`, i_force_sub_result ),

		sys_assertz( grammar_set( i_analyse_forward_to_address ) ),
		trace( `***Intervention Result: Forward to Email Address***` )

	),

	sys_assertz( grammar_set( ignore_enquire ) ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION RULES FILENAME CHANGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_rules_filename_change( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `questions[0].value`, Rules ),

	get_rules_file_name( Rules_file_name ),

	sys_string_length( Rules_file_name, L ),

	sys_calculate( L4, L - 4 ),

	q_sys_sub_string( Rules_file_name, 1, L4, Current_Rules ),

	!,

	Current_Rules \= Rules,

	not( chained_to( Rules ) ),

	sys_assertz( grammar_set( chain, Rules ) ),
	trace( `***Intervention Result: Chained to a new set of rules***` ),
	trace( Rules )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION DOCUMENT SCENARIO DROPDOWN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_document_scenario_dropdown( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_find_first_container( Form_In, `id`, `Quick Action`, Scenario_Array_Reference ),

	strcat_list( [ Scenario_Array_Reference, `.value` ], Scenario_Value_Field ),
	json_get( Form_In, Scenario_Value_Field, Answer ),

	Answer \= ``,

	document_scenario_dropdown( Scenario, Action, Email_Address, Error_Description_Text ),

	q_sys_sub_string( Answer, 1, _, Scenario ),

	strcat_list( [ Error_Description_Text, `<br><br>` ], Document_Error_Text_No_Breaks ),

	string_string_replace( Document_Error_Text_No_Breaks, `
`, `<br>`, Document_Error_Text ),

	strcat_list( [ `Document Not Processed - `, Scenario ], Subject ),

	beginning_text( Beginning_Text ),

	(
		Action = `Reject to Supplier`,

		sys_assertz( grammar_set( i_analyse_return_to_sender ) ),

		remaining_rejection_text( Remaining_Rejection_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Rejection_Text ], Return_Email_Body ),

		assertz_derived_data( invoice, return_email_body, Return_Email_Body, i_insert_return_email_body ),

		assertz_derived_data( invoice, return_email_subject, Subject, i_insert_return_email_subject )

		;

		Action = `Forward to Email Address`,

		sys_assertz( grammar_set( i_analyse_forward_to_address ) ),

		remaining_forward_text( Remaining_Forward_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Forward_Text ], Forward_Email_Body ),

		assertz_derived_data( invoice, forward_email_body, Forward_Email_Body, i_insert_forward_email_body ),

		assertz_derived_data( invoice, forward_email, Email_Address, i_insert_forward_email ),

		assertz_derived_data( invoice, forward_email_subject, Subject, i_insert_forward_email_subject )

		;

		Action = `Flag As Fail and Post`,

		sys_assertz( grammar_set( i_analyse_flag_as_fail_and_post ) )

		;

		Action = `Delete`,

		sys_assertz( grammar_set( i_analyse_junk_flag ) )

	),

	!,

	document_reason_lookup( Scenario, _, Sub_Result, _, _ ),

	assertz_derived_data( invoice, force_result, `failed`, i_force_result ),

	assertz_derived_data( invoice, force_sub_result, Sub_Result, i_force_sub_result ),

	sys_assertz( grammar_set( ignore_enquire ) ),

	strcat_list( [ `***Intervention Result: `, Scenario, ` - `, Action, `***` ], Trace ),
	trace( Trace ),

	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION FAILURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_failures( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	get_data_item_failures( Form_In, List_of_Header_Level_Data_Item_Failures ),

	get_line_level_data_item_failures( Form_In, List_of_Line_Level_Data_Item_Failures ),

	get_document_scenario_failures( Form_In, List_Of_Document_Scenario_Failures ),

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

		sys_assertz( grammar_set( i_analyse_return_to_sender ) ),

		remaining_rejection_text( Remaining_Rejection_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Rejection_Text ], Return_Email_Body ),

		assertz_derived_data( invoice, return_email_body, Return_Email_Body, i_insert_return_email_body ),

		assertz_derived_data( invoice, return_email_subject, Subject, i_insert_return_email_subject )

		;

		Action = `Forward to Email Address`,

		sys_assertz( grammar_set( i_analyse_forward_to_address ) ),

		remaining_forward_text( Remaining_Forward_Text ),

		strcat_list( [ Beginning_Text, Document_Error_Text, Remaining_Forward_Text ], Forward_Email_Body ),

		assertz_derived_data( invoice, forward_email_body, Forward_Email_Body, i_insert_forward_email_body ),

		assertz_derived_data( invoice, forward_email, Email_Address, i_insert_forward_email ),

		assertz_derived_data( invoice, forward_email_subject, Subject, i_insert_forward_email_subject )

	),

	assertz_derived_data( invoice, force_result, Result, i_force_result ),

	assertz_derived_data( invoice, force_sub_result, Sub_Result, i_force_sub_result ),

	sys_assertz( grammar_set( ignore_enquire ) ),

	strcat_list( [ `***Intervention Result: `, Error_Header_Text, ` - `, Action, `***` ], Trace ),
	trace( Trace ),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_data_item_failures( Form_In, List_of_Data_Item_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_data_item_failures_function( Form_In, Rows_Reference, 0, Count, [ ], List_of_Data_Item_Failures )

		;

		List_of_Data_Item_Failures = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_data_item_failures_function( Form_In, Rows_Reference, Count, Count, List_of_Data_Item_Failures, List_of_Data_Item_Failures ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_data_item_failures_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, List_of_Data_Item_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Data_Item_Field ),
	json_get( Form_In, Data_Item_Field, Data_Item_Name ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field )

	),

	json_get( Form_In, Answer_Field, Answer ),

	(
		q_sys_sub_string( Answer, 1, _, `Fail` ),

		required_data_item( Data_Item_Name, _, _, _, _, Action, Email_Address, Error_Description_Text, _, Variable, _ ),

		q_sys_member( Action, [ `Reject to Supplier`, `Forward to Email Address` ] ),

		strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),

		strcat_list( [ `Missing `, Data_Item_Name ], Error_Header_Text ),

		sys_append( Initial_List, [ ( Action, Email_Address, `failed`, Sub_Result, Error_Header_Text, Error_Description_Text ) ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_data_item_failures_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, List_of_Data_Item_Failures )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_failures( Form_In, List_of_Data_Item_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_line_level_data_item_failures_function( Form_In, Rows_Reference, 0, Count, [ ], List_of_Data_Item_Failures )

		;

		List_of_Data_Item_Failures = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_failures_function( Form_In, Rows_Reference, Count, Count, List_of_Data_Item_Failures, List_of_Data_Item_Failures ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_failures_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, List_of_Data_Item_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Data_Item_Field ),
	json_get( Form_In, Data_Item_Field, Data_Item_Name ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Missing_At_Lines_Field ),

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[4].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Missing_At_Lines_Field ),

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

	),

	json_get( Form_In, Missing_At_Lines_Field, Missing_At_Lines ),

	json_get( Form_In, Answer_Field, Answer ),

	(
		q_sys_sub_string( Answer, 1, _, `Fail` ),

		required_data_item( Data_Item_Name, _, _, _, _, Action, Email_Address, Error_Description_Text, _, Variable, _ ),

		q_sys_member( Action, [ `Reject to Supplier`, `Forward to Email Address` ] ),

		strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),

		strcat_list( [ `Missing `, Data_Item_Name, ` at lines `, Missing_At_Lines ], Error_Header_Text ),

		sys_append( Initial_List, [ ( Action, Email_Address, `failed`, Sub_Result, Error_Header_Text, Error_Description_Text ) ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_line_level_data_item_failures_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, List_of_Data_Item_Failures )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_failures( Form_In, List_Of_Document_Scenario_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Detected the below document errors:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_document_scenario_failures_function( Form_In, Rows_Reference, 0, Count, [ ], List_Of_Document_Scenario_Failures )

		;

		List_Of_Document_Scenario_Failures = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_failures_function( Form_In, Rows_Reference, Count, Count, List_Of_Document_Scenario_Failures, List_Of_Document_Scenario_Failures ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_failures_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, List_Of_Document_Scenario_Failures )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Scenario_Field ),
	json_get( Form_In, Scenario_Field, Scenario ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field ),
	json_get( Form_In, Answer_Field, Answer ),

	(
		q_sys_sub_string( Answer, 1, _, `Fail` ),

		document_scenario( Scenario, _, _, Action, Email_Address, _, Error_Description_Text, _, _, _, _, _ ),

		document_reason_lookup( Scenario, Result, Sub_Result, _, _ ),

		sys_append( Initial_List, [ ( Action, Email_Address, Result, Sub_Result, Scenario, Error_Description_Text ) ], Updated_List )

		;

		not( q_sys_sub_string( Answer, 1, _, `Fail` ) ),

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_document_scenario_failures_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, List_Of_Document_Scenario_Failures )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION BLANK QUESTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_blank_questions( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		find_unanswered_data_item_question( Form_In )

		;

		find_unanswered_line_level_data_item_question( Form_In )

		;

		find_unanswered_document_scenario_question( Form_In )

	),

	trace( `***Intervention Result: Resend to Intervention***` ),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_data_item_question( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

	strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
	json_array_count( Form_In, Rows_Reference, Count ),

	find_unanswered_data_item_question_function( Form_In, Rows_Reference, 0, Count )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_data_item_question_function( Form_In, Rows_Reference, Count, Count ):- fail.
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_data_item_question_function( Form_In, Rows_Reference, Initial_Count, Count )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field )

	),

	json_get( Form_In, Answer_Field, Answer ),

	(
		Answer = ``,

		!

		;

		Answer = `This error cannot be ignored.`,

		!

		;

		Answer = `Only customer can action.`,

		!

		;

		sys_calculate( Count_Plus_One, Initial_Count + 1 )

		-> find_unanswered_data_item_question_function( Form_In, Rows_Reference, Count_Plus_One, Count )

	)
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_line_level_data_item_question( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

	strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
	json_array_count( Form_In, Rows_Reference, Count ),

	find_unanswered_line_level_data_item_question_function( Form_In, Rows_Reference, 0, Count )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_line_level_data_item_question_function( Form_In, Rows_Reference, Count, Count ):- fail.
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_line_level_data_item_question_function( Form_In, Rows_Reference, Initial_Count, Count )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[4].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

	),

	json_get( Form_In, Answer_Field, Answer ),

	(
		Answer = ``,

		!

		;

		Answer = `This error cannot be ignored.`,

		!

		;

		Answer = `Only customer can action.`,

		!

		;

		sys_calculate( Count_Plus_One, Initial_Count + 1 )

		-> find_unanswered_line_level_data_item_question_function( Form_In, Rows_Reference, Count_Plus_One, Count )

	)
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_document_scenario_question( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_find_first_container( Form_In, `title`, `Detected the below document errors:`, Section_Reference ),

	strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
	json_array_count( Form_In, Rows_Reference, Count ),

	find_unanswered_document_scenario_question_function( Form_In, Rows_Reference, 0, Count )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_document_scenario_question_function( Form_In, Rows_Reference, Count, Count ):- fail.
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
find_unanswered_document_scenario_question_function( Form_In, Rows_Reference, Initial_Count, Count )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field ),
	json_get( Form_In, Answer_Field, Answer ),

	(
		Answer = ``,

		!

		;

		Answer = `This error cannot be ignored.`,

		!

		;

		Answer = `Only customer can action.`,

		!

		;

		sys_calculate( Count_Plus_One, Initial_Count + 1 )

		-> find_unanswered_document_scenario_question_function( Form_In, Rows_Reference, Count_Plus_One, Count )

	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION FLAG AS FAIL AND POST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_flag_as_fail_and_posts( Form_In )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	get_header_level_data_item_flag_as_fail_and_posts( Form_In, Header_Level_Data_Items_List ),

	get_line_level_data_item_flag_as_fail_and_posts( Form_In, Line_Level_Data_Items_List ),

	get_document_scenarios_flag_as_fail_and_posts( Form_In, Document_Scenarios_List ),

	(
		(
			q_sys_member( Sub_Result, Header_Level_Data_Items_List )

			;

			q_sys_member( Sub_Result, Line_Level_Data_Items_List )

			;

			q_sys_member( Sub_Result, Document_Scenarios_List )

		),

		assertz_derived_data( invoice, force_result, `failed`, i_force_failed ),

		assertz_derived_data( invoice, force_sub_result, Sub_Result, i_force_sub_result ),

		sys_assertz( grammar_set( i_analyse_flag_as_fail_and_post ) ),

		trace( `***Intervention Result: Flag As Fail and Post***` )

		;

		Header_Level_Data_Items_List = [ ],

		Line_Level_Data_Items_List = [ ],

		Document_Scenarios_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_header_level_data_item_flag_as_fail_and_posts( Form_In, Header_Level_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_header_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, 0, Count, [ ], Header_Level_Data_Items_List )

		;

		Header_Level_Data_Items_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_header_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Count, Count, Header_Level_Data_Items_List, Header_Level_Data_Items_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_header_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Header_Level_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Data_Item_Field ),
	json_get( Form_In, Data_Item_Field, Data_Item_Name ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field )

	),

	json_get( Form_In, Answer_Field, Value ),

	(
		q_sys_sub_string( Value, 1, _, `Fail` ),

		required_data_item( Data_Item_Name, _, _, _, _, `Flag As Fail and Post`, _, _, _, Variable, _ ),

		strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),

		sys_append( Initial_List, [ Sub_Result ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_header_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, Header_Level_Data_Items_List )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_flag_as_fail_and_posts( Form_In, Line_Level_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_line_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, 0, Count, [ ], Line_Level_Data_Items_List )

		;

		Line_Level_Data_Items_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Count, Count, Line_Level_Data_Items_List, Line_Level_Data_Items_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Line_Level_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Data_Item_Field ),
	json_get( Form_In, Data_Item_Field, Data_Item_Name ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[4].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

	),

	json_get( Form_In, Answer_Field, Value ),

	(
		q_sys_sub_string( Value, 1, _, `Fail` ),

		required_data_item( Data_Item_Name, _, _, _, _, `Flag As Fail and Post`, _, _, _, Variable, _ ),

		strcat_list( [ `i_analyse_missing_`, Variable ], Sub_Result ),

		sys_append( Initial_List, [ Sub_Result ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_line_level_data_item_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, Line_Level_Data_Items_List )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenarios_flag_as_fail_and_posts( Form_In, Document_Scenarios_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Detected the below document errors:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_document_scenarios_flag_as_fail_and_posts_function( Form_In, Rows_Reference, 0, Count, [ ], Document_Scenarios_List )

		;

		Document_Scenarios_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenarios_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Count, Count, Document_Scenarios_List, Document_Scenarios_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenarios_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Document_Scenarios_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Scenario_Field ),
	json_get( Form_In, Scenario_Field, Scenario ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field ),
	json_get( Form_In, Answer_Field, Value ),

	(
		q_sys_sub_string( Value, 1, _, `Fail` ),

		document_scenario( Scenario, _, _, `Flag As Fail and Post`, _, _, _, _, _, _, _, _ ),

		document_reason_lookup( Scenario, _, Sub_Result, _, _ ),

		sys_append( Initial_List, [ Sub_Result ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_document_scenarios_flag_as_fail_and_posts_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, Document_Scenarios_List )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION TRANSFERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
action_transfers( Form_In, Transferred_Intervention_Questions_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	get_data_item_transfers( Form_In, Transfer_Data_Items_List ),

	get_line_level_data_item_transfers( Form_In, Transfer_Line_Level_Data_Items_List ),

	get_document_scenario_transfers( Form_In, Transfer_Document_Scenarios_List ),

	!,

	sys_append( Transfer_Data_Items_List, Transfer_Line_Level_Data_Items_List, Transfer_Data_Items_List_Final ),

	sys_append( Transfer_Data_Items_List_Final, Transfer_Document_Scenarios_List, Transferred_Intervention_Questions_List ),

	!,

	Transferred_Intervention_Questions_List \= [ ],

	!,

	trace( `***Intervention Result: Transfer to Customer Intervention***` ),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_data_item_transfers( Form_In, Transfer_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below header level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_data_item_transfers_function( Form_In, Rows_Reference, 0, Count, [ ], Transfer_Data_Items_List )

		;

		Transfer_Data_Items_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_data_item_transfers_function( Form_In, Rows_Reference, Count, Count, Transfer_Data_Items_List, Transfer_Data_Items_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_data_item_transfers_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Transfer_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Data_Item_Field ),
	json_get( Form_In, Data_Item_Field, Data_Item_Name ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field )

	),

	json_get( Form_In, Answer_Field, Value ),

	(
		q_sys_sub_string( Value, 1, _, `Fail` ),

		required_data_item( Data_Item_Name, _, _, _, _, `Send to Customer Intervention`, _, _, _, _, _ ),

		sys_append( Initial_List, [ Data_Item_Name ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_data_item_transfers_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, Transfer_Data_Items_List )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_transfers( Form_In, Transfer_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Failed to map the below line level data items:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_line_level_data_item_transfers_function( Form_In, Rows_Reference, 0, Count, [ ], Transfer_Data_Items_List )

		;

		Transfer_Data_Items_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_transfers_function( Form_In, Rows_Reference, Count, Count, Transfer_Data_Items_List, Transfer_Data_Items_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_line_level_data_item_transfers_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Transfer_Data_Items_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	json_get( Form_In, `role`, Role ),

	(
		qq_op_param( rules_intervention_role, Rules_Intervention_Role )

		;

		Rules_Intervention_Role = `CloudTrade`

	),

	!,

	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Data_Item_Field ),
	json_get( Form_In, Data_Item_Field, Data_Item_Name ),

	(
		Role = Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Missing_At_Lines_Field ),

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[4].value` ], Answer_Field )

		;

		Role \= Rules_Intervention_Role,

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Missing_At_Lines_Field ),

		strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[3].value` ], Answer_Field )

	),

	json_get( Form_In, Missing_At_Lines_Field, Missing_At_Lines ),

	json_get( Form_In, Answer_Field, Value ),

	(
		q_sys_sub_string( Value, 1, _, `Fail` ),

		required_data_item( Data_Item_Name, _, _, _, _, `Send to Customer Intervention`, _, _, _, _, _ ),

		sys_append( Initial_List, [ Data_Item_Name ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_line_level_data_item_transfers_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, Transfer_Data_Items_List )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_transfers( Form_In, Transfer_Document_Scenarios_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		json_find_first_container( Form_In, `title`, `Detected the below document errors:`, Section_Reference ),

		strcat_list( [ Section_Reference, `.questions[0].rows` ], Rows_Reference ),
		json_array_count( Form_In, Rows_Reference, Count ),

		get_document_scenario_transfers_function( Form_In, Rows_Reference, 0, Count, [ ], Transfer_Document_Scenarios_List )

		;

		Transfer_Document_Scenarios_List = [ ]

	),

	!
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_transfers_function( Form_In, Rows_Reference, Count, Count, Transfer_Document_Scenarios_List, Transfer_Document_Scenarios_List ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
get_document_scenario_transfers_function( Form_In, Rows_Reference, Initial_Count, Count, Initial_List, Transfer_Document_Scenarios_List )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_string_number( Initial_Count_String, Initial_Count ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[0].value` ], Scenario_Field ),
	json_get( Form_In, Scenario_Field, Scenario ),

	strcat_list( [ Rows_Reference, `[`, Initial_Count_String, `].cells[2].value` ], Answer_Field ),
	json_get( Form_In, Answer_Field, Value ),

	(
		q_sys_sub_string( Value, 1, _, `Fail` ),

		document_scenario( Scenario, _, _, `Send to Customer Intervention`, _, _, _, _, _, _, _, _ ),

		sys_append( Initial_List, [ Scenario ], Updated_List )

		;

		Initial_List = Updated_List

	),

	!,

	sys_calculate( Count_Plus_One, Initial_Count + 1 )

	-> get_document_scenario_transfers_function( Form_In, Rows_Reference, Count_Plus_One, Count, Updated_List, Transfer_Document_Scenarios_List )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE DATA ITEMS QUESTIONS BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_data_items_questions_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_data_items_questions_based_on_list( Form_In, [ ( Data_Item_Name, Mapping_Logic, Mandatory_Condition, Action, Email_Address, Variable, Value ) | Remaining_Items ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		Mandatory_Condition = ``,

		Mapping_Logic = Mapping_Logic_Updated

		;

		Mandatory_Condition \= ``,

		strcat_list( [ Mapping_Logic, ` This is mandatory under the following condition: '`, Mandatory_Condition, `'.` ], Mapping_Logic_Updated )

	),

	(
		Action = `Flag As Fail and Post`,

		strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will cause it to post but flag as a fail in the portal.` ], Mapping_Logic_Final ),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Forward to Email Address`,

		strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will forward it to `, Email_Address, `.` ], Mapping_Logic_Final ),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Reject to Supplier`,

		(
			result( _, invoice, return_email, Email ),

			strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will return it to `, Email, `.` ], Mapping_Logic_Final )

			;

			strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will return it to the sender's email address.` ], Mapping_Logic_Final )

		),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Send to Customer Intervention`,

		strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will transfer it to the customer's intervention.` ], Mapping_Logic_Final ),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Will Never Be Missing`,

		strcat_list( [ Mapping_Logic_Updated, ` Documents cannot be failed for missing this data item as it should always be possible to map it.` ], Mapping_Logic_Final ),

		Options = [ ``, `Ignore error` ]

	),

	!,

	add_header_level_data_item_tabular_list_question( Data_Item_Name, Variable, Mapping_Logic_Final, Value, Options, Form_In, Form_Updated )

	-> create_data_items_questions_based_on_list( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE LINE LEVEL DATA ITEMS QUESTIONS BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_line_level_data_items_questions_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_line_level_data_items_questions_based_on_list( Form_In, [ ( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, Action, Email_Address, Variable, Value ) | Remaining_Items ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		Mandatory_Condition = ``,

		Mapping_Logic = Mapping_Logic_Updated

		;

		Mandatory_Condition \= ``,

		strcat_list( [ Mapping_Logic, ` This is mandatory under the following condition: '`, Mandatory_Condition, `'.` ], Mapping_Logic_Updated )

	),

	(
		Action = `Flag As Fail and Post`,

		strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will cause it to post but flag as a fail in the portal.` ], Mapping_Logic_Final ),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Forward to Email Address`,

		strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will forward it to `, Email_Address, `.` ], Mapping_Logic_Final ),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Reject to Supplier`,

		(
			result( _, invoice, return_email, Email ),

			strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will return it to `, Email, `.` ], Mapping_Logic_Final )

			;

			strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will return it to the sender's email address.` ], Mapping_Logic_Final )

		),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Send to Customer Intervention`,

		strcat_list( [ Mapping_Logic_Updated, ` Failing the document for missing this data item will transfer it to the customer's intervention.` ], Mapping_Logic_Final ),

		Options = [ ``, `Fail`, `Ignore error` ]

		;

		Action = `Will Never Be Missing`,

		strcat_list( [ Mapping_Logic_Updated, ` Documents cannot be failed for missing this data item as it should always be possible to map it.` ], Mapping_Logic_Final ),

		Options = [ ``, `Ignore error` ]

	),

	!,

	add_line_level_data_item_tabular_list_question( Data_Item_Name, Variable, Mapping_Logic_Final, Missing_At_Lines, Value, Options, Form_In, Form_Updated )

	-> create_line_level_data_items_questions_based_on_list( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE CUSTOMER DATA ITEMS QUESTIONS BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_customer_data_items_questions_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_customer_data_items_questions_based_on_list( Form_In, [ ( Data_Item_Name, Mapping_Logic, Mandatory_Condition, Value ) | Remaining_Items ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		Mandatory_Condition = ``,

		Mapping_Logic = Mapping_Logic_Final

		;

		Mandatory_Condition \= ``,

		strcat_list( [ Mapping_Logic, ` This is mandatory under the following condition: '`, Mandatory_Condition, `'.` ], Mapping_Logic_Final )

	),

	add_customer_header_level_data_item_tabular_list_question( Data_Item_Name, Mapping_Logic_Final, Value, [ ``, `Ignore error` ], Form_In, Form_Updated )

	-> create_customer_data_items_questions_based_on_list( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE CUSTOMER DATA ITEMS QUESTIONS BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_customer_line_level_data_items_questions_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_customer_line_level_data_items_questions_based_on_list( Form_In, [ ( Data_Item_Name, Mapping_Logic, Missing_At_Lines, Mandatory_Condition, Value ) | Remaining_Items ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		Mandatory_Condition = ``,

		Mapping_Logic = Mapping_Logic_Final

		;

		Mandatory_Condition \= ``,

		strcat_list( [ Mapping_Logic, ` This is mandatory under the following condition: '`, Mandatory_Condition, `'.` ], Mapping_Logic_Final )

	),

	add_customer_line_level_data_item_tabular_list_question( Data_Item_Name, Mapping_Logic_Final, Missing_At_Lines, Value, [ ``, `Ignore error` ], Form_In, Form_Updated )

	-> create_customer_line_level_data_items_questions_based_on_list( Form_Updated, Remaining_Items, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE DOCUMENT SCENARIO QUESTIONS BASED ON LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_document_scenario_questions_based_on_list( Form, [ ], Form ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create_document_scenario_questions_based_on_list( Form_In, [ ( Scenario, Description, Question_ID, Question_Type, Question_Options, Question_Ignore, Question_Role, Value ) | Remaining_Scenarios ], Form_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	(
		Question_Type = `Dropdown List`,

		sys_string_split( Question_Options, `|`, List_of_Options ),

		sys_append( [ `` ], List_of_Options, Options_List ),

		add_document_scenario_tabular_list_question( Scenario, Description, Value, Options_List, Question_Ignore, Question_Role, Form_In, Form_Updated )

		% ;

		% Question_Type = `Text Box`,

		% add_document_scenario_tabular_text_question( Scenario, Description, Value, Question_ID, Form_In, Form_Updated )

	)

	-> create_document_scenario_questions_based_on_list( Form_Updated, Remaining_Scenarios, Form_Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I FORCE LIST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
i_force_list( List_In, List_Out )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	q_sys_is_list( List_In )

	-> List_In = List_Out

	;

	[ List_In ] = List_Out
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL INTERVENTION FORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_initial_intervention_form( `

{
	"question_type": "customer_enquire"
    , "name": ""
    , "answered": false
	, "ignored_rules_intervention_questions": []
	, "ignored_customer_intervention_questions": []
	, "transferred_intervention_questions": []
    , "role": "cloudtrade"
    , "reason": "reason"
    , "long_reason": "long_reason"
    , "from_address": ""
    , "return_to_sender": false
    , "forward": false
    , "unrecognised": false
    , "junk": false
	, "return_to_sender_address_options": []
    , "selected_return_to_sender_addresses": []
    , "forward_address_options": []
    , "selected_forward_addresses": []
    , "return_to_sender_email_subject": ""
    , "forward_email_subject": ""
    , "return_to_sender_email_body": ""
    , "forward_email_body": ""
    , "questions": []
}

` ).

i_initial_completion_form( `

{
    "caption": ""
	, "include_all_but": [ "dummy_variable_that_has_to_be_here" ]
	, "group": []
}

` ).
