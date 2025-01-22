page 50308 "Cross Company Cust. Balances"
{
    Caption = 'Cross Company Customer Balances';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = Customer;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Balance; GetBalance())
                {
                    ApplicationArea = All;
                    Caption = 'Balance';
                }
                field(BalanceDue; GetBalanceDue())
                {
                    ApplicationArea = All;
                    Caption = 'Balance Due';
                }
            }
        }
    }

    var
        CustomerFilter: Code[20];

    procedure SetCustomerFilter(CustNo: Code[20])
    begin
        CustomerFilter := CustNo;
    end;

    local procedure GetBalance(): Decimal
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SetRange("Customer No.", Rec."No.");
        DetailedCustLedgEntry.CalcSums(Amount);
        exit(DetailedCustLedgEntry.Amount);
    end;

    local procedure GetBalanceDue(): Decimal
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustLedgEntry.SetRange("Customer No.", Rec."No.");
        DetailedCustLedgEntry.SetFilter("Posting Date", '<%1', WorkDate());
        DetailedCustLedgEntry.CalcSums(Amount);
        exit(DetailedCustLedgEntry.Amount);
    end;
}