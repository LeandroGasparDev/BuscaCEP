unit uCEP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, IdMultipartFormData,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  IdSSLOpenSSL, IdHTTP, ExtCtrls, ComObj, ActiveX, IdCoderMIME,
  AxCtrls, Vcl.Buttons, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  Vcl.Mask, superobject;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    edtCEP: TMaskEdit;
    BitBtn1: TBitBtn;
    mmResult: TMemo;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function HttpRequest(const aBody: string; const aMethod: String; aURL: String; aTimeout: integer; const aContentType: string = '') : TStringStream;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses uFuncoes;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  CEP, url     : String;
 _StringStream  : TStringStream;
 objRetorno     : ISuperObject;

begin
  CEP := ApenasNumeros(edtCEP.Text);
  if CEP = '' then
  begin
    ShowMessage('Informe o CEP!');
    edtCEP.SetFocus;
    edtCEP.SelectAll;
    Exit;
  end;

  url := 'https://viacep.com.br/ws/'+CEP+'/'+'json'+'/';

  try
    _StringStream := HttpRequest(NullAsStringValue, 'GET', url, 100000, 'application/json');

    objRetorno    := SO(Utf8ToAnsi(_StringStream.DataString));
    mmResult.Text := (objRetorno.AsJSon(True));

  finally
    _StringStream.Free;
  end;
end;

function TForm1.HttpRequest(const aBody, aMethod: String; aURL: String;
  aTimeout: integer; const aContentType: string): TStringStream;
var
  Request       : OleVariant;
  HttpStream    : IStream;
  OleStream     : TOleStream;
  _StringStream : TStringStream;
begin
  CoInitialize(nil);
  _StringStream := TStringStream.Create;
  try
    Request := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Request.Open(aMethod, aURL, False);
    Request.SetRequestHeader('Content-Type', aContentType);
    Request.Send(aBody);
    HttpStream := IUnknown(Request.ResponseStream) as IStream;

    OleStream := TOleStream.Create(HttpStream);
    _StringStream.LoadFromStream(OleStream);

    Result := _StringStream
  finally
    OleStream.Free;
    Request := Unassigned;
    CoUninitialize;
  end;

end;

end.
