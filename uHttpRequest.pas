unit uHttpRequest;

interface

uses
  System.SysUtils, System.Classes, Winapi.ActiveX, Winapi.WinInet, System.Variants,  System.Win.ComObj, System.Generics.Collections;

type
 THttpMethod = (mmGet, mmPost, mmPut, mmDelete);

type
  TResponse = class
  private
    FResponseCode: Integer;
    FResponseText: string;
    FHeaders     : TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    property ResponseCode: Integer read FResponseCode write FResponseCode;
    property ResponseText: string read FResponseText write FResponseText;
    property Headers: TDictionary<string, string> read FHeaders write FHeaders;
  end;

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
  public
    property Headers: THeaders read FHeaders;
    constructor Create;
    destructor Destroy; override;
    class function New: THttpRequest;
    function SetUrl(const pURL: string): THttpRequest;
    function SetMethod(const pMethod: THttpMethod): THttpRequest;
    function SetBody(const pBody: string): THttpRequest;
    function SetContentType(const pContentType: string): THttpRequest;
    function SetEsperaRetorno(pEsperaRetorno: Boolean): THttpRequest;
    function Execute: TResponse;
  end;

implementation

function HttpMethodToString(Method: THttpMethod): string;
begin
  case Method of
    mmGet     : Result := 'GET';
    mmPost    : Result := 'POST';
    mmPut     : Result := 'PUT';
    mmDelete  : Result := 'DELETE';
  else
    Result    := 'GET';
  end;
end;

{ TResponse }

constructor TResponse.Create;
begin
 FHeaders := TDictionary<string, string>.Create;
end;

destructor TResponse.Destroy;
begin
  FHeaders.Free;
  inherited;
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
  Result  := Self;
end;

function THeaders.Remove(const Name: string): THeaders;
begin
  FHeaders.Remove(Name);
  Result  := Self;
end;

function THeaders.Get(const Name: string): string;
begin
  if FHeaders.ContainsKey(Name) then
    Result  := FHeaders[Name]
  else
    Result  := '';
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

constructor THttpRequest.Create;
begin
  FHeaders        := THeaders.Create;
  FUrl            := '';
  FMethod         := mmGet;
  FBody           := '';
  FContentType    := '';
  FEsperaRetorno  := True;
  FCodeApi        := 0;
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

function THttpRequest.Execute: TResponse;
var
  Request: OleVariant;
  HeaderName, HeaderValue: string;
  Response: TResponse;
  i: Integer;
  HeaderLines : TStringList;
begin
  CoInitialize(nil);
  try
    if FUrl = '' then
      raise Exception.Create('URL não pode ser vazia.');

    Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Request.Open(HttpMethodToString(FMethod), FUrl, (not FEsperaRetorno));
    Request.SetRequestHeader('Content-Type', FContentType);

    for HeaderName in FHeaders.GetHeaderNames do
      Request.SetRequestHeader(HeaderName, FHeaders.Get(HeaderName));

    Request.Send(FBody);

    if not FEsperaRetorno then
      Exit;

    Response := TResponse.Create;
    try
      Response.ResponseCode := Request.Status;
      Response.ResponseText := Request.ResponseText;

      HeaderLines := TStringList.Create;
      try
        HeaderLines.Text := StringReplace(Request.GetAllResponseHeaders, #13#10, #10, [rfReplaceAll]);
        for i := 0 to HeaderLines.Count - 1 do
        begin
          if Pos(': ', HeaderLines[i]) > 0 then
          begin
            HeaderName := Trim(Copy(HeaderLines[i], 1, Pos(':', HeaderLines[i]) - 1));
            HeaderValue := Trim(Copy(HeaderLines[i], Pos(':', HeaderLines[i]) + 2, Length(HeaderLines[i])));

            // Verifica se o header já existe
            if Response.Headers.ContainsKey(HeaderName) then
              Response.Headers[HeaderName] := Response.Headers[HeaderName] + ', ' + HeaderValue
            else
              Response.Headers.Add(HeaderName, HeaderValue);
          end;
        end;
      finally
        HeaderLines.Free;
      end;

      Result := Response;
    except
      Response.Free;
      raise;
    end;

  finally
    Request := Unassigned;
    CoUninitialize;
  end;
end;



end.
