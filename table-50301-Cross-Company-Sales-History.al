table 50301 "Cross Company Sales History"
{
    Caption = 'Cross Company Sales History';
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Source Company"; Text[30])
        {
            Caption = 'Company';
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(4; "Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(5; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(9; "Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(10; "Source Type"; Enum "Analysis Source Type")
        {
            Caption = 'Source Type';
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Sales Amount (Actual)"; Decimal)
        {
            Caption = 'Sales Amount';
            DecimalPlaces = 2 : 2;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}