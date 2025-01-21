query 50300 "Cross Company Sales History"
{
    QueryType = Normal; // Defines the query type
    Caption = 'Cross Company Sales History'; // Display caption
    UsageCategory = ReportsAndAnalysis; // Makes the query discoverable in Tell Me and Role Explorer

    AboutTitle = 'Analyze Sales History Across Locations';
    AboutText = 'This query shows sales history for items based on item ledger entries.';

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = CONST(Sale); // Filters for sales entries only

            column(EntryNo; "Entry No.") { } // Entry No.
            column(ItemNo; "Item No.") { } // Item No.
            column(PostingDate; "Posting Date") { } // Posting Date
            column(DocumentNo; "Document No.") { } // Document No.
            column(Quantity; Quantity) { } // Quantity
            column(EntryType; "Entry Type") { } // Entry Type

        }
    }
}