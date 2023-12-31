%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - D_TRAINING_CHAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( d_training_chain, `17/02/2020 17:09:47` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INVOICE DATA ITEMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Header Level Data Items
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
required_data_item( `Invoice Number`, `Map invoice number from invoice.`, `Always`, ``, `No`, `Send to Customer Intervention`, `N/A`, `The system was unable to determine a value for the Invoice Number.`, `Rules (Mapped)`, `invoice_number`, ( true ) ).
required_data_item( `Invoice Date`, `Map invoice date from invoice.`, `Always`, `No`, `No`, `Send to Customer Intervention`, `N/A`, `The system was unable to determine a value for the Invoice Date.`, `Rules (Mapped)`, `invoice_date`, ( true ) ).
required_data_item( `Supplier VAT Number`, `Hard-code supplier VAT number.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Hard-Coded)`, `supplier_vat_number`, ( true ) ).
required_data_item( `Purchase Order Number`, `Map purchase order number from invoice.`, `Never`, `No`, `No`, `Process As Normal`, `N/A`, `The document does not contain a purchase order number.`, `Rules (Mapped)`, `order_number`, ( true ) ).

required_data_item( `Total Net Amount`, `Map total net amount from invoice.`, `Always`, ``, `No`, `Send to Customer Intervention`, `N/A`, `The system was unable to determine a value for the Total Net Amount.`, `Rules (Mapped)`, `total_net`, ( true ) ).
required_data_item( `Total VAT Amount`, `Map total VAT amount from invoice.`, `Always`, ``, `No`, `Send to Customer Intervention`, `N/A`, `The system was unable to determine a value for the Total VAT Amount.`, `Rules (Mapped)`, `total_vat`, ( true ) ).
required_data_item( `Total Invoice Amount`, `Map total gross amount from invoice.`, `Always`,``, `No`, `Send to Customer Intervention`, `N/A`, `The system was unable to determine a value for the Total Invoice Amount.`, `Rules (Mapped)`, `total_invoice`, ( true ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line Level Data Items
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
required_data_item( `Line Quantity`, `Map line quantity from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_quantity`, ( true ) ).
required_data_item( `Line Quantity Unit of Measure`, `Map line quantity UOM code from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_quantity_uom_code`, ( true ) ).
required_data_item( `Line Unit Price`, `Map line unit price from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_unit_amount`, ( true ) ).
required_data_item( `Line Item Code`, `Map line item code from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_item`, ( true ) ).
required_data_item( `Line Description`, `Map line description from invoice.`, `Always`, `Yes`, `Yes`, `Send to Customer Intervention`, `N/A`, ``, `Rules (Mapped)`, `line_descr`, ( true ) ).
required_data_item( `Line Net Amount`, `Map line net amount from invoice,`, `Always`, `Yes`, `Yes`, `Send to Customer Intervention`, `N/A`, ``, `Rules (Mapped)`, `line_net_amount`, ( true ) ).
required_data_item( `Line VAT Amount`, `Map line VAT amount from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_vat_amount`, ( true ) ).
required_data_item( `Line VAT Rate`, `Map line VAT rate from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_vat_rate`, ( true ) ).
required_data_item( `Line VAT Code`, `Map line VAT code from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_vat_code`, ( true ) ).
required_data_item( `Line Total Amount`, `Map line gross amount from invoice.`, `Never`, ``, `No`, `Process As Normal`, `N/A`, ``, `Rules (Mapped)`, `line_total_amount`, ( true ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DOCUMENT SCENARIOS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Document Scenarios
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
document_scenario( `Unrecognised/Failed to Map Any Data`, `A document is received and is either unrecognised or fails to map any data. There are a number of causes for this, however the most common are documents in unsupported formats and documents that do not require processing, such as statements. These will have to be actioned according to what the document is and where it is supposed to go.`, `No`, `Send to Customer Intervention`, `N/A`, ``, `The document is either unrecognised or has failed to map any data. This is usually because it is a document that does not require processing, such as a statement or a body of an email, but can also be because the layout of the document is different to previous documents from the sender.`, `Unrecognised`, `Dropdown List`, `Ignore error`, `Do Not Allow`, ( missed_data_items_condition ) ).
document_scenario( `PDF Error`, `The document is a PDF which is either secured or contains an embedded font, which means that the system cannot read the text contained within the document. In order for the document to be processed, it must be generated by either using a different method or by changing the settings on the application which generates the document.`, `No`, `Send to Customer Intervention`, `N/A`, ``, `The document is a PDF which is either secured or contains an embedded font, which means that the system cannot read the text contained within the document. In order for the document to be processed, it must be generated by either using a different method or by changing the settings on the application which generates the document. The ideal format is a data PDF (which is not the same as an image PDF), but any text-based document format will do. If text can be copied and pasted from the document, then it is in a format which is supported by the system.`, `PDF Error`, `Dropdown List`, `Ignore error`, `Do Not Allow`, ( i_error_pdf_error ) ).
document_scenario( `Image Document`, `The document does not contain any text which can be read by the system, which suggests that it is an image or has been scanned.`, `No`, `Send to Customer Intervention`, `N/A`, ``, `The document does not contain any text which can be read by the system, which suggests that it is an image or has been scanned. The ideal format is a data PDF (which is not the same as an image PDF), but any text-based document format will do. If text can be copied and pasted from the document, then it is in a format which is supported by the system.`, `Empty`, `Dropdown List`, `Ignore error`, `Do Not Allow`, ( i_error_empty ) ).
document_scenario( `Unsupported File Type`, `The document has a file extension which is unsupported by the system.`, `No`, `Send to Customer Intervention`, `N/A`, ``, `The document has a file extension which is unsupported by the system. The ideal format is a data PDF (which is not the same as an image PDF), but any text-based document format will do. If text can be copied and pasted from the document, then it is in a format which is supported by the system.`, `Unsupported File Type`, `Dropdown List`, `Ignore error`, `Do Not Allow`, ( i_error_unsupported_file_type ) ).
document_scenario( `Credit Note`, `The document has been recognised as a credit note.`, `No`, `Process As Normal`, `N/A`, ``, `The document has been recognised as a credit note.`, `Credit Note`, `Dropdown List`, `Ignore error`, `Allow`, ( grammar_set( credit_note ) ) ).
document_scenario( `No Lines`, `The document does not contain any lines.`, `No`, `Process As Normal`, `N/A`, ``, `The document does not contain any lines.`, `No Lines`, `Dropdown List`, `Ignore error`, `Allow`, ( i_error_missing_lines ) ).
document_scenario( `Quantity Times Unit Amount Not Equal to Net Amount`, `The document contains a line where the quantity times the unit price is not equal to the net price.`, `No`, `Process As Normal`, `N/A`, ``, `The document contains a line where the quantity times the unit price is not equal to the net price.`, `Quantity Unit and Net Amounts Inconsistent`, `Dropdown List`, `Ignore error`, `Allow`, ( i_error_quantity_and_unit_and_net_amounts_inconsistent ) ).
document_scenario( `Invoice With Negative Totals`, `The document contains negative totals but does not appear to be a credit note.`, `No`, `Process As Normal`, `N/A`, ``, `The document contains negative totals but does not appear to be a credit note.`, `Negative Totals`, `Dropdown List`, `Ignore error`, `Allow`, ( i_error_negative_totals ) ).
document_scenario( `Sum of Line Net Amounts Not Equal to Total Net Amount`, `The sum of the line net amounts are not equal to the total net amount.`, `No`, `Send to Customer Intervention`, `N/A`, `Triggers if required for demo.`, `The sum of the line net amounts are not equal to the total net amount.`, `Sum Net Discrepancy`, `Dropdown List`, `Ignore error`, `Allow`, ( i_error_sum_net_discrepancy ) ).
document_scenario( `Sum of Line Gross Amounts Not Equal to Total Gross Amount`, `The sum of the line gross amounts are not equal to the total gross amount.`, `No`, `Send to Customer Intervention`, `N/A`, `Triggers if required for demo.`, `The sum of the line gross amounts are not equal to the total gross amount.`, `Sum Total Discrepancy`, `Dropdown List`, `Ignore error`, `Allow`, ( i_error_sum_total_discrepancy ) ).
document_scenario( `Totals Do Not Add Up`, `The document contains inconsistent totals, i.e. Total Net + Total VAT \= Total Gross.`, `No`, `Send to Customer Intervention`, `N/A`, `Triggers if required for demo.`, `The document contains inconsistent totals, i.e. Total Net + Total VAT \= Total Gross.`, `Inconsistent Totals`, `Dropdown List`, `Ignore error`, `Allow`, ( i_error_invoice_totals_inconsistent ) ).
