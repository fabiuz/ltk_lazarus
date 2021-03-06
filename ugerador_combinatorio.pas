unit ugerador_combinatorio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Grids;

// Este registro guarda a informação do jogo escolhido, a quantidade de números jogados
// e a quantidade de volantes jogados.
type
  TJogoInfo = record
    JogoTipo: string;
    bolaInicial: integer;
    bolaFinal: integer;

    // Cada jogo, pode-se apostar tantas bolas
    bolaAposta: integer;

    // Quantidade de volantes apostados.
    quantidadeBilhetes: integer;

    // Indica, que todos os números devem ser sorteados, antes de repetir um novo número.
    naoRepetirBolas: boolean;

    // Alternar entre par e impar.
    alternarParImpar: boolean;

    // Cada grupo de bola terá x bolas que não estarão em outro grupo.
    bolas_combinadas: integer;
  end;

const
  JogoTipo: array[0..7] of string = ('DUPLASENA', 'LOTOFACIL',
    'LOTOMANIA', 'MEGASENA', 'QUINA', 'INTRALOT_MINAS_5',
    'INTRALOT_LOTOMINAS', 'INTRALOT_KENO_MINAS');


type

  { TJogoThread }

  TJogoThread = class(TThread)
  public
    constructor Create(jogoInfo: TJogoInfo; jogoGrade: TStringGrid; CreateSuspended: boolean);
    procedure Execute; override;

  private
    jogoInfo: TJogoInfo;
    jogoGrade: TStringGrid;
		procedure GerarLotomania;
		procedure GerarLotomaniaGrupo10Numeros;
		procedure GerarLotomaniaGrupo2Numeros;
		procedure GerarLotomaniaGrupo5Numeros;
  procedure Preencher_Grade;
  end;

type

  { TfrmGerador_Combinatorio }

  TfrmGerador_Combinatorio = class(TForm)
    btnImportar: TButton;
    btnGerar: TButton;
    btnCopiar: TButton;
    btnExportar: TButton;
    btnLimpar_Resultados: TButton;
		chkAlternarParImpar: TCheckBox;
		chkAlternarParImpar1: TCheckBox;
    cmbJogo_Tipo: TComboBox;
    cmbJogo_com: TComboBox;
    cmbJogo_Quantidade: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
		Label5: TLabel;
    panel_Superior: TPanel;
    Panel2: TPanel;
    panel_Direito: TPanel;
    StatusBar1: TStatusBar;
    gradeJogos: TStringGrid;
    procedure btnCopiarClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnGerarClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure btnLimpar_ResultadosClick(Sender: TObject);
    procedure cmbJogo_comChange(Sender: TObject);
    procedure cmbJogo_TipoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    strJogo_Tipo: string;
    strErro: string;
    iJogo_com, iJogo_Quantidade: integer;

    iMenor_Bola, iMaior_Bola: integer;

    // Indica a quantidade de bolas, que compõe o jogo.
    iQuantidade_de_Bolas: integer;

    // Estrutura que guarda o jogo selecionado.
    jogoInfo: TJogoInfo;

    // JogoThread.
    jogoThread: TJogoThread;


    { private declarations }
    procedure Preencher_Jogos(Sender: TObject);
    procedure Preencher_Jogos_Quantidade;

    //function Retornar_Aposta_com_x_numeros(strJogo_com: string;
    //  out strErro: string): integer;
    //function Retornar_Quantidade_de_Jogos(strJogo_Quantidade: string;
    //  out strErro: string): integer;

    function Validar_Jogo: boolean; overload;
    //function Validar_Campos(strJogo, strJogo_Com, strJogo_Quantidade: string;
    //  var strErro: string): boolean; overload;

    procedure Exportar_Arquivo_csv;
    procedure Importar_Arquivo_csv;

    //procedure Preencher_Grade;
		//function Validar_Jogo(strJogo: string; out strErro: string): boolean;
    //procedure Preencher_Grade_Lotofacil;

  public
    { public declarations }
  end;

var
  frmGerador_Aleatorio: TfrmGerador_Combinatorio;

implementation

uses dmLtk;

{$R *.lfm}

{ TJogoThread }

constructor TJogoThread.Create(jogoInfo: TJogoInfo; jogoGrade: TStringGrid;
			CreateSuspended: boolean);
begin
 self.FreeOnTerminate:=true;
  self.jogoInfo := jogoInfo;
  self.jogoGrade := jogoGrade;
end;

procedure TJogoThread.Execute;
begin
      self.Preencher_Grade;
end;

{ TfrmGerador_Combinatorio }

procedure TfrmGerador_Combinatorio.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := TCloseAction.caFree;
  FreeAndNil(JogoThread);
end;

// A informação disponível na caixa de combinação é alterada conforme o tipo do
// jogo.
procedure TfrmGerador_Combinatorio.cmbJogo_comChange(Sender: TObject);
var
			strJogo: TCaption;
      iA: integer;
begin
  // Altera o valor conforme o jogo.
  strJogo := cmbJogo_Tipo.Text;

  // Apagar sempre a caixa de combinação de cmbJogo_Quantidade
  cmbJogo_Quantidade.Items.Clear;
  if strJogo = 'LOTOMANIA' then begin
    for iA in [2, 5, 10, 25] do begin
        cmbJogo_Quantidade.Items.Add(IntToStr(iA));
		end;
	end else if strJogo = 'LOTOFACIL' then begin
    if cmbJogo_com.Text = '15' then begin
      for iA in [3, 5] do begin
          cmbJogo_Quantidade.Items.Add(IntToStr(iA));
  		end;

		end else if cmbJogo_com.Text = '16' then begin
      for iA in [2, 4, 8] do begin
          cmbJogo_Quantidade.Items.Add(IntToStr(iA));
  		end;
		end;
	end;

end;

procedure TfrmGerador_Combinatorio.btnGerarClick(Sender: TObject);
begin
  // Vamos preencher os dados e passa para validar.
  JogoInfo.JogoTipo:= cmbJogo_Tipo.Text;
  JogoInfo.bolaAposta:= StrToInt(cmbJogo_Com.Text);
  JogoInfo.quantidadeBilhetes:= StrToInt(cmbJogo_Quantidade.Text);
  JogoInfo.alternarParImpar:= chkAlternarParImpar.Checked;
  JogoInfo.bolas_combinadas:= StrToInt(cmbJogo_Quantidade.Text);


  if Validar_Jogo = false then begin
    MessageDlg(strErro, TMsgDlgType.mtError, [mbOK], 0);
    Exit;
	end;

  JogoThread := TJogoThread.Create(jogoInfo, gradeJogos, true);
  JogoThread.Execute;
end;

procedure TfrmGerador_Combinatorio.btnImportarClick(Sender: TObject);
begin
  self.Importar_Arquivo_csv;
end;

procedure TfrmGerador_Combinatorio.btnExportarClick(Sender: TObject);
begin
  self.Exportar_Arquivo_csv;
end;

procedure TfrmGerador_Combinatorio.btnCopiarClick(Sender: TObject);
begin
  // Vamos copiar para o ClipBoard;
  self.gradeJogos.CopyToClipboard(False);
end;

procedure TfrmGerador_Combinatorio.btnLimpar_ResultadosClick(Sender: TObject);
var
  iResposta: integer;
begin
  iResposta := MessageDlg('Deseja apagar os resultados', TMsgDlgType.mtInformation,
    [mbYes, mbNo], 0);
  if iResposta = mrYes then
  begin
    gradeJogos.Clean;
    gradeJogos.RowCount := 0;
  end;
end;

// Toda vez que o usuário clicar na caixa de combinação Jogo_Tipo, devemos
// atualizar o controle cmbJogo_com para refletir a quantidade de números
// a jogar para o jogo respectivo.

procedure TfrmGerador_Combinatorio.cmbJogo_TipoChange(Sender: TObject);
var
  iA: integer;
  strJogo: string;
begin
  // Sempre apagar o que já havia na caixa de combinação.
  cmbJogo_com.Items.Clear;
  cmbJogo_Quantidade.Items.Clear;

  strJogo := cmbJogo_Tipo.Text;
  // Vamos garantir que sempre o valor estará em maiúsculas.
  strJogo := UpCase(strJogo);

  if strJogo = 'QUINA' then
  begin
    for iA := 5 to 7 do
    begin
      cmbJogo_com.Items.Add(IntToStr(iA));
    end;
  end
  else

  if (strJogo = 'MEGASENA') or (strJogo = 'DUPLASENA') then
  begin
    for iA := 6 to 15 do
    begin
      cmbJogo_com.Items.Add(IntToStr(iA));
    end;
  end
  else

  if strJogo = 'LOTOFACIL' then
  begin
    for iA := 15 to 18 do
    begin
      cmbJogo_com.Items.Add(IntToStr(iA));
    end;
  end
  else

  if strJogo = 'LOTOMANIA' then
  begin
    cmbJogo_com.Items.Add('50');

    for iA in [2, 5, 10, 25] do begin
        cmbJogo_Quantidade.Items.Add(IntToStr(iA));
    end
  end
	else

  if strJogo = 'INTRALOT_MINAS_5' then
  begin
    cmbJogo_com.Items.Add('5');
  end
  else

  if strJogo = 'INTRALOT_LOTOMINAS' then
  begin
    cmbJogo_com.Items.Add('6');
  end;

  IF strJogo = 'INTRALOT_KENO_MINAS' then
  begin
    for iA := 1 to 10 do
        cmbJogo_Com.Items.Add(IntToStr(iA));
	end;

  // Selecionar sempre o primeiro ítem.
  cmbJogo_com.ItemIndex := 0;
  cmbJogo_Quantidade.ItemIndex := 0;
end;

procedure TfrmGerador_Combinatorio.FormCreate(Sender: TObject);
begin
  self.Preencher_Jogos(Sender);
  self.Preencher_Jogos_Quantidade;
end;

procedure TfrmGerador_Combinatorio.Preencher_Jogos(Sender: TObject);
var
  iA: integer;
begin
  // Preencher combobox com o nome dos jogos.
  for iA := 0 to High(JogoTipo) do
    cmbJogo_Tipo.Items.Add(JogoTipo[iA]);

  // Definir o primeiro ítem, na inicialização.
  cmbJogo_Tipo.ItemIndex := 0;

  // Vamos também atualizar o controle 'cmbJogo_com' para refletir o jogo selecionado
  cmbJogo_Tipo.OnChange(Sender);

end;

// Preencher o controle 'cmbJogo_Quantidade' com a lista de quantidade de jogos.
procedure TfrmGerador_Combinatorio.Preencher_Jogos_Quantidade;
var
  iA: integer;
begin
  for iA := 1 to 10 do
  begin
    cmbJogo_Quantidade.Items.Add(IntToStr(iA));
  end;

  iA := 20;
  repeat
    cmbJogo_Quantidade.Items.Add(IntToStr(iA));

    if iA < 100 then
    begin
      iA += 10;
    end
    else
    begin
      iA += 100;
    end;


  until iA > 1000;

  cmbJogo_Quantidade.ItemIndex := 0;
end;

// Validar o jogo e definir a menor e maior bola
function TfrmGerador_Combinatorio.Validar_Jogo: boolean;
var
			strJogo: String;
begin
  // Validar nome do jogo.
  strJogo := UpperCase(JogoInfo.JogoTipo);
  if (strJogo <> 'QUINA') and (strJogo <> 'MEGASENA') and
    (strJogo <> 'LOTOFACIL') and (strJogo <> 'LOTOMANIA') and
    (strJogo <> 'DUPLASENA') and (strJogo <> 'INTRALOT_MINAS_5') and
    (strJogo <> 'INTRALOT_LOTOMINAS') and (strJogo <> 'INTRALOT_KENO_MINAS') then
  begin
    strErro := 'Jogo inválido: ' + strJogo;
    Exit(False);
  end;

  // Definir limite inferior e superior.
  // Nos jogos da loteria, somente o jogo lotomania, a menor bola é 0.
  if strJogo = 'LOTOMANIA' then
    JogoInfo.bolaInicial:=0
  else
    JogoInfo.bolaInicial := 1;

    // Definir limite superior.
  if strJogo = 'QUINA' then
    JogoInfo.BolaFinal := 80
  else if strJogo = 'MEGASENA' then
    JogoInfo.BolaFinal := 60
  else if strJogo = 'LOTOFACIL' then
    JogoInfo.BolaFinal := 25
  else if strJogo = 'LOTOMANIA' then
    JogoInfo.BolaFinal := 99
  else if strJogo = 'DUPLASENA' then
    JogoInfo.BolaFinal := 50
  else if strJogo = 'INTRALOT_MINAS_5' then
    JogoInfo.BolaFinal := 34
  else if strJogo = 'INTRALOT_LOTOMINAS' then
    JogoInfo.BolaFinal := 38
  else if strJogo = 'INTRALOT_KENO_MINAS' then
    JogoInfo.BolaFinal := 80;

  // Validar o campo de quantidade de números apostados escolhido pelo usuário.
  if ((strJogo = 'MEGASENA') or (strJogo = 'DUPLASENA')) AND not(JogoInfo.bolaAposta in [6..15]) then
  begin
     strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
     Exit(False);
  end;

  if (strJogo = 'QUINA') and not(JogoInfo.bolaAposta in [5..7]) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'LOTOFACIL') and not(JogoInfo.bolaAposta in [15..18]) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'LOTOMANIA') and (JogoInfo.bolaAposta <> 50) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'INTRALOT_MINAS_5') and (JogoInfo.bolaAposta <> 5) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'INTRALOT_LOTO_MINAS') and (JogoInfo.bolaAposta <> 6) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'INTRALOT_KENO_MINAS') and (JogoInfo.bolaAposta <> 5) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  Exit(True);
end;



procedure TfrmGerador_Combinatorio.Exportar_Arquivo_csv;
var
  dlgExportar_Csv: TSaveDialog;
  strArquivo_Sugestao: string;
begin
  // Se não há nenhum jogo gerado, emiti um erro e sair.
  if gradeJogos.RowCount = 0 then
  begin
    MessageDlg('Erro, não há nenhum jogo gerado.', TMsgDlgType.mtError,
      [mbOK], 0);
    Exit;
  end;

  // Vamos pegar o nome do arquivo, através da caixa de diálogo.
  dlgExportar_Csv := TSaveDialog.Create(TComponent(self));
  dlgExportar_Csv.Filter := '*.csv';
  dlgExportar_Csv.InitialDir := '/home/fabiuz/meus_documentos/exportados';

  // Vamos sugerir um nome baseado no jogo atual
  strArquivo_Sugestao := JogoInfo.JogoTipo + '_com_' +
    IntToStr(JogoInfo.bolaAposta) + '_números_' +
    FormatDateTime('dd_mm_yyyy', Now) + '-' +
    FormatDateTime('hh_mm_ss', Now) + '.csv';

  dlgExportar_Csv.FileName := strArquivo_Sugestao;


  if dlgExportar_Csv.Execute = False then
  begin
    Exit;
  end;

  // O Arquivo não pode existir
  if FileExists(dlgExportar_Csv.FileName) = True then
  begin
    MessageDlg('Erro, arquivo já existe.', TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  gradeJogos.SaveToCSVFile(dlgExportar_Csv.FileName, ';', True, False);

end;

procedure TfrmGerador_Combinatorio.Importar_Arquivo_csv;
var
  dlgExportar_Csv: TOpenDialog;
begin
  dlgExportar_Csv := TOpenDialog.Create(TComponent(self));
  dlgExportar_Csv.InitialDir := '~/meus_documentos/exportados/';
  dlgExportar_Csv.Filter := '*.csv';

  if dlgExportar_Csv.Execute = False then
  begin
    Exit;
  end;

  // Vamos verificar se o arquivo existe.
  if FileExists(dlgExportar_Csv.FileName) = False then
  begin
    MessageDlg('Arquivo ' + dlgExportar_Csv.FileName + ' não existe.',
      TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  // Se o arquivo existe, iremos preencher no controle 'gradeJogos'.
  // Se o controle não está vazio, avisar ao usuário que os dados serão sobrescritos.
  if gradeJogos.RowCount <> 0 then
  begin
    if MessageDlg(
      'Os dados que serão importados, sobrescreverão os dados atuais, desejar continuar.',
      TMsgDlgType.mtConfirmation, [mbYes, mbNo], 0) = mrNo then
    begin
      MessageDlg('Dados não foram importados, nenhuma informação foi sobrescrita.',
        TMsgDlgType.mtInformation, [mbOK], 0);
      Exit;
    end;
  end;

  try
    gradeJogos.LoadFromCSVFile(dlgExportar_csv.FileName, ';', True);
  except
    On Exception do
    begin
      MessageDlg('Um erro ocorreu ao importar.', TMsgDlgType.mtError, [mbOK], 0);
      gradeJogos.RowCount := 0;
    end;
  end;

  // Ajusta a largura das colunas
  gradeJogos.AutoSizeColumns;

end;

procedure TJogoThread.GerarLotomania;
begin
  case JogoInfo.bolas_combinadas of
       //2: GerarLotomaniaGrupo2Numeros;
       //5: GerarLotomaniaGrupo5Numeros;
       10: GerarLotomaniaGrupo10Numeros;
	end;
end;


procedure TJogoThread.GerarLotomaniaGrupo10Numeros;
begin

end;

procedure TJogoThread.GerarLotomaniaGrupo2Numeros;
begin

end;

procedure TJogoThread.GerarLotomaniaGrupo5Numeros;
begin

end;

procedure TJogoThread.Preencher_Grade;
type
  TParImpar = (NumeroPar, NumeroImpar);
var
  iA, iB, iC: integer;
  numeroAleatorio: integer;

  // Guarda cada bola, de cada aposta
  //iJogo_Grade: array of array of integer;
  iJogo_Grade: array[0..1000, 0..50] of integer;

  bolaJaSorteada: array[0..99] of boolean;


  // Indica a quantidade de bolas já sorteadas.
  quantidadeBolasSorteadas: integer;

  // Indica o total de bolas que compõe o jogo.
  bolaTotal, numeroTemp, iD, iE, ColunaBolaCombinada: Integer;
	bTrocou: Boolean;

  listaNumero: TStringList;

  TrocarParImpar: TParImpar;
  listaNumeroPar: TStringList;
  listaNumeroImpar: TStringList;

	IndiceLista: LongInt;
	strNumeroConcatenado: String;
	Data: TDateTime;
begin
  bolaTotal := JogoInfo.bolaFinal - JogoInfo.bolaInicial + 1;

  quantidadeBolasSorteadas := 0;
  Dec(JogoInfo.quantidadeBilhetes);

  // Iniciar o gerador de números randômicos.
  Randomize;

  // Vamos criar uma lista de string com os números
  listaNumero := TStringList.Create;
  listaNumeroImpar := TStringList.Create;
  listaNUmeroPar := TStringList.Create;
	for iC := JogoInfo.bolaInicial to JogoInfo.bolaFinal do begin
		  bolaJaSorteada[iC] := false;
      listaNumero.Add(IntToStr(iC));

      if iC mod 2 = 0 then
         ListaNumeroPar.Add(IntToSTr(iC))
      else
        ListaNumeroImpar.Add(IntToStr(iC));
	end;


  // Indica qual o tipo do número a usar.
  TrocarParImpar := TParImpar.NumeroPar;

  for iA := 0 to JogoInfo.quantidadeBilhetes do
  begin
    iB := 0;
    while iB < JogoInfo.bolaAposta do begin
      // Nossa lista irá guardar todos os números, iremos pegar um número aleatória,
      // este número corresponde a qualquer número que corresponde ao índice da lista.
      // Em seguida, iremos remove este ítem da lista, a lista, irá diminuir, até a
      // quantidade de ítens ser igual a zero.
      // Fiz, desta maneira, pois sempre é garantido que a cada iteração, sempre
      // vai sair um ítem da lista, ao contrário, da outra tentativa, que às vezes,
      // o mesmo número pode já ter sido selecionado e o loop demorar a executar.

      // Hoje, 10/06/2016, coloquei uma nova opção, a opção de escolher
      // se desejar que saía alternadamente par e impar.
      // Devemos observar, que pode acontecer que a quantidade de números pares e
      // impares não seja igual, neste caso, devemos pegar o número que resta,
      // por exemplo, há os números 2, 5, 8, 15, 17.
      // Por exemplo, ao percorrermos, iremos pegar par 2, impar 5, par 8, impar
      // 15 e em seguida, deveriamos pegar um número par, mas há um número impar
      // neste caso, devemos pegar o número ímpar.

      if JogoInfo.alternarParImpar = true then begin
        // Se as duas lista está vazia então enviar mensagem de erro.
        if (listaNumeroPar.Count = 0) and (listaNumeroImpar.Count = 0) then
        begin
           Raise Exception.Create('Lista de números pares e impares vazia.');
           Exit
        end;


         if TrocarParImpar = TParImpar.NumeroPar then begin
           // Vamos verificar se há números pares ainda na lista.
           if listaNumeroPar.Count <> 0 then
           begin
             IndiceLista := Random(listaNumeroPar.Count);
             numeroAleatorio := StrToInt(listaNumeroPar.Strings[IndiceLista]);
             // Sempre sai um número não precisamos, gravar um arranjo de booleanos
             // indica o número já lido.
             listaNumeroPar.Delete(IndiceLista);
             // Gravar no arranjo.
             iJogo_Grade[iA, iB] := numeroAleatorio;
             Inc(quantidadeBolasSorteadas);
             Inc(iB);
           end;
           // Alterna para impar.
           TrocarParImpar := TParImpar.NumeroImpar;

         end else begin
           // Vamos verificar se há números impares na lista.
           if listaNumeroImpar.Count <> 0 then
           begin
                IndiceLista := Random(listaNumeroImpar.Count);
                numeroAleatorio := StrToInt(listaNumeroImpar.Strings[IndiceLista]);
                // Sempre sai número impar, não precisamos marcar qual saiu.
                listaNumeroImpar.Delete(IndiceLista);
                // Gravar no arranjo.
                iJogo_Grade[iA, iB] := numeroAleatorio;
                Inc(quantidadeBolasSorteadas);
                Inc(iB);
           end else begin
               // Geralmente, isto nunca acontecerá.
               Raise Exception.Create('Isto não deve nunca acontecer.' + #10#13 +
                                            'A próxima iteração é par mas não há nenhum par.');
               Exit;
           end;
           // Alterna para par.
           TrocarParImpar := TParImpar.NumeroPar;
         end
      end else
      begin
        // Isto quer dizer que o número pode vir em qualquer ordem de números par e impar.
        IndiceLista := Random(ListaNumero.Count);
        numeroAleatorio := StrToInt(ListaNumero.Strings[IndiceLista]);
        // Retirar item da lista.
        listaNumero.Delete(IndiceLista);
        // Gravar no arranjo.
        iJogo_Grade[iA, iB] := numeroAleatorio;
        Inc(quantidadeBolasSorteadas);
        Inc(iB);
      end;

      // Se a quantidade de bolas já foi atingida,
      // devemos resetar a variável 'BolaJaSorteada', em seguida, devemos
      // definir para true, as bolas que já foram sorteadas, aqui, neste loop.
      if quantidadeBolasSorteadas = bolaTotal then begin
        quantidadeBolasSorteadas := 0;
        // Garantir que a lista está vazia, não é necessário.
        listaNumero.Clear;
        listaNumeroPar.Clear;
        listaNumeroImpar.Clear;
        for iC := JogoInfo.bolaInicial to JogoInfo.bolaFinal do begin
            // Adiciona os números à lista de string de números.
            listaNumero.Add(IntToStr(iC));

            if iC mod 2 = 0 then
               listaNumeroPar.Add(IntToStr(iC))
            else
              listaNumeroImpar.Add(IntToStr(iC));
				end;

        // Se iB é igual a quantidade de números apostados, e que se todos
        // as bolas foram sorteadas, quer dizer, que todos os números foram
        // sorteados, podemos começar um novo jogo, escolhendo qualquer número.
        if iB = JogoInfo.bolaAposta then
        begin
           // Randomize os números.
           //RandSeed := StrToFloat(Format('%f', [Now]));

           Randomize;
           Continue;
        end
        else begin
          // Se chegamos aqui, quer dizer, que a quantidade de bolas aposta
          // ainda está incompleta, então devemos repetir bolas que estão no
          // nos concurso anterior e que não pode estar no concurso atual.
          // Vamos percorrer, cada bola já sorteada e retirar da lista de número
          // que ainda não foram sorteados.

          // Definir a quantidade de bolas sorteadas, da aposta corrente.
          // Será iB - 1, pois iB é baseado em zero.
          quantidadeBolasSorteadas := iB;
          for iC := 0 to iB - 1 do
          begin
            if JogoInfo.alternarParImpar = true then begin
              // Vamos verificar se é par ou impar.
              numeroAleatorio := iJogo_Grade[iA, iC];
              if numeroAleatorio mod 2 = 0 then begin
                IndiceLista := ListaNumeroPar.IndexOf(IntToStr(numeroAleatorio));
                if IndiceLista <> -1 then
                begin
                   ListaNumeroPar.Delete(IndiceLista);
                end else begin
                  // Isto, nunca pode acontecer.
                  Raise Exception.Create('O número é par, mas não está na lista, deveria estar.');
                  Exit;
                end;

              end else begin
                // O número é impar.
                IndiceLista := ListaNumeroImpar.IndexOf(IntToStr(numeroAleatorio));
                if IndiceLista <> -1 then
                begin
                   ListaNumeroImpar.Delete(IndiceLista);
                end else begin
                  // Isto, nunca pode acontecer.
                  Raise Exception.Create('O número é impar, mas não está na lista, deveria estar.');
                  Exit;
                end;
              end;
            end else begin
              // O usuário não marcou que quer par e impar alternados.
              IndiceLista := ListaNumero.IndexOf(IntToStr(iJogo_Grade[iA, iC]));
              if IndiceLista <> -1 then
              begin
                ListaNumero.Delete(IndiceLista);
              end else
              begin
                // Isto, nunca pode acontecer, somente acontecer, se algum número
                // repetiu, acho bem improvável acontecer.
                Raise Exception.Create('O número não foi localizado, provavelmente, este ' +
                                          'número saiu mais de uma vez.');
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;

     //O arranjo é baseado em zero, devemos diminuir iB, para utilizar
     //com melhor desempenho no loop.
    dec(iB);

      repeat
        bTrocou := false;
        for iE := 0 to iB - 1 do begin
          if iJogo_Grade[iA, iE] > iJogo_Grade[iA, iE + 1] then begin
            numeroTemp := iJogo_Grade[iA, iE];
            iJogo_Grade[iA, iE] := iJogo_Grade[iA, iE + 1];
            iJogo_Grade[iA, iE + 1] := numeroTemp;
            bTrocou := true;
					end;
				end;
			until bTrocou = false ;


	end;

  // A quantidade de números apostados, indicará a quantidade de colunas que haverá.
  // Também, haverá colunas adicionais para indicar informações para identificar
  // O tipo do jogo, a quantidade de números apostados, e quantos jogos foram
  // selecionados.
	// Haverá 4 colunas a mais, para indicar:
  // Tipo do jogo;
  // quantidade de números apostados;
  // quantidade de jogos apostados; e,
  // bolas_concatenadas.
  // bolas_repetidas;
  JogoGrade.ColCount := JogoInfo.bolaAposta + 5;

  // A quantidade de fileira será 1 maior, pois uma coluna será o cabeçalho.
  // Retorna ao estado atual.
  Inc(JogoInfo.quantidadeBilhetes);
  JogoGrade.RowCount := JogoInfo.quantidadeBilhetes + 1;

  // A primeira fileira conterá o cabeçalho
  JogoGrade.FixedRows := 1;

  // As três colunas iniciais de cada fileira, indica:
  // O tipo do jogo,
  // A quantidade de números apostados,
  // e, quantidade de jogos apostados.
  JogoGrade.FixedCols := 3;

  // Vamos preencher o cabeçalho
  JogoGrade.Cells[0, 0] := 'BILHETE';
  JogoGrade.Cells[1, 0] := 'JOGO';
  JogoGrade.Cells[2, 0] := 'APOSTA';
  JogoGrade.Cells[JogoGrade.ColCount - 2 , 0] := 'BOLAS_COMBINADAS';
  JogoGrade.Cells[JogoGrade.ColCount - 1, 0] := 'REPETIU';

  // Vamos começar na coluna 3, como os índices são baseados em 0
  // iremos adicionar + 2
  for iA := 1 to JogoInfo.bolaAposta do
  begin
    JogoGrade.Cells[iA + 2, 0] := 'B' + IntToStr(iA);
  end;

  // Preencher grid.
  for iA := 1 to JogoInfo.quantidadeBilhetes do
  begin
          // Insira informações das colunas 1 a 2
      JogoGrade.Cells[0, iA] := IntToStr(iA);
      JogoGrade.cells[1, iA] := JogoInfo.JogoTipo;
      JogoGrade.Cells[2, iA] := 'com ' + IntToStr(JogoInfo.bolaAposta) + ' números.';

        //statusBar1.Panels[0].Text := 'Processando linha: ' + IntToStr(iA + 1);
        //statusBar1.Refresh;


       strNumeroConcatenado := '';
       for iB := 0 to JogoInfo.bolaAposta-1 do
       begin
         JogoGrade.Cells[3 + iB, iA] := IntToStr(iJogo_Grade[iA-1, iB]);
         strNumeroConcatenado += '_' + Format('%.2d', [iJogo_Grade[iA - 1, iB]]);
			 end;
       // Números concatenados.
       Inc(iB);
       JogoGrade.Cells[3 + iB, iA] := strNumeroConcatenado;
       JogoGrade.Cells[4 + iB, iA] := '';
  end;

  // Pega a coluna das bolas combinadas
  ColunaBolaCombinada := JogoGrade.ColCount - 2;
  for iA := 1 to JogoInfo.quantidadeBilhetes do
      for iB := iA + 1 to JogoInfo.quantidadeBilhetes do
      begin
        if JogoGrade.Cells[ColunaBolaCombinada, iA] = JogoGrade.Cells[ColunaBolaCombinada, iB] then begin
           // Vamos acrescentar os dados ao que já está na célula.
           JogoGrade.Cells[ColunaBolaCombinada + 1, iB] := JogoGrade.Cells[ColunaBolaCombinada + 1, iB] + IntToStr(iA) + ';'
        end;
      end;

  JogoGrade.AutoSizeColumns;
  FreeAndNil(listaNumero);



end;

end.
