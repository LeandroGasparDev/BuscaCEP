unit uHttpRequest;

interface

uses
  System.SysUtils, System.Classes, Winapi.ActiveX, Winapi.WinInet, System.Variants,  System.Win.ComObj, System.Generics.Collections;

type
 THttpMethod = (mmGet, mmPost, mmPut, mmDelete);


type
  THeaders = class
  private
    FHeaders: TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const Name, Value: string): THeaders;
    function Remove(const Name: string): THeaders;
    function Get(const Name: string): string;
    function Count: Integer;
    function GetHeaderNames: TArray<string>;
  end;

  THttpRequest = class
  private
    FUrl: string;
    FMethod: THttpMethod;
    FBody: string;
    FContentType: string;
    FHeaders: THeaders;
    FEsperaRetorno: Boolean;
    FCodeApi: Integer;
    function GetResponseText: string;
  public
    property ResponseText: string read GetResponseText;
    property CodeApi: Integer read FCodeApi;
    property Headers: THeaders read FHeaders;
    constructor Create;
    destructor Destroy; override;
    class function New: THttpRequest;
    function SetUrl(const pURL: string): THttpRequest;
    function SetMethod(const pMethod: THttpMethod): THttpRequest;
    function SetBody(const pBody: string): THttpRequest;
    function SetContentType(const pContentType: string): THttpRequest;
    function SetEsperaRetorno(pEsperaRetorno: Boolean): THttpRequest;
    function Execute: string;
  end;

implementation

function HttpMethodToString(Method: THttpMethod): string;
begin
  case Method of
    mmGet   : Result := 'GET';
    mmPost  : Result := 'POST';
    mmPut   : Result := 'PUT';
    mmDelete: Result := 'DELETE';
  else
    Result := 'GET';
  end;
end;

{ THeaders }
constructor THeaders.Create;
begin
  FHeaders := TDictionary<string, string>.Create;
end;

destructor THeaders.Destroy;
begin
  FHeaders.Free;
  inherited;
end;

function THeaders.Add(const Name, Value: string): THeaders;
begin
  FHeaders.AddOrSetValue(Name, Value);
  Result := Self;
end;

function THeaders.Remove(const Name: string): THeaders;
begin
  FHeaders.Remove(Name);
  Result := Self;
end;

function THeaders.Get(const Name: string): string;
begin
  if FHeaders.ContainsKey(Name) then
    Result := FHeaders[Name]
  else
    Result := '';
end;

function THeaders.Count: Integer;
begin
  Result := FHeaders.Count;
end;

function THeaders.GetHeaderNames: TArray<string>;
begin
  Result := FHeaders.Keys.ToArray;
end;


{ THttpRequest }

function THttpRequest.GetResponseText: string;
begin
 Result := Execute;
end;

constructor THttpRequest.Create;
begin
  FHeaders := THeaders.Create;
end;

destructor THttpRequest.Destroy;
begin
  FHeaders.Free;
  inherited;
end;

class function THttpRequest.New: THttpRequest;
begin
  Result := THttpRequest.Create;
end;

function THttpRequest.SetUrl(const pURL: string): THttpRequest;
begin
  FUrl := pURL;
  Result := Self;
end;

function THttpRequest.SetMethod(const pMethod: THttpMethod): THttpRequest;
begin
  FMethod := pMethod;
  Result := Self;
end;

function THttpRequest.SetBody(const pBody: string): THttpRequest;
begin
  FBody := pBody;
  Result := Self;
end;

function THttpRequest.SetContentType(const pContentType: string): THttpRequest;
begin
  FContentType := pContentType;
  Result := Self;
end;

function THttpRequest.SetEsperaRetorno(pEsperaRetorno: Boolean): THttpRequest;
begin
  FEsperaRetorno := pEsperaRetorno;
  Result := Self;
end;

function THttpRequest.Execute: string;
var
  Request: OleVariant;
  HeaderName: string;
begin
  CoInitialize(nil);
  try
    Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Request.Open(HttpMethodToString(FMethod), FUrl, (not FEsperaRetorno));
    Request.SetRequestHeader('Content-Type', FContentType);

//     Adiciona todos os headers configurados na subclasse
    for HeaderName in FHeaders.GetHeaderNames do
      Request.SetRequestHeader(HeaderName, FHeaders.Get(HeaderName));

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


end.
