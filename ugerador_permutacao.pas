unit ugerador_permutacao;

{$mode objfpc}{$H+}

interface

uses
  //{$ifdef unix}cthreads, {$endif}

  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, EditBtn, Spin, ComCtrls, strUtils;

type

  // Este record utilizaremos para passar à função Thread
  TJogo_Info = ^ jogo_info;
  jogo_info = record
    strJogo_tipo: string;
    jogo_qt_bolas: integer;
    strPasta: string;
    linhas_por_arquivo: integer;
  end;


  { TFrmGerador_Permutacao }

  TFrmGerador_Permutacao = class(TForm)
    btnGerar: TButton;
    btnParar: TButton;
    btnLocalizar: TButton;
		chkAtivar_Desativar_Log: TCheckBox;
    cmbJogo_Tipo: TComboBox;
    cmbJogo_Com: TComboBox;
    GroupBox1: TGroupBox;
    Jogo: TLabel;
    Jogo1: TLabel;
    Label1: TLabel;
    edDiretorio: TLabeledEdit;
    dlgDiretorio: TSelectDirectoryDialog;
		rotulo_status: TLabel;
    mmLog: TMemo;
    ProgressBar1: TProgressBar;
    spLinhas_por_Arquivo: TSpinEdit;
    procedure btnGerarClick(Sender: TObject);
		procedure CheckBox1Change(Sender: TObject);
		procedure chkAtivar_Desativar_LogChange(Sender: TObject);
    procedure cmbJogo_TipoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure edDiretorioChange(Sender: TObject);
		procedure Permutacao_Concluida(strStatus: string);
  private
    procedure Preencher_Lista_de_Jogo;
    procedure Preencher_Lista_Jogo_Com;
		procedure Preencher_Log(strLog: string);

    { private declarations }
  private
    permutacao_info: jogo_info;
    idThread: integer;

  public
    { public declarations }
  end;


implementation
uses uPermutador_Thread;
var
  objPermutador: TPermutador_Thread;

const
  strJogo_Tipo: array[0..7] of string = ('DUPLASENA', 'LOTOFACIL',
    'LOTOMANIA', 'MEGASENA', 'QUINA', 'INTRALOT_MINAS_5',
    'INTRALOT_LOTOMINAS', 'INTRALOT_KENO_MINAS');
var
  strJogo_Com: array[0..7] of TStrings;

{$R *.lfm}


{ TFrmGerador_Permutacao }

procedure TFrmGerador_Permutacao.FormCreate(Sender: TObject);
begin
  Preencher_Lista_Jogo_com;
  Preencher_Lista_de_Jogo;
  edDiretorio.Text := 'gerador_combinacao_sql/';
end;

procedure TFrmGerador_Permutacao.edDiretorioChange(Sender: TObject);
begin
  if edDiretorio.Text = '' then
  begin
    btnGerar.Enabled := False;
  end
  else
  begin
    btnGerar.Enabled := True;
  end;

end;

procedure TFrmGerador_Permutacao.Permutacao_Concluida(strStatus: string);
begin
      mmLog.Lines.Add('Permutação concluída com sucesso.');

      // Reativa os controles.
      btnGerar.Enabled := true;
		  edDiretorio.Enabled := true;
		  btnLocalizar.Enabled := true;
		  btnParar.Enabled := False;
end;


// Aqui, toda vez que o usuário alterar o conteúdo do controle
// cmbJogo_Tipo, devemos atualizar o controle cmbJogo_com para refletir
// o novo jogo.
procedure TFrmGerador_Permutacao.cmbJogo_TipoChange(Sender: TObject);
var
  iJogo_Tipo_Indice: integer;
begin
  iJogo_Tipo_Indice := cmbJogo_Tipo.ItemIndex;
  if iJogo_Tipo_Indice < 0 then
  begin
    Exit;
  end;

  cmbJogo_Com.Items.Clear;
  cmbJogo_Com.Items.AddStrings(strJogo_Com[iJogo_Tipo_Indice]);
  cmbJogo_Com.ItemIndex := 0;
end;



// Quando o usuário clicar no botão gerar, iremos criar um thread para
// ficar mais rápido a executação do processamento
procedure TFrmGerador_Permutacao.btnGerarClick(Sender: TObject);
var
  iBolas_Quantidade: integer;
  strTexto: string;
  iEspaco_Posicao: SizeInt;
  strPasta: TCaption;
begin
  permutacao_info.strJogo_tipo := cmbJogo_Tipo.Text;

  // A quantidade de bolas ficar informada no controle 'jogo_com'.
  // Ela está no layout: 'com 5 números'.

  strTexto := LowerCase(cmbJogo_Com.Text);

  // Se não existe um palavra começando com 'com ', indicar um erro.
  if not AnsiStartsStr('com ', strTexto) then
  begin
    ShowMessage('Jogo_com não começa com a palavra ''com ''');
    Exit;
  end;

  // Aponta strTexto, 1 caractere após a string 'com '.
  strTexto := AnsiMidStr(strTexto, 4, Length(strTexto));
  strTexto := Trim(strTexto);

  // Vamos procurar pelo caractere #32
  iEspaco_Posicao := AnsiPos(#32, strTexto);
  if iEspaco_Posicao = 0 then
  begin
    ShowMessage('Conteúdo do controle ''cmbJogo_Com'' inválido.');
    Exit;
  end;

  // Acharmos pegar os caracteres antes do espaço
  strTexto := AnsiMidStr(strTexto, 1, iEspaco_Posicao);
  strTexto := Trim(strTexto);
  if strTexto = '' then
  begin
    ShowMessage('Número não encontrado.');
  end;

  // Achamos o número vamos tentar convertê-lo.
  try
    iBolas_Quantidade := StrToInt(strTexto);
  except
    ShowMessage('Número não encontrado.');
    Exit;
  end;

  strPasta := edDiretorio.Text;
  if strPasta = '' then
  begin
    ShowMessage('Pasta está vazia.');
    Exit;
  end;

  // Vamos verificar se diretório existe, senão, iremos indicar um erro.
  if not DirectoryExists(strPasta) then
  begin
    MessageDlg('Erro', 'Diretório não existe', TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  try
     objPermutador := TPermutador_Thread.Create(true, strPasta, permutacao_info.strJogo_tipo,
     iBolas_Quantidade, spLinhas_por_Arquivo.Value);
	except ON exc:Exception do begin
    MessageDlg('Erro: ' + exc.Message, TMsgDlgType.mtError, [mbOk], 0);
    Exit;
  end;
	end;

  mmLog.Clear;
  objPermutador.permutador_status := @Preencher_Log;
  objPermutador.permutador_status_concluido:=@Permutacao_Concluida;
  objPermutador.Execute;


  btnGerar.Enabled := False;
  edDiretorio.Enabled := False;
  btnLocalizar.Enabled := False;
  btnParar.Enabled := True;

end;

procedure TFrmGerador_Permutacao.CheckBox1Change(Sender: TObject);
begin

end;

procedure TFrmGerador_Permutacao.chkAtivar_Desativar_LogChange(Sender: TObject);
begin


      if chkAtivar_Desativar_Log.Checked = true then begin
        if Assigned(objPermutador) then begin
           objPermutador.permutador_status := @Preencher_Log;
           objPermutador.permutador_status_concluido:=@Permutacao_Concluida;
				end;
			end else begin
        if Assigned(objPermutador) then begin
         objPermutador.permutador_status := nil;
         objPermutador.permutador_status_concluido:=nil;
				end;
			end;
end;

procedure TFrmGerador_Permutacao.Preencher_Log(strLog: string);
begin
  //mmLog.Lines.Insert(0, strLog);
  rotulo_status.Caption := strLog;
  rotulo_status.refresh;
end;

procedure TFrmGerador_Permutacao.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
var
  iA: integer;
begin
  if Assigned(objPermutador) then begin
   objPermutador.Parar_Permutacao;
	end;

  for iA := Low(strJogo_com) to High(strJogo_com) do
  begin
    if (Assigned(strJogo_com[iA])) then
    begin
      strJogo_com[iA].Free;
    end;
  end;
end;

// Preenche o listBox com o nome dos jogos.
procedure TFrmGerador_Permutacao.Preencher_Lista_de_Jogo;
var
  iA: integer;
begin
  for iA := Low(strJogo_Tipo) to High(strJogo_Tipo) do
  begin
    cmbJogo_Tipo.Items.Add(strJogo_Tipo[iA]);
  end;
end;

// Preenche o arranjo de lista com a quantidade de números por jogo.
procedure TFrmGerador_Permutacao.Preencher_Lista_Jogo_Com;
var
  iA: integer;
  iB: integer;
begin

  for iA := Low(strJogo_com) to High(strJogo_com) do
  begin
    strJogo_com[iA] := TStringList.Create;
  end;


  // Vamos percorrer o arranjo e prencher, conforme jogo encontrado.
  for iA := Low(strJogo_Tipo) to High(strJogo_Tipo) do
  begin
    if (strJogo_Tipo[iA] = 'DUPLASENA') or (strJogo_Tipo[iA] = 'MEGASENA') then
    begin
      // DUPLASENA E MEGASENA você pode jogar de 6 a 15 números.
      for iB := 6 to 15 do
      begin
        strJogo_com[iA].Add('com ' + IntToStr(iB) + ' números.');
      end;
      Continue;
    end;

    // Lotofacil joga-se de 15 a 18 números.
    if strJogo_Tipo[iA] = 'LOTOFACIL' then
    begin
      for iB := 15 to 18 do
      begin
        strJogo_com[iA].Add('com ' + IntToStr(iB) + ' números.');
      end;
      Continue;
    end;

    // Na quina, joga-se de 5 a 7 números.
    if strJogo_Tipo[iA] = 'QUINA' then
    begin
      for iB := 5 to 7 do
      begin
        strJogo_Com[iA].Add('com ' + IntToStr(iB) + ' números.');
      end;
    end;

    // Na jogo Keno_Minas, da Intralot, o jogador pode jogar de 1 a 10 números.
    if strJogo_Tipo[iA] = 'INTRALOT_KENO_MINAS' then
    begin
      for iB := 1 to 10 do
      begin
        begin
            strJogo_com[iA].Add('com ' + IntToStr(iB) + ' números.');
				end;
			end;


    // Na lotomania joga-se de 50 números, é possível jogar-menos, entretanto
    // O sistema da loteria preenche aleatoriamente os números, então iremos
    // considerar somente com 50 números.
		end;


    if strJogo_Tipo[iA] = 'LOTOMANIA' then
    begin
      strJogo_com[iA].Add('com 50 números.');
      Continue;
    end;

    if strJogo_Tipo[iA] = 'INTRALOT_MINAS_5' then
    begin
      strJogo_com[iA].Add('com 5 números.');
    end;

    if strJogo_Tipo[iA] = 'INTRALOT_LOTOMINAS' then
    begin
      strJogo_com[iA].Add('com 6 números.');
    end;

  end;
end;



end.
