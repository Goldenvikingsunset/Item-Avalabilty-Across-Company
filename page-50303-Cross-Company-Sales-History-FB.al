page 50303 "Cross Company Sales History FB"
{
    Caption = 'Sales History All Companies';
    PageType = CardPart;
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            group(SalesSummary)
            {
                Caption = 'Sales History';
                field(TotalSoldQty; TotalSold)
                {
                    Caption = 'Total Sold All Companies';
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Shows the total quantity sold across all companies';

                    trigger OnDrillDown()
                    begin
                        ShowSalesHistory();
                    end;
                }
                field(CurrentMonthQty; CurrentMonthSold)
                {
                    Caption = 'Sold This Month';
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Shows quantity sold in the current month across all companies';
                }
                field(LastMonthQty; LastMonthSold)
                {
                    Caption = 'Sold Last Month';
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Shows quantity sold in the previous month across all companies';
                }
                field(YearToDateQty; YearToDateSold)
                {
                    Caption = 'Year To Date';
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Shows total quantity sold this year across all companies';
                }
            }
        }
    }

    var
        TotalSold: Decimal;
        CurrentMonthSold: Decimal;
        LastMonthSold: Decimal;
        YearToDateSold: Decimal;

    trigger OnAfterGetRecord()
    begin
        if Rec."No." <> '' then
            CalculateSalesHistory();
    end;

    local procedure CalculateSalesHistory()
    var
        Companies: Record Company;
        ItemLedgerEntry: Record "Item Ledger Entry";
        StartDate: Date;
        EndDate: Date;
        YearStartDate: Date;
    begin
        Clear(TotalSold);
        Clear(CurrentMonthSold);
        Clear(LastMonthSold);
        Clear(YearToDateSold);

        // Calculate date ranges
        StartDate := CalcDate('<CM>', WorkDate());  // Current month
        EndDate := CalcDate('<CM>', StartDate);
        YearStartDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));  // First day of current year

        if Companies.FindSet() then
            repeat
                if not Companies.Name.ToLower().Contains('mycompany') then begin
                    ItemLedgerEntry.ChangeCompany(Companies.Name);

                    // Total Sales
                    ItemLedgerEntry.SetRange("Item No.", Rec."No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            TotalSold += Abs(ItemLedgerEntry.Quantity);
                        until ItemLedgerEntry.Next() = 0;

                    // Current Month
                    ItemLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            CurrentMonthSold += Abs(ItemLedgerEntry.Quantity);
                        until ItemLedgerEntry.Next() = 0;

                    // Last Month
                    ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-1M>', StartDate), CalcDate('<-1D>', StartDate));
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            LastMonthSold += Abs(ItemLedgerEntry.Quantity);
                        until ItemLedgerEntry.Next() = 0;

                    // Year to Date
                    ItemLedgerEntry.SetRange("Posting Date", YearStartDate, EndDate);
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            YearToDateSold += Abs(ItemLedgerEntry.Quantity);
                        until ItemLedgerEntry.Next() = 0;
                end;
            until Companies.Next() = 0;
    end;

    local procedure ShowSalesHistory()
    var
        SalesHistoryPage: Page "Cross Company Sales History";
    begin
        SalesHistoryPage.SetFilters(Rec."No.");
        SalesHistoryPage.RunModal();
    end;
}