unit dmLtk;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Menus, Dialogs;

type

  { TdmModulo }

  TdmModulo = class(TDataModule)
    MenuItem1: TMenuItem;
    mnGerador_Permutacao: TMenuItem;
    mnResultados: TMenuItem;
    mnIntralot_Resultado: TMenuItem;
    mnBanco_de_Dados: TMenuItem;
    mnOpcoes: TMenuItem;
    menu_Ajuda_Sobre: TMenuItem;
    menu_Ajuda: TMenuItem;
    menu_Ferramentas_Gerador_Aleatorio: TMenuItem;
    menu_Arquivo_Sair: TMenuItem;
    menu_Ferramentas: TMenuItem;
    menu_ltk_principal: TMainMenu;
    dlgExportar_CSV: TSaveDialog;
    procedure menu_Ajuda_SobreClick(Sender: TObject);
    procedure menu_Arquivo_SairClick(Sender: TObject);
    procedure menu_Ferramentas_Gerador_AleatorioClick(Sender: TObject);
    procedure mnBanco_de_DadosClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  dmModulo: TdmModulo;

implementation
uses
  uGerador_Aleatorio, uBanco_de_Dados;

var
  frmGerador_Aleatorio : TfrmGerador_Aleatorio;
  frmBanco_de_Dados: TFrmBanco_de_Dados;

{$R *.lfm}

{ TdmModulo }

procedure TdmModulo.menu_Ferramentas_Gerador_AleatorioClick(Sender: TObject);
begin
  frmGerador_Aleatorio := TFrmGerador_Aleatorio.Create(TComponent(Sender));
  frmGerador_Aleatorio.ShowModal;
  if Assigned(frmGerador_Aleatorio) then
     frmGerador_Aleatorio.Free;
end;

procedure TdmModulo.menu_Ajuda_SobreClick(Sender: TObject);
begin

end;

procedure TdmModulo.menu_Arquivo_SairClick(Sender: TObject);
begin

end;

procedure TdmModulo.mnBanco_de_DadosClick(Sender: TObject);
begin
  frmBanco_de_Dados := TFrmBanco_de_Dados.Create(TComponent(Sender));

  if Assigned(frmBanco_de_Dados) = false then begin
    MessageDlg('Um erro ocorreu!', TmsgDlgType.mtError, [mbOk], 0);
    Exit;
  end;

  frmBanco_de_Dados.ShowModal;

  frmBanco_de_Dados.Free;
end;

end.

