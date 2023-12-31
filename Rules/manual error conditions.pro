%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MANUAL ERROR CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( manual_error_conditions, `06/11/2019 09:45:53` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DOCUMENT SCENARIOS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
% Empty
%-----------------------------------------------------------------------
i_error_empty
:-
	not( any_lines_present ),
	not( extraction_error( _, _ ) )
.

%-----------------------------------------------------------------------
% PDF Error
%-----------------------------------------------------------------------
i_error_pdf_error
:-
	extraction_error( pdf_error, Error ),
	not( q_sys_sub_string( Error, _, _, `System.OutOfMemory` ) )
.

%-----------------------------------------------------------------------
% Unsupported File Type
%-----------------------------------------------------------------------
i_error_unsupported_file_type
:-
	extraction_error( unsupported( _ ), _ )
.

%-----------------------------------------------------------------------
% Too Big
%-----------------------------------------------------------------------
i_error_too_big
:-
	extraction_error( too_big( _ ), _ )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% HEADER LEVEL DOCUMENT SCENARIOS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
% Missing Data Item
%-----------------------------------------------------------------------
i_error_missing_data_item( Data_item )
:-
	not( result( _, invoice, Data_item, _ ) ),
	not( result( _, LID, Data_item, _ ) ),
	!
.

%-----------------------------------------------------------------------
% Missing Order Number
%-----------------------------------------------------------------------
i_error_missing_order_number
:-
	not( result( _, invoice, order_number, _ ) ),
	!
.

%-----------------------------------------------------------------------
% Missing Invoice Number
%-----------------------------------------------------------------------
i_error_missing_invoice_number
:-
	not( result( _, invoice, invoice_number, _ ) ),
	!
.

%-----------------------------------------------------------------------
% Missing Invoice Date
%-----------------------------------------------------------------------
i_error_missing_invoice_date
:-
	not( result( _, invoice, invoice_date, _ ) ),
	!
.

%-----------------------------------------------------------------------
% VAT Without VAT Number
%-----------------------------------------------------------------------
i_error_vat_without_vat_number
:-
	result( _, invoice, total_vat, VAT ),
	not( q_sys_comp_str_eq( VAT, `0` ) ),
	not( result( _, invoice, supplier_vat_number, _ ) ),
	!
.

%-----------------------------------------------------------------------
% Negative Totals
%-----------------------------------------------------------------------
i_error_negative_totals
:-
	not( grammar_set( credit_note ) ),
	(
		result( _, invoice, total_net, Total )
		;
		result( _, invoice, total_invoice, Total )
	),
	q_sys_comp_str_gt( `0`, Total ),
	!
.

%-----------------------------------------------------------------------
% Missing Totals
%-----------------------------------------------------------------------
i_error_missing_totals
:-
	(
		not( result( _, invoice, total_net, _ ) ),
		(
			not( result( _, invoice, total_vat, _ ) )
			;
			not( result( _, invoice, total_invoice, _ ) )
		)
		
		;
		
		not( result( _, invoice, total_vat, _ ) ),
		not( result( _, invoice, total_invoice, _ ) )

	),
	!
.

%-----------------------------------------------------------------------
% Invoice Totals Inconsistent
%-----------------------------------------------------------------------
i_error_invoice_totals_inconsistent:- i_error_invoice_totals_inconsistent( `0` ).

i_error_invoice_totals_inconsistent( Tolerance )
:-
	result( _, invoice, total_net, Net ),
	result( _, invoice, total_vat, VAT ),
	result( _, invoice, total_invoice, Total ),
	(
		result( _, invoice, total_advance_amount, Total_Advance_Amount )
		;
		not( result( _, invoice, total_advance_amount, _ ) ),
		Total_Advance_Amount = `0`
	),
	!,
	(
		result( _, invoice, rounding_amount, Rounding_Amount )
		;
		not( result( _, invoice, rounding_amount, _ ) ),
		Rounding_Amount = `0`
	),
	!,
	sys_calculate_str_add( Net, VAT, Sum ),
	sys_calculate_str_add( Sum, Total_Advance_Amount, Sum_Advance ),
	sys_calculate_str_add( Sum_Advance, Rounding_Amount, Sum_Final ),
	sys_calculate_str_subtract( Total, Sum_Final, Diff ),
	
	(
		q_sys_comp_str_gt( `0`, Diff ),
		sys_calculate_str_multiply( Diff, `-1`, Difference )
		
		;
		
		Diff = Difference
		
	),
	
	q_sys_comp_str_gt( Difference, Tolerance ),
	!
.

%-----------------------------------------------------------------------
% No Lines
%-----------------------------------------------------------------------
i_error_missing_lines
:-
	not( i_error_empty ),
	not( i_error_pdf_error ),
	not( i_error_unsupported_file_type ),
	not( i_error_too_big ),
	not( missed_data_items_condition ),

	not( result( _, LID, line_net_amount, _ ) ),
	not( result( _, LID, line_total_amount, _ ) ),
	not( result( _, LID, line_quantity, _ ) ),
	not( result( _, LID, line_unit_amount, _ ) ),
	!
.

%-----------------------------------------------------------------------
% Positive and Negative Lines
%-----------------------------------------------------------------------
i_error_positive_and_negative_lines
:-
	(
		result( _, LID, line_net_amount, Pos )
		
		;
		
		result( _, LID, line_total_amount, Pos )
		
	),
	
	sys_string_number( Pos, _ ),
	
	q_sys_comp_str_gt( Pos, `0` ),
	
	!,
	
	(
		result( _, LID_1, line_net_amount, Neg )
		
		;
		
		result( _, LID_1, line_total_amount, Neg )

	),
	
	q_sys_comp_str_lt( Neg, `0` )
.

%-----------------------------------------------------------------------
% Zero Value Invoice
%-----------------------------------------------------------------------
i_error_zero_value_invoice
:-
	result( _, invoice, total_net, Total_net ),
	result( _, invoice, total_invoice, Total ),
	q_sys_comp_str_eq( `0`, Total_net ),
	q_sys_comp_str_eq( `0`, Total ),
	!
.

%-----------------------------------------------------------------------
% Sum Net Discrepancy
%-----------------------------------------------------------------------
i_error_sum_net_discrepancy:- i_error_sum_net_discrepancy( `0.01` ).

i_error_sum_net_discrepancy( Tolerance ):- i_error_sum_net_discrepancy( _, _, Tolerance ).

i_error_sum_net_discrepancy( Sum_of_nets, Total_net ):- i_error_sum_net_discrepancy( Sum_of_nets, Total_net, `0.01` ).

i_error_sum_net_discrepancy( Sum_of_nets, Total_net, Tolerance )
:-
	not( qq_op_param( us_invoice, _ ) ),
	sys_findall(
		Net,
		(
			result( _, LID, line_net_amount, Net ),
			sys_string_number( Net, _ ),
			not( result( _, LID, line_type, _ ) )
		),
		List_of_nets_Raw
	),
	
	i_force_list( List_of_nets_Raw, List_of_nets ),
	
	i_user_check( sum_string_list, List_of_nets, Sum_of_nets ),
	
	(
		i_correlate_amounts_total_to_use( total_net, Variable )
		-> result( _, invoice, Variable, Total_net )
		;
		result( _, invoice, total_net, Total_net )
	),
	
	!,
	
	sys_calculate_str_subtract( Total_net, Sum_of_nets, Diff ),
	
	(
		q_sys_comp_str_gt( `0`, Diff ),
		sys_calculate_str_multiply( Diff, `-1`, Difference )
		
		;
		
		Diff = Difference
		
	),
	
	q_sys_comp_str_gt( Difference, Tolerance ),
	
	strcat_list( [ `Total Net: `, Total_net, `, Sum of Line Nets: `, Sum_of_nets, `, Difference: `, Diff ], Trace ),
	
	trace( [ Trace ] ),
	
	!
.

%-----------------------------------------------------------------------
% Sum Total Discrepancy
%-----------------------------------------------------------------------
i_error_sum_total_discrepancy:- i_error_sum_total_discrepancy( `0.01` ).

i_error_sum_total_discrepancy( Tolerance ):- i_error_sum_total_discrepancy( _, _, Tolerance ).

i_error_sum_total_discrepancy( Sum_of_totals, Total_invoice ):- i_error_sum_total_discrepancy( Sum_of_totals, Total_invoice, `0.01` ).

i_error_sum_total_discrepancy( Sum_of_totals, Total_invoice, Tolerance )
:-
	sys_findall(
		Total,
		(
			result( _, LID, line_total_amount, Total ),
			sys_string_number( Total, _ ),
			(
				not( result( _, LID, line_type, _ ) )
				;
				result( _, LID, line_type, _ ),
				qq_op_param( us_invoice, _ )
			)
		),
		List_of_totals_Raw
	),
	
	i_force_list( List_of_totals_Raw, List_of_totals ),
	
	i_user_check( sum_string_list, List_of_totals, Sum_of_totals ),
	
	(
		result( _, invoice, total_advance_amount, Total_Advance_Amount )
		;
		not( result( _, invoice, total_advance_amount, _ ) ),
		Total_Advance_Amount = `0`
	),
	
	!,
	
	sys_calculate_str_add( Sum_of_totals, Total_Advance_Amount, Sum_of_totals_advance ),
	
	(
		result( _, invoice, rounding_amount, Rounding_Amount )
		;
		not( result( _, invoice, rounding_amount, _ ) ),
		Rounding_Amount = `0`
	),
	
	!,
	
	sys_calculate_str_add( Sum_of_totals_advance, Rounding_Amount, Sum_of_totals_rounding ),
	
	(
		result( _, invoice, header_discount, Header_Discount )
		;
		not( result( _, invoice, header_discount, _ ) ),
		Header_Discount = `0`
	),
	
	!,
	
	sys_calculate_str_subtract( Sum_of_totals_rounding, Header_Discount, Sum_of_totals_rounding_discount ),
	
	(
		qq_op_param( us_invoice, _ ),
		sys_findall(
			Line_VAT,
			(
				result( _, LID, line_vat_amount, Line_VAT ),
				sys_string_number( Line_VAT, _ )
			),
			List_of_VATs_Raw
		),
		i_force_list( List_of_VATs_Raw, List_of_VATs ),
		i_user_check( sum_string_list, List_of_VATs, Sum_of_VATs ),
		result( _, invoice, total_vat, VAT ),
		sys_calculate_str_subtract( VAT, Sum_of_VATs, VAT_Diff ),
		sys_calculate_str_add( Sum_of_totals_rounding_discount, VAT_Diff, Sum_of_totals_final )
		;
		Sum_of_totals_rounding_discount = Sum_of_totals_final
	),
	
	!,
	
	(
		i_correlate_amounts_total_to_use( total_invoice, Variable )
		-> result( _, invoice, Variable, Total_invoice )
		;
		result( _, invoice, total_invoice, Total_invoice )
	),
	
	!,
	
	sys_calculate_str_subtract( Total_invoice, Sum_of_totals_final, Diff ),
	
	(
		q_sys_comp_str_gt( `0`, Diff ),
		sys_calculate_str_multiply( Diff, `-1`, Difference )
		
		;
		
		Diff = Difference
		
	),

	q_sys_comp_str_gt( Difference, Tolerance ),
	
	strcat_list( [ `Total Invoice: `, Total_invoice, `, Sum of Line Totals: `, Sum_of_totals_final, `, Difference: `, Diff ], Trace ),
	
	trace( [ Trace ] ),

	!
.

%-----------------------------------------------------------------------
% Quantity Times Unit Amount Not Equal to Net Amount
%-----------------------------------------------------------------------
i_error_quantity_and_unit_and_net_amounts_inconsistent:- i_error_quantity_and_unit_and_net_amounts_inconsistent( `0.01` ).

i_error_quantity_and_unit_and_net_amounts_inconsistent( Tolerance ):- i_error_quantity_and_unit_and_net_amounts_inconsistent( _, Tolerance ).

%-----------------------------------------------------------------------
% Zero Value Line
%-----------------------------------------------------------------------
i_error_zero_value_line:- i_error_zero_value_line( _ ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LINE LEVEL DOCUMENT SCENARIOS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
% Quantity Times Unit Amount Not Equal to Net Amount
%-----------------------------------------------------------------------
i_error_quantity_and_unit_and_net_amounts_inconsistent( LID, Tolerance )
:-
	result( _, LID, line_quantity, Qty ),
	sys_string_number( Qty, _ ),
	result( _, LID, line_unit_amount, Unit ),
	sys_string_number( Unit, _ ),
	result( _, LID, line_net_amount, Net ),
	sys_string_number( Net, _ ),

	(
		result( _, LID, line_amount_discount, Discount )
		;
		not( result( _, LID, line_amount_discount, _ ) ),
		Discount = `0`
	),

	(
		result( _, LID, line_price_uom_code, Price_UOM ),
		q_sys_member( Price_UOM, [ `100`, `1000` ] )
		;
		(
			not( result( _, LID, line_price_uom_code, _ ) )
			;
			result( _, LID, line_price_uom_code, UOM ),
			not( q_sys_member( UOM, [ `100`, `1000` ] ) )
		),
		Price_UOM = `1`
	),

	sys_calculate_str_multiply( Qty, Unit, Qty_unit ),
	sys_calculate_str_divide( Qty_unit, Price_UOM, Qty_unit_final ),
	sys_calculate_str_subtract( Qty_unit_final, Discount, Qty_unit_after_discount ),
	sys_calculate_str_subtract( Qty_unit_after_discount, Net, Diff ),

	(
		q_sys_comp_str_gt( `0`, Diff ),
		sys_calculate_str_multiply( Diff, `-1`, Difference )
		;
		q_sys_comp_str_le( `0`, Diff ),
		Diff = Difference
	),

	q_sys_comp_str_gt( Difference, Tolerance ),

	sys_string_number( LID_S, LID ),

	(
		Price_UOM = `1`,
		Price_UOM_Trace = ``
		;
		Price_UOM \= `1`,
		strcat_list( [  `, Price_UOM: `, Price_UOM ], Price_UOM_Trace )
	),

	(
		Discount = `0`,
		Discount_Trace = ``
		;
		Discount \= `0`,
		strcat_list( [  `, Discount: `, Discount ], Discount_Trace )
	),

	strcat_list( [ `Line `, LID_S, ` - Qty: `, Qty, `, Unit: `, Unit, Price_UOM_Trace, Discount_Trace, `, Net: `, Net ], Trace ),
	
	trace( [ Trace ] )
.

%-----------------------------------------------------------------------
% Zero Value Line
%-----------------------------------------------------------------------
i_error_zero_value_line( LID )
:-
	(
		result( _, LID, line_net_amount, Amount )
		
		;
		
		not( result( _, LID, line_net_amount, _ ) ),
		result( _, LID, line_total_amount, Amount )
		
	),
	
	q_sys_comp_str_eq( Amount, `0` )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PREDICATES
%
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
