unit uLtk;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ComCtrls, SynHighlighterHTML, IdFTP,
  uLotofacil_database;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnGerador_combinatorio: TButton;
    btnGerador_combinatorio1: TButton;
    Button1: TButton;
    Button2: TButton;
    btnGerador_Permutacao: TButton;
    btnAtualizar_Intralot: TButton;
    Button3 : TButton;
    Button4 : TButton;
    IdFTP1: TIdFTP;
    StatusBar1 : TStatusBar;
    procedure btnAtualizar_IntralotClick(Sender: TObject);
    procedure btnGerador_combinatorio1Click(Sender: TObject);
    procedure btnGerador_combinatorioClick(Sender: TObject);
    procedure btnGerador_Permutacao1Click(Sender: TObject);
    procedure btnGerador_PermutacaoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender : TObject);
    procedure Button4Click(Sender : TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
    ltfDatabase: TLotofacilDatabase;
    procedure lotofacilThreadStatus(qtGerados: LongInt);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

uses uAtualizar, uGerador_Permutacao, uintralot_extrator, uLotofacilGerador,
  uGerador_Combinatorio, uGerador_Aleatorio;

var
  frmGerador_Permutacao: TFrmGerador_Permutacao;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  frmAtualizar.ShowModal;
  MessageDlg('TEste', TMsgDlgType.mtConfirmation, [mbOK], 0);
end;

procedure TForm1.btnGerador_PermutacaoClick(Sender: TObject);
begin
  if not Assigned(frmGerador_Permutacao) then
  begin
    frmGerador_Permutacao := TFrmGerador_Permutacao.Create(TComponent(Sender));
  end;
  frmGerador_Permutacao.ShowModal;
end;

procedure TForm1.btnAtualizar_IntralotClick(Sender: TObject);
var
  frmIntralot_Extrator: TfrmIntralot_Extrator;
begin
  frmIntralot_Extrator := TFrmIntralot_Extrator.Create(TComponent(Sender));
  if Assigned(frmIntralot_Extrator) then
  begin
    frmIntralot_Extrator.ShowModal;
    frmIntralot_Extrator.FreeOnRelease;
  end;

end;

procedure TForm1.btnGerador_combinatorio1Click(Sender: TObject);
begin
  frmGerador_Aleatorio := TFrmGerador_Aleatorio.Create(TComponent(Sender));
  frmGerador_Aleatorio.ShowModal;
  if Assigned(frmGerador_Aleatorio) then
    frmGerador_Aleatorio.Free;
end;

procedure TForm1.btnGerador_combinatorioClick(Sender: TObject);
var
  frmGerador_Combinatorio: TFrmGerador_combinatorio;
begin
  frmGerador_Combinatorio := TFrmGerador_Combinatorio.Create(TComponent(Sender));
  if Assigned(frmGerador_Combinatorio) then
  begin
    frmGerador_Combinatorio.ShowModal;
    frmGerador_Combinatorio.FreeOnRelease;
  end;
end;

procedure TForm1.btnGerador_Permutacao1Click(Sender: TObject);
begin

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  jogoLotofacil: TLotofacil;
begin
  jogoLotofacil := TLotofacil.Create;
  jogoLotofacil.Gerar15Numeros;
end;

procedure TForm1.Button3Click(Sender : TObject);
begin
  if ltfDatabase = nil then begin
    ltfDatabase := TLotofacilDatabase.Create;
  end;

  ltfDatabase.onStatus := @self.lotofacilThreadStatus;
  ltfDatabase.GerarLotofacil15Numeros;
end;

procedure TForm1.Button4Click(Sender : TObject);
begin
  if ltfDatabase = nil then begin
    ltfDatabase := TLotofacilDatabase.Create;
  end;

  ltfDatabase.GerarSubConjuntos;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Assigned(FrmAtualizar) then
  begin
    frmAtualizar.Free;
  end;

end;

procedure TForm1.lotofacilThreadStatus(qtGerados : LongInt);
begin
     statusBar1.Panels[0].Text := IntToStr(qtGerados);
end;

end.
