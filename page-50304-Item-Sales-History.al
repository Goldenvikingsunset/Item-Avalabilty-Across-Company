page 50304 "Item Sales History"
{
    Caption = 'Item Sales History All Companies';
    PageType = List;
    SourceTable = "Item Ledger Entry";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; -Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Sold';
                }
                field("Company Name"; CompanyNameGlobal)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        ItemFilter: Code[20];
        CompanyNameGlobal: Text[30];

    procedure SetItem(Item: Record Item)
    begin
        ItemFilter := Item."No.";
        LoadData();
    end;

    local procedure LoadData()
    var
        Companies: Record Company;
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if ItemFilter = '' then
            exit;

        Rec.Reset();
        Rec.DeleteAll();

        if Companies.FindSet() then
            repeat
                if not Companies.Name.ToLower().Contains('mycompany') then begin
                    Clear(ItemLedgerEntry);
                    ItemLedgerEntry.ChangeCompany(Companies.Name);
                    ItemLedgerEntry.SetRange("Item No.", ItemFilter);
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);

                    if ItemLedgerEntry.FindSet() then
                        repeat
                            Rec.Init();
                            Rec.TransferFields(ItemLedgerEntry);
                            CompanyNameGlobal := Companies.Name;
                            Rec.Insert();
                        until ItemLedgerEntry.Next() = 0;
                end;
            until Companies.Next() = 0;

        if Rec.FindFirst() then;
    end;
}