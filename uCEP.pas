unit uCEP;

interface

uses
  Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.Mask, Vcl.Controls, System.Classes, Vcl.StdCtrls,
  System.SysUtils, System.JSON, System.StrUtils, system.Math ;

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
  vobjJSON  : TJSONObject;
  vRequest  : THttpRequest;
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
    try
      vRequest  := THttpRequest.New
                               .SetUrl(vstrUrl)
                               .SetMethod(mmGet)
                               .SetContentType('application/json')
                               .SetEsperaRetorno(True);
      with vRequest do
      begin
        FormData.AddField('FieldName','FieldValue');
        FormData.AddField('FieldName','FieldValue');
        FormData.AddField('FieldName','FieldValue');
        FormData.AddField('FieldName','FieldValue');
        FormData.AddField('FieldName','FieldValue');
      end;
      Response := vRequest.Execute;

      vstrJSON := Utf8ToAnsi(Response.ResponseText);
      vobjJSON := TJSONObject.ParseJSONValue(vstrJSON) as TJSONObject;
    finally
      Response.Free;
    end;

    try
      if Assigned(vobjJSON) then
        mmResult.Text := vobjJSON.Format
      else
        ShowMessage('Resposta inválida ou erro ao parsear JSON.');
    finally
      vobjJSON.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao realizar a requisição: ' + E.Message);
  end;
end;

end.
