table 50302 "Combined Posted Sales Inv."
{
    Caption = 'Combined Posted Sales Invoices';
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
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(4; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
        }
        field(5; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(8; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatExpression = "Currency Code";
        }
        field(10; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            AutoFormatExpression = "Currency Code";
        }
        field(11; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            AutoFormatExpression = "Currency Code";
        }
        field(12; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Posting Date")
        {
        }
        key(Key3; "Sell-to Customer No.")
        {
        }
    }
}