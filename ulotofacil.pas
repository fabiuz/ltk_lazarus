unit uLotofacil;

{$mode objfpc}{$H+}

interface

uses
                  Classes, SysUtils, strUtils;

type

  { Lotofacil }

  { TLotofacil }

  TLotofacil = class
    procedure Analisar_Html(tokens_html: TStrings; out strErro: string);

end;

implementation

{ TLotofacil }

procedure TLotofacil.Analisar_Html(tokens_html: TStrings; out strErro: string);
var
		  uTag_Tabela_Inicio: Integer;
		  uTag_Tabela_Fim: Integer;
		  uIndice: Integer;
		  uIndice_Cabecalho_Inicio: Integer;
		  uIndice_Cabecalho_Fim: Integer;
		  uColuna_Quantidade: Integer;
begin
     if Assigned(tokens_html) = false then begin
       strErro:= 'tokens_html é nulo.';
       Exit;
     end;

     if tokens_html.Count = 0 then begin
       strErro:= 'tokens_html está vazio.';
     end;

     // Vamos verifica se existe um tag html de tabela.
     uTag_Tabela_Inicio := tokens_html.IndexOf('<table');

     // if uTag_Table_Posicao = -1, vamos verificar se esta na forma '<table'>
     if uTag_Tabela_Inicio = -1 then begin
       uTag_Tabela_Inicio := tokens_html.IndexOf('<table>');

       if uTag_Tabela_Inicio = -1 then begin
         strErro := 'Não existe uma tabela no conteúdo html.';
         Exit;
       end;

     end;

     // Vamos verifica se existe um tag html de fim de tabela: '</table>':
     uTag_Tabela_Fim := tokens_html.IndexOf('</table');

     if uTag_Tabela_Fim = -1 then begin
       // Não encontramos o fim da tabela indicar um erro.
       strErro:= 'Existe o tag de início de tabela, entretanto, não existe ' +
                 ' o tag de fim de tabela.';
       Exit;
     end;

     // Vamos apontar um token após '<table'
     uIndice := uTag_Tabela_Inicio + 1;

     // Vamos localizar o início do cabeçalho.
     while (uIndice <= uTag_Tabela_Fim) and
           (AnsiStartsStr('<tr', tokens_html.Strings[uIndice]) = false) do begin
                                 Inc(uIndice);
     end;

     // Vamos verificar se realmente, encontramos o token '<tr>' ou '<tr'
     if (tokens_html.Strings[uIndice] <> '<tr>') and
        (tokens_html.Strings[uIndice] <> '<tr') then begin
        strErro := 'Tag ''<tr'' ou ''<tr>'' não localizado.';
        Exit;
     end;

     uIndice_Cabecalho_Inicio := uIndice;

     // Vamos localizar o fim do cabeçalho.
     while (uIndice <= uTag_Tabela_Fim) and
           (tokens_html.Strings[uIndice] <> '</tr>') do begin
           Inc(uIndice);
     end;

     if uIndice > uTag_Tabela_Fim then begin
       strErro := 'Fim inesperado do arquivo, tag de fim de fileira de cabeçalho ' +
                  ' não localizado.';
       Exit;
     end;

     uIndice_Cabecalho_Fim := uIndice;

     uColuna_Quantidade := 0;










end;

end.

