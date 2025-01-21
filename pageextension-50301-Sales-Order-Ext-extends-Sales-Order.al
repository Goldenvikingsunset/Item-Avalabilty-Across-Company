pageextension 50301 "Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addfirst(factboxes)
        {
            part(MultiCompanyAvail; "Multi-Company Avail. Factbox")
            {
                ApplicationArea = All;
                Provider = SalesLines;
                SubPageLink = "Document Type" = field("Document Type"),
                            "Document No." = field("Document No."),
                            "Line No." = field("Line No.");
            }
            part(SalesHistory; "Cross Company Sales History FB")
            {
                ApplicationArea = All;
                Provider = SalesLines;
                SubPageLink = "Document Type" = field("Document Type"),
                            "Document No." = field("Document No."),
                            "Line No." = field("Line No.");
            }
        }
    }
}