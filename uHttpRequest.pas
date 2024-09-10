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
    destructor  Destroy; override;
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

  type
    TMultipartFormData = class
    private
      FBoundary: string;
      FParts: TStringList;
      function GenerateBoundary: string;
    public
      constructor Create;
      destructor Destroy; override;
      function AddField(const FieldName, FieldValue: string): TMultipartFormData;
      function AddFile(const FieldName, FileName: string; const ContentType: string = 'application/octet-stream'): TMultipartFormData;
      function GetContentType: string;
      function GetRequestBody: string;
      property Boundary: string read FBoundary;
    end;

type
  TQueryParams = class
  private
    FQueryParams: TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const Key, Value: string): TQueryParams;
    function Remove(const Key: string): TQueryParams;
    function Get(const Name: string): string;
    function Count: Integer;
    function GetParamNames: TArray<string>;
    function UrlQueryString: string;
  end;

  THttpRequest = class
  private
    FUrl: string;
    FMethod: THttpMethod;
    FBody: string;
    FContentType: string;
    FHeaders: THeaders;
    FFormData: TMultipartFormData;
    FParams : TQueryParams;
    FEsperaRetorno: Boolean;
    FCodeApi: Integer;
    function GetFormData: TMultipartFormData;
  public
    property Headers: THeaders read FHeaders;
    property QParams: TQueryParams read FParams;
    property FormData: TMultipartFormData read GetFormData;

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

{ TQueryParams }

function TQueryParams.Add(const Key, Value: string): TQueryParams;
begin
  FQueryParams.AddOrSetValue(Key, Value);
  Result := Self;
end;

function TQueryParams.Count: Integer;
begin
  Result := FQueryParams.Count;
end;

constructor TQueryParams.Create;
begin
  FQueryParams := TDictionary<string, string>.Create;
end;

destructor TQueryParams.Destroy;
begin
  FQueryParams.Free;
  inherited;
end;

function TQueryParams.Get(const Name: string): string;
begin
  if FQueryParams.ContainsKey(Name) then
    Result  := FQueryParams[Name]
  else
    Result  := '';
end;

function TQueryParams.GetParamNames: TArray<string>;
begin
  Result := FQueryParams.Keys.ToArray;
end;

function TQueryParams.Remove(const Key: string): TQueryParams;
begin
  FQueryParams.Remove(Key);
  Result  := Self;
end;

function TQueryParams.UrlQueryString: string;
var
  QueryString: string;
begin
  //
end;

{ THttpRequest }

constructor THttpRequest.Create;
begin
  FHeaders        := THeaders.Create;
  FParams         := TQueryParams.Create;
  FFormData       := nil;
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
  FParams.Free;
  FFormData.Free;
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

    try
      Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    except
      on E: Exception do
        raise Exception.Create('Falha ao criar objeto WinHttpRequest: ' + E.Message);
    end;

    if (FMethod in [mmPost, mmPut]) and (Assigned(FFormData) and (FFormData.FParts.Count > 0)) then
    begin
      FBody        := FFormData.GetRequestBody;
      FContentType := FFormData.GetContentType;
    end;

    Request.Open(HttpMethodToString(FMethod), FUrl, (not FEsperaRetorno));
    Request.SetRequestHeader('Content-Type', FContentType);

    for HeaderName in FHeaders.GetHeaderNames do
      Request.SetRequestHeader(HeaderName, FHeaders.Get(HeaderName));

    try
      Request.Send(FBody);
    except
      on E: Exception do
        raise Exception.Create('Erro ao enviar a requisição Http/Rest: ' + E.Message);
    end;

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

      try
        Result := Response;
      except
        on E: Exception do
        begin
          Response.Free;
          raise Exception.Create('Erro ao processar a resposta: ' + E.Message);
        end;
      end;

    except
      Response.Free;
      raise;
    end;

  finally
    Request := Unassigned;
    CoUninitialize;
  end;
end;

function THttpRequest.GetFormData: TMultipartFormData;
begin
if FFormData = nil then
    FFormData := TMultipartFormData.Create;  // Cria a instância sob demanda
  Result := FFormData;
end;

{ TMultipartFormData }

function TMultipartFormData.AddField(const FieldName, FieldValue: string): TMultipartFormData;
begin
  FParts.Add('--' + FBoundary);
  FParts.Add('Content-Disposition: form-data; name="' + FieldName + '"');
  FParts.Add('');
  FParts.Add(FieldValue);
  Result := Self;
end;

function TMultipartFormData.AddFile(const FieldName, FileName, ContentType: string): TMultipartFormData;
var
  FileStream: TFileStream;
  Buffer: TBytes;
begin
  if not FileExists(FileName) then
    raise Exception.Create('Arquivo não encontrado: ' + FileName);
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Buffer, FileStream.Size);
    FileStream.ReadBuffer(Buffer[0], FileStream.Size);
    FParts.Add('--' + FBoundary);
    FParts.Add('Content-Disposition: form-data; name="' + FieldName + '"; filename="' + ExtractFileName(FileName) + '"');
    FParts.Add('Content-Type: ' + ContentType);
    FParts.Add('');
    FParts.Add(TEncoding.Default.GetString(Buffer));
  finally
    FileStream.Free;
  end;
  Result := Self;
end;

constructor TMultipartFormData.Create;
begin
  FBoundary := GenerateBoundary;
  FParts := TStringList.Create;
end;

destructor TMultipartFormData.Destroy;
begin
  FParts.Free; // Libera a memória
  inherited;
end;

function TMultipartFormData.GenerateBoundary: string;
begin
  // Gera um boundary único baseado em uma string aleatória
  Result := '----WebKitFormBoundary' + IntToStr(Random(MaxInt));
end;

function TMultipartFormData.GetContentType: string;
begin
 Result := 'multipart/form-data; boundary=' + FBoundary;
end;

function TMultipartFormData.GetRequestBody: string;
begin
  FParts.Add('--' + FBoundary + '--');
  Result := FParts.Text;
end;

end.
