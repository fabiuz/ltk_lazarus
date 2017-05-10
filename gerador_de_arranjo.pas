unit gerador_de_arranjo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, strUtils, EditBtn, ComCtrls;

const
  strJogo_Tipo: array[0..7] of string = ('DUPLASENA', 'LOTOFACIL',
    'LOTOMANIA', 'MEGASENA', 'QUINA', 'INTRALOT_MINAS_5',
    'INTRALOT_LOTOMINAS', 'INTRALOT_KENO_MINAS');
const
  NumeroUnderLine: array[0..99] of string = (
  '_00',	'_01',	'_02',	'_03',	'_04',	'_05',	'_06',	'_07',	'_08',	'_09',
  '_10',	'_11',	'_12',	'_13',	'_14',	'_15',	'_16',	'_17',	'_18',	'_19',
  '_20',	'_21',	'_22',	'_23',	'_24',	'_25',	'_26',	'_27',	'_28',	'_29',
  '_30',	'_31',	'_32',	'_33',	'_34',	'_35',	'_36',	'_37',	'_38',	'_39',
  '_40',	'_41',	'_42',	'_43',	'_44',	'_45',	'_46',	'_47',	'_48',	'_49',
  '_50',	'_51',	'_52',	'_53',	'_54',	'_55',	'_56',	'_57',	'_58',	'_59',
  '_60',	'_61',	'_62',	'_63',	'_64',	'_65',	'_66',	'_67',	'_68',	'_69',
  '_70',	'_71',	'_72',	'_73',	'_74',	'_75',	'_76',	'_77',	'_78',	'_79',
  '_80',	'_81',	'_82',	'_83',	'_84',	'_85',	'_86',	'_87',	'_88',	'_89',
  '_90',	'_91',	'_92',	'_93',	'_94',	'_95',	'_96',	'_97',	'_98',	'_99');
const
  NumeroCSV: array[0..99] of string = (
   ';0',	 ';1',	 ';2',	 ';3',	 ';4',	 ';5',	 ';6',	 ';7',	 ';8',	 ';9',
  ';10',	';11',	';12',	';13',	';14',	';15',	';16',	';17',	';18',	';19',
  ';20',	';21',	';22',	';23',	';24',	';25',	';26',	';27',	';28',	';29',
  ';30',	';31',	';32',	';33',	';34',	';35',	';36',	';37',	';38',	';39',
  ';40',	';41',	';42',	';43',	';44',	';45',	';46',	';47',	';48',	';49',
  ';50',	';51',	';52',	';53',	';54',	';55',	';56',	';57',	';58',	';59',
  ';60',	';61',	';62',	';63',	';64',	';65',	';66',	';67',	';68',	';69',
  ';70',	';71',	';72',	';73',	';74',	';75',	';76',	';77',	';78',	';79',
  ';80',	';81',	';82',	';83',	';84',	';85',	';86',	';87',	';88',	';89',
  ';90',	';91',	';92',	';93',	';94',	';95',	';96',	';97',	';98',	';99');

const Teste: array[0..99] of Pchar = (
   ';0',	 ';1',	 ';2',	 ';3',	 ';4',	 ';5',	 ';6',	 ';7',	 ';8',	 ';9',
  ';10',	';11',	';12',	';13',	';14',	';15',	';16',	';17',	';18',	';19',
  ';20',	';21',	';22',	';23',	';24',	';25',	';26',	';27',	';28',	';29',
  ';30',	';31',	';32',	';33',	';34',	';35',	';36',	';37',	';38',	';39',
  ';40',	';41',	';42',	';43',	';44',	';45',	';46',	';47',	';48',	';49',
  ';50',	';51',	';52',	';53',	';54',	';55',	';56',	';57',	';58',	';59',
  ';60',	';61',	';62',	';63',	';64',	';65',	';66',	';67',	';68',	';69',
  ';70',	';71',	';72',	';73',	';74',	';75',	';76',	';77',	';78',	';79',
  ';80',	';81',	';82',	';83',	';84',	';85',	';86',	';87',	';88',	';89',
  ';90',	';91',	';92',	';93',	';94',	';95',	';96',	';97',	';98',	';99');



var
  strJogo_Com: array[0..7] of TStrings;

type
  TArranjoStatus = procedure(ArranjoStatus: string) of object;
  TArranjoErro = procedure(ArranjoErro: string) of object;

type

  { TArranjo }

  TArranjo = class(TThread)
  private
    strTexto: string;

    // Mensagem de erro.
    strErro: string;

    // Indica se ocorreu um erro.
    bErro: boolean;

    FArranjoStatus: TArranjoStatus;
    FArranjoErro: TArranjoErro;
    bPararThread : boolean;

    // Data e hora que iniciou a gravação.
    dataInicial: TDateTime;

    // Indica o diretório selecionado pelo usuário.
    DiretorioSelecionado: string;

    // Indica o diretório criado pelo próprio thread.
    DiretorioGerado: string;

    ArquivoGerado: string;
    ArquivoMemoria: TMemoryStream;

    // Guarda a data e hora que iníciou a gravação do arquivo.
    ArquivoTempoInicio: string;

    ContadorArquivo: Int64;
    ContadorLinha: Integer;
    ContadorArranjo: Int64;

		procedure CriarDiretorioGerado;
   procedure CriarNovoArquivo;
   function CriarNovoDiretorio: string;
   procedure GerarLinha;

    procedure GerarLotoMania;
    procedure GerarQuina;
    procedure GerarQuina5Numeros;
    procedure GerarQuina6Numeros;
    procedure GerarQuina7Numeros;
    procedure GravarArquivo;

  public
    JogoTipo: string;
    JogoNumero: integer;
    property OnArranjoStatus: TArranjoStatus read FArranjoStatus write FArranjoStatus;
    property OnArranjoErro: TarranjoErro read FArranjoErro write FArranjoErro;

    procedure Execute; override;
    procedure GerarLotofacil;
    procedure ExibirStatus;
    procedure ExibirErro;
    procedure PararThread;

  public
    constructor Create(CreateSuspended: boolean);

  end;

type

  { TfrmGeradorArranjo }

  TfrmGeradorArranjo = class(TForm)
    btnGerar: TButton;
    btnParar: TButton;
    cmbJogoTipo: TComboBox;
    cmbJogoNumeros: TComboBox;
		DiretorioDestino: TDirectoryEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
		Label5: TLabel;
		StatusBar1: TStatusBar;
    procedure btnGerarClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
		procedure Button2Click(Sender: TObject);
    procedure cmbJogoTipoChange(Sender: TObject);
		procedure DiretorioDestinoChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure PreencherLista;
    procedure StatusGeracao(status: string);

  private
    ArranjoThread: TArranjo;
    { private declarations }
  public
				procedure FimGeracao(Sender: TObject);
    { public declarations }
  end;

var
  frmGeradorArranjo: TfrmGeradorArranjo;

implementation

{$R *.lfm}

{ TArranjo }

procedure TArranjo.Execute;
begin
  // Vamos verificar primeiro se o jogo é válido ou não.
  JogoTipo := UpperCase(JogoTipo);

  if (JogoTipo = 'LOTOFACIL') and (not(JogoNumero in [15..18])) then begin
     strErro := 'Jogo: ' + JogoTipo + ', intervalo inválido para jogo: ' + IntToSTr(JogoNumero);
     Synchronize(@ExibirErro);
     Exit;
	end;

  if ((JogoTipo = 'MEGASENA') or (JogoTipo = 'DUPLASENA')) and (not(JogoNumero in [6..15])) then begin
    strErro := 'Jogo: ' + JogoTipo + ', intervalo inválido para jogo: ' + IntToStr(JogoNumero);
    Synchronize(@ExibirErro);
    Exit;
 end;


  // Guarda a data inicial.
  dataInicial := Now;

  case JogoTipo OF
       'QUINA': self.GerarQuina;
  end;


  //GerarLotomania;
  //GerarLotofacil;
end;

// Cria um novo arquivo e grava os dados na memória antes de salvar no computador.
// Parece que este procedimento é mais rápido.
procedure TArranjo.CriarNovoArquivo;
begin

  if ArquivoMemoria = nil then
     ArquivoMemoria := TMemoryStream.Create;

  ArquivoMemoria.Clear;

  // Guarda o ínicio do arquivo.
  ArquivoTempoInicio :=  FormatDateTime('YYYY-MM-DD_HHNNSS', Now);

  //ArquivoGerado := TFileStream.Create('/mnt/Gerador_de_Palavras/' + JogoTipo + '_com_' + JogoNumero +
  //              FormatDateTime('YYYY-MM-DD_HHNNSS', dataInicial) + '_arquivo_' +
  //              Format('%.10d', [ContadorArquivo]) + '.txt', fmCreate);
end;

// Após gerado tantas linhas de arranjos númericos, gravar os mesmos em um arquivo.
// Aqui, iremos definir 1 milhão de linhas.
procedure TArranjo.GravarArquivo;

begin
    Inc(ContadorArquivo, 1);

    // Vamos criar o nome do arquivo, por enquanto, o local é fixo, só mudando o nome do arquivo.
    ArquivoGerado := DiretorioGerado + FormatDateTime('YYYY-MM-DD_HHNNSS', dataInicial) + '_' +
                     JogoTipo + '_com_' + intToStr(JogoNumero) + '_numeros_inicio_' + ArquivoTempoInicio +
                     '_fim_' + FormatDateTime('YYYY-MM-DD_HHNNSS', Now) + '_arq_' +
                     Format('%.10d', [ContadorArquivo]) + '.txt';

     if ArquivoMemoria <> nil then begin
       ArquivoMemoria.SaveToFile(ArquivoGerado);
       ArquivoMemoria.Clear;
		 end;
end;


// Esta função retorna um nome de um novo diretório, o nome estará no formato:
// YYYY_MM_DD-HHNNSS
function TArranjo.CriarNovoDiretorio: string;
begin
     ArquivoTempoInicio:=FormatDateTime('YYYY-MM-DD_HHNNSS', Now);
     Exit(ArquivoTempoInicio);
end;

// Toda a vez que o usuário clicar em gerar um novo arranjo, será criado
// um subdiretório dentro do diretório selecionado pelo usuário.
procedure TArranjo.CriarDiretorioGerado;
begin
  // Verificar se diretório existe.
  if not DirectoryExists(DiretorioSelecionado) then begin
    strErro := 'Diretório ' + DiretorioSelecionado + ' não existe.';
    bErro := true;
    Synchronize(@ExibirErro);
    FreeAndNil(ArquivoMemoria);
    Exit;
	end;

  // Vamos tentar criar a pasta.
  try
    if AnsiRightStr(DiretorioSelecionado, 1) <> '/' then begin
       {$ifdef WINDOWS}
               DiretorioSelecionado += '\';
       {$else}
              DiretorioSelecionado += '/';
       {$endif}

		end;

    // Vamos repetir enquanto o diretório existir.
    repeat
          DiretorioGerado := DiretorioSelecionado + CriarNovoDiretorio;
		until not DirectoryExists(DiretorioSelecionado + DiretorioGerado);

    // Vamos criar o diretório.
    CreateDir(DiretorioGerado);
    if AnsiRightStr(DiretorioGerado, 1) <> '/' then begin
       {$ifdef WINDOWS}
               DiretorioGerado += '\';
       {$else}
              DiretorioGerado += '/';
       {$endif}
    end;

	except
    On exc: Exception do begin
      strErro := Exc.Message;
      bErro := true;
		end;
	end;
end;

procedure TArranjo.GerarQuina;
begin
     try
     case JogoNumero of
          5: GerarQuina5Numeros;
          6: GerarQuina6Numeros;
          7: GerarQuina7Numeros;
          else begin
               bErro := true;
               strErro := 'Intervalo válido para o jogo Quina: ' + IntToStr(JogoNumero);
          end;
		 end;
		 except
       On Exc: Exception do begin
            strErro := Exc.Message;
			 end;
		 end;
end;


procedure TArranjo.GerarQuina5Numeros;
var
  uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7: integer;
begin

      strTexto := '';
      ContadorLinha := 0;
      ContadorArquivo := 0;
      ContadorArranjo := 0;


	CriarDiretorioGerado;
	CriarNovoArquivo;

	for uColuna1 := 1 to 80 do
	for uColuna2 := uColuna1 + 1 to 80 do
	for uColuna3 := uColuna2 + 1 to 80 do
	for uColuna4 := uColuna3 + 1 to 80 do
	for uColuna5 := uColuna4 + 1 to 80 do begin
      strTexto := 'QUINA;5;';


      strTexto += Format('_%.2d_%.2d_%.2d_%.2d_%.2d;', [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5]);
      strTexto += Format('%.2d;%.2d;%.2d;%.2d;%.2d', [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5]);

      GerarLinha;
	end;

  // Se sobrou linhas, gravá-las.
    if ContadorLinha <> 0 then begin
     GravarArquivo;
     ContadorLinha := 0;
	end;

  // Limpar instância.
  FreeAndNil(ArquivoMemoria);
end;

procedure TArranjo.GerarQuina6Numeros;
var
  uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7: integer;
begin

		  strTexto := '';
		  ContadorLinha := 0;
		  ContadorArquivo := 0;
      ContadorArranjo := 0;


		  CriarDiretorioGerado;
		  CriarNovoArquivo;

	for uColuna1 := 1 to 80 do
	for uColuna2 := uColuna1 + 1 to 80 do
	for uColuna3 := uColuna2 + 1 to 80 do
	for uColuna4 := uColuna3 + 1 to 80 do
	for uColuna5 := uColuna4 + 1 to 80 do
  for uColuna6 := uColuna5 + 1 to 80 do begin
      strTexto := 'QUINA;6;';
      strTexto += Format('_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d;',
               [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6]);
      strTexto += Format('%.2d;%.2d;%.2d;%.2d;%.2d;%.2d',
               [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6]);

      GerarLinha;
	end;

  // Se sobrou linhas, gravá-las.
    if ContadorLinha <> 0 then begin
     GravarArquivo;
     ContadorLinha := 0;
	end;

  // Limpar instância.
  FreeAndNil(ArquivoMemoria);
end;

procedure TArranjo.GerarQuina7Numeros;
var
  uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7: integer;
begin

		  strTexto := '';
		  ContadorLinha := 0;
		  ContadorArquivo := 0;
      ContadorArranjo := 0;

		  CriarDiretorioGerado;
		  CriarNovoArquivo;

	for uColuna1 := 1 to 80 do
	for uColuna2 := uColuna1 + 1 to 80 do
	for uColuna3 := uColuna2 + 1 to 80 do
	for uColuna4 := uColuna3 + 1 to 80 do
	for uColuna5 := uColuna4 + 1 to 80 do
        for uColuna6 := uColuna5 + 1 to 80 do
        for uColuna7 := uColuna6 + 1 to 80 do begin
            strTexto := 'QUINA;7;';
            strTexto += NumeroUnderLine[uColuna1] + NumeroUnderline[uColuna2] + NumeroUnderLine[uColuna3];
            strTexto += NumeroUnderLine[uColuna4] + NumeroUnderline[uColuna5] + NumeroUnderLine[uColuna6];
            strTexto += NumeroUnderLine[uColuna7];
            strTexto += NumeroCSV[uColuna1] + NumeroCSV[uColuna2] + NumeroCSV[uColuna3];
            strTexto += NumeroCSV[uColuna4] + NumeroCSV[uColuna5] + NumeroCSV[uColuna6];
            strTexto += NumeroCSV[uColuna7];

      //strTexto += Format('_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d;',
      //         [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7]);
      //strTexto += Format('%.2d;%.2d;%.2d;%.2d;%.2d;%.2d;%.2d',
      //         [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7]);

      GerarLinha;
	end;

  // Se sobrou linhas, gravá-las.
    if ContadorLinha <> 0 then begin
     GravarArquivo;
     ContadorLinha := 0;
	end;

  // Limpar instância.
  FreeAndNil(ArquivoMemoria);
end;


procedure TArranjo.GerarLinha;
begin
  ArquivoMemoria.Write(strTexto[1], length(strTexto));

  self.Synchronize(@ExibirStatus);

  if self.Terminated then begin
     FreeAndNil(ArquivoMemoria);
     Exit;
  end;

  ContadorLinha += 1;
  ContadorArranjo += 1;

  // Só grava o caractere de nova linha, se não for a última linha do arquivo.
  if ContadorLinha <> 1000000 then begin
       {$IFDEF UNIX}
		    ArquivoMemoria.WriteByte(10);
		    {$ELSE}
		    {$IFDEF WINDOWS}
		    ArquivoMemoria.WriteByte(10);
		    ArquivoMemoria.WriteByte(13);
		    {$ElSE}
		    ArquivoMemoria.WriteByte(13);
		    {$ENDIF}
		    {$ENDIF}
	end else begin
     GravarArquivo;
     CriarNovoArquivo;
     ContadorLinha := 0;
	end;
end;



procedure TArranjo.GerarLotoMania;
var
  uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7,
  uColuna8, uColuna9, uColuna10, uColuna11, uColuna12, uColuna13,
  uColuna14, uColuna15, uColuna16, uColuna17, uColuna18, uColuna19,
	uColuna20, uColuna21, uColuna22, uColuna23, uColuna24, uColuna25,
	uColuna26, uColuna27, uColuna28, uColuna29, uColuna30, uColuna31,
	uColuna32, uColuna33, uColuna34, uColuna35, uColuna36, uColuna37,
	uColuna38, uColuna39, uColuna40, uColuna41, uColuna42, uColuna43,
	uColuna44, uColuna45, uColuna46, uColuna47, uColuna48, uColuna49,
	uColuna50: integer;
begin
  strTexto := '';
  ContadorLinha := 0;
  ContadorArquivo := 0;

  CriarDiretorioGerado;
  CriarNovoArquivo;


		  for uColuna1 := 0 to 99 do
		  for uColuna2 := uColuna1 + 1 to 99 do
		  for uColuna3 := uColuna2 + 1 to 99 do
		  for uColuna4 := uColuna3 + 1 to 99 do
		  for uColuna5 := uColuna4 + 1 to 99 do
		  for uColuna6 := uColuna5 + 1 to 99 do
		  for uColuna7 := uColuna6 + 1 to 99 do
		  for uColuna8 := uColuna7 + 1 to 99 do
		  for uColuna9 := uColuna8 + 1 to 99 do
		  for uColuna10 := uColuna9 + 1 to 99 do
		  for uColuna11 := uColuna10 + 1 to 99 do
		  for uColuna12 := uColuna11 + 1 to 99 do
		  for uColuna13 := uColuna12 + 1 to 99 do
		  for uColuna14 := uColuna13 + 1 to 99 do
		  for uColuna15 := uColuna14 + 1 to 99 do
		  for uColuna16 := uColuna15 + 1 to 99 do
		  for uColuna17 := uColuna16 + 1 to 99 do
		  for uColuna18 := uColuna17 + 1 to 99 do
		  for uColuna19 := uColuna18 + 1 to 99 do
		  for uColuna20 := uColuna19 + 1 to 99 do
		  for uColuna21 := uColuna20 + 1 to 99 do
		  for uColuna22 := uColuna21 + 1 to 99 do
		  for uColuna23 := uColuna22 + 1 to 99 do
		  for uColuna24 := uColuna23 + 1 to 99 do
		  for uColuna25 := uColuna24 + 1 to 99 do
		  for uColuna26 := uColuna25 + 1 to 99 do
		  for uColuna27 := uColuna26 + 1 to 99 do
		  for uColuna28 := uColuna27 + 1 to 99 do
		  for uColuna29 := uColuna28 + 1 to 99 do
		  for uColuna30 := uColuna29 + 1 to 99 do
		  for uColuna31 := uColuna30 + 1 to 99 do
		  for uColuna32 := uColuna31 + 1 to 99 do
		  for uColuna33 := uColuna32 + 1 to 99 do
		  for uColuna34 := uColuna33 + 1 to 99 do
		  for uColuna35 := uColuna34 + 1 to 99 do
		  for uColuna36 := uColuna35 + 1 to 99 do
		  for uColuna37 := uColuna36 + 1 to 99 do
		  for uColuna38 := uColuna36 + 1 to 99 do
		  for uColuna39 := uColuna37 + 1 to 99 do
		  for uColuna40 := uColuna39 + 1 to 99 do
		  for uColuna41 := uColuna40 + 1 to 99 do
		  for uColuna42 := uColuna41 + 1 to 99 do
		  for uColuna43 := uColuna42 + 1 to 99 do
		  for uColuna44 := uColuna43 + 1 to 99 do
		  for uColuna45 := uColuna44 + 1 to 99 do
		  for uColuna46 := uColuna45 + 1 to 99 do
		  for uColuna47 := uColuna46 + 1 to 99 do
		  for uColuna48 := uColuna47 + 1 to 99 do
		  for uColuna49 := uColuna48 + 1 to 99 do
		  for uColuna50 := uColuna49 + 1 to 99 do
		    begin
		      // Fica neste formato: JOGO;QT_NUMEROS;NUMEROS_COMBINADOS;NUM_1;NUM2; ...
		      strTexto := 'LOTOMANIA;50;';
          strTexto += Format(
                   '_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d' +
                   '_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d' +
                   '_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d' +
                   '_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d' +
                   '_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d',
		               [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5,
                    uColuna6, uColuna7, uColuna8, uColuna9, uColuna10,
                    uColuna11, uColuna12, uColuna13, uColuna14, uColuna15,
                    uColuna16, uColuna17, uColuna18, uColuna19, uColuna20,
                    uColuna21, uColuna22, uColuna23, uColuna24, uColuna25,
					          uColuna26, uColuna27, uColuna28, uColuna29, uColuna30,
                    uColuna31, uColuna32, uColuna33, uColuna34, uColuna35,
                    uColuna36, uColuna37, uColuna38, uColuna39, uColuna40,
                    uColuna41, uColuna42, uColuna43, uColuna44, uColuna45,
                    uColuna46, uColuna47, uColuna48, uColuna49, uColuna50]);

          strTexto += Format(
                   ';_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d' +
                   ';_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d' +
                   ';_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d' +
                   ';_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d' +
                   ';_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d;_%.2d' ,
                   [uColuna1, uColuna2, uColuna3, uColuna4, uColuna5,
                    uColuna6, uColuna7, uColuna8, uColuna9, uColuna10,
                    uColuna11, uColuna12, uColuna13, uColuna14, uColuna15,
                    uColuna16, uColuna17, uColuna18, uColuna19, uColuna20,
                    uColuna21, uColuna22, uColuna23, uColuna24, uColuna25,
					          uColuna26, uColuna27, uColuna28, uColuna29, uColuna30,
                    uColuna31, uColuna32, uColuna33, uColuna34, uColuna35,
                    uColuna36, uColuna37, uColuna38, uColuna39, uColuna40,
                    uColuna41, uColuna42, uColuna43, uColuna44, uColuna45,
                    uColuna46, uColuna47, uColuna48, uColuna49, uColuna50]);

          GerarLinha;

				end;

      // Se sobrou linhas, gravá-las.
        if ContadorLinha = 1000000 then begin
         GravarArquivo;
         ContadorLinha := 0;
    	end;

      // Limpar instância.
      FreeAndNil(ArquivoMemoria);

end;

procedure TArranjo.GerarLotofacil;
var
  strArquivo: TFileStream;
  uColuna1, uColuna2, uColuna3, uColuna4, uColuna5, uColuna6, uColuna7,
  uColuna8, uColuna9, uColuna10, uColuna11, uColuna12, uColuna13,
  uColuna14, uColuna15: Integer;
  strFormatado: string;
begin
  strTexto := '';
  try
    strArquivo := TFileStream.Create('/mnt/Gerador_de_Palavras/lotofacil.txt',
      fmCreate);

    for uColuna1 := 1 to 25 do
      for uColuna2 := uColuna1 + 1 to 25 do
        for uColuna3 := uColuna2 + 1 to 25 do
          for uColuna4 := uColuna3 + 1 to 25 do
            for uColuna5 := uColuna4 + 1 to 25 do
              for uColuna6 := uColuna5 + 1 to 25 do
                for uColuna7 := uColuna6 + 1 to 25 do
                  for uColuna8 := uColuna7 + 1 to 25 do
                    for uColuna9 := uColuna8 + 1 to 25 do
                      for uColuna10 := uColuna9 + 1 to 25 do
                        for uColuna11 := uColuna10 + 1 to 25 do
                          for uColuna12 :=
                            uColuna11 + 1 to 25 do
                            for uColuna13 :=
                              uColuna12 + 1 to 25 do
                              for uColuna14 :=
                                uColuna13 + 1 to 25 do
                                for uColuna15 :=
                                  uColuna14 + 1 to 25 do
                                begin
                                  // Fica neste formato: JOGO;QT_NUMEROS;NUMEROS_COMBINADOS;NUM_1;NUM2; ...
                                  strTexto :=
                                    'LOTOFACIL;15;';
                                  strFormatado :=
                                    Format(
                                    '_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d_%.2d',
                                    [uColuna1,
                                    uColuna2, uColuna3, uColuna4,
                                    uColuna5, uColuna6, uColuna7, uColuna8, uColuna9,
                                    uColuna10, uColuna11, uColuna12,
                                    uColuna13, uColuna14, uColuna15]);
                                  strTexto +=
                                    strFormatado;
                                  strTexto +=
                                    ReplaceText(strFormatado, '_', ';');

                        		      ArquivoMemoria.Write(strTexto[1], length(strTexto));

                                  {$IFDEF UNIX}
                        		      ArquivoMemoria.WriteByte(10);
                                  {$ELSE}
                                  {$IF WINDOWS}
                                  ArquivoMemoria.WriteByte(10);
                                  ArquivoMemoria.WriteByte(13);
                                  {$ElSE}
                                  ArquivoMemoria.WriteByte(13);
                                  {$ENDIF}
                                  {$ENDIF}

                        		      self.Synchronize(@ExibirStatus);

                        		      if self.Terminated then begin
                        		         FreeAndNil(ArquivoMemoria);
                        		         Exit;
                        				  end;

                                  ContadorLinha += 1;
                                  if ContadorLinha = 1000000 then begin
                                     Self.GravarArquivo;
                                     CriarNovoArquivo;
                                     ContadorLinha := 0;
                        					end;
                        		    end;

                            if contadorLinha <> 0 then begin
                               contadorLinha := 0;
                               GravarArquivo;
                        		end;
                            FreeAndNil(ArquivoMemoria);
                            MessageDlg('', 'Executado com sucesso!!!', TMsgDlgType.mtInformation, [mbOK], 0);




  except
    On exc: Exception do
    begin

    end;

  end;
end;

procedure TArranjo.ExibirStatus;
begin
  OnArranjoStatus(Format('%.15d', [ContadorArranjo]) + #10 + strTexto);
end;

procedure TArranjo.ExibirErro;
begin
  OnArranjoErro(strErro);
end;

procedure TArranjo.PararThread;
begin
      bPararThread := true;
end;

constructor TArranjo.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

{ TfrmGeradorArranjo }

procedure TfrmGeradorArranjo.FormCreate(Sender: TObject);
begin
  // Preencher comboBox.
  PreencherLista;
end;

// Altera a caixa de combinação conforme o jogo é escolhido.
procedure TfrmGeradorArranjo.cmbJogoTipoChange(Sender: TObject);
var
  strJogo: string;
  uA: integer;
begin
  strJogo := UpperCase(cmbJogoTipo.Items[cmbJogoTipo.ItemIndex]);

  // Apaga os ítens da lista pois o usuário escolheu um novo jogo.
  cmbJogoNumeros.Items.Clear;

  if strJogo = 'QUINA' then
  begin
    for uA := 5 to 7 do
    begin
      cmbJogoNumeros.Items.Add(IntToStr(uA));
    end;
  end
  else if (strJogo = 'MEGASENA') or (strJogo = 'DUPLASENA') then
  begin
    for uA := 6 to 15 do
    begin
      cmbJogoNumeros.Items.Add(IntToStr(uA));
    end;
  end
  else if strJogo = 'LOTOFACIL' then
  begin
    for uA := 15 to 18 do
    begin
      cmbJogoNumeros.Items.Add(IntToStr(uA));
    end;
  end
  else if strJogo = 'LOTOMANIA' then
  begin
    cmbJogoNumeros.Items.Add('50');
  end
  else if strJogo = 'INTRALOT_MINAS_5' then
  begin
    cmbJogoNumeros.Items.Add('5');
  end
  else if strJogo = 'INTRALOT_KENO_MINAS' then
  begin
    cmbJogoNumeros.Items.Add('6');
  end;

  // Define o primeiro item como o escolhido.
  cmbJogoNumeros.ItemIndex := 0;
end;

procedure TfrmGeradorArranjo.DiretorioDestinoChange(Sender: TObject);
begin

end;

procedure TfrmGeradorArranjo.btnGerarClick(Sender: TObject);
begin
  btnGerar.Enabled := False;
  btnParar.Enabled := True;
  ArranjoThread := TArranjo.Create(True);

  ArranjoThread.JogoTipo:= cmbJogoTipo.Items[cmbJogoTipo.ItemIndex];
  ArranjoThread.JogoNumero:= StrToInt(cmbJogoNumeros.Items[cmbJogoNumeros.ItemIndex]);

  if not DirectoryExists(DiretorioDestino.Directory) then
     DiretorioDestino.Directory:= './';

  ArranjoThread.DiretorioSelecionado:=DiretorioDestino.Directory;
  ArranjoThread.OnArranjoStatus := @StatusGeracao;
  ArranjoThread.OnTerminate:=@FimGeracao;
  ArranjoThread.Start;
end;

procedure TfrmGeradorArranjo.btnPararClick(Sender: TObject);
begin
  //ArranjoThread.OnArranjoStatus := nil;
  ArranjoThread.Terminate;
  //FreeAndNil(ArranjoThread);
  //ArranjoThread.PararThread;
  btnParar.Enabled := False;
  btnGerar.Enabled := True;
end;

procedure TfrmGeradorArranjo.Button2Click(Sender: TObject);
begin

end;

procedure TfrmGeradorArranjo.PreencherLista;
var
  uA: integer;
begin
  for uA := 0 to High(strJogo_Tipo) do
  begin
    cmbJogoTipo.Items.Add(strJogo_Tipo[uA]);
  end;
  cmbJogoTipo.ItemIndex := 0;

end;

procedure TfrmGeradorArranjo.StatusGeracao(status: string);
begin
  label4.Caption := status;
end;

procedure TfrmGeradorArranjo.FimGeracao(Sender: TObject);
begin
      btnParar.Enabled:=False;
      btnGerar.Enabled := true;
end;

end.
