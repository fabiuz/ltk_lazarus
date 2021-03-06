unit ultk_gerador_aleatorio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, ButtonPanel;

type

  { TfrmGeradorAleatorio }

  TfrmGeradorAleatorio = class(TForm)
    btnGerar: TButton;
    btnCopiar: TButton;
    cmbJogoTipo: TComboBox;
    cmbJogoCom: TComboBox;
    cmbJogoQuantidade: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
    StringGrid1: TStringGrid;
		procedure btnGerarClick(Sender: TObject);
    procedure cmbJogoTipoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
		procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

const
  JogoTipo : array[0..7] of string = ('QUINA', 'MEGASENA', 'LOTOFACIL', 'LOTOMANIA',
                                               'DUPLASENA', 'INTRALOT_MINAS_5',
                                               'INTRALOT_LOTOMINAS', 'INTRALOT_KENO');
type
  JogoInfo = record
    JogoTipo: string;
    bolaInicial: Integer;
    bolaFinal: Integer;
    bolaAposta: TObjectList;
    end;

implementation
uses uMain;

{$R *.lfm}

{ TfrmGeradorAleatorio }

procedure TfrmGeradorAleatorio.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  frmMain.mnGeradorAleatorio.Enabled:=true;
  //CloseAction := TCloseAction.caFree;
end;

procedure TfrmGeradorAleatorio.FormCreate(Sender: TObject);
begin

end;

procedure TfrmGeradorAleatorio.FormShow(Sender: TObject);
var
  iA: integer;
begin
  // Ao iniciar o formulário devemos preencher o controle 'cmbJogoQuantidade'
  // com números de 1 a 1000.

  cmbJogoQuantidade.Items.Clear;
  for iA := 1 to 1000 do
  begin
    cmbJogoQuantidade.Items.Add('Teste' + IntToStr(iA) + ' jogo(s).');
  end;

  cmbJogoQuantidade.ItemHeight := 10;
  cmbJogoTipo.ItemIndex:=0;
  self.cmbJogoTipoChange(cmbJogoTipo);
end;

procedure TfrmGeradorAleatorio.cmbJogoTipoChange(Sender: TObject);
var
  strJogoTipo: string;
  iA: Integer;
begin
  // Vamos colocar em maiúsculas para evitar ficar convertendo depois.
  strJogoTipo := UpCase(cmbJogoTipo.Text);
  cmbJogoCom.Items.Clear;

  if (strJogoTipo = 'DUPLASENA') or (strJogoTipo = 'MEGASENA') then
  begin
     for iA := 6 to 15 do
    begin
      cmbJogoCom.Items.Add('com ' + IntToStr(iA) + ' números.');
    end;
  end else
  if strJogoTipo = 'QUINA' then
  begin
    for iA := 5 to 7 do
    begin
      cmbJogoCom.Items.Add('com ' + IntToStr(iA) + ' números.');
    end;
  end else
  if strJogoTipo = 'LOTOFACIL' then
  begin
    for iA := 15 TO 18 DO
    begin
      cmbJogoCom.Items.Add('com ' + IntToStr(iA) + ' números.');
    end;
  end else
  if strJogoTipo = 'LOTOMANIA' then
     cmbJogoCom.Items.Add('com 50 números');

  // Selecionar sempre o primeiro item do controle 'cmbJogoCom'
  cmbJogoCom.ItemIndex := 0;
  cmbJogoQuantidade.ItemIndex := 0;



  // Alterar a caixa de combinação chamada 'cmbJogoCom'
end;

procedure TfrmGeradorAleatorio.btnGerarClick(Sender: TObject);
begin

end;

end.

