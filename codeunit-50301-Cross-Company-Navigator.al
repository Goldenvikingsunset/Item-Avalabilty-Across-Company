codeunit 50301 "Cross Company Navigator"
{
    procedure GoToCompanyWithUrl(CompanyName: Text)
    var
        CurrentUrl: Text;
        BaseUrl: Text;
        CompanyParam: Text;
        EnvironmentName: Text;
        TenantId: Text;
    begin
        // Get current URL and parse its parts
        CurrentUrl := GetUrl(ClientType::Web);
        ParseCurrentUrl(CurrentUrl, BaseUrl, EnvironmentName, TenantId);

        // Encode company name for URL
        CompanyParam := 'company=' + EncodeCompanyName(CompanyName);

        // Build new URL maintaining environment context
        if TenantId <> '' then
            BaseUrl += TenantId + '/';
        if EnvironmentName <> '' then
            BaseUrl += EnvironmentName + '?'
        else
            BaseUrl += '?';

        BaseUrl += CompanyParam;

        // Add session key if present in current URL
        if CurrentUrl.Contains('&sk=') then
            BaseUrl += GetSessionKeyFromUrl(CurrentUrl);

        Hyperlink(BaseUrl);
    end;

    local procedure ParseCurrentUrl(CurrentUrl: Text; var BaseUrl: Text; var EnvironmentName: Text; var TenantId: Text)
    var
        UrlParts: List of [Text];
        Position: Integer;
    begin
        // Extract base URL
        Position := CurrentUrl.IndexOf('?');
        if Position > 0 then
            CurrentUrl := CurrentUrl.Substring(1, Position - 1);

        // Parse URL parts
        BaseUrl := 'https://businesscentral.dynamics.com/';

        UrlParts := CurrentUrl.Split('/');

        if UrlParts.Count >= 5 then begin  // Has tenant ID and environment
            TenantId := UrlParts.Get(4);
            EnvironmentName := UrlParts.Get(5);
        end else if UrlParts.Count >= 4 then  // Has environment only
                EnvironmentName := UrlParts.Get(4);
    end;

    local procedure EncodeCompanyName(CompanyName: Text): Text
    begin
        // URL encode the company name properly
        exit(CompanyName.Replace(' ', '%20'));
    end;

    local procedure GetSessionKeyFromUrl(Url: Text): Text
    var
        Position: Integer;
        SessionKey: Text;
    begin
        Position := Url.IndexOf('&sk=');
        if Position > 0 then
            SessionKey := Url.Substring(Position);
        exit(SessionKey);
    end;
}