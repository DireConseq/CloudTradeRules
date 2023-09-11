%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - XML C_XML Support
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( xml_c_support, `15/06/2018 16:16:35` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_c_xml_extrinsic( invoice, single, buyers_code_for_supplier, `BuyersCodeForSupplier` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice, single, cost_centre, `CostCentre` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice, single, supplier_bank_account_number, `SupplierBankAccountNumber` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice, single, supplier_iban, `SupplierIBAN` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice, single, contract_order_reference, `ContractOrderReference` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice, multi, delivery_note_number, `DeliveryNoteNumber` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice, single, delivery_note_reference, `DeliveryNoteReference` ):- not( qq_op_param( stop_standard_header_extrinsics, _ ) ).

i_c_xml_extrinsic( invoice_line, single, line_vat_code, `TaxRefCode` ):- not( qq_op_param( stop_standard_line_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice_line, single, line_buyers_order_number, `LinePurchaseOrderNumber` ):- not( qq_op_param( stop_standard_line_extrinsics, _ ) ).
i_c_xml_extrinsic( invoice_line, single, line_quantity_ordered, `QuantityOrdered` ):- not( qq_op_param( stop_standard_line_extrinsics, _ ) ).


