page 50305 "Cross Company Sales History"
{
    Caption = 'Sales History All Companies';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Cross Company Sales History";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Filters';
                field(CompanyFilter; CompanyFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Company Filter';
                    TableRelation = Company;

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update();
                    end;
                }
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Location Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Location: Record Location;
                        Locations: Page "Location List";
                    begin
                        Location.Reset();
                        Locations.LookupMode(true);
                        if Locations.RunModal() = Action::LookupOK then begin
                            Locations.GetRecord(Location);
                            Text := Location.Code;
                            exit(true);
                        end;
                        exit(false);
                    end;

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update();
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update();
                    end;
                }
                field(CustomerFilter; CustomerFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Filter';
                    TableRelation = Customer;

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Lines)
            {
                field("Source Company"; Rec."Source Company")
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                }
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
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowSourceDocument();
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; -Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Sold';
                }
                field("Sales Amount (Actual)"; -Rec."Sales Amount (Actual)")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Amount';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowCustomerCard();
                    end;
                }
            }
            group(Totals)
            {
                field(TotalQuantity; TotalQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity';
                    Editable = false;
                }
                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearFilters)
            {
                ApplicationArea = All;
                Caption = 'Clear Filters';
                Image = ClearFilter;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Clear(CompanyFilter);
                    Clear(LocationFilter);
                    Clear(DateFilter);
                    Clear(CustomerFilter);
                    LoadData();
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        ItemFilter: Code[20];
        CompanyFilter: Text;
        LocationFilter: Code[10];
        DateFilter: Text;
        CustomerFilter: Code[20];
        CompanyNameGlobal: Text[30];
        CrossCompanyNavigator: Codeunit "Cross Company Navigator";
        TotalQuantity: Decimal;
        TotalAmount: Decimal;

    trigger OnOpenPage()
    begin
        LoadData();
    end;

    procedure SetFilters(ItemNo: Code[20])
    begin
        ItemFilter := ItemNo;
        LoadData();
    end;

    local procedure LoadData()
    var
        Companies: Record Company;
        ItemLedgerEntry: Record "Item Ledger Entry";
        EntryNo: Integer;
    begin
        Clear(TotalQuantity);
        Clear(TotalAmount);

        if ItemFilter = '' then
            exit;

        Rec.Reset();
        Rec.DeleteAll();
        EntryNo := 0;

        if Companies.FindSet() then
            repeat
                if (not Companies.Name.ToLower().Contains('mycompany')) and
                   ((CompanyFilter = '') or (CompanyFilter = Companies.Name)) then begin
                    Clear(ItemLedgerEntry);
                    ItemLedgerEntry.ChangeCompany(Companies.Name);
                    ItemLedgerEntry.SetRange("Item No.", ItemFilter);
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);

                    if LocationFilter <> '' then
                        ItemLedgerEntry.SetRange("Location Code", LocationFilter);

                    if DateFilter <> '' then
                        ItemLedgerEntry.SetFilter("Posting Date", DateFilter);

                    if CustomerFilter <> '' then
                        ItemLedgerEntry.SetRange("Source No.", CustomerFilter);

                    if ItemLedgerEntry.FindSet() then
                        repeat
                            EntryNo += 1;
                            Rec.Init();
                            // Copy relevant fields
                            Rec."Entry No." := EntryNo;
                            Rec."Source Company" := Companies.Name;
                            Rec."Posting Date" := ItemLedgerEntry."Posting Date";
                            Rec."Entry Type" := ItemLedgerEntry."Entry Type";
                            Rec."Document Type" := ItemLedgerEntry."Document Type";
                            Rec."Document No." := ItemLedgerEntry."Document No.";
                            Rec."Location Code" := ItemLedgerEntry."Location Code";
                            Rec."Item No." := ItemLedgerEntry."Item No.";
                            Rec."Source No." := ItemLedgerEntry."Source No.";
                            Rec."Source Type" := ItemLedgerEntry."Source Type";
                            Rec.Quantity := ItemLedgerEntry.Quantity;
                            Rec."Sales Amount (Actual)" := ItemLedgerEntry."Sales Amount (Actual)";
                            Rec.Insert();

                            // Update totals
                            TotalQuantity += Abs(ItemLedgerEntry.Quantity);
                            TotalAmount += Abs(ItemLedgerEntry."Sales Amount (Actual)");
                        until ItemLedgerEntry.Next() = 0;
                end;
            until Companies.Next() = 0;

        if Rec.FindFirst() then;
    end;

    local procedure GetCustomerNo(ItemLedgerEntry: Record "Item Ledger Entry"): Code[20]
    begin
        if ItemLedgerEntry."Source Type" = ItemLedgerEntry."Source Type"::Customer then
            exit(ItemLedgerEntry."Source No.");
        exit('');
    end;

    local procedure ShowSourceDocument()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TargetUrl: Text;
    begin
        case Rec."Document Type" of
            Rec."Document Type"::"Sales Shipment":
                begin
                    Clear(SalesShipmentHeader);
                    SalesShipmentHeader.ChangeCompany(Rec."Source Company");
                    if SalesShipmentHeader.Get(Rec."Document No.") then begin
                        TargetUrl := GetUrl(ClientType::Web, Rec."Source Company",
                            ObjectType::Page, Page::"Posted Sales Shipment");
                        TargetUrl += '&No=' + Rec."Document No.";
                        Hyperlink(TargetUrl);
                    end;
                end;
            Rec."Document Type"::"Sales Invoice":
                begin
                    Clear(SalesInvoiceHeader);
                    SalesInvoiceHeader.ChangeCompany(Rec."Source Company");
                    if SalesInvoiceHeader.Get(Rec."Document No.") then begin
                        TargetUrl := GetUrl(ClientType::Web, Rec."Source Company",
                            ObjectType::Page, Page::"Posted Sales Invoice");
                        TargetUrl += '&No=' + Rec."Document No.";
                        Hyperlink(TargetUrl);
                    end;
                end;
        end;
    end;

    local procedure ShowCustomerCard()
    var
        Customer: Record Customer;
        TargetUrl: Text;
    begin
        if Rec."Source Type" = Rec."Source Type"::Customer then begin
            Clear(Customer);
            Customer.ChangeCompany(CompanyNameGlobal);
            if Customer.Get(Rec."Source No.") then begin
                // Navigate to Customer Card page with the specific customer
                TargetUrl := GetUrl(ClientType::Web, CompanyNameGlobal, ObjectType::Page, Page::"Customer Card");
                TargetUrl += '&No=' + Rec."Source No.";
                Hyperlink(TargetUrl);
            end;
        end;
    end;
}