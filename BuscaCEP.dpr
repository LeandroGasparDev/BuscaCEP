program BuscaCEP;

uses
  Vcl.Forms,
  uCEP in 'uCEP.pas' {frmBuscaCep},
  uHttpRequest in 'uHttpRequest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmBuscaCep, frmBuscaCep);
  Application.Run;
end.
