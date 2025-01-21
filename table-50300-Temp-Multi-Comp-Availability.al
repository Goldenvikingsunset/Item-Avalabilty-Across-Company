table 50300 "Multi-Company Page Data"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(2; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(4; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(6; "Inventory"; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(7; Level; Integer)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
        }
        field(8; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(9; "Show in Bold"; Boolean)
        {
            Caption = 'Show in Bold';
            DataClassification = CustomerContent;
        }
        field(50000; "Source Company"; Text[30])
        {
            Caption = 'Company Name';
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Company Name", "Location Code")
        {
        }
    }
}