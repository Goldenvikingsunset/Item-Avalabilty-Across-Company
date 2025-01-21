page 50300 "Multi-Comp Item Availability"
{
    Caption = 'Multi-Company Item Availability';
    PageType = ListPlus;
    SourceTable = "Multi-Company Page Data";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(TotalGroup)
            {
                ShowCaption = false;
                field(TotalInventory; TotalInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Total Inventory All Companies';
                    StyleExpr = TotalStyleExpr;
                    Editable = false;
                }
            }
            group(Options)
            {
                Caption = 'Options';
                field(ItemFilter; ItemFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item Filter';
                    TableRelation = Item;
                    Editable = false;
                }
                field(ShowLocationNames; ShowLocationNames)
                {
                    ApplicationArea = All;
                    Caption = 'Show Location Names';

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update(false);
                    end;
                }
                field(ShowZeroQty; ShowZeroQty)
                {
                    ApplicationArea = All;
                    Caption = 'Show Zero Quantities';

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(Lines)
            {
                Editable = false;
                IndentationColumn = Rec.Indentation;
                ShowAsTree = true;

                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Rec."Show in Bold";
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Visible = not ShowLocationNames;
                    Style = Strong;
                    StyleExpr = Rec."Show in Bold";
                }
                field("Location Name"; Rec."Location Name")
                {
                    ApplicationArea = All;
                    Visible = ShowLocationNames;
                    Style = Strong;
                    StyleExpr = Rec."Show in Bold";
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = InventoryStyleExpr;
                    BlankZero = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    LoadData();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        ShowLocationNames: Boolean;
        ShowZeroQty: Boolean;
        ItemFilter: Code[20];
        TotalInventory: Decimal;
        TotalStyleExpr: Text;
        InventoryStyleExpr: Text;

    trigger OnOpenPage()
    begin
        LoadData();
    end;

    trigger OnAfterGetRecord()
    begin
        StyleExpression();
    end;

    procedure SetItem(NewItemNo: Code[20])
    begin
        ItemFilter := NewItemNo;
    end;

    local procedure StyleExpression()
    begin
        Rec."Show in Bold" := (Rec.Level = 0);
        if Rec.Inventory < 0 then
            InventoryStyleExpr := 'Unfavorable'
        else if Rec.Inventory > 0 then
            InventoryStyleExpr := 'Favorable'
        else
            InventoryStyleExpr := 'None';
    end;

    local procedure LoadData()
    var
        Companies: Record Company;
        Location: Record Location;
        ItemLedgerEntry: Record "Item Ledger Entry";
        InvQty: Decimal;
        BlankLocationQty: Decimal;
        LineNo: Integer;
        CompanyLineNo: Integer;
        CompanyTotal: Decimal;
    begin
        if ItemFilter = '' then
            exit;

        Clear(TotalInventory);
        Rec.Reset();
        Rec.DeleteAll();
        LineNo := 0;

        if Companies.FindSet() then
            repeat
                if not Companies.Name.ToLower().Contains('mycompany') then begin
                    Clear(CompanyTotal);
                    Clear(BlankLocationQty);

                    // Insert company header
                    Clear(Rec);
                    LineNo += 10000;
                    CompanyLineNo := LineNo;
                    Rec.Init();
                    Rec."Line No." := LineNo;
                    Rec."Company Name" := Companies.Name;
                    Rec."Item No." := ItemFilter;
                    Rec.Level := 0;
                    Rec.Indentation := 0;
                    Rec.Insert();

                    // Get blank location quantity first
                    Clear(ItemLedgerEntry);
                    ItemLedgerEntry.ChangeCompany(Companies.Name);
                    ItemLedgerEntry.SetRange("Item No.", ItemFilter);
                    ItemLedgerEntry.SetRange("Location Code", '');
                    if ItemLedgerEntry.FindSet() then
                        repeat
                            BlankLocationQty += ItemLedgerEntry.Quantity;
                        until ItemLedgerEntry.Next() = 0;

                    // Add blank location if it has quantity or showing zero quantities
                    if (BlankLocationQty <> 0) or ShowZeroQty then begin
                        LineNo += 10;
                        Clear(Rec);
                        Rec.Init();
                        Rec."Line No." := LineNo;
                        Rec."Company Name" := Companies.Name;
                        Rec."Location Code" := '';
                        Rec."Location Name" := 'Default Location';
                        Rec."Item No." := ItemFilter;
                        Rec.Inventory := BlankLocationQty;
                        Rec.Level := 1;
                        Rec.Indentation := 1;
                        Rec.Insert();
                        CompanyTotal += BlankLocationQty;
                    end;

                    // Get locations and inventory
                    Clear(Location);
                    Location.ChangeCompany(Companies.Name);
                    if Location.FindSet() then
                        repeat
                            Clear(ItemLedgerEntry);
                            ItemLedgerEntry.ChangeCompany(Companies.Name);
                            ItemLedgerEntry.SetRange("Item No.", ItemFilter);
                            ItemLedgerEntry.SetRange("Location Code", Location.Code);
                            Clear(InvQty);
                            if ItemLedgerEntry.FindSet() then
                                repeat
                                    InvQty += ItemLedgerEntry.Quantity;
                                until ItemLedgerEntry.Next() = 0;

                            if (InvQty <> 0) or ShowZeroQty then begin
                                LineNo += 10;
                                Clear(Rec);
                                Rec.Init();
                                Rec."Line No." := LineNo;
                                Rec."Company Name" := Companies.Name;
                                Rec."Location Code" := Location.Code;
                                Rec."Location Name" := Location.Name;
                                Rec."Item No." := ItemFilter;
                                Rec.Inventory := InvQty;
                                Rec.Level := 1;
                                Rec.Indentation := 1;
                                Rec.Insert();
                                CompanyTotal += InvQty;
                            end;
                        until Location.Next() = 0;

                    // Update company total
                    if Rec.Get(CompanyLineNo) then begin
                        Rec.Inventory := CompanyTotal;
                        Rec.Modify();
                        TotalInventory += CompanyTotal;
                    end;
                end;
            until Companies.Next() = 0;

        // Set total style
        if TotalInventory < 0 then
            TotalStyleExpr := 'Unfavorable'
        else if TotalInventory > 0 then
            TotalStyleExpr := 'Favorable'
        else
            TotalStyleExpr := 'None';

        if Rec.FindFirst() then;
    end;
}