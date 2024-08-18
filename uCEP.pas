unit uCEP;

interface

uses
  Vcl.Forms, Vcl.Dialogs, superobject, Vcl.Buttons,
  Vcl.Mask, Vcl.Controls, System.Classes, Vcl.StdCtrls;

type
  TfrmBuscaCep = class(TForm)
    Label1: TLabel;
    edtCEP: TMaskEdit;
    btnBuscarCep: TBitBtn;
    mmResult: TMemo;
    procedure btnBuscarCepClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBuscaCep: TfrmBuscaCep;

implementation

{$R *.dfm}

uses uFuncoes, uHttpRequest;

procedure TfrmBuscaCep.btnBuscarCepClick(Sender: TObject);
var
  CEP, url     : String;
  HttpRequest  : THttpRequest;
  Response     : string;
  objRetorno   : ISuperObject;
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
    HttpRequest  := THttpRequest.Create(url,'GET','','application/json',True);
    Response     := HttpRequest.Execute;

    objRetorno    := SO(Utf8ToAnsi(Response));
    mmResult.Text := (objRetorno.AsJSon(True));

  finally
    HttpRequest.Free;
  end;
end;


end.
