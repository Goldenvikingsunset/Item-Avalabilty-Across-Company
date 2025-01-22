page 50306 "Combined Posted Sales Invoices"
{
    Caption = 'Combined Posted Sales Invoices';
    PageType = ListPlus;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Combined Posted Sales Inv.";
    ShowFilter = false;
    CardPageID = "Posted Sales Invoice";  // Add this

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(CompanyFilter; CompanyFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Company Filter';
                    TableRelation = Company.Name;

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
                field(LocationFilter; LocationFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Location Filter';
                    TableRelation = Location;

                    trigger OnValidate()
                    begin
                        LoadData();
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Lines)
            {
                Editable = false;
                field("Source Company"; Rec."Source Company")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")  // Change from "Location"
                {
                    ApplicationArea = All;
                    Caption = 'Location';  // Keep caption as 'Location' for display
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowInvoice();
                    end;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Style = Unfavorable;
                    StyleExpr = HasRemainingAmount;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
            }
            group(Totals)
            {
                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount';
                    Editable = false;
                    AutoFormatType = 1;
                }
                field(TotalAmountInclVAT; TotalAmountInclVAT)
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount Incl. VAT';
                    Editable = false;
                    AutoFormatType = 1;
                }
                field(TotalRemainingAmount; TotalRemainingAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Remaining Amount';
                    Editable = false;
                    AutoFormatType = 1;
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
                    Clear(DateFilter);
                    Clear(CustomerFilter);
                    Clear(LocationFilter);
                    LoadData();
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        LocationFilter: Code[10];
        CompanyFilter: Text;
        DateFilter: Text;
        CustomerFilter: Code[20];
        TotalAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalRemainingAmount: Decimal;
        CrossCompanyNavigator: Codeunit "Cross Company Navigator";
        RemainingAmountStyleExpr: Boolean;
        HasRemainingAmount: Boolean;

    trigger OnOpenPage()
    begin
        LoadData();
    end;

    trigger OnAfterGetRecord()
    begin
        HasRemainingAmount := Rec."Remaining Amount" <> 0;
    end;

    procedure SetFilters(NewCompanyFilter: Text; NewDateFilter: Text; NewCustomerFilter: Code[20]; NewLocationFilter: Code[10])
    begin
        CompanyFilter := NewCompanyFilter;
        DateFilter := NewDateFilter;
        CustomerFilter := NewCustomerFilter;
        LocationFilter := NewLocationFilter;
        LoadData();
    end;

    local procedure LoadData()
    var
        Companies: Record Company;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EntryNo: Integer;
    begin
        Clear(TotalAmount);
        Clear(TotalAmountInclVAT);
        Clear(TotalRemainingAmount);

        Rec.Reset();
        Rec.DeleteAll();
        EntryNo := 0;

        if Companies.FindSet() then
            repeat
                if (not Companies.Name.ToLower().Contains('mycompany')) and
                   ((CompanyFilter = '') or (CompanyFilter = Companies.Name))
                then begin
                    Clear(SalesInvoiceHeader);
                    SalesInvoiceHeader.ChangeCompany(Companies.Name);

                    if DateFilter <> '' then
                        SalesInvoiceHeader.SetFilter("Posting Date", DateFilter);

                    if CustomerFilter <> '' then
                        SalesInvoiceHeader.SetRange("Sell-to Customer No.", CustomerFilter);

                    if LocationFilter <> '' then
                        SalesInvoiceHeader.SetRange("Location Code", LocationFilter);

                    if SalesInvoiceHeader.FindSet() then
                        repeat
                            // First calculate invoice amounts
                            SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");

                            // Get Customer Ledger Entry and calculate remaining
                            Clear(CustLedgerEntry);
                            CustLedgerEntry.ChangeCompany(Companies.Name);
                            CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                            CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");

                            if CustLedgerEntry.FindFirst() then begin
                                CustLedgerEntry.CalcFields("Remaining Amount");

                                EntryNo += 1;
                                Clear(Rec);
                                Rec.Init();
                                Rec."Entry No." := EntryNo;
                                Rec."Source Company" := Companies.Name;
                                Rec."Location Code" := SalesInvoiceHeader."Location Code";
                                Rec."No." := SalesInvoiceHeader."No.";
                                Rec."Posting Date" := SalesInvoiceHeader."Posting Date";
                                Rec."Due Date" := SalesInvoiceHeader."Due Date";
                                Rec."Sell-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
                                Rec."Sell-to Customer Name" := SalesInvoiceHeader."Sell-to Customer Name";


                                // Get the calculated amounts
                                Rec.Amount := SalesInvoiceHeader.Amount;
                                Rec."Amount Including VAT" := SalesInvoiceHeader."Amount Including VAT";
                                Rec."Remaining Amount" := CustLedgerEntry."Remaining Amount";
                                Rec."Currency Code" := SalesInvoiceHeader."Currency Code";
                                Rec.Insert();

                                // Update totals with calculated amounts
                                TotalAmount += SalesInvoiceHeader.Amount;
                                TotalAmountInclVAT += SalesInvoiceHeader."Amount Including VAT";
                                TotalRemainingAmount += CustLedgerEntry."Remaining Amount";
                            end;
                        until SalesInvoiceHeader.Next() = 0;
                end;
            until Companies.Next() = 0;

        if Rec.FindFirst() then;
    end;

    local procedure LookupDateFilter(var DateFilterText: Text): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        GLSetup: Record "General Ledger Setup";
        PeriodPageHandler: Page "Accounting Periods";
        StartDate: Date;
        EndDate: Date;
        FiscalYear: Integer;
    begin
        GLSetup.Get();
        AccountingPeriod.SetRange("New Fiscal Year", true);

        PeriodPageHandler.SetTableView(AccountingPeriod);
        PeriodPageHandler.LookupMode(true);

        if PeriodPageHandler.RunModal() = Action::LookupOK then begin
            PeriodPageHandler.GetRecord(AccountingPeriod);
            StartDate := AccountingPeriod."Starting Date";
            FiscalYear := Date2DMY(StartDate, 3);
            EndDate := CalcDate('<CY>', StartDate);

            DateFilterText := Format(StartDate) + '..' + Format(EndDate);
            exit(true);
        end;
        exit(false);
    end;

    local procedure OnAfterLoadData()
    begin
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure ShowInvoice()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        TargetUrl: Text;
    begin
        Clear(SalesInvHeader);
        SalesInvHeader.ChangeCompany(Rec."Source Company");
        if SalesInvHeader.Get(Rec."No.") then begin
            TargetUrl := GetUrl(ClientType::Web, Rec."Source Company",
                ObjectType::Page, Page::"Posted Sales Invoice", SalesInvHeader);
            Hyperlink(TargetUrl);
        end;
    end;
}