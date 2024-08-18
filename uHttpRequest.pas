unit uHttpRequest;

interface

uses
  System.SysUtils, System.Classes, Winapi.ActiveX, Winapi.WinInet, System.Variants,  System.Win.ComObj;

type
  THttpRequest = class
  private
    FUrl: string;
    FMethod: string;
    FBody: string;
    FContentType: string;
    FHeaderTitle: string;
    FHeaderValue: string;
    FCountHeader: Integer;
    FEsperaRetorno: Boolean;
    FCodeApi: Integer;
    function GetResponseText: string;
  public
    constructor Create(const aURL: string; const aMethod: string; const aBody: string; const aContentType: string = ''; esperaRetorno: boolean = True);
    procedure AddHeader(const HeaderTitle, HeaderValue: string);
    function Execute: string;
    property ResponseText: string read GetResponseText;
    property CodeApi: Integer read FCodeApi;
  end;
implementation

{ THttpRequest }

constructor THttpRequest.Create(const aURL, aMethod, aBody, aContentType: string; esperaRetorno: boolean);
begin
 inherited Create;
  FUrl := aURL;
  FMethod := aMethod;
  FBody := aBody;
  FContentType := aContentType;
  FEsperaRetorno := esperaRetorno;
  FCountHeader := 0;
end;

procedure THttpRequest.AddHeader(const HeaderTitle, HeaderValue: string);
begin
  FHeaderTitle := FHeaderTitle + HeaderTitle + ';';
  FHeaderValue := FHeaderValue + HeaderValue + ';';
  Inc(FCountHeader);
 end;

function THttpRequest.Execute: string;
var
  Request: OleVariant;
  HeaderTitulo, HeaderValor: TStringList;
  i: Integer;
begin
  CoInitialize(nil);
  try
    Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Request.Open(FMethod, FUrl, (not FEsperaRetorno));

    if FCountHeader > 0 then
    begin
      HeaderTitulo := TStringList.Create;
      HeaderValor := TStringList.Create;
      try
        HeaderTitulo.Delimiter := ';';
        HeaderTitulo.DelimitedText := FHeaderTitle;

        HeaderValor.Delimiter := ';';
        HeaderValor.DelimitedText := FHeaderValue;

        for i := 0 to FCountHeader - 1 do
        begin
          Request.SetRequestHeader(Trim(HeaderTitulo.Strings[i]), Trim(HeaderValor.Strings[i]));
        end;
      finally
        HeaderTitulo.Free;
        HeaderValor.Free;
      end;
    end;

    Request.SetRequestHeader('Content-Type', FContentType);
    Request.Send(FBody);

    if not FEsperaRetorno then
      Exit('');

    if Request.Status < 205 then
      FCodeApi := 200
    else
      FCodeApi := Request.Status;

    Result := Request.ResponseText;
  finally
    Request := Unassigned;
    CoUninitialize;
  end;
end;

function THttpRequest.GetResponseText: string;
begin
 Result := Execute;
end;

end.
