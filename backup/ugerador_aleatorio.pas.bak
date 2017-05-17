unit ugerador_aleatorio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Grids, CheckLst


  ;

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
  end;

type
  TLotofacilEtapa = (
    LOTOFACIL_ETAPA_ZERO, LOTOFACIL_ETAPA_UM,
    LOTOFACIL_ETAPA_DOIS, LOTOFACIL_ETAPA_TRES,
    LOTOFACIL_ETAPA_QUATRO);

const
  JogoTipo: array[0..7] of string = ('DUPLASENA', 'LOTOFACIL',
    'LOTOMANIA', 'MEGASENA', 'QUINA', 'INTRALOT_MINAS_5',
    'INTRALOT_LOTOMINAS', 'INTRALOT_KENO_MINAS');


type

  {
   TJogoThread
   Para evitar que a interface de usuário fica não-responsiva, criaremos
   um thread.
  }

  TJogoThread = class(TThread)
  public
    constructor Create(jogoInfo: TJogoInfo; jogoGrade: TStringGrid;
      CreateSuspended: boolean);
    procedure Execute; override;

  private
    jogoInfo: TJogoInfo;
    jogoGrade: TStringGrid;
    procedure Preencher_Grade;
    procedure Preencher_Grade_Lotofacil;
    procedure Preencher_Grade_Lotomania;
  end;

type

  { TfrmGerador_Aleatorio }

  TfrmGerador_Aleatorio = class(TForm)
    btnImportar: TButton;
    btnGerar: TButton;
    btnCopiar: TButton;
    btnExportar: TButton;
    btnLimpar_Resultados: TButton;
    CheckListBox1 : TCheckListBox;
    CheckListBox2 : TCheckListBox;
    chkAlternarParImpar: TCheckBox;
    cmbJogo_Tipo: TComboBox;
    cmbJogo_com: TComboBox;
    cmbJogo_Quantidade: TComboBox;
    gradeJogos : TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6 : TLabel;
    Label7 : TLabel;
    PageControl1 : TPageControl;
    panel_Superior: TPanel;
    Panel2: TPanel;
    panel_Direito: TPanel;
    StatusBar1: TStatusBar;
    TabSheet1 : TTabSheet;
    TabSheet2 : TTabSheet;
    procedure btnCopiarClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnGerarClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure btnLimpar_ResultadosClick(Sender: TObject);
    procedure cmbJogo_comChange(Sender: TObject);

    procedure cmbJogo_QuantidadeKeyPress(Sender: TObject; var Key: char);
    procedure cmbJogo_TipoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    strErro: string;

    // Estrutura que guarda o jogo selecionado.
    jogoInfo: TJogoInfo;

    // Toda vez que o usuário clicar para gerar um novo resultado, iremos
    // utilizar uma thread para evitar que a interface fique não-responsiva.
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
  frmGerador_Aleatorio: TfrmGerador_Aleatorio;

implementation

uses dmLtk;

{$R *.lfm}

{ TJogoThread }

constructor TJogoThread.Create(jogoInfo: TJogoInfo; jogoGrade: TStringGrid;
  CreateSuspended: boolean);
begin
  self.FreeOnTerminate := True;
  self.jogoInfo := jogoInfo;
  self.jogoGrade := jogoGrade;
end;

procedure TJogoThread.Execute;
begin

  if self.jogoInfo.JogoTipo = 'LOTOFACIL' then
    self.Preencher_Grade_Lotofacil
  else
    self.Preencher_Grade;


end;

{ TfrmGerador_Aleatorio }

procedure TfrmGerador_Aleatorio.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := TCloseAction.caFree;
  FreeAndNil(JogoThread);
end;

// A informação disponível na caixa de combinação é alterada conforme o tipo do
// jogo.
procedure TfrmGerador_Aleatorio.cmbJogo_comChange(Sender: TObject);
begin

end;



procedure TfrmGerador_Aleatorio.cmbJogo_QuantidadeKeyPress(Sender: TObject;
			var Key: char);
begin
      if not ((Key >= '0') and (Key <= '9')) and (Key <> '#9') then
        Key := Char(Byte(0));
end;

procedure TfrmGerador_Aleatorio.btnGerarClick(Sender: TObject);
begin
  // Vamos preencher os dados e passa para validar.
  JogoInfo.JogoTipo := cmbJogo_Tipo.Text;
  JogoInfo.bolaAposta := StrToInt(cmbJogo_Com.Text);
  JogoInfo.quantidadeBilhetes := StrToInt(cmbJogo_Quantidade.Text);
  JogoInfo.alternarParImpar := chkAlternarParImpar.Checked;

  if Validar_Jogo = False then
  begin
    MessageDlg(strErro, TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  JogoThread := TJogoThread.Create(jogoInfo, gradeJogos, True);
  JogoThread.Execute;
end;

procedure TfrmGerador_Aleatorio.btnImportarClick(Sender: TObject);
begin
  self.Importar_Arquivo_csv;
end;

procedure TfrmGerador_Aleatorio.btnExportarClick(Sender: TObject);
begin
  self.Exportar_Arquivo_csv;
end;

procedure TfrmGerador_Aleatorio.btnCopiarClick(Sender: TObject);
begin
  // Vamos copiar para o ClipBoard;
  self.gradeJogos.CopyToClipboard(False);
end;

procedure TfrmGerador_Aleatorio.btnLimpar_ResultadosClick(Sender: TObject);
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

procedure TfrmGerador_Aleatorio.cmbJogo_TipoChange(Sender: TObject);
var
  iA: integer;
  strJogo: string;
begin
  // Sempre apagar o que já havia na caixa de combinação.
  cmbJogo_com.Items.Clear;

  strJogo := cmbJogo_Tipo.Text;
  // Vamos garantir que sempre o valor estará em maiúsculas.
  strJogo := UpCase(strJogo);

  if strJogo = 'QUINA' then
  begin
    // Quina, agora, vc pode jogar de 5 a 15 números.
    for iA := 5 to 15 do
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

  if strJogo = 'INTRALOT_KENO_MINAS' then
  begin
    for iA := 10 downto 1 do
      cmbJogo_Com.Items.Add(IntToStr(iA));
  end;

  // Selecionar sempre o primeiro ítem.
  cmbJogo_com.ItemIndex := 0;
end;

procedure TfrmGerador_Aleatorio.FormCreate(Sender: TObject);
begin
  self.Preencher_Jogos(Sender);
  self.Preencher_Jogos_Quantidade;
end;

procedure TfrmGerador_Aleatorio.Preencher_Jogos(Sender: TObject);
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
procedure TfrmGerador_Aleatorio.Preencher_Jogos_Quantidade;
var
  iA: integer;
begin
  for iA := 1 to 1000 do
  begin
    cmbJogo_Quantidade.Items.Add(IntToStr(iA));
  end;

  cmbJogo_Quantidade.ItemIndex := 0;
end;

// Validar o jogo e definir a menor e maior bola
function TfrmGerador_Aleatorio.Validar_Jogo: boolean;
var
  strJogo: string;
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
    JogoInfo.bolaInicial := 0
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
  if ((strJogo = 'MEGASENA') or (strJogo = 'DUPLASENA')) and not
    (JogoInfo.bolaAposta in [6..15]) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'QUINA') and not (JogoInfo.bolaAposta in [5..15]) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  if (strJogo = 'LOTOFACIL') and not (JogoInfo.bolaAposta in [15..18]) then
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

  if (strJogo = 'INTRALOT_KENO_MINAS') and (not (JogoInfo.bolaAposta in [1..10])) then
  begin
    strErro := 'Quantidade de bolas apostadas inválida para o jogo: ' + strJogo;
    Exit(False);
  end;

  Exit(True);
end;



procedure TfrmGerador_Aleatorio.Exportar_Arquivo_csv;
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
    IntToStr(JogoInfo.bolaAposta) + '_números_' + FormatDateTime('dd_mm_yyyy', Now) +
    '-' + FormatDateTime('hh_mm_ss', Now) + '.csv';

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

procedure TfrmGerador_Aleatorio.Importar_Arquivo_csv;
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

procedure TJogoThread.Preencher_Grade;
type
  TParImpar = (NumeroPar, NumeroImpar);
var
  iA, iB, iC, iD, iE: integer;
  numeroAleatorio: integer;

  // Guarda cada bola, de cada aposta
  //iJogo_Grade: array of array of integer;
  iJogo_Grade: array[0..1000, 0..50] of integer;

  bolaJaSorteada: array[0..99] of boolean;

  // Indica a quantidade de bolas já sorteadas.
  quantidadeBolasSorteadas: integer;

  // Indica o total de bolas que compõe o jogo.
  bolaTotal, numeroTemp, ColunaBolaCombinada: integer;
  bTrocou: boolean;

  listaNumero: TStringList;

  TrocarParImpar: TParImpar;
  listaNumeroPar: TStringList;
  listaNumeroImpar: TStringList;

  IndiceLista: longint;
  strNumeroConcatenado: string;
  //Data: TDateTime;
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
  for iC := JogoInfo.bolaInicial to JogoInfo.bolaFinal do
  begin
    bolaJaSorteada[iC] := False;
    listaNumero.Add(IntToStr(iC));

    if iC mod 2 = 0 then
      ListaNumeroPar.Add(IntToStr(iC))
    else
      ListaNumeroImpar.Add(IntToStr(iC));
  end;


  // Indica qual o tipo do número a usar.
  TrocarParImpar := TParImpar.NumeroPar;

  for iA := 0 to JogoInfo.quantidadeBilhetes do
  begin
    iB := 0;
    while iB < JogoInfo.bolaAposta do
    begin
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

      if JogoInfo.alternarParImpar = True then
      begin
        // Se as duas lista está vazia então enviar mensagem de erro.
        if (listaNumeroPar.Count = 0) and (listaNumeroImpar.Count = 0) then
        begin
          raise Exception.Create('Lista de números pares e impares vazia.');
          Exit;
        end;


        RandSeed := Random(1000000);
        if TrocarParImpar = TParImpar.NumeroPar then
        begin
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

        end
        else
        begin
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
          end
          else
          begin
            // Geralmente, isto nunca acontecerá.
            raise Exception.Create('Isto não deve nunca acontecer.' +
              #10#13 +
              'A próxima iteração é par mas não há nenhum par.');
            Exit;
          end;
          // Alterna para par.
          TrocarParImpar := TParImpar.NumeroPar;
        end;
      end
      else
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
      if quantidadeBolasSorteadas = bolaTotal then
      begin
        quantidadeBolasSorteadas := 0;
        // Garantir que a lista está vazia, não é necessário.
        listaNumero.Clear;
        listaNumeroPar.Clear;
        listaNumeroImpar.Clear;
        for iC := JogoInfo.bolaInicial to JogoInfo.bolaFinal do
        begin
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

          RandSeed := Random(1000000);
          //Randomize;
          //Continue;
        end
        else
        begin
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
            if JogoInfo.alternarParImpar = True then
            begin
              // Vamos verificar se é par ou impar.
              numeroAleatorio := iJogo_Grade[iA, iC];
              if numeroAleatorio mod 2 = 0 then
              begin
                IndiceLista := ListaNumeroPar.IndexOf(IntToStr(numeroAleatorio));
                if IndiceLista <> -1 then
                begin
                  ListaNumeroPar.Delete(IndiceLista);
                end
                else
                begin
                  // Isto, nunca pode acontecer.
                  raise Exception.Create(
                    'O número é par, mas não está na lista, deveria estar.');
                  Exit;
                end;

              end
              else
              begin
                // O número é impar.
                IndiceLista := ListaNumeroImpar.IndexOf(IntToStr(numeroAleatorio));
                if IndiceLista <> -1 then
                begin
                  ListaNumeroImpar.Delete(IndiceLista);
                end
                else
                begin
                  // Isto, nunca pode acontecer.
                  raise Exception.Create(
                    'O número é impar, mas não está na lista, deveria estar.');
                  Exit;
                end;
              end;
            end
            else
            begin
              // O usuário não marcou que quer par e impar alternados.
              IndiceLista := ListaNumero.IndexOf(IntToStr(iJogo_Grade[iA, iC]));
              if IndiceLista <> -1 then
              begin
                ListaNumero.Delete(IndiceLista);
              end
              else
              begin
                // Isto, nunca pode acontecer, somente acontecer, se algum número
                // repetiu, acho bem improvável acontecer.
                raise Exception.Create(
                  'O número não foi localizado, provavelmente, este ' +
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
    Dec(iB);

    repeat
      bTrocou := False;
      for iE := 0 to iB - 1 do
      begin
        if iJogo_Grade[iA, iE] > iJogo_Grade[iA, iE + 1] then
        begin
          numeroTemp := iJogo_Grade[iA, iE];
          iJogo_Grade[iA, iE] := iJogo_Grade[iA, iE + 1];
          iJogo_Grade[iA, iE + 1] := numeroTemp;
          bTrocou := True;
        end;
      end;
    until bTrocou = False;

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
  JogoGrade.Cells[JogoGrade.ColCount - 2, 0] := 'BOLAS_COMBINADAS';
  JogoGrade.Cells[JogoGrade.ColCount - 1, 0] := 'REPETIU NOS BILHETES';

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
    for iB := 0 to JogoInfo.bolaAposta - 1 do
    begin
      JogoGrade.Cells[3 + iB, iA] := IntToStr(iJogo_Grade[iA - 1, iB]);
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
      if JogoGrade.Cells[ColunaBolaCombinada, iA] =
        JogoGrade.Cells[ColunaBolaCombinada, iB] then
      begin
        // Vamos acrescentar os dados ao que já está na célula.
        JogoGrade.Cells[ColunaBolaCombinada + 1, iB] :=
          JogoGrade.Cells[ColunaBolaCombinada + 1, iB] + IntToStr(iA) + ';';
      end;
    end;

  JogoGrade.AutoSizeColumns;
  FreeAndNil(listaNumero);

end;

// Este gerador aleatório, gera os números aleatórios, entretanto, enquanto houver
// número ainda não sorteado, nenhum número já sorteado pode aparecer no próximo jogo.

// Exemplo, vamos supor que os números saem em ordem crescente.
// 1 ,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,  15.

// Então, na próxima linha, deve sortear os números que ainda não foram sorteados
// não pode haver repetidos, enquanto houver número sorteado.
// 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,

// Observe, que na lotofacil há 25 números, você pode apostar de 15 a 18 números.
// No jogo, das 25 bolas são sorteadas 15 bolas.
// Então, isto quer dizer, que em nosso gerador, a cada 2 jogos, todos os números
// já foram sorteados, entretanto, se apostarmos 15 números, o primeiro jogo
// terá 15 números e o segundo 10 números, pois só há 25 números.
// Então, nosso gerador deve sortear 5 bolas do jogo anterior.
// E aí, que entra meu raciocínio para aumentar a chance de ganhar na lotofácil.
// Na lotofacil, sempre haverá no mínimo 5 números que sempre se repete do jogo anterior.
// No gerador aleatório cada tipo de aposta, terá um esquema para distribuir os números.
// Na aposta de 15 números:
// Irá selecionar os 15 primeiros números para o primeiro jogo;
// Em seguida, no segundo jogo, iremos pegar os 10 números restantes e definirmos
// como fixo, em seguida, iremos pegar 5 números do primeiro jogo.
// Depois, no terceiro jogo, iremos pegar os 10 números fixos do jogo anterior e pegar
// os 5 números ainda não sorteados do primeiro jogo



procedure TJogoThread.Preencher_Grade_Lotofacil;
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
  bolaTotal, numeroTemp, iD, iE, ColunaBolaCombinada: integer;
  bTrocou: boolean;



  TrocarParImpar: TParImpar;

  listaNumero: TStringList;
  listaNumeroPar: TStringList;
  listaNumeroImpar: TStringList;

  // Indica os números que estarão fixos, após o primeiro jogo
  listaFixa: TStringList;

  // Indica os números que estão no primeiro concurso
  listaPrimeiroJogo, listaNaoFixa: TStringList;


  IndiceLista: longint;
  strNumeroConcatenado: string;
  Data: TDateTime;
  lotofacilEstado: TLotofacilEtapa;
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
  listaFixa:= TStringList.Create;
  listaPrimeiroJogo:= TStringList.Create;
  listaNaoFixa:=TStringList.Create;



  // Indica qual o tipo do número a usar.
  TrocarParImpar := TParImpar.NumeroPar;
  lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_ZERO;

  for iA := 0 to JogoInfo.quantidadeBilhetes do
  begin

    // Se está no passo zero, popular lista.
    if lotofacilEstado = TLotofacilEtapa.LOTOFACIL_ETAPA_ZERO then
    begin
      // Apagar lista.
      listaNumero.Clear;
      listaNumeroPar.Clear;
      listaNumeroImpar.Clear;
      listaNaoFixa.Clear;

      // Popular lista.
      for iC := JogoInfo.bolaInicial to JogoInfo.bolaFinal do
      begin
        bolaJaSorteada[iC] := False;
        listaNumero.Add(IntToStr(iC));

        // Há duas lista, uma lista de números pares e uma lista de números ímpares.
        // Definir popular conforme o tipo do número.
        if iC mod 2 = 0 then
          ListaNumeroPar.Add(IntToStr(iC))
        else
          ListaNumeroImpar.Add(IntToStr(iC));
      end;

      lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_UM;

      // Gerar semente do gerador aleatório.
      RandSeed := Random(1000000);
    end;


    case lotofacilEstado of
          // Passo 1, sortea aleatoriamente 15 números.
          TLotofacilEtapa.LOTOFACIL_ETAPA_UM:
          begin


            // Apaga as listas.
            listaFixa.Clear;
            listaPrimeiroJogo.Clear;

            iB := 0;
            while iB < JogoInfo.bolaAposta do
            begin

              // Pegar aleatóriamente um índice da lista de números.
              indiceLista := Random(ListaNumero.Count);

              // Pegar número que está na posição deste índice.
              numeroAleatorio := StrToInt(ListaNumero.Strings[IndiceLista]);

              // Adiciona este número à lista do primeiro jogo.
              ListaPrimeiroJogo.Add(IntToStr(numeroAleatorio));

              // Apagar item no índice que foi selecionado.
              ListaNumero.Delete(indiceLista);
              // Gravar no arranjo
              iJogo_Grade[iA, iB] := numeroAleatorio;
              Inc(iB);
              // Continua até chegar ao fim do loop
              Continue;

            end;

            // Percorremos todos os ítens, agora, pegar os números que serão fixos.
            while listaNumero.Count <> 0 do
            begin
                 listaFixa.Add(listaNumero.Strings[0]);
                 listaNumero.Delete(0);
            end;
            lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_DOIS;
          end;

          // Passo 2, insere os números fixos, em seguida, sortea aleatoriamente
          // os números que foram sorteados no primeiro jogo.
          TLotofacilEtapa.LOTOFACIL_ETAPA_DOIS:
          begin
               iB := 0;
               // Preenche os números fixos.
               for iC := 0 to listaFixa.Count - 1 do begin
                 iJogo_Grade[iA, iB] := StrToInt(listaFixa.Strings[iC]);
                 Inc(iB);
							 end;

               // Cada tipo de aposta, terá uma quantidade de bolas não-fixas:
               // Aposta de 15 números, haverá 10 números fixos e 5 números não-fixos;
               // Aposta de 16 números, haverá 9 números fixos e 6 números não-fixos;
               // Aposta de 17 numeros, haverá 8 números fixos e 7 números não-fixos;
               // Aposta de 18 números, haverá 7 números fixos e 8 números não-fixos;
               for iC := listaFixa.Count to jogoInfo.bolaAposta - 1 do
               begin
                    // Seleciona um índice aleatoriamente.
                    indiceLista := Random(listaPrimeiroJogo.Count);

                    // Seleciona o número que está na posição do índice selecionado.
                    numeroAleatorio := StrToInt(listaPrimeiroJogo.Strings[indiceLista]);

                    // Apaga o índice selecionado da lista.
                    listaPrimeiroJogo.Delete(indiceLista);

                    // Insere na lista.
                    iJogo_Grade[iA, iB] := numeroAleatorio;
                    Inc(iB);

                    // Adiciona item a lista não-fixa, pois, quando não houver
                    // mais números selecionar os números já sorteados anteriormente.
                    listaNaoFixa.Add(IntToStr(numeroAleatorio));
							 end;
               // Passa para etapa 3:
               lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_TRES;
          end;

          // No passo 3, devemos preencher os números fixos e em seguidas os
          // números não-fixos, entretanto, para as aposta de 17 e 18 números,
          // há números faltando:
          // Para a aposta de 17 números, faltará um número.
          // Para a aposta de 18 números, faltará 4 números.

          // Nas apostas de 17 e 18 números, na etapa 3, haverá falta de números
          // pois, a etapa 3, termina as apostas de 17 e 18 números, então devemos
          // pegar os números já sorteados da lista não-fixa e inserir na lista
          // 'listaPrimeiroJogo'.
          TLotofacilEtapa.LOTOFACIL_ETAPA_TRES:
          begin

		            if jogoInfo.bolaAposta in [17..18] then
		            begin
		              for iC := 1 to 4 do
		              begin
				                indiceLista := Random(listaNaoFixa.Count);
				                numeroAleatorio := StrToInt(listaNaoFixa.Strings[indiceLista]);
				                listaNaoFixa.Delete(indiceLista);
		                    listaPrimeiroJogo.Add(IntToStr(numeroAleatorio));

		                    // Na aposta de 17 números, haverá somente 1 número faltando.
		                    // Então, após definirmos este número podemos sair do loop.
		                    if jogoInfo.bolaAposta = 17 then BREAK;
								  end;
							  end;

		             iB := 0;
		           // Preenche os números fixos.
		           for iC := 0 to listaFixa.Count - 1 do
		           begin
		                iJogo_Grade[iA, iB] := StrToInt(listaFixa.Strings[iC]);
		                Inc(iB);
						   end;

		           // Cada tipo de aposta, terá uma quantidade de bolas não-fixas:
		           // Aposta de 15 números, haverá 10 números fixos e 5 números não-fixos;
		           // Aposta de 16 números, haverá 9 números fixos e 6 números não-fixos;
		           // Aposta de 17 numeros, haverá 8 números fixos e 7 números não-fixos;
		           // Aposta de 18 números, haverá 7 números fixos e 8 números não-fixos;
		           for iC := listaFixa.Count to jogoInfo.bolaAposta - 1 do
		           begin
		                // Seleciona um índice aleatoriamente.
		                indiceLista := Random(listaPrimeiroJogo.Count);

		                // Seleciona o número que está na posição do índice selecionado.
		                numeroAleatorio := StrToInt(listaPrimeiroJogo.Strings[indiceLista]);

		                // Apaga o índice selecionado da lista.
		                listaPrimeiroJogo.Delete(indiceLista);

		                // Insere na lista.
		                iJogo_Grade[iA, iB] := numeroAleatorio;
		                Inc(iB);

		                // Adiciona item a lista não-fixa, pois, quando não houver
		                // mais números selecionar os números já sorteados anteriormente.
		                listaNaoFixa.Add(IntToStr(numeroAleatorio));
						   end;
               // Só iremos passar para a etapa 4, se as apostas forem de 15, 16
               if JogoInfo.bolaAposta in [17..18] then
                  lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_ZERO
               else
                   lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_QUATRO;
         end;

         // Na etapa 4, os únicos tipos de aposta que pode ter é a aposta 15 e 16
         // número e é também a última etapa.
         // Nesta etapa, a aposta de 16 números faltará 5 números, então, devemos
         // pegar os números já sorteados da lista não-fixa e inserir na lista
         // 'listaPrimeiroJogo'.
         TLotofacilEtapa.LOTOFACIL_ETAPA_QUATRO:
          begin

		            if jogoInfo.bolaAposta = 16 then
		            begin
		              for iC := 1 to 5 do
		              begin
				                indiceLista := Random(listaNaoFixa.Count);

				                numeroAleatorio := StrToInt(listaNaoFixa.Strings[indiceLista]);
				                listaNaoFixa.Delete(indiceLista);
		                    listaPrimeiroJogo.Add(IntToStr(numeroAleatorio));
								  end;
							  end;

		           iB := 0;
		           // Preenche os números fixos.
		           for iC := 0 to listaFixa.Count - 1 do
		           begin
		                iJogo_Grade[iA, iB] := StrToInt(listaFixa.Strings[iC]);
		                Inc(iB);
						   end;

		           // Cada tipo de aposta, terá uma quantidade de bolas não-fixas:
		           // Aposta de 15 números, haverá 10 números fixos e 5 números não-fixos;
		           // Aposta de 16 números, haverá 9 números fixos e 6 números não-fixos;
		           // Aposta de 17 numeros, haverá 8 números fixos e 7 números não-fixos;
		           // Aposta de 18 números, haverá 7 números fixos e 8 números não-fixos;
		           for iC := listaFixa.Count to jogoInfo.bolaAposta - 1 do
		           begin
		                // Seleciona um índice aleatoriamente.
		                indiceLista := Random(listaPrimeiroJogo.Count);

		                // Seleciona o número que está na posição do índice selecionado.
		                numeroAleatorio := StrToInt(listaPrimeiroJogo.Strings[indiceLista]);

		                // Apaga o índice selecionado da lista.
		                listaPrimeiroJogo.Delete(indiceLista);

		                // Insere na lista.
		                iJogo_Grade[iA, iB] := numeroAleatorio;
		                Inc(iB);

		                // Adiciona item a lista não-fixa, pois, quando não houver
		                // mais números selecionar os números já sorteados anteriormente.
		                listaNaoFixa.Add(IntToStr(numeroAleatorio));
						   end;
               // Retorna para a etapa zero.
               lotofacilEstado := TLotofacilEtapa.LOTOFACIL_ETAPA_ZERO
         end;
    end;



    //O arranjo é baseado em zero, devemos diminuir iB, para utilizar
    //com melhor desempenho no loop.
    Dec(iB);

    repeat
      bTrocou := False;
      for iE := 0 to iB - 1 do
      begin
        if iJogo_Grade[iA, iE] > iJogo_Grade[iA, iE + 1] then
        begin
          numeroTemp := iJogo_Grade[iA, iE];
          iJogo_Grade[iA, iE] := iJogo_Grade[iA, iE + 1];
          iJogo_Grade[iA, iE + 1] := numeroTemp;
          bTrocou := True;
        end;
      end;
    until bTrocou = False;

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
  JogoGrade.Cells[JogoGrade.ColCount - 2, 0] := 'BOLAS_COMBINADAS';
  JogoGrade.Cells[JogoGrade.ColCount - 1, 0] := 'REPETIU COM BILHETE:';

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
    for iB := 0 to JogoInfo.bolaAposta - 1 do
    begin
      JogoGrade.Cells[3 + iB, iA] := IntToStr(iJogo_Grade[iA - 1, iB]);
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
      if JogoGrade.Cells[ColunaBolaCombinada, iA] =
        JogoGrade.Cells[ColunaBolaCombinada, iB] then
      begin
        // Vamos acrescentar os dados ao que já está na célula.
        JogoGrade.Cells[ColunaBolaCombinada + 1, iB] :=
          JogoGrade.Cells[ColunaBolaCombinada + 1, iB] + IntToStr(iA) + ';';
      end;
    end;

  JogoGrade.AutoSizeColumns;
  FreeAndNil(listaNumero);

end;

procedure TJogoThread.Preencher_Grade_Lotomania;
var bolasSorteadas: array of array of integer;
begin

end;


end.
