page 50302 "Multi-Company Avail. Factbox"
{
    Caption = 'Multi-Company Availability';
    PageType = CardPart;
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            group(Availability)
            {
                Caption = 'Multi-Company Availability';

                field(TotalQty; TotalInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Total Available';
                    StyleExpr = TotalStyleExpr;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowAvailabilityPage();
                    end;
                }
                field(CurrentCompQty; CurrentCompanyQty)
                {
                    ApplicationArea = All;
                    Caption = 'Current Company';
                    StyleExpr = CurrentCompanyStyle;
                }
                field(OtherCompQty; OtherCompaniesQty)
                {
                    ApplicationArea = All;
                    Caption = 'Other Companies';
                    StyleExpr = OtherCompaniesStyle;
                }
            }
        }
    }

    var
        TotalStyleExpr: Text;
        CurrentCompanyStyle: Text;
        OtherCompaniesStyle: Text;
        TotalInventory: Decimal;
        CurrentCompanyQty: Decimal;
        OtherCompaniesQty: Decimal;

    trigger OnAfterGetRecord()
    begin
        CalculateQuantities();
    end;

    local procedure CalculateQuantities()
    var
        Companies: Record Company;
        ItemLedgerEntry: Record "Item Ledger Entry";
        CurrentCompanyTotal: Decimal;
        OtherCompaniesTotal: Decimal;
    begin
        if Rec."No." = '' then
            exit;

        Clear(TotalInventory);
        Clear(CurrentCompanyQty);
        Clear(OtherCompaniesQty);

        // Get current company quantity
        ItemLedgerEntry.SetRange("Item No.", Rec."No.");
        if ItemLedgerEntry.FindSet() then
            repeat
                CurrentCompanyTotal += ItemLedgerEntry.Quantity;
            until ItemLedgerEntry.Next() = 0;

        // Get other companies quantities
        if Companies.FindSet() then
            repeat
                if (not Companies.Name.ToLower().Contains('mycompany')) and
                   (Companies.Name <> CompanyName) then begin
                    Clear(ItemLedgerEntry);
                    ItemLedgerEntry.ChangeCompany(Companies.Name);
                    ItemLedgerEntry.SetRange("Item No.", Rec."No.");
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            OtherCompaniesTotal += ItemLedgerEntry.Quantity;
                        until ItemLedgerEntry.Next() = 0;
                end;
            until Companies.Next() = 0;

        // Set the values and styles
        CurrentCompanyQty := CurrentCompanyTotal;
        OtherCompaniesQty := OtherCompaniesTotal;
        TotalInventory := CurrentCompanyTotal + OtherCompaniesTotal;

        // Set styles
        if TotalInventory < 0 then
            TotalStyleExpr := 'Unfavorable'
        else if TotalInventory > 0 then
            TotalStyleExpr := 'Favorable'
        else
            TotalStyleExpr := 'None';

        if CurrentCompanyQty < 0 then
            CurrentCompanyStyle := 'Unfavorable'
        else if CurrentCompanyQty > 0 then
            CurrentCompanyStyle := 'Favorable'
        else
            CurrentCompanyStyle := 'None';

        if OtherCompaniesQty < 0 then
            OtherCompaniesStyle := 'Unfavorable'
        else if OtherCompaniesQty > 0 then
            OtherCompaniesStyle := 'Favorable'
        else
            OtherCompaniesStyle := 'None';
    end;

    local procedure ShowAvailabilityPage()
    var
        Item: Record Item;
        MultiCompAvail: Page "Multi-Comp Item Availability";
    begin
        if Item.Get(Rec."No.") then begin
            MultiCompAvail.SetItem(Rec."No.");
            MultiCompAvail.RunModal();
        end;
    end;
}