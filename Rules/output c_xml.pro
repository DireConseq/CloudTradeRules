
i_version( output_c_xml, `21/11/2019 14:33:39` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	16/10/2014
%		-	Added SupplierList into the purchase order XML
%		-	operated with i_op_param 'supplier_list_extension'
%
%	04/11/2014
%		-	Added SupplierID tag - currently populated by 'DUMMY' as it has no use
%			But is mandatory for the system (?!!)
%
%	17/11/201426/07/2018 15:52:30
%		-	Added a check to prevent single extrinsics being written multiple times
%
%	26/11/2014
%		-	Fixed Bug with line level extrinsics being suppressed.
%
%	12/01/2014
%		-	Added an option to reverse the way the extrinsics are written in a multi extrinsic
%			- Activated with the flag reverse_extrinsics
%
%	15/04/2015
%		-	Added buyer_vat_number
%
%	15/06/2016
%		-	Added DocType population
%
%	20/07/2016
%		-	New i_op_params
%			-	force_payment_and_weight_to_disappear - set to true
%			-	c_xml_request_attributes - set to true
%			-	c_xml_remove_vatrecoverable - set to true
%			-	force_c_xml_invoice_shared_secret - set to string value
%			-	force_c_xml_doctype - set to string value
%
%			-	set( cxml_shipping_information_at_header )
%				-	Moves shipping information to header level - non-standard for CXML
%
%	22/08/2016
%		-	ShipTo and ShipFrom are now in their own section at header level - not considered part of the 'InvoicePartner' section
%
%	23/08/2016
%		-	Further Additions to the structure (hidden in the qq_op_param)
%		-	Ability to alter the language of the document - currently global
%
%	24/01/2017
%		-	Additional i_op_params
%			-	c_xml_include_payment_terms
%			-	c_xml_set_accounting_in_line_indicator
%			-	c_xml_set_special_handling_in_line_indicator
%
%	06/02/2017
%		-	Additional i_op_params
%			-	c_xml_include_tax_point_date_attribute_in_tax_detail_header
%			-	c_xml_include_tax_point_date_attribute_in_tax_detail_line
%
%	13/03/2017
%		-	Additional i_op_params (true to enable)
%			-	c_xml_disable_idreference_population
%			-	c_xml_suppress_document_reference
%			-	c_xml_include_invoice_origin
%			-	c_xml_use_orderidinfo_label
%		-	Additional i_op_params (variable specification)
%			-	c_xml_separate_supplier_id_and_vat_number
%			-	c_xml_separate_buyer_id_and_vat_number
%
%	02/11/2017
%		-	Additional i_op_param (true to enable)
%			-	c_xml_sap_change_payload_id
%
%	10/01/2018
%		-	Additional i_op_param
%			-	c_xml_supplier_party_role_name - the string value that the role name should take
%			-	c_xml_hide_shipping_amount_if_zero - true to enable
%		-	Extrinsic Modification
%			-	Extrinsics can now contain compound segments
%
%	17/01/2018
%		-	Additional i_op_param
%			-	c_xml_purpose - Sets the value of the document purpose
%
%	02/02/2018
%		-	Extrinsics Within InvoicePartner
%
%	16/02/2018
%		-	Introduced c_xml_convert_negative_lines_to_allowances
%			-	When true the allowance segment is created (basic)
%
%	26/02/2018
%		-	Added description segment to modification area
%
%	19/03/2018
%		-	New op param - c_xml_order_include_customer_comments
%			-	Included comments tag
%
%	23/03/2018
%		-	New op param - c_xml_order_include_url
%			-	Included URL tag
%		-	New op param - c_xml_order_contact_role_name
%			-	Includes role attribute in contact tag
%
%	10/04/2018
%		-	New op param - c_xml_mark_exempt_lines_as_exempt
%			-	Marks lines with zero vat rate as exempt
%		-	Flag - reverse_charge
%			-	Includes some additional text (tax_information) in the tax segments
%
%	13/04/2018
%		-	New op param - c_xml_include_additional_charges_from_line_type
%			-	Creates
%		-	Flag - reverse_charge
%			-	Includes some additional text (tax_information) in the tax segments
%
%	24/04/2018
%		-	Modification to handle negative allowances, not percents
%
%	20/06/2018
%		-	US Variation - c_xml_us_invoice_variant
%			-	Tax Summary will be created based on header values only
%		-	c_xml_include_discount_if_not_zero
%			-	Populates the discount segment if needed
%		-	New variables for 'detailed_payment_terms'
%
%	18/10/2018
%		-	wireReceivingBank can now be populated
%			-	i_op_param - c_xml_include_wire_receiving_bank
%		-	Alternative trigger for header shipping
%			-	i_op_param - c_xml_shipping_information_at_header
%			-	Customisation to allow for specific variables for the 'from' and 'remit to' partners
%				- i_op_param - c_xml_remit_to_partner_use_remit_to_variables
%				- i_op_param - c_xml_from_partner_use_remit_to_variables
%				- The variables require i_user_fields
%
%	02/11/2018
%		-	wireReceivingBank segments only appear if present
%
%	05/11/2019
%		-	Change already_written/3 predicate to instead wrap in i_user_check
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_output( Checksum, VAT_totals, Version )
%-------------------------------------------------------------------------------
:- d1( write_output___( Checksum, VAT_totals, Version ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_output___( Checksum, VAT_totals, Version )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	sys_cntr_get( 0, Num_lines_plus_one ),

	sys_calculate( Num_lines, Num_lines_plus_one - 1 ),

	sys_length( VAT_totals, Num_tax_lines ),

	write_start,

	write_head( Checksum, Version ),

	write_start_element( `Request` ),

		( qq_op_param( c_xml_request_deployment_attribute_string, String )
			->	write_attribute_string( `deploymentMode`, String )

			;	true
		),

		write_body( VAT_totals ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_start
%-------------------------------------------------------------------------------
:- d1( write_start___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_start___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	(
		qq_op_param( force_c_xml_doctype, DocType )

		->	write_doctype( `cXML`, DocType )

		;

		qq_op_param( elcom_c_xml_extensions, _ )

		->	write_doctype( `cXML`, `http://xml.cxml.org/schemas/cXML/1.2.014/InvoiceDetail.dtd` )

		;

		true

	),

	write_start_element( `cXML` ),

	write_english_language_attribute,

	write_attribute_string(`version`, `1.2.014`),

	( grammar_set( cxml_set_payload_id_to_blank )
		-> Expected_output_file = ``

		; qq_op_param( c_xml_sap_change_payload_id, true )
			->	get_i_mail_expected_output_file( Expected_output_file_Raw ),
				strcat_list( [ Expected_output_file_Raw, `-1` ], Expected_output_file )

		;

		get_i_mail_expected_output_file( Expected_output_file )

	),

	write_processed_attribute_string( i_mail( expected_output_file_name ), `payloadID`, Expected_output_file ),

	date_get( today, Date ),

	string_date( DateS, Date ), % uses my method

	time_get( now, Time ),

	time_string( Time, TimeS ), % uses method in date_time.pro

	strcat_list( [ DateS, `T`, TimeS, `-00:00` ], Time_stamp ),

	write_processed_attribute_string( time( now ), `timestamp`, Time_stamp )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_head( Checksum, Version )
%-------------------------------------------------------------------------------
:- d1( write_head___( Checksum, Version ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_head___( Checksum, Version )
%-------------------------------------------------------------------------------
:-	not( grammar_set( purchase_order ) ),
	qq_op_param( elcom_c_xml_extensions, _ ),
%===============================================================================

	write_start_element( `Header` ),

		write_start_element( `From` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_1, `domain` ),

				write_variable_as_tag( invoice, buyers_code_for_supplier, `Identity` ),

			write_end_element,

		write_end_element,

		write_start_element( `To` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_2, `domain` ),

				write_variable_as_tag( invoice, suppliers_code_for_buyer, `Identity` ),

			write_end_element,

		write_end_element,

		write_start_element( `Sender` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_3, `domain` ),

				write_variable_as_tag( invoice, supplier_registration_number, `Identity` ),

   			write_start_element( `SharedSecret` ),

					(	qq_op_param( c_xml_shared_secret, SS )

						-> write_string_value_only( c_xml_shared_secret, SS )

						;	write_string_value_only( c_xml_shared_secret, `` )
					),

				write_end_element,

			write_end_element,

	   	write_config_as_tag( software_manufacturer, `UserAgent` ),

		write_end_element,

	write_end_element
.

%===============================================================================
write_head___( Checksum, Version )
%-------------------------------------------------------------------------------
:-	not( grammar_set( purchase_order ) ),
%===============================================================================

	write_start_element( `Header` ),

		write_start_element( `From` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_1, `domain` ),

				write_variable_as_tag( invoice, buyers_code_for_supplier, `Identity` ),

			write_end_element,

			( qq_op_param( force_payment_and_weight_to_disappear, _ )
				->	true

				;	write_start_element( `Credential` ),

						write_attribute_string( `domain`, `PaymentTerms` ),

						write_variable_as_tag( invoice, payment_terms, `Identity` ),

					write_end_element,

					write_start_element( `Credential` ),

						write_attribute_string( `domain`, `TotalWeight` ),

						write_variable_as_tag( invoice, total_weight, `Identity` ),

					write_end_element
			),

		write_end_element,

		write_start_element( `To` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_2, `domain` ),

				write_variable_as_tag( invoice, suppliers_code_for_buyer, `Identity` ),

			write_end_element,

		write_end_element,

		write_start_element( `Sender` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_3, `domain` ),

				write_variable_as_tag( invoice, supplier_registration_number, `Identity` ),

				(	(	qq_op_param( force_c_xml_invoice_shared_secret, SS )

						;	result( _, invoice, c_xml_shared_secret, SS )

					)

					->	write_start_element( `SharedSecret` ),

							write_string_value_only( c_xml_shared_secret, SS ),

						write_end_element

					;	true

				),

			write_end_element,

	   	write_config_as_tag( software_manufacturer, `UserAgent` ),

		write_end_element,

	write_end_element
.

%===============================================================================
write_head___( Checksum, Version )
%-------------------------------------------------------------------------------
:-	grammar_set( purchase_order ),
%===============================================================================

	write_start_element( `Header` ),

		write_start_element( `From` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_1, `domain` ),

				write_variable_as_tag( invoice, buyers_code_for_buyer, `Identity` ),

			write_end_element,

		write_end_element,

		write_start_element( `To` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_2, `domain` ),

				write_variable_as_tag( invoice, buyers_code_for_supplier, `Identity` ),

			write_end_element,

		write_end_element,

		write_start_element( `Sender` ),

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_3, `domain` ),

				write_variable_as_tag( invoice, supplier_registration_number, `Identity` ),

   			write_start_element( `SharedSecret` ),

					( qq_op_param( c_xml_shared_secret, SS )

						->	write_string_value_only( c_xml_shared_secret, SS )

						;	write_string_value_only( c_xml_shared_secret, `` )
					),

				write_end_element,

			write_end_element,

			write_start_element( `Credential` ),

				write_variable_as_attribute( invoice, agent_code_4, `domain` ),

				write_variable_as_tag( invoice, agent_code_5, `Identity` ),

   			write_start_element( `SharedSecret` ),

					( qq_op_param( c_xml_shared_secret, SS )

						->	write_string_value_only( c_xml_shared_secret, SS )

						;	write_string_value_only( c_xml_shared_secret, `` )
					),

				write_end_element,

			write_end_element,

	   	write_config_as_tag( software_manufacturer, `UserAgent` ),

		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_body( VAT_totals )
%-------------------------------------------------------------------------------
:- d1( write_body___( VAT_totals ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_body___( VAT_totals )
%-------------------------------------------------------------------------------
:-	not( grammar_set( purchase_order ) ),
%===============================================================================

	( qq_op_param( c_xml_request_attributes, true )
		->	write_attribute_string( `Id`, `cXMLData` ),
			( grammar_set( test_flag )
				->	write_attribute_string( `deploymentMode`, `test` )
				;	true
			)
		;	true
	),

	write_start_element( `InvoiceDetailRequest` ),

		write_invoice_detail_request_header,

		write_request_invoice_detail_order,

		write_request_invoice_detail_summary( VAT_totals ),

	write_end_element
.

%===============================================================================
write_body___( VAT_totals )
%-------------------------------------------------------------------------------
:-	grammar_set( purchase_order ),
%===============================================================================

	write_start_element( `OrderRequest` ),

		write_purchase_order_request_header,

		write_lines( write_purchase_order_line ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_invoice_detail_request_header
%-------------------------------------------------------------------------------
:- d1( write_invoice_detail_request_header___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_invoice_detail_request_header___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `InvoiceDetailRequestHeader` ),
		write_variable_as_attribute( invoice, invoice_number, `invoiceID` ),

		( qq_op_param( c_xml_purpose, Type ),
			q_sys_is_string( Type )
			->	write_attribute_string( `purpose`, Type )
			;	grammar_set( credit_note )
				->	write_attribute_string( `purpose`, `creditMemo` )
			;	grammar_set( debit_note )
				->	write_attribute_string( `purpose`, `lineLevelDebitMemo` )
			;	write_attribute_string( `purpose`, `standard` )
		),

		write_attribute_string( `operation`, `new` ),

		( result( _, invoice, date, Date )
			->	write_date_as_attribute( `invoiceDate`, Date )
			;	date_get( today, Date ),
				write_date_as_attribute( `invoiceDate`, Date )
		),

		( qq_op_param( c_xml_include_invoice_origin, true )
			->	write_attribute_string( `invoiceOrigin`, `supplier` )
			;	true
		),

		write_start_element( `InvoiceDetailHeaderIndicator` ),

			( qq_op_param( c_xml_remove_vatrecoverable, true )
				->	true
				;	write_attribute_string( `isVatRecoverable`, `yes` )
			),

		write_end_element,

		write_start_element( `InvoiceDetailLineIndicator` ),

			( qq_op_param( c_xml_set_accounting_in_line_indicator, true )
				->	write_attribute_string( `isAccountingInLine`, `yes` )
				;	true
			),
			( qq_op_param( c_xml_set_special_handling_in_line_indicator, true )
				->	write_attribute_string( `isSpecialHandlingInLine`, `yes` )
				;	true
			),

			( qq_op_param( c_xml_us_invoice_variant, true )
				->	true
				;	write_attribute_string( `isTaxInLine`, `yes` )
			),

		write_end_element,

		( qq_op_param( c_xml_separate_supplier_id_and_vat_number, SupplierID )
			->	true
			;	SupplierID = supplier_vat_number
		),
		( qq_op_param( c_xml_supplier_party_role_name, SupplierRole )
			->	true
			;	SupplierRole = `issuerOfInvoice`
		),

		write_invoice_partner( SupplierRole, supplier_party, SupplierID, supplier_contact, supplier_address_line,
			supplier_street, supplier_city, supplier_state, supplier_postcode, supplier_country_code, supplier_ddi, supplier_email ), 

		( qq_op_param( c_xml_separate_buyer_id_and_vat_number, BuyerID )
			->	true
			;	BuyerID = buyer_vat_number
		),
		write_invoice_partner( `soldTo`, buyer_party, BuyerID, buyer_contact, buyer_address_line,
			buyer_street, buyer_city, buyer_state, buyer_postcode, buyer_country_code, buyer_ddi, buyer_email ),

		write_invoice_partner( `billTo`, invoice_to_party, none, invoice_to_contact, invoice_to_address_line,
			invoice_to_street, invoice_to_city, invoice_to_state, invoice_to_postcode, invoice_to_country_code, invoice_to_ddi, invoice_to_email ),

		( qq_op_param( c_xml_require_bill_from, BillFrom ),
			write_invoice_partner( `billFrom`, invoice_from_party, none, invoice_from_contact, invoice_from_address_line,
			invoice_from_street, invoice_from_city, invoice_from_state, invoice_from_postcode, invoice_from_country_code, invoice_from_ddi, invoice_from_email )

			;
			true
		),


		( qq_op_param( c_xml_include_wire_receiving_bank, true )
			->(
				( result( _, invoice, supplier_bank_name, _ )
					; result( _, invoice, supplier_bank_account_name, _ )
					; result( _, invoice, supplier_bank_account_type, _ )
					; result( _, invoice, supplier_bank_account_id, _ )
					; result( _, invoice, supplier_bank_swift_id, _ )
					; result( _, invoice, supplier_iban, _ )
				)
				->
					write_start_element( `InvoicePartner` ),
						write_start_element( `Contact` ),
							write_attribute_string( `role`, `wireReceivingBank` ),
							write_start_element( `Name` ),
								write_english_language_attribute,
								( q_available_value( invoice, supplier_bank_name, `Name`, false, NameValue )
									->	write_string_value_only( supplier_bank_name, NameValue )
									;	true
								),
							write_end_element,
						write_end_element,

						write_start_element( `IdReference` ),
							write_variable_as_attribute( invoice, supplier_bank_account_name, `identifier` ),
							write_attribute_string( `domain`, `accountName` ),
						write_end_element,
						write_start_element( `IdReference` ),
							write_variable_as_attribute( invoice, supplier_bank_account_type, `identifier` ),
							write_attribute_string( `domain`, `accountType` ),
						write_end_element,
						write_start_element( `IdReference` ),
							write_variable_as_attribute( invoice, supplier_bank_account_id, `identifier` ),
							write_attribute_string( `domain`, `accountID` ),
						write_end_element,
						write_start_element( `IdReference` ),
							write_variable_as_attribute( invoice, supplier_bank_swift_id, `identifier` ),
							write_attribute_string( `domain`, `swiftID` ),
						write_end_element,
						write_start_element( `IdReference` ),
							write_variable_as_attribute( invoice, supplier_iban, `identifier` ),
							write_attribute_string( `domain`, `ibanID` ),
						write_end_element,

					write_end_element

				;	true
			)

			;	true
		),

		( ( grammar_set( cxml_shipping_information_at_header );	qq_op_param( c_xml_shipping_information_at_header, true ) )
			->
				(	qq_op_param( c_xml_remit_to_partner_use_remit_to_variables, true )
					->	write_invoice_partner( `remitTo`, remit_to_party, remit_to_vat_number, remit_to_contact, remit_to_address_line,
							remit_to_street, remit_to_city, remit_to_state, remit_to_postcode, remit_to_country_code, remit_to_ddi, remit_to_email )
					;	write_invoice_partner( `remitTo`, supplier_party, SupplierID, supplier_contact, supplier_address_line,
							supplier_street, supplier_city, supplier_state, supplier_postcode, supplier_country_code, supplier_ddi, supplier_email )
				),

				(	qq_op_param( c_xml_from_partner_use_from_variables, true )
					->	write_invoice_partner( `from`, from_party, from_vat_number, from_contact, from_address_line,
							from_street, from_city, from_state, from_postcode, from_country_code, from_ddi, from_email )
					;	write_invoice_partner( `from`, supplier_party, SupplierID, supplier_contact, supplier_address_line,
							supplier_street, supplier_city, supplier_state, supplier_postcode, supplier_country_code, supplier_ddi, supplier_email )
				),

				write_start_element( `InvoiceDetailShipping` ),
					
					(	result( _, invoice, processed_delivery_date, Delivery_Date )
						
						->	write_date_as_attribute( `shippingDate`, Delivery_Date )

						;

						write_variable_as_attribute( invoice, processed_delivery_date, `shippingDate` )
					),

					write_start_element( `Contact` ),
						write_attribute_string( `role`, `shipFrom` ),

						write_start_element( `Name` ),
							write_english_language_attribute,
							( q_available_value( invoice, delivery_from_party, `Name`, false, DFP )
								->	write_string_value_only( delivery_from_party, DFP )
								;	true
							),
						write_end_element,

						write_start_element( `PostalAddress` ),
							write_variable_as_multi_tag( invoice, delivery_from_contact, `DeliverTo` ),
							write_variable_as_multi_tag( invoice, delivery_from_street, `Street` ),
							write_variable_as_multi_tag( invoice, delivery_from_address_line, `Street` ),
							write_variable_as_tag( invoice, delivery_from_city, `City` ),
							write_variable_as_tag( invoice, delivery_from_state, `State` ),
							write_variable_as_tag( invoice, delivery_from_postcode, `PostalCode` ),
							write_mandatory_country( delivery_from_country_code, `Country`, `isoCountryCode` ),
						write_end_element,

					write_end_element,

					write_start_element( `Contact` ),
						write_attribute_string( `role`, `shipTo` ),

						write_start_element( `Name` ),
							write_english_language_attribute,
							( q_available_value( invoice, delivery_party, `Name`, false, DP )
								->	write_string_value_only( delivery_party, DP )
								;	true
							),
						write_end_element,

						write_start_element( `PostalAddress` ),
							write_variable_as_multi_tag( invoice, delivery_contact, `DeliverTo` ),
							write_variable_as_multi_tag( invoice, delivery_street, `Street` ),
							write_variable_as_multi_tag( invoice, delivery_address_line, `Street` ),
							write_variable_as_tag( invoice, delivery_city, `City` ),
							write_variable_as_tag( invoice, delivery_state, `State` ),
							write_variable_as_tag( invoice, delivery_postcode, `PostalCode` ),
							write_mandatory_country( delivery_country_code, `Country`, `isoCountryCode` ),
						write_end_element,

					write_end_element,
				write_end_element

			;	qq_op_param( force_c_xml_remit_to_disappear, _ )
				->	true

			;	write_invoice_partner( `remitTo`, delivery_party, none, delivery_contact, delivery_address_line,
					delivery_street, delivery_city, delivery_state, delivery_postcode, delivery_country_code, delivery_ddi, delivery_email )
		),

		( grammar_set( credit_note ),
			qq_op_param( c_xml_include_previous_invoice_references, true ),
			result( _, invoice, original_invoice_number, _ )
			->	write_start_element( `InvoiceIDInfo` ),
					( result( _, invoice, processed_original_invoice_date, OIDate )
						->	write_date_as_attribute( `invoiceDate`, OIDate )
						;	true
					),
					write_variable_as_attribute( invoice, original_invoice_number, `invoiceID` ),
				write_end_element
			;	true
		),

		( qq_op_param( c_xml_include_payment_terms, true )
			->	write_start_element( `PaymentTerm` ),
				write_variable_as_attribute( invoice, payment_terms, `payInNumberOfDays` ),
				write_end_element

			;	true
		),

		write_detailed_payment_terms,

		( qq_op_param( c_xml_include_base64_image_section, true )
			->	write_start_element( `Base64Image` ),
					write_element_string( `Content`, `` ),
					writeln_proc_file_predicate( image_xml_tag( `Content` ) ),
					( i_mail( pdf_image_file_name, File ); i_mail( file, File ) ),
					write_element_string( `FileName`, File ),
				write_end_element

			;	true
		),

		write_variable_as_tag( invoice, narrative, `Comments` ),

		write_extrinsics( invoice, invoice ),
		( qq_op_param( c_xml_file_id, File )
			-> true
			; 	i_mail( pdf_image_file_name, File )
			->	true
			;	i_mail( file, File )
		),

		write_extrinsic_value( none, `SupplierPortalInvoiceID`, File ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_request_invoice_detail_order
%-------------------------------------------------------------------------------
:- d1( write_request_invoice_detail_order___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_request_invoice_detail_order___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `InvoiceDetailOrder` ),

			write_start_element( `InvoiceDetailOrderInfo` ),

			( 
				grammar_set(blanket_purchase_order)
					-> OrderLabel = `MasterAgreementReference`
				; 
				qq_op_param( c_xml_use_orderidinfo_label, true )
					->	OrderLabel = `OrderIDInfo`
				;	
				OrderLabel = `OrderReference`
			),

			write_start_element( OrderLabel ),

				( 
					grammar_set(blanket_purchase_order),
					write_variable_as_attribute( invoice, order_number, `agreementID` )
					;
					write_variable_as_attribute( invoice, order_number, `orderID` )
				), 

				( qq_op_param( c_xml_suppress_document_reference, true )
					->	true

					;		write_start_element( `DocumentReference` ),

								( 
									qq_op_param( c_xml_include_sap_reference_payload_id, true ),
									result( _, invoice, sap_payload_id, ID ),
									write_attribute_string( `payloadID`, ID )
									;
									write_attribute_string( `payloadID`, `` )
								),

							write_end_element,

						write_end_element,

						write_start_element( `SupplierOrderInfo` ),

							write_variable_as_attribute( invoice, supplier_order_number, `orderID` )

				),

			write_end_element,

		write_end_element,

		write_lines( write_invoice_detail_line ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_request_invoice_detail_summary( VAT_totals )
%-------------------------------------------------------------------------------
:- d1( write_request_invoice_detail_summary___( VAT_totals ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_request_invoice_detail_summary___( VAT_totals )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `InvoiceDetailSummary` ),

		( qq_op_param( c_xml_us_invoice_variant, true )
			->	(
					result( _, invoice, subtotal, _ )
					->	write_money_item( invoice, subtotal, `SubtotalAmount` )
					;	write_money_item( invoice, total_net, `SubtotalAmount` )
				)

			;	write_money_item( invoice, total_net, `SubtotalAmount` )
		),

		write_start_element( `Tax` ),

			write_money_amount( invoice, total_vat ),

			write_start_element( `Description` ),

				write_english_language_attribute,

				write_string( `Total Tax` ),

			write_end_element,

			(	qq_op_param( c_xml_us_invoice_variant, true )
				->	(
						i_calculate_vat_totals_from_table,
						perform_list( write_us_tax_summary, VAT_totals )
						;	write_us_tax_summary
					)

				;	perform_list( write_tax_summary, VAT_totals )
			),

		write_end_element,

		( qq_op_param( us_invoice, _ )

			->	( result( _, LID_SHIP, line_type, `shipping` ),

					write_money_item( LID_SHIP, line_net_amount, `ShippingAmount` )

					;	true

				)

			;	( 	qq_op_param( c_xml_hide_shipping_amount_if_zero, true )
					->
						(
							q_available_value( [ write_element_string( `ShippingAmount` ) ], invoice, net_subtotal_3, `Money`, false, ShipAmount ),
							not( q_sys_comp_str_eq( ShipAmount, `0` ) )
							->	write_money_item( invoice, net_subtotal_3, `ShippingAmount` )

							;	true
						)
					;	write_money_item( invoice, net_subtotal_3, `ShippingAmount` )
				)
		),

		( qq_op_param( c_xml_us_invoice_variant, true )
				->	( result( _, invoice, gross_total, _ )
						->	write_money_item( invoice, gross_total, `GrossAmount` )
						;	write_money_item( invoice, total_net, `GrossAmount` )
					)

			;	write_money_item( invoice, total_invoice, `GrossAmount` )
		),

		(
			qq_op_param( c_xml_include_additional_charges_from_line_type, ChargesType ),
			not( qq_op_param( c_xml_convert_negative_lines_to_allowances, _ ) ),
			result( _, _, line_type, ChargesType )
			->	write_start_element( `InvoiceHeaderModifications` ),
					write_special_lines( ChargesType, write_charge_and_allowance_lines ),
				write_end_element,

				( result( _, invoice, sum_of_additional_charges, ChargeSum )
					->	write_start_element( `TotalCharges` ),
								write_start_element( `Money` ),
									write_variable_as_attribute( invoice, currency, `currency` ),
									write_string( ChargeSum ),
								write_end_element,
							write_end_element
					;	true
				),
				( result( _, invoice, sum_of_additional_allowances, AllowanceSum )
					->	write_start_element( `TotalAllowances` ),
								write_start_element( `Money` ),
									write_variable_as_attribute( invoice, currency, `currency` ),
									write_string( AllowanceSum ),
								write_end_element,
							write_end_element
					;	true
				)

			;	qq_op_param( c_xml_convert_negative_lines_to_allowances, true ),
				not( qq_op_param( c_xml_include_additional_charges_from_line_type, _ ) ),
				result( _, _, line_net_amount, NetAmt ),
				q_sys_comp_str_lt( NetAmt, `0` )
				->	write_start_element( `InvoiceHeaderModifications` ),
						write_lines( write_charge_and_allowance_lines ),
					write_end_element,

					sys_findall( NegativeLineNet,
						(
							result( _, _, line_net_amount, NegativeLineNet ),
							q_sys_comp_str_lt( NegativeLineNet, `0` )
						),
						NegativeLineNets
					),
					(
						NegativeLineNets = [ ]
						->	true
						;	i_user_check( sum_string_list, NegativeLineNets, AllowanceSum ),
							write_start_element( `TotalAllowances` ),
								write_start_element( `Money` ),
									write_variable_as_attribute( invoice, currency, `currency` ),
									write_string( AllowanceSum ),
								write_end_element,
							write_end_element
					)
			;	true
		),

		( qq_op_param( c_xml_include_discount_if_not_zero, true ),
			result( _, invoice, total_discount, TDisc ),
			not( q_sys_comp_str_eq( TDisc, `0` ) )
			->	write_money_item( invoice, total_discount, `InvoiceDetailDiscount` )
			;	true
		),

		( qq_op_param( c_xml_us_invoice_variant, true )
			->	write_money_item( invoice, total_invoice, `NetAmount` ),

				( result( _, invoice, prepaid_amount, Prepaid )
					->	write_start_element( `DepositAmount` ),
							normalise_2dp_in_string( Prepaid, Prepaid_2dp ),
							write_money_value( Prepaid_2dp ),
						write_end_element
					;	true
				),

				( result( _, invoice, total_due, _ )
					->	write_money_item( invoice, total_due, `DueAmount` )
					;	write_money_item( invoice, total_invoice, `DueAmount` )
				)

			;	qq_op_param( c_xml_use_correct_variables_for_totals, true )

				->	write_money_item( invoice, total_net, `NetAmount` ),

				write_money_item( invoice, total_due, `DueAmount` )

			;	write_money_item( invoice, total_invoice, `NetAmount` ),

				write_money_item( invoice, total_invoice, `DueAmount` )

		),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_detailed_payment_terms
%-------------------------------------------------------------------------------
:- d1( write_detailed_payment_terms___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_detailed_payment_terms___
%-------------------------------------------------------------------------------
:- not( result( _, invoice, default_payment_days, _ ) ), not( result( _, invoice, discount_payment_days, _ ) ), not( result( _, invoice, discount_payment_rate, _ ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_detailed_payment_terms___
%-------------------------------------------------------------------------------
:-
	(
		
		( 
			qq_op_param( c_xml_german_terms, true ),
			result( _, invoice, default_payment_days, _ )
			->	write_start_element( `PaymentTerm` ),
					write_variable_as_attribute( invoice, default_payment_days, `payInNumberOfDays` ),
						write_start_element(`Discount`),
							write_start_element( `DiscountPercent` ),
								write_variable_as_attribute( invoice , discount_payment_rate , `percent`),
							write_end_element,
						write_end_element,
				write_end_element
		)
				
		;
	
		( 
			result( _, invoice, default_payment_days, _ )
			->	write_start_element( `InvoiceDetailPaymentTerm` ),
					write_variable_as_attribute( invoice, default_payment_days, `payInNumberOfDays` ),
					write_attribute_string( `percentageRate`, `0` ),
				write_end_element

			;	true
		),

		( 
			result( _, invoice, discount_payment_days, _ ),
			result( _, invoice, discount_payment_rate, _ )
			->	write_start_element( `InvoiceDetailPaymentTerm` ),
					write_variable_as_attribute( invoice, discount_payment_days, `payInNumberOfDays` ),
					write_variable_as_attribute( invoice, discount_payment_rate, `percentageRate` ),
				write_end_element

			;	true
		)
	)
.
%===============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_purchase_order_request_header
%===============================================================================
:- d1( write_purchase_order_request_header___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%===============================================================================
write_purchase_order_request_header___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `OrderRequestHeader` ),

		write_attribute_string( `type`, `new` ),

		( qq_op_param( shipcomplete_flag, `true` )

			->	write_attribute_string( `shipComplete`, `yes` )

			;	true

		),

		write_variable_as_attribute( invoice, order_number, `orderID` ),

		( result( _, invoice, date, Date )

			->	write_date_as_attribute( `orderDate`, Date )

			;	date_get( today, Date ),
				write_date_as_attribute( `orderDate`, Date )
		),

		( qq_op_param( c_xml_order_include_header_delivery_date, _ ),
			result( _, invoice, processed_delivery_date, DDate )
			->	write_date_as_attribute( `requestedDeliveryDate`, DDate )
			;	true
		),

		write_money_item( invoice, total_invoice, `Total` ),

		write_order_address( `ShipTo`, delivery_party, general_ledger_code, delivery_contact, delivery_address_line,
			delivery_street, delivery_city, delivery_state, delivery_postcode, delivery_country_code, delivery_ddi, delivery_email ),

		write_order_address( `BillTo`, invoice_to_party, invoice_to_dept, invoice_to_contact, invoice_to_address_line,
			invoice_to_street, invoice_to_city, invoice_to_state, invoice_to_postcode, invoice_to_country_code, invoice_to_ddi, invoice_to_email ),

		(	qq_op_param( c_xml_order_include_remit_to, true )

			->	write_order_address( `RemitTo`, buyer_party, buyer_dept, buyer_contact, buyer_address_line,
					buyer_street, buyer_city, buyer_state, buyer_postcode, buyer_country_code, buyer_ddi, buyer_email )

			;	true
		),

		write_start_element( `Shipping` ),

			write_money_value( `0.00` ),

			write_start_element( `Description` ),

				write_english_language_attribute,

				( q_available_value( invoice, shipping_instructions, `Description`, false, INSTRUCTIONS )

					->	write_string_value_only( shipping_instructions, INSTRUCTIONS )

					;	true
				),

			write_end_element,

		write_end_element,

		write_start_element( `Tax` ),

			write_money_amount( invoice, total_vat ),

			write_start_element( `Description` ),

				write_english_language_attribute,

				write_string( `VAT Charge` ),

			write_end_element,

		write_end_element,

		write_start_element( `Contact` ),

			( qq_op_param( c_xml_order_contact_role_name, Role )
				->	write_attribute_string( `role`, Role )
				;	true
			),

			write_start_element( `Name` ),

				write_english_language_attribute,

				( q_available_value( invoice, buyer_contact, `Name`, false, BC )

					->	write_string_value_only( buyer_contact, BC )

					;	true
				),

			write_end_element,

			write_variable_as_tag( invoice, buyer_email, `Email` ),

			( q_available_value( [ write_start_element( `Phone` ),
											write_start_element( `TelephoneNumber` ) ],
										invoice, buyer_ddi, `Number`, false, _ )

				->	write_start_element( `Phone` ),

						write_start_element( `TelephoneNumber` ),

							write_start_element( `CountryCode` ),

								write_variable_as_attribute( invoice, buyer_country_code, `isoCountryCode` ),

							write_end_element,

							write_element_string( `AreaOrCityCode`, `` ),

							write_variable_as_tag( invoice, buyer_ddi, `Number` ),

						write_end_element,

					write_end_element

				;	true
			),

		write_end_element,

		( qq_op_param( c_xml_order_include_customer_comments, true )
			->	write_variable_as_multi_tag( invoice, customer_comments, `Comments` )

			;	true
		),

		( qq_op_param( c_xml_order_include_additional_document_reference_sections, true )
			->	write_additional_document_reference_sections

			;	true
		),

		write_extrinsics( order, invoice ),

		( qq_op_param( c_xml_order_include_url, URLVar )
			->	write_variable_as_tag( invoice, URLVar, `URL` )
			;	true
		),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_additional_document_reference_sections
%-------------------------------------------------------------------------------
:- d1( write_additional_document_reference_sections___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_additional_document_reference_sections___
%-------------------------------------------------------------------------------
:-
%===============================================================================
	sys_findall(
		Additional_Document_Reference_Var,
		(
			result( _, invoice, Additional_Document_Reference_Var, _ ),
			sub_atom( Additional_Document_Reference_Var, _, _, additional_document_reference_id )
		),
		List_of_Vars
	),

	sys_length( List_of_Vars, Number_of_Sections ),

	write_additional_document_reference_sections_function( 0, Number_of_Sections )
.

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write_additional_document_reference_sections_function( Number_of_Sections, Number_of_Sections ).
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write_additional_document_reference_sections_function( Initial_Count, Number_of_Sections )
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
:-
	sys_calculate( New_Count, Initial_Count + 1 ),

	atomlist_concat( [ additional_document_reference_id_, New_Count ], Additional_Document_Reference_ID_Var ),

	atomlist_concat( [ additional_document_reference_type_, New_Count ], Additional_Document_Reference_Type_Var ),

	write_start_element( `AdditionalDocumentReference` ),

		write_variable_as_tag( invoice, Additional_Document_Reference_ID_Var, `ID` ),
		
		write_variable_as_tag( invoice, Additional_Document_Reference_Type_Var, `DocumentType` ),

	write_end_element,

	write_additional_document_reference_sections_function( New_Count, Number_of_Sections )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_invoice_partner( Role, Party, ID, Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email )
%-------------------------------------------------------------------------------
:- d1( write_invoice_partner___( Role, Party, ID, Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_invoice_partner___( Role, Party, ID, Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `InvoicePartner` ),

		write_start_element( `Contact` ),

			write_attribute_string( `role`, Role ), 

			write_variable_as_attribute( invoice, ID, `addressID` ), trace( [ ID , `iD`]),

			write_start_element( `Name` ),

				write_english_language_attribute,

				( q_available_value( invoice, Party, `Name`, false, Party_value )

					->	write_string_value_only( Party, Party_value )

					;	true
				),

			write_end_element,

			write_postal_address( Contact, Address_line, Street, City, State, Postcode,
										Country_code, DDI, Email ),

			write_extrinsics( Role, invoice ),

		write_end_element,

		(
			qq_op_param( c_xml_disable_idreference_population, true )
			->	true

			;	q_available_value( invoice, ID, `identifier`, false, _ )

				->
					( 
						qq_op_param( c_xml_us_invoice_variant, true )
						->	true
						
						;
						qq_op_param( c_xml_remove_vat_id, true )
						->	true

						;	write_start_element( `IdReference` ),
								write_variable_as_attribute( invoice, ID, `identifier` ),
								write_attribute_string( `domain`, `vatID` ),
							write_end_element
					),

				write_start_element( `IdReference` ),
					write_variable_as_attribute( invoice, ID, `identifier` ),
					write_attribute_string( `domain`, `supplierTaxID` ),
				write_end_element

			;	true
		),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_order_address( Role, Party, ID, Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email )
%-------------------------------------------------------------------------------
:- d1( write_order_address___( Role, Party, ID, Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_order_address___( Role, Party, ID, Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( Role ),

		write_start_element( `Address` ),

			write_variable_as_attribute( invoice, Country_code, `isoCountryCode` ),

			write_variable_as_attribute( invoice, ID, `addressID` ),

			write_start_element( `Name` ),

				write_english_language_attribute,

				( q_available_value( invoice, Party, `Name`, false, Party_value )

					->	write_string_value_only( Party, Party_value )

					;	true
				),

			write_end_element,

			write_postal_address( Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email ),

		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_postal_address( Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email )
%-------------------------------------------------------------------------------
:- d1( write_postal_address___( Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_postal_address___( Contact, Address_line, Street, City, State, Postcode, Country_code, DDI, Email )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `PostalAddress` ),

		write_variable_as_multi_tag( invoice, Contact, `DeliverTo` ),

		write_variable_as_multi_tag( invoice, Street, `Street` ),

		write_variable_as_multi_tag( invoice, Address_line, `Street` ),

		write_variable_as_tag( invoice, City, `City` ),

		write_variable_as_tag( invoice, State, `State` ),

		write_variable_as_tag( invoice, Postcode, `PostalCode` ),

		write_mandatory_country( Country_code, `Country`, `isoCountryCode` ),

	write_end_element,

	write_variable_as_tag( invoice, Email, `Email` ),

	( q_available_value( [ write_start_element( `Phone` ), write_start_element( `TelephoneNumber` ) ], invoice, DDI, `Number`, false, _ )

		->	write_start_element( `Phone` ),

				write_attribute_string( `name`, `DDI` ),

				write_start_element( `TelephoneNumber` ),

					write_start_element( `CountryCode` ),

						write_variable_as_attribute( invoice, Country_code, `isoCountryCode` ),

					write_end_element,

					write_element_string( `AreaOrCityCode`, `` ),

					write_variable_as_tag( invoice, DDI, `Number` ),

				write_end_element,

			write_end_element

		;	true
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_extrinsics( Meta, Type )
%-------------------------------------------------------------------------------
:- d1( write_extrinsics___( Meta, Type ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_extrinsics___( Meta, Type )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	i_c_xml_extrinsic( Meta, Ordinal, Name, Attribute_name, ExtensionList ), % this repeats
	write_extrinsic_by_ordinal( Type, Ordinal, Name, Attribute_name, ExtensionList ),
	fail

	;

	true
.

i_c_xml_extrinsic( Meta, Ordinal, Name, Attribute_name, [ ] ):- i_c_xml_extrinsic( Meta, Ordinal, Name, Attribute_name ).
i_c_xml_extrinsic( Meta, single, Name, Attribute_name, [ ] ):- i_c_xml_extrinsic( Meta, Name, Attribute_name ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_extrinsic_by_ordinal( Type, Ordinal, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:- d1( write_extrinsic_by_ordinal___( Type, Ordinal, Name, Attribute_name, ExtensionList ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_extrinsic_by_ordinal___( Type, single, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:- write_extrinsic( Type, Name, Attribute_name, ExtensionList ).
%===============================================================================

%===============================================================================
write_extrinsic_by_ordinal___( Type, multi, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:- write_multi_c_xml_extrinsic( Type, Name, Attribute_name, ExtensionList ).
%===============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_multi_c_xml_extrinsic( Type, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:- not( grammar_set( reverse_extrinsics ) ), d1( write_regular_multi_c_xml_extrinsic___( Type, Name, Attribute_name, ExtensionList ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_multi_c_xml_extrinsic( Type, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:- grammar_set( reverse_extrinsics ), d1( write_reversed_multi_c_xml_extrinsic___( Type, Name, Attribute_name, ExtensionList ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_regular_multi_c_xml_extrinsic___( Type, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	result( _, Type, Name, Value ), % this repeats

	write_extrinsic_value( Name, Attribute_name, Value, ExtensionList ),

	fail

	;

	true
.

%===============================================================================
write_reversed_multi_c_xml_extrinsic___( Type, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	findall( Value_in, result( _, Type, Name, Value_in ), Value_in_list ),

	( Value_in_list = [ ]
		-> true

		;	sys_reverse( Value_in_list, Value_in_right_way_round_list ),

			write_reversed_extrinsic_list( Name, Attribute_name, Value_in_right_way_round_list, ExtensionList )
	)
.

%===============================================================================
write_reversed_extrinsic_list( Name, Attribute_name, [ ], ExtensionList ).
%===============================================================================
write_reversed_extrinsic_list( Name, Attribute_name, [ H | T ], ExtensionList )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_extrinsic_value( Name, Attribute_name, H, ExtensionList ),

	write_reversed_extrinsic_list( Name, Attribute_name, T, ExtensionList )

.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_extrinsic( Type, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:- d1( write_extrinsic___( Type, Name, Attribute_name , ExtensionList) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_extrinsic___( Type, Name, Attribute_name, ExtensionList )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( q_available_value( Type, Name, `Extrinsic`, false, Value ),
		not( i_user_data( already_written( Type, Name, Attribute_name ) ) )	%	To prevent the same extrinsic being written multiple times

		->	write_extrinsic_value( Name, Attribute_name, Value, ExtensionList ),
			sys_assertz( i_user_data( already_written( Type, Name, Attribute_name ) ) )	%	Keeping track of written extrinsics

		;	true
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_extrinsic_value( Name, Attribute_name, Value )
%-------------------------------------------------------------------------------
:- d1( write_extrinsic_value___( Name, Attribute_name, Value, [ ] ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_extrinsic_value( Name, Attribute_name, Value, ExtensionList )
%-------------------------------------------------------------------------------
:- d1( write_extrinsic_value___( Name, Attribute_name, Value, ExtensionList ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_extrinsic_value___( Name, Attribute_name, Value, ExtensionList )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `Extrinsic` ),

		write_attribute_string( `name`, Attribute_name ),

		( ExtensionList = [ ]
			->	write_string_value_only( Name, Value )
			;	write_extrinsic_extension_list( Name, Value, ExtensionList, 0 )

		),


	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_extrinsic_extension_list( Name, Value, ExtensionList, Num )
%-------------------------------------------------------------------------------
:- d1( write_extrinsic_extension_list___( Name, Value, ExtensionList, Num ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_extrinsic_extension_list___( Name, Value, complete, 0 ).
%===============================================================================
%===============================================================================
write_extrinsic_extension_list___( Name, Value, complete, Num )
%-------------------------------------------------------------------------------
:- write_end_element, NumOut is Num - 1, write_extrinsic_extension_list( Name, Value, complete, NumOut ).
%===============================================================================
%===============================================================================
write_extrinsic_extension_list___( Name, Value, [ ], Num )
%-------------------------------------------------------------------------------
:- write_string_value_only( Name, Value ), write_extrinsic_extension_list( Name, Value, complete, Num ).
%===============================================================================
write_extrinsic_extension_list___( Name, Value, [ attribute( Tag, Where, What ) | T ], Num )
%-------------------------------------------------------------------------------
:- write_variable_as_attribute( Where, What, Tag ), write_extrinsic_extension_list( Name, Value, T , Num ).
%===============================================================================
write_extrinsic_extension_list___( Name, Value, [ segment( Tag, Where, What ) | T ], Num )
%-------------------------------------------------------------------------------
:- write_variable_as_tag( Where, What, Tag ), NumOut is Num + 1, write_extrinsic_extension_list( Name, Value, T, NumOut ).
%===============================================================================
write_extrinsic_extension_list___( Name, Value, [ segment( Tag ) | T ], Num )
%-------------------------------------------------------------------------------
:- write_start_element( Tag ), NumOut is Num + 1, write_extrinsic_extension_list( Name, Value, T, NumOut ).
%===============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_invoice_detail_line( LID )
%-------------------------------------------------------------------------------
:- d1( write_invoice_detail_line___( LID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_invoice_detail_line___( LID )
%-------------------------------------------------------------------------------
:- qq_op_param( c_xml_convert_negative_lines_to_allowances, true ), result( _, LID, line_net_amount, Net ), q_sys_comp_str_lt( Net, `0` ).
%===============================================================================
%===============================================================================
write_invoice_detail_line___( LID )
%-------------------------------------------------------------------------------
:-
	not( (
		qq_op_param( c_xml_convert_negative_lines_to_allowances, true ),
		result( _, LID, line_net_amount, Net ),
		q_sys_comp_str_lt( Net, `0` )
	) ),
%===============================================================================

	( 
		result( _, LID, processed_line_service_start_date, _ ),
		write_start_element( `InvoiceDetailServiceItem` )
		;
		write_start_element( `InvoiceDetailItem` )
	),

		xml_line_number_to_use( LID, Number ),

		( result( _, invoice, line_invoice_line_number, LILN )
			->	write_processed_attribute_string( line_number, `invoiceLineNumber`, LILN )
			;	write_processed_attribute_string( line_number, `invoiceLineNumber`, Number )
		), % compulsory, but guaranteed present

		(
			result( _, LID, processed_line_service_start_date, _ ),
			result( _, LID, line_quantity, Quantity),
			normalise_2dp_in_string( Quantity, Quantity_2dp ),
			trace( [ `Quantity_2dp`, Quantity_2dp ] ),
			write_variable_as_attribute( LID, Quantity_2dp, `quantity` )
			; 
			write_variable_as_attribute( LID, line_quantity, `quantity` )
		),

		( 
		
		result( _, LID, processed_line_service_end_date, EndDate ),
		result( _, LID, processed_line_service_start_date, StartDate ),

			write_start_element( `Period` ),

				result( _, LID, processed_line_service_end_date, EndDate )
					->	write_date_as_attribute( `endDate`, EndDate ),

				result( _, LID, processed_line_service_start_date, StartDate )
					->	write_date_as_attribute( `startDate`, StartDate ),

			write_end_element
			
			; true
		),
			
		write_variable_as_tag( LID, line_quantity_uom_code, `UnitOfMeasure` ),

		write_money_item( LID, line_unit_amount, `UnitPrice` ),

		write_line_invoice_detail_item_reference( LID, Number ),

		write_money_item( LID, line_net_amount, `SubtotalAmount` ),

		( qq_op_param( c_xml_us_invoice_variant, true )
			->	true
			;	write_tax_details( LID, line_net_amount, line_vat_amount, line_vat_rate, line_vat_code )
		),

		( result( _, LID, processed_line_start_date, Date )

			->	write_start_element( `InvoiceDetailLineShipping` ),

					write_start_element( `InvoiceDetailShipping` ),

						write_date_as_attribute( `shippingDate`, Date ),

					write_end_element,

				write_end_element

			;	true
		),

		( qq_op_param( c_xml_us_invoice_variant, true )
			->	write_money_item( LID, line_net_amount, `GrossAmount` )
			;	write_money_item( LID, line_total_amount, `GrossAmount` )
		),

		(
			qq_op_param( c_xml_use_correct_variables_for_totals, true )
			->	write_money_item( LID, line_net_amount, `NetAmount` )

			;	qq_op_param( c_xml_us_invoice_variant, true )
				->	write_money_item( LID, line_net_amount, `NetAmount` )

			;	write_money_item( LID, line_total_amount, `NetAmount` )
		),

		write_extrinsics( invoice_line, LID ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_line_invoice_detail_item_reference( LID, Number )
%-------------------------------------------------------------------------------
:- d1( write_line_invoice_detail_item_reference___( LID, Number ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_line_invoice_detail_item_reference___( LID, Number )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( 
		result( _, LID, processed_line_service_end_date, _ ),
		write_start_element( `InvoiceDetailServiceItemReference` )
		;
		write_start_element( `InvoiceDetailItemReference` )
	),

		( result( _, LID, line_order_line_number, LOLN )
			->	write_processed_attribute_string( line_order_line_number, `lineNumber`, LOLN )

			;	write_processed_attribute_string( line_order_line_number, `lineNumber`, Number )
		),

		write_start_element( `ItemID` ),

			write_variable_as_tag( LID, line_item, `SupplierPartID` ),

			write_variable_as_tag( LID, line_item_for_buyer, `SupplierPartAuxiliaryID` ),

		write_end_element,

		write_start_element( `Description` ),

			write_english_language_attribute,

			( q_available_value( LID, line_descr, `Description`, false, Line_descr )

				->	write_string_value_only( line_descr, Line_descr )

				;	true
			),

		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_charge_and_allowance_lines( LID )
%-------------------------------------------------------------------------------
:- d1( write_charge_and_allowance_lines___( LID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_charge_and_allowance_lines___( LID )
%-------------------------------------------------------------------------------
:- not( qq_op_param( c_xml_include_additional_charges_from_line_type, _ ) ), not( ( result( _, LID, line_net_amount, Net ), q_sys_comp_str_lt( Net, `0` ) ) ).
%===============================================================================

%===============================================================================
write_charge_and_allowance_lines___( LID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	( qq_op_param( c_xml_convert_negative_lines_to_allowances, true ),
		result( _, LID, line_net_amount, Net ), q_sys_comp_str_lt( Net, `0` )
		->	true

		;	qq_op_param( c_xml_include_additional_charges_from_line_type, _ )
			->	true
	),

	result( _, LID, line_net_amount, Net ),

	write_start_element( `Modification` ),
		(  ( grammar_set( credit_note ), q_sys_comp_str_ge( Net, `0` )
				;	not( grammar_set( credit_note ) ), q_sys_comp_str_lt( Net, `0` )
			),
			write_start_element( `AdditionalDeduction` ),
				(
					result( _, LID, line_percent_discount, Disc ),
					q_sys_comp_str_gt( Disc, `0` )
					->
						write_start_element( `DeductionPercent` ),
							write_variable_as_attribute( LID, line_percent_discount, `percent` ),
						write_end_element

					;	write_money_amount( LID, line_total_amount )
				),
			write_end_element,
			ModName = `Allowance`

			;	( not( grammar_set( credit_note ) ), q_sys_comp_str_ge( Net, `0` )
					;	grammar_set( credit_note ), q_sys_comp_str_lt( Net, `0` )
				)
				->	write_start_element( `AdditionalCost` ),
						write_money_amount( LID, line_total_amount ),
					write_end_element,
					ModName = `Charge`

			;	ModName = `Charge`
		),

		write_start_element( `Tax` ),
			write_money_amount( LID, line_vat_amount ),

			write_start_element( `Description` ),
				write_english_language_attribute,
			write_end_element,

			write_start_element( `TaxDetail` ),
				write_attribute_string( `category`, `vat` ),
				write_variable_as_attribute( LID, line_vat_rate, `percentageRate` ),
				(
					qq_op_param( c_xml_include_tax_point_date_attribute_in_tax_detail_header, true ),
					result( _, invoice, processed_tax_point_date, TPDate )
					->	write_date_as_attribute( `taxPointDate`, TPDate )
					;	true
				),
				write_money_item( LID, line_net_amount, `TaxableAmount` ),
				write_money_item( LID, line_vat_amount, `TaxAmount` ),
			write_end_element,
		write_end_element,

		write_start_element( `ModificationDetail` ),
			write_attribute_string( `name`, ModName ),
			write_start_element( `Description` ),
				write_english_language_attribute,
				( result( _, LID, line_descr, Descr )
					->	write_string( Descr )
					;	true
				),
			write_end_element,
		write_end_element,
	write_end_element

.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_purchase_order_line( LID )
%-------------------------------------------------------------------------------
:- d1( write_purchase_order_line___( LID ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_purchase_order_line___( LID )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `ItemOut` ),

		xml_line_number_to_use( LID, Number ),

		write_processed_attribute_string( line_number, `lineNumber`, Number ), % compulsory, but guaranteed present

		write_variable_as_attribute( LID, line_quantity, `quantity` ),

		write_attribute_string( `isAdHoc`, `yes` ),

		( result( _, LID, processed_line_start_date, Date )

			->	write_date_as_attribute( `requestedDeliveryDate`, Date )

			;	true
		),

		write_start_element( `ItemID` ),

			write_variable_as_tag( LID, line_item, `SupplierPartID` ),

			write_variable_as_tag( LID, line_item_for_buyer, `SupplierPartAuxiliaryID` ),

		write_end_element,

		write_start_element( `ItemDetail` ),

			write_money_item( LID, line_unit_amount, `UnitPrice` ),

			write_start_element( `Description` ),

				write_english_language_attribute,

				( q_available_value( LID, line_descr, `Description`, false, Line_descr )

					->	write_string_value_only( line_descr, Line_descr )

					;	true
				),

			write_end_element,

			write_variable_as_tag( LID, line_quantity_uom_code, `UnitOfMeasure` ),

			write_start_element( `Classification` ),

				write_attribute_string( `domain`, `UNSPSC` ),

			write_end_element,

			write_extrinsics( order_line, LID ),

			write_extrinsic_value( line_number, `LineNo`, Number ),

		write_end_element,

		( qq_op_param( supplier_list_extension, `true` )
			->	write_supplier_list_extension

			;	true
		),

		write_start_element( `Tax` ),

			write_money_amount( LID, line_vat_amount ),

			write_start_element( `Description` ),

				write_english_language_attribute,

				( result( _, LID, line_vat_code, VC ) -> true ; VC = `no-vat` ),

				strcat_list( [ `VAT: `, VC ], VC_LINE ),

				write_string( VC_LINE ),

			write_end_element,

		write_end_element,

		write_start_element( `Distribution` ),

			write_start_element( `Accounting` ),

				write_attribute_string( `name`, `DistributionCharge` ),

				write_start_element( `AccountingSegment` ),

					write_attribute_string( `id`, `n/a---` ),

					write_start_element( `Name` ),

						write_english_language_attribute,

						write_string( `n/a---` ),

					write_end_element,

					write_start_element( `Description` ),

						write_english_language_attribute,

						( i_config_param( software_manufacturer, Manuf )

							->	write_string( Manuf )

							;	true
						),

					write_end_element,

				write_end_element,

			write_end_element,

			write_money_item( LID, line_net_amount, `Charge` ),

		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_supplier_list_extension
%-------------------------------------------------------------------------------
:- d1( write_supplier_list_extension___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_supplier_list_extension___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `SupplierList` ),
		write_start_element( `Supplier` ),

			write_element_string( `SupplierID`, `DUMMY` ),

			( result( _, invoice, supplier_party, Party )
				->	write_start_element( `Name` ),
					write_english_language_attribute,
						write_string( Party ),
					write_end_element

				;	true
			),

			write_start_element( `SupplierLocation` ),
				write_start_element( `Address` ),
					write_variable_as_attribute( invoice, supplier_country_code, `isoCountryCode` ),

					( result( _, invoice, supplier_party, Party )
						->	write_start_element( `Name` ),
							write_english_language_attribute,
								write_string( Party ),
							write_end_element

						;	true
					),

					write_start_element( `PostalAddress` ),

						write_variable_as_tag( invoice, supplier_address_line, `DeliverTo` ),
						write_variable_as_tag( invoice, supplier_street, `Street` ),
						write_variable_as_tag( invoice, supplier_city, `City` ),
						write_variable_as_tag( invoice, supplier_state, `State` ),
						write_variable_as_tag( invoice, supplier_postcode, `PostalCode` ),

						( qq_op_param( document_country_override, Country ),
							q_sys_is_string( Country )
							;	Country = `GB`
						),
						write_variable_as_tag( invoice, supplier_country_code, `Country`, attribute_list( [ ( Country, `isoCountryCode` ) ] ) ),

					write_end_element,

					write_variable_as_tag( invoice, supplier_email, `Email` ),

					( result( _, invoice, supplier_ddi, _ )
						->	write_start_element( `Phone` ),
								write_variable_as_tag( invoice, supplier_ddi, `Number` ),
							write_end_element

						;	true
					),

					( result( _, invoice, supplier_fax, _ )
						->	write_start_element( `Fax` ),
								write_variable_as_tag( invoice, supplier_fax, `Number` ),
							write_end_element

						;	true
					),

				write_end_element,
			write_end_element,
		write_end_element,
	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_tax_summary( Line )
%-------------------------------------------------------------------------------
:- d1( write_tax_summary___( Line ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_tax_summary___( vat( Rate, Code, Num, Net, VAT, Total ) )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	normalise_2dp_in_string( Net, Net_2dp ),

	normalise_2dp_in_string( VAT, VAT_2dp ),

	write_start_element( `TaxDetail` ),

		write_attribute_string( `purpose`, `tax` ),
		write_attribute_string( `category`, `vat` ),

		( q_sys_comp_str_eq( Rate, `0` ),
			qq_op_param( c_xml_mark_exempt_lines_as_exempt, true )
			->	write_attribute_string( `exemptDetail`, `exempt` )

			;	true
		),
		
		( 
			qq_op_param( c_xml_line_tax_rate_2dp, true ),
			normalise_2dp_in_string( Rate, Rate_2dp ),
			write_processed_attribute_string( tax_rate, `percentageRate`, Rate_2dp )

			;
			write_processed_attribute_string( tax_rate, `percentageRate`, Rate )
		),

		(
			qq_op_param( c_xml_include_tax_point_date_attribute_in_tax_detail_header, true ),
			result( _, invoice, processed_tax_point_date, TPDate )
			->	write_date_as_attribute( `taxPointDate`, TPDate )
			;	true
		),

		write_start_element( `TaxableAmount` ),
			write_money_value( Net_2dp ),
		write_end_element,

		write_start_element( `TaxAmount` ),
			write_money_value( VAT_2dp ),
		write_end_element,

		write_start_element( `TaxLocation` ),
			write_english_language_attribute,
				( qq_op_param( document_country_override, Country ),
					q_sys_is_string( Country )
					->	write_string( Country )
					;	write_string( `GB` )
				),
		write_end_element,

		write_start_element( `Description` ),
			write_english_language_attribute,

			( grammar_set( reverse_charge ),
				result( _, invoice, tax_information, Tax ),
				sys_string_length( Tax, TaxLen ),
				( TaxLen > 44 -> q_sys_sub_string( Tax, 1, 45, Tax45 )
					;	Tax45 = Tax
				)
				->	write_string( Tax45 ),
					write_end_element,
					write_start_element( `TriangularTransactionLawReference` ),
						write_english_language_attribute,
						write_string( Tax )

				;	write_string( Code )
			),

		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_us_tax_summary( Line )
%-------------------------------------------------------------------------------
:- d1( write_us_tax_summary___( Line ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_us_tax_summary___( vat( Rate, Code, Num, Net, VAT, Total ) )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	normalise_2dp_in_string( Net, Net_2dp ),
	normalise_2dp_in_string( VAT, VAT_2dp ),
	normalise_2dp_in_string( Rate, Rate_2dp ),

	write_start_element( `TaxDetail` ),

		write_attribute_string( `purpose`, `tax` ),
		write_attribute_string( `category`, `sales` ),

		write_processed_attribute_string( tax_rate, `percentageRate`, Rate_2dp ),

		write_start_element( `TaxableAmount` ),
			write_money_value( Net_2dp ),
		write_end_element,

		write_start_element( `TaxAmount` ),
			write_money_value( VAT_2dp ),
		write_end_element,

		write_start_element( `TaxLocation` ),
			write_english_language_attribute,
				( qq_op_param( document_country_override, Country ),
					q_sys_is_string( Country )
					->	write_string( Country )
					;	write_string( `GB` )
				),
		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_us_tax_summary
%-------------------------------------------------------------------------------
:- d1( write_us_tax_summary___ ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_us_tax_summary___
%-------------------------------------------------------------------------------
:-
%===============================================================================

	(
		result( _, invoice, total_net, Net ),
		result( _, invoice, total_vat, VAT ),

		( result( _, invoice, default_vat_rate, Rate )
			->	sys_calculate_str_divide( Rate, `100`, RateDec ),
				sys_calculate_str_divide( VAT, RateDec, NetCalc ),
				normalise_2dp_in_string( NetCalc, Net_2dp )

			;	sys_calculate_str_divide( VAT, Net, RateDec ),
				sys_calculate_str_multiply( RateDec, `100`, Rate ),
				normalise_2dp_in_string( Net, Net_2dp )
		),

		normalise_2dp_in_string( VAT, VAT_2dp ),
		normalise_2dp_in_string( Rate, Rate_2dp ),

		write_start_element( `TaxDetail` ),

			write_attribute_string( `purpose`, `tax` ),
			write_attribute_string( `category`, `sales` ),

			write_processed_attribute_string( tax_rate, `percentageRate`, Rate_2dp ),

			write_start_element( `TaxableAmount` ),
				write_money_value( Net_2dp ),
			write_end_element,

			write_start_element( `TaxAmount` ),
				write_money_value( VAT_2dp ),
			write_end_element,

			write_start_element( `TaxLocation` ),
				write_english_language_attribute,
					( qq_op_param( document_country_override, Country ),
						q_sys_is_string( Country )
						->	write_string( Country )
						;	write_string( `GB` )
					),
			write_end_element,

		write_end_element

		;	true
	)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_tax_details( Type, Net_name, Vat_name, Rate_name, Code_name )
%-------------------------------------------------------------------------------
:- d1( write_tax_details___( Type, Net_name, Vat_name, Rate_name, Code_name ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_tax_details___( Type, Net_name, Vat_name, Rate_name, Code_name )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `Tax` ),

		write_money_amount( Type, Vat_name ),

		write_start_element( `Description` ),

			write_english_language_attribute,

			write_string( `Total Line Item Tax` ),

		write_end_element,

		write_start_element( `TaxDetail` ),

			write_attribute_string( `purpose`, `tax` ),

			write_attribute_string( `category`, `vat` ),

			( result( _, Type, Rate_name, Rate ), q_sys_comp_str_eq( Rate, `0` ),
				qq_op_param( c_xml_mark_exempt_lines_as_exempt, true )
				->	write_attribute_string( `exemptDetail`, `exempt` )

				;	true
			),

			write_variable_as_attribute( Type, Rate_name, `percentageRate` ),

			(
				qq_op_param( c_xml_include_tax_point_date_attribute_in_tax_detail_line, true ),
				result( _, invoice, processed_tax_point_date, TPDate )
				->	write_date_as_attribute( `taxPointDate`, TPDate )
				;	true
			),

			write_money_item( Type, Net_name, `TaxableAmount` ),

			write_money_item( Type, Vat_name, `TaxAmount` ),

			write_start_element( `TaxLocation` ),

				write_english_language_attribute,

				( qq_op_param( document_country_override, Country ),
					q_sys_is_string( Country )
					->	write_string( Country )

					;	write_string( `GB` )
				),

			write_end_element,

			write_start_element( `Description` ),

				write_english_language_attribute,

				( grammar_set( reverse_charge ),
					result( _, invoice, tax_information, Tax ),
					sys_string_length( Tax, TaxLen ),
					( TaxLen > 44 -> q_sys_sub_string( Tax, 1, 45, Tax45 )
						;	Tax45 = Tax
					)
					->	write_string( Tax45 ),
						write_end_element,
						write_start_element( `TriangularTransactionLawReference` ),
							write_english_language_attribute,
							write_string( Tax )

					;	q_available_value( Type, Code_name, `Description`, false, Code )
						->	write_string_value_only( Code_name, Code )

					;	true
				),

			write_end_element,

		write_end_element,

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_money_item( Type, Name, Tag )
%-------------------------------------------------------------------------------
:- d1( write_money_item___( Type, Name, Tag ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_money_item___( Type, Name, Tag )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( Tag ),

		write_money_amount( Type, Name ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_money_amount( Type, Name )
%-------------------------------------------------------------------------------
:- d1( write_money_amount___( Type, Name ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_money_amount___( Type, Name )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `Money` ),

		write_variable_as_attribute( invoice, currency, `currency` ),

		( qq_op_param( c_xml_accept_blank_numerical_values, true ),

			result( _, Type, Name, `` )

			->	write_string( `` )

			;	result( _, Type, Name, Value )

				->	write_string_value_only( Name, Value )

			;	write_string_value_only( Name, `0.00` )
		),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_money_value( Value )
%-------------------------------------------------------------------------------
:- d1( write_money_value___( Value ) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===============================================================================
write_money_value___( Value )
%-------------------------------------------------------------------------------
:-
%===============================================================================

	write_start_element( `Money` ),

		write_variable_as_attribute( invoice, currency, `currency` ),

		write_string( Value ),

	write_end_element
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%===============================================================================
write_english_language_attribute
%-------------------------------------------------------------------------------
:-
	( qq_op_param( document_language_override, Language ),
		qq_op_param( document_country_override, Country ),
		q_sys_is_string( Language ),
		q_sys_is_string( Country )
		;	qq_op_param( document_language_override, Language ),
			q_sys_is_string( Language ),
			Country = `GB`
		;	qq_op_param( document_country_override, Country ),
			q_sys_is_string( Country ),
			Language = `en`
	),
	strcat_list( [ Language, `-`, Country ], Text ),
	write_attribute_string(`xml`, `lang`, Text)
.
%===============================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
write_english_language_attribute :-	write_attribute_string(`xml`, `lang`, `en-GB`).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

