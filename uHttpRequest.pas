unit uHttpRequest;

interface

uses
  System.SysUtils, System.Classes, Winapi.ActiveX, Winapi.WinInet, System.Variants,  System.Win.ComObj;

type
  THttpRequest = class
  private
    FUrl          : string;
    FMethod       : string;
    FBody         : string;
    FContentType  : string;
    FHeaderTitle  : string;
    FHeaderValue  : string;
    FCountHeader  : Integer;
    FEsperaRetorno: Boolean;
    FCodeApi      : Integer;
    function GetResponseText: string;
  public
    property ResponseText: string read GetResponseText;
    property CodeApi: Integer read FCodeApi;
    constructor Create(const pURL: string; const pMethod: string; const pBody: string; const pContentType: string = ''; pEsperaRetorno: boolean = True);
    function Execute: string;
  end;

function Get(const pURL: string; pContentType: string = 'application/json'; pEsperaRetorno: boolean = True): string;
function Post(const pURL, pBody: String; pContentType: string = 'application/json'; pEsperaRetorno: boolean = True): string;
function Put(const pURL, pBody: string; pContentType: string = 'application/json'; pEsperaRetorno: boolean = True): string;

implementation

{ THttpRequest }

constructor THttpRequest.Create(const pURL: string; const pMethod: string; const pBody: string; const pContentType: string = ''; pEsperaRetorno: boolean = True);
begin
  FUrl            := pURL;
  FMethod         := pMethod;
  FBody           := pBody;
  FContentType    := pContentType;
  FEsperaRetorno  := pEsperaRetorno;
  FCountHeader    := 0;
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
    Request.SetRequestHeader('Content-Type', FContentType);
    Request.Send(FBody);
    if not FEsperaRetorno then
      Exit;

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

{ Funções externas  - THttpRequest }
function Get(const pURL: string; pContentType: string = 'application/json'; pEsperaRetorno: boolean = True): string;
var
  HttpRequest: THttpRequest;
begin
  HttpRequest := THttpRequest.Create(pURL, 'GET', '', pContentType, pEsperaRetorno);
  try
    Result := HttpRequest.Execute;
  finally
    HttpRequest.Free;
  end;
end;
function Post(const pURL, pBody: String; pContentType: string = 'application/json'; pEsperaRetorno: boolean = True): string;
var
  HttpRequest: THttpRequest;
begin
  HttpRequest := THttpRequest.Create(pURL, 'POST', pBody, pContentType, pEsperaRetorno);
  try
    Result := HttpRequest.Execute;
  finally
    HttpRequest.Free;
  end;
end;
function Put(const pURL, pBody: string; pContentType: string = 'application/json'; pEsperaRetorno: boolean = True): string;
var
  HttpRequest: THttpRequest;
begin
  HttpRequest := THttpRequest.Create(pURL, 'PUT', pBody, pContentType, pEsperaRetorno);
  try
    Result := HttpRequest.Execute;
  finally
    HttpRequest.Free;
  end;
end;


end.
