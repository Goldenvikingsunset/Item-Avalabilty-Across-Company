pageextension 50300 "Item Card Ext" extends "Item Card"
{
    actions
    {
        addlast(navigation)
        {
            action("Multi-Company Availability")
            {
                ApplicationArea = All;
                Caption = 'Multi-Company Availability';
                Image = AvailableToPromise;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MultiCompanyPage: Page "Multi-Comp Item Availability";
                begin
                    MultiCompanyPage.SetItem(Rec."No.");
                    MultiCompanyPage.Run();
                end;
            }
            action("Multi-Company History")
            {
                ApplicationArea = All;
                Caption = 'Multi-Company History';
                Image = AvailableToPromise;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MultiCompanyPage: Page "Cross Company Sales History";
                begin
                    MultiCompanyPage.SetFilters(Rec."No.");
                    MultiCompanyPage.Run();
                end;
            }

        }
    }
}