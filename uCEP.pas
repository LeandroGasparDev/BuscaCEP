unit uCEP;

interface

uses
  Vcl.Forms, Vcl.Dialogs, superobject, Vcl.Buttons, Vcl.Mask, Vcl.Controls, System.Classes, Vcl.StdCtrls,
  System.SysUtils, System.JSON;

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

uses uFuncoes, uHttpRequest ;

procedure TfrmBuscaCep.btnBuscarCepClick(Sender: TObject);
var
  vstrCEP,
  vstrUrl,
  vstrJSON  : String;
  Response  : TResponse;
  JSONObj   : TJSONObject;
begin
  vstrCEP := ApenasNumeros(edtCEP.Text);
  if vstrCEP = '' then
  begin
    ShowMessage('Informe o CEP!');
    edtCEP.SetFocus;
    edtCEP.SelectAll;
    Exit;
  end;

  vstrUrl := 'https://viacep.com.br/ws/'+vstrCEP+'/'+'json'+'/';
  try
     Response := THttpRequest.New
                             .SetUrl(vstrUrl)
                             .SetMethod(mmGet)
                             .SetContentType('application/json')
                             .SetEsperaRetorno(True)
                           //.Headers.Add('Authorization', 'Bearer token_aqui')
                           //.Headers.Add('Header', 'HeaderValor')
                             .Execute;

    vstrJSON := Utf8ToAnsi(Response.ResponseText);
    JSONObj := TJSONObject.ParseJSONValue(vstrJSON) as TJSONObject;
    try
      if Assigned(JSONObj) then
        mmResult.Text := JSONObj.Format
      else
        ShowMessage('Resposta inválida ou erro ao parsear JSON.');
    finally
      JSONObj.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao realizar a requisição: ' + E.Message);
  end;
end;

end.
