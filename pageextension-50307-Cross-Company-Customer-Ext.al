pageextension 50307 "Cross Company Customer Ext" extends "Customer Card"
{
    layout
    {
        addfirst(factboxes)
        {
            part(CrossCompanyBalances; "Cross Company Cust. Balance FB")
            {
                ApplicationArea = All;
                Caption = 'Cross-Company Balances';
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }
}