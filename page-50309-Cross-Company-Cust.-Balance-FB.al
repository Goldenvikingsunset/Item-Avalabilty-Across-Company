page 50309 "Cross Company Cust. Balance FB"
{
    Caption = 'Cross-Company Balances';
    PageType = CardPart;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            group(Balances)
            {
                Caption = 'Combined Balances';
                field(TotalBalance; TotalBalance)
                {
                    ApplicationArea = All;
                    Caption = 'Total Balance';
                    StyleExpr = BalanceStyle;
                    AutoFormatType = 1;
                }
                field(TotalDue; TotalDue)
                {
                    ApplicationArea = All;
                    Caption = 'Total Due';
                    StyleExpr = DueStyle;
                    AutoFormatType = 1;
                }
                field(TotalSales; TotalSales)
                {
                    ApplicationArea = All;
                    Caption = 'Total Sales (12M)';
                    AutoFormatType = 1;
                }
                field(AvailableCredit; TotalCreditLimit - TotalBalance)
                {
                    ApplicationArea = All;
                    Caption = 'Available Credit';
                    StyleExpr = CreditStyle;
                    AutoFormatType = 1;
                }
                field(NumCompanies; NumCompanies)
                {
                    ApplicationArea = All;
                    Caption = 'Number of Companies';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowCompanyDetails();
                    end;
                }
            }
        }
    }

    var
        TotalBalance: Decimal;
        TotalDue: Decimal;
        TotalSales: Decimal;
        TotalCreditLimit: Decimal;
        NumCompanies: Integer;
        BalanceStyle: Text;
        DueStyle: Text;
        CreditStyle: Text;

    trigger OnAfterGetRecord()
    begin
        CalculateTotals();
    end;

    local procedure CalculateTotals()
    var
        Companies: Record Company;
        Customer: Record Customer;
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        Clear(TotalBalance);
        Clear(TotalDue);
        Clear(TotalSales);
        Clear(TotalCreditLimit);
        Clear(NumCompanies);

        if Companies.FindSet() then
            repeat
                if not Companies.Name.ToLower().Contains('mycompany') then begin
                    Clear(Customer);
                    Customer.ChangeCompany(Companies.Name);
                    if Customer.Get(Rec."No.") then begin
                        // Get Balance
                        Clear(DetailedCustLedgEntry);
                        DetailedCustLedgEntry.ChangeCompany(Companies.Name);
                        DetailedCustLedgEntry.SetRange("Customer No.", Customer."No.");
                        DetailedCustLedgEntry.CalcSums("Amount (LCY)");
                        TotalBalance += DetailedCustLedgEntry."Amount (LCY)";

                        // Get Due Balance
                        DetailedCustLedgEntry.SetFilter("Posting Date", '<%1', WorkDate());
                        DetailedCustLedgEntry.CalcSums("Amount (LCY)");
                        TotalDue += DetailedCustLedgEntry."Amount (LCY)";

                        // Get Sales
                        Clear(CustLedgerEntry);
                        CustLedgerEntry.ChangeCompany(Companies.Name);
                        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
                        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                        CustLedgerEntry.SetRange("Posting Date", CalcDate('<-12M>', WorkDate()), WorkDate());
                        CustLedgerEntry.CalcSums("Sales (LCY)");
                        TotalSales += CustLedgerEntry."Sales (LCY)";

                        TotalCreditLimit += Customer."Credit Limit (LCY)";
                        NumCompanies += 1;
                    end;
                end;
            until Companies.Next() = 0;

        SetStyles();
    end;

    local procedure SetStyles()
    begin
        if TotalBalance > 0 then
            BalanceStyle := 'Unfavorable'
        else
            BalanceStyle := 'Favorable';

        if TotalDue > 0 then
            DueStyle := 'Unfavorable'
        else
            DueStyle := 'Favorable';

        if (TotalCreditLimit > 0) then begin
            if (TotalBalance > 0) and ((TotalBalance / TotalCreditLimit) > 0.8) then
                CreditStyle := 'Unfavorable'
            else
                CreditStyle := 'Favorable';
        end
        else
            CreditStyle := 'Favorable'; // Default style if TotalCreditLimit <= 0
    end;

    local procedure ShowCompanyDetails()
    var
        CrossCompanyBalances: Page "Cross Company Cust. Balances";
    begin
        CrossCompanyBalances.SetCustomerFilter(Rec."No.");
        CrossCompanyBalances.Run();
    end;
}