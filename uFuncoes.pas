unit uFuncoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics;


function ApenasNumeros(const Texto: string): string;



implementation


function ApenasNumeros(const Texto: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Texto) do
  begin
    if Texto[i] in ['0'..'9'] then
      Result := Result + Texto[i];
  end;

end;

end.
