%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - INVOICE EXAMPLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( invoice_example, `03/08/2016 13:17:29` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_date_format( _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		
	get_order_number


] ). % Drop the PDF into the RDE, and write "invoice b" in the Chain File page to perform Page Classfication
	% Delete the full stop on the above line, save this file and run another Page Classification.
	% The rules file now has a syntax error and the RDE will display an error message
	% A syntax error means that the rules have not been written correctly.
	 % copy and paste this " i_trace_lists. " and paste it below "i_date_format( _ )."
	% Save this rules file again and run another Page Classification
	 % it should now tell you that the syntax error is on line 21. Put back the missing full stop and save the file again (ctrl+S)
	 % Run a Page Classification and watch the file now process properly.

	 % This is a syntax error, when you write rules you have to write them correctly or you will see these errors. Use i_trace_lists. to help you find where your errors are to fix them.
	 % There is also a syntax error linter in the VSC-Prolog extension that will put a red line under any syntax errors

	 % Rules Requests behave slightly differently for syntax errors - this part of processing ignores the part of your logic with a syntax error
	 % If you repeat the above steps with Rules Requests rather than Page Classification, you will find that the RDE fails to run the rule get_order_number when there is a syntax error

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q(0,10,line)

	, get_order_number_line
	
] ).

%=======================================================================
i_line_rule( get_order_number_line, [
%=======================================================================
 
	q0n(anything) , `order`,  `no`,  `:` , tab , generic_item( [ order_number , s1 , newline ] )
    
] ).
