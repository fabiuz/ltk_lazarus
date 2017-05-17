unit ulotofacil_database;

{
 Esta unit serve para gerar todos as combinações que serão inseridas
 no banco de dados
 }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strUtils;

const
  Lotofacil_Bolas_Combinadas: array[1..25] of string = (
    '_01', '_02', '_03', '_04', '_05', '_06', '_07', '_08',
    '_09', '_10', '_11', '_12', '_13', '_14', '_15', '_16',
    '_17', '_18', '_19', '_20', '_21', '_22', '_23', '_24',
    '_25');
  Lotofacil_Coluna_Numero: array[1..25] of string = (
    'num_1',
    'num_2',
    'num_3',
    'num_4',
    'num_5',
    'num_6',
    'num_7',
    'num_8',
    'num_9',
    'num_10',
    'num_11',
    'num_12',
    'num_13',
    'num_14',
    'num_15',
    'num_16',
    'num_17',
    'num_18',
    'num_19',
    'num_20',
    'num_21',
    'num_22',
    'num_23',
    'num_24',
    'num_25');

  Lotofacil_Coluna_B_Campos: array[1..15] of string = (
    'b_1', 'b_2', 'b_3', 'b_4', 'b_5', 'b_6', 'b_7',
    'b_8', 'b_9', 'b_10', 'b_11', 'b_12', 'b_13', 'b_14', 'b_15');

type
  TLotofacilDatabaseStatus = procedure(qtGerados: longint) of object;


type
  TLotofacilModo = (
    GERAR_15_NUMEROS, GERAR_16_NUMEROS, GERAR_17_NUMEROS,
    GERAR_18_NUMEROS, GERAR_SUBCONJUNTO);

  { TLotofacilDatabaseThread }

  TLotofacilDatabaseThread = class(TThread)
  private
    // Indica o modo do gerador atual.
    fLotofacilModo : TLotofacilModo;


    procedure GerarLinha(var arquivo_csv: TMemoryStream; qtColunas: integer;
      qtRank: integer);
    { Armazena cada número após a interação }
  private
    bolasSubConjunto: array[1..25] of integer;
  private
    bolasConjunto: array of integer;
  private
    bolasConjuntoCombinadas: string;

    qtBolas: integer;      // Indica a quantidade de bolas do jogo.
    fStatus: TLotofacilDatabaseStatus;
    function GerarDataHora: string;
  public
    procedure Execute; override;
  private
    procedure GerarLotofacil15Numeros;
    procedure GerarLotofacil16Numeros;
    procedure GerarLotofacil17Numeros;
    procedure GerarLotofacil18Numeros;

    procedure GerarSubConjuntos(const bolas: array of integer);

    property onStatus: TLotofacilDatabaseStatus read fStatus write fStatus;
    property LotofacilModo : TLotofacilModo read fLotofacilModo write fLotofacilModo;
  end;



  TLotofacilDatabase = class
  private
    LTFThread: TLotofacilDatabaseThread;
    fStatus: TLotofacilDatabaseStatus;
  public
    constructor Create;
    procedure GerarLotofacil15Numeros;
    procedure GerarLotofacil16Numeros;
    procedure GerarLotofacil17Numeros;
    procedure GerarLotofacil18Numeros;

    procedure GerarSubConjuntos;

    property onStatus: TLotofacilDatabaseStatus read fStatus write fStatus;

    procedure StatusResultado(qtRank: longint);
  end;


implementation

{ TLotofacilDatabase }

constructor TLotofacilDatabase.Create;
begin
  ltfThread := TLotofacilDatabaseThread.Create(True);
  ltfThread.fStatus := @StatusResultado;
end;

procedure TLotofacilDatabase.GerarLotofacil15Numeros;
begin
  if ltfThread = nil then
    ltfThread := TLotofacilDatabaseThread.Create(True);

  ltfThread.fStatus := self.onStatus;
  ltfThread.qtBolas := 15;
  ltfThread.Start;

  //ltfThread.Execute;
  //ltfThread.GerarLotofacil15Numeros;

end;

procedure TLotofacilDatabase.GerarLotofacil16Numeros;
begin

end;

procedure TLotofacilDatabase.GerarLotofacil17Numeros;
begin

end;

procedure TLotofacilDatabase.GerarLotofacil18Numeros;
begin

end;

procedure TLotofacilDatabase.GerarSubConjuntos;
const
  bolas : array[1..10] of integer = (2, 5, 6, 14, 16, 17, 20, 21, 23, 25);
begin
  // Vamos eliminar a thread e começar uma nova.
  //FreeAndNil(LTFThread);

  LTFThread := TLotofacilDatabaseThread.Create(true);
  LtfThread.LotofacilModo := TLotofacilModo.GERAR_SUBCONJUNTO;

  // Carregar os números.
  //ltfThread.bolasConjunto := bolas;
  ltfThread.GerarSubConjuntos(bolas);

end;

function TLotofacilDatabaseThread.GerarDataHora: string;
var
  dataAtual: TDateTime;
begin
  Result := FormatDateTime('yyyyMMddHHNNss', Now);
end;

{
 Este método, gera todos os subconjuntos para um conjunto de números dados.
 O resultado será armazenado em um arquivo *.csv.
 Este formato é mais rápido para fazer a importação para o banco de dados.
 Cada conjunto de números, gerar x quantidades de números, segue-se exemplo:

 15 números -> 32767 subconjuntos,
 14 números -> 16383 subconjuntos,
 13 números -> 8191 subconjuntos,
 12 números -> 4095 subconjuntos,
 11 números -> 2047 subconjuntos,
 10 números -> 1023 subconjuntos,
 9  números -> 511 subconjuntos,
 8  números -> 255 subconjuntos,
 7  números -> 127 subconjuntos,
 6  números -> 63 subconjuntos,
 5  números -> 31 subconjuntos,
 4  números -> 15 subconjuntos,
 3  números -> 7 subconjuntos,
 2  números -> 3 subconjuntos,
 }
procedure TLotofacilDatabaseThread.GerarSubConjuntos(const bolas: array of integer);
var
  tamanhoArranjo, iA, coluna1, qtRank, coluna2, coluna3, coluna4,
  coluna5, coluna6, coluna7, coluna8, coluna9, coluna10, coluna11,
  coluna12, coluna13, coluna14, coluna15, uA, ultimoIndice: integer;
  arquivo_CSV: TMemoryStream;
  strTexto: string;
begin
  tamanhoArranjo := Length(bolas);

  // Como arranjos não declarados o ínicio começa em zero, então devemos decrementar.
  ultimoIndice := tamanhoArranjo - 1;

  // Só iremos pegar até 15 números.
  if tamanhoArranjo > 15 then
    exit;

  // Vamos copiar o arranjo
  // Inicializa o arranjo.
  SetLength(bolasConjunto, tamanhoArranjo);
  for uA := 0 to ultimoIndice do begin
    bolasConjunto[uA] := bolas[uA];
  end;




  // Cria um fluxo de memória para depois ser salvo em um arquivo.
  arquivo_CSV := TMemoryStream.Create;

  // Cria o cabeçalho do arquivo.
  strTexto := 'jogo;qt_bolas;bolas_combinadas;qt_bolas_base;bolas_combinadas_base;';
  for iA := 1 to 15 do
  begin
    strTexto := strTexto + 'b_' + IntToStr(iA) + ';';
  end;
  strTexto := strTexto + 'par;impar;cmb_par_impar;rank_posicao;';
  for iA := 1 to 25 do
  begin
    strTexto := strTexto + 'num_' + IntToStr(iA) + ';';
  end;
  strTexto := strTexto + 'sql_num_subconjunto;qt_grupos_item_em_sequencia;';
  strTexto := strTexto + 'qt_max_item_em_sequencia;qt_grupos_item_nao_sequencial;';
  strTexto := strTexto + 'qt_max_item_nao_sequencial';

  {$ifdef LINUX}
  strTexto := strTexto + #10;
  {$else $ifdef WINDOWS}
  strTexto := strTexto + #1310;
  {$endif}

  // Gravar o cabeçalho
  arquivo_Csv.Write(PChar(strTexto)^, Length(strTexto));

  // Concatena as bolas do conjunto e
  // aproveita para iniciar o arranjo 'bolasConjunto'.
  bolasConjuntoCombinadas := '';

  // Constantes começa em 0.
  for uA := 0 to ultimoIndice do
  begin
    bolasConjuntoCombinadas :=
      bolasConjuntoCombinadas + lotofacil_bolas_combinadas
      [bolas[uA]];

  end;

  qtRank := 0;
  for coluna1 := 0 to ultimoIndice do
  begin
    bolasSubConjunto[1] := bolasConjunto[coluna1];
    Inc(qtRank);
    GerarLinha(arquivo_csv, 1, qtRank);

    for coluna2 := coluna1 + 1 to ultimoIndice do
    begin
      bolasSubConjunto[2] := bolasConjunto[coluna2];
      Inc(qtRank);
      GerarLinha(arquivo_csv, 2, qtRank);

      for coluna3 := coluna2 + 1 to ultimoIndice do
      begin
        bolasSubConjunto[3] := bolasConjunto[coluna3];
        Inc(qtRank);
        GerarLinha(arquivo_csv, 3, qtRank);

        for coluna4 := coluna3 + 1 to ultimoIndice do
        begin
          bolasSubConjunto[4] := bolasConjunto[coluna4];
          Inc(qtRank);
          GerarLinha(arquivo_csv, 4, qtRank);

          for coluna5 := coluna4 + 1 to ultimoIndice do
          begin
            bolasSubConjunto[5] := bolasConjunto[coluna5];
            Inc(qtRank);
            GerarLinha(arquivo_csv, 5, qtRank);

            for coluna6 := coluna5 + 1 to ultimoIndice do
            begin
              bolasSubConjunto[6] := bolasConjunto[coluna6];
              Inc(qtRank);
              GerarLinha(arquivo_csv, 6, qtRank);

              for coluna7 := coluna6 + 1 to ultimoIndice do
              begin
                bolasSubConjunto[7] := bolasConjunto[coluna7];
                Inc(qtRank);
                GerarLinha(arquivo_csv, 7, qtRank);

                for coluna8 := coluna7 + 1 to ultimoIndice do
                begin
                  bolasSubConjunto[8] := bolasConjunto[coluna8];
                  Inc(qtRank);
                  GerarLinha(arquivo_csv, 8, qtRank);

                  for coluna9 := coluna8 + 1 to ultimoIndice do
                  begin
                    bolasSubConjunto[9] := bolasConjunto[coluna9];
                    Inc(qtRank);
                    GerarLinha(arquivo_csv, 9, qtRank);

                    for coluna10 := coluna9 + 1 to ultimoIndice do
                    begin
                      bolasSubConjunto[10] := bolasConjunto[coluna10];
                      Inc(qtRank);
                      GerarLinha(arquivo_csv, 10, qtRank);

                      for coluna11 := coluna10 + 1 to ultimoIndice do
                      begin
                        bolasSubConjunto[11] := bolasConjunto[coluna11];
                        Inc(qtRank);
                        GerarLinha(arquivo_csv, 11, qtRank);

                        for coluna12 := coluna11 + 1 to ultimoIndice do
                        begin
                          bolasSubConjunto[12] := bolasConjunto[coluna12];
                          Inc(qtRank);
                          GerarLinha(arquivo_csv, 12, qtRank);

                          for coluna13 := coluna12 + 1 to ultimoIndice do
                          begin
                            bolasSubConjunto[13] := bolasConjunto[coluna13];
                            Inc(qtRank);
                            GerarLinha(arquivo_csv, 13, qtRank);

                            for coluna14 := coluna13 + 1 to ultimoIndice do
                            begin
                              bolasSubConjunto[14] := bolasConjunto[coluna14];
                              Inc(qtRank);
                              GerarLinha(arquivo_csv, 14, qtRank);

                              for coluna15 := coluna14 + 1 to ultimoIndice do
                              begin
                                bolasSubConjunto[15] := bolasConjunto[coluna15];
                                Inc(qtRank);
                                GerarLinha(arquivo_csv, 15, qtRank);

                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  // Gravar no arquivo.
  arquivo_csv.SaveToFile('/run/media/fabiuz/000E4C3400030AE7/Downloads_3/teste_lazarus/lotofacil_subconjunto.csv');


end;


procedure TLotofacilDatabaseThread.GerarLinha(var arquivo_csv: TMemoryStream;
  qtColunas: integer; qtRank: integer);
var
  bolasCombinadas, strTexto, strSql: string;
  bolas: array[1..25] of boolean;
  uA, par, impar: integer;
begin
  // Percorre cada bola e coloca no arranjo.
  bolasCombinadas := '';

  for uA := 1 to qtColunas do
  begin
    bolasCombinadas := bolasCombinadas +
      Lotofacil_Bolas_Combinadas[bolasSubConjunto[uA]];
    bolas[bolasSubConjunto[uA]] := True;
  end;

  strTexto := 'LOTOFACIL;';
  strTexto := strTexto + IntToStr(qtColunas) + ';';
  strTexto := strTexto + bolasCombinadas + ';';
  strTexto := strTexto + IntToStr(Length(bolasConjunto)) + ';';
  strTexto := strTexto + bolasConjuntoCombinadas + ';';

  // Pega a quantidade de bolas que foram sorteadas.
  // Devemos usar o while ao invés do for, pois, o valor é indefinido após
  // sair do loop.

  // Vamos contar par e impar.
  par := 0;
  impar := 0;

  uA := 1;
  while uA <= qtColunas do
  begin
    strTexto := strTexto + IntToStr(bolasSubConjunto[uA]) + ';';
    if bolasSubConjunto[uA] mod 2 = 0 then
    begin
      Inc(par);
    end
    else
    begin
      Inc(impar);
    end;

    Inc(uA);
  end;

  // Vamos preencher as colunas 'b_' restantes.
  uA := 15 - qtColunas;
  if uA <> 0 then
  begin
    strTexto := strTexto + DupeString('0;', uA);
  end;

  // Preencher par e impar
  strTexto := strTexto + IntToStr(par) + ';';
  strTexto := strTexto + IntToStr(impar) + ';';
  strTexto := strTexto + Format('%.2d_%.2d;', [par, impar]);

  // Preencher rank.
  strTexto := strTexto + IntToStr(qtRank) + ';';

  // Iremos, utilizar, um sql parcial, pois iremos utilizar, pra ficar
  // fácil pegar todos os ítens em uma consulta, sql.
  strSql := '';
  for uA := 1 to 25 do
  begin
    if bolas[uA] = True then
    begin
      strTexto := strTexto + '1;';

      if strSql <> '' then
      begin
        strSql := strSql + ' and';
      end;
      strSql := strSql + ' num_' + IntToStr(uA) + ' = 1';
    end
    else
    begin
      strTexto := strTexto + '0;';
    end;
  end;

  // Agora, inserir o sql, como um dos campos.
  strTexto := strTexto + '(' + strSql + ');';

  // No momento não iremos implementar os 4 últimos campos.
  strTexto := strTexto + '0;0;0;0';

  // Iremos colocar o caractere de nova linha.
  {$ifdef LINUX}
  strTexto := strTexto + #10;
  {$else $ifdef WINDOWS}
  strTexto := strTexto + #1310;
  {$endif}

  // Gravar o resultado na memória, pra futuramente, ser gravado em um arquivo.
  arquivo_Csv.Write(PChar(strTexto)^, Length(strTexto));

end;

procedure TLotofacilDatabase.StatusResultado(qtRank: longint);
begin
  onStatus(qtRank);
end;

{ TLotofacilDatabaseThread }

procedure TLotofacilDatabaseThread.Execute;
begin


  case qtBolas of
    15: GerarLotofacil15Numeros;
    16: GerarLotofacil16Numeros;
    17: GerarLotofacil17Numeros;
    18: GerarLotofacil18Numeros;
  end;
end;



procedure TLotofacilDatabaseThread.GerarLotofacil15Numeros;
var
  QuinzeBolas: array[1..15] of integer;
  // Cada posição armazena a bola que está sendo iterada.
  coluna1, coluna2, coluna3, coluna4, coluna5, coluna6, coluna7,
  coluna8, coluna9, coluna10, coluna11, coluna12, coluna13, coluna14,
  coluna15, qtPares, qtImpares, uA, vertical_1, vertical_2, vertical_3,
  vertical_4, vertical_5, horizontal_1, horizontal_2, horizontal_3,
  horizontal_4, horizontal_5, diagonal_1, diagonal_2, diagonal_3,
  diagonal_4, diagonal_5, qtExterno, qtInterno: integer;
  qtRank: longint;
  strColunaB, strColunaPOS, strColunaNum, strCombinado, colunaB_Valores,
  colunaNumero_Valores, colunaNumero_Campos, strSqlInsert, strTexto: string;
  listaSqlInsert: TStringList;
  listaSqlMemoryStream: TMemoryStream;
  arquivoListaSql: TFileStream;

begin
  strColunaB := '';   // Indica os valores das colunas b_1 a b_15.
  strColunaNum := ''; // Armazena cada número que foi sorteado.
  strCombinado := ''; // Armazena cada número combinado.
  qtPares := 0;
  qtImpares := 0;

  colunaB_Valores := '';  // Um string, onde cada bola, é separada por vírgula.

  // Não precisamos inserir todas as 25 colunas, somente, as 15 que sairão,
  // pois, todas as colunas da tabela que começa com 'num_' tem o valor padrão '0'.
  // então, a variável abaixo, armazenará todas as 15 bolas que sairão.
  colunaNumero_Valores := '';

  // Como não iremos armazenar todos os campos, devemos armazenar, quais campos
  // serão inseridos.
  colunaNumero_Campos := '';


  listaSqlInsert := TStringList.Create;

  qtRank := 0;

  listaSqlMemoryStream := TMemoryStream.Create;

  // Vamos criar um arquivo para armazenar os dados.
  arquivoListaSql := TFileStream.Create(
    '/run/media/fabiuz/000E4C3400030AE7/Downloads_3/teste_lazarus/lotofacil_15_2.sql', fmCreate);

  for coluna1 := 1 to 25 do
  begin
    QuinzeBolas[1] := coluna1;
    for coluna2 := coluna1 + 1 to 25 do
    begin
      QuinzeBolas[2] := coluna2;
      for coluna3 := coluna2 + 1 to 25 do
      begin
        QuinzeBolas[3] := coluna3;
        for coluna4 := coluna3 + 1 to 25 do
        begin
          QuinzeBolas[4] := coluna4;
          for coluna5 := coluna4 + 1 to 25 do
          begin
            QuinzeBolas[5] := coluna5;
            for coluna6 := coluna5 + 1 to 25 do
            begin
              QuinzeBolas[6] := coluna6;
              for coluna7 := coluna6 + 1 to 25 do
              begin
                QuinzeBolas[7] := coluna7;
                for coluna8 := coluna7 + 1 to 25 do
                begin
                  QuinzeBolas[8] := coluna8;
                  for coluna9 := coluna8 + 1 to 25 do
                  begin
                    QuinzeBolas[9] := coluna9;
                    for coluna10 := coluna9 + 1 to 25 do
                    begin
                      QuinzeBolas[10] := coluna10;
                      for coluna11 := coluna10 + 1 to 25 do
                      begin
                        QuinzeBolas[11] := coluna11;
                        for coluna12 := coluna11 + 1 to 25 do
                        begin
                          QuinzeBolas[12] := coluna12;
                          for coluna13 := coluna12 + 1 to 25 do
                          begin
                            QuinzeBolas[13] := coluna13;
                            for coluna14 := coluna13 + 1 to 25 do
                            begin
                              QuinzeBolas[14] := coluna14;
                              for coluna15 := coluna14 + 1 to 25 do
                              begin
                                QuinzeBolas[15] := coluna15;

                                qtPares := 0;
                                qtImpares := 0;

                                colunaB_Valores := '';

                                strCombinado := '';

                                vertical_1 := 0;
                                vertical_2 := 0;
                                vertical_3 := 0;
                                vertical_4 := 0;
                                vertical_5 := 0;

                                horizontal_1 := 0;
                                horizontal_2 := 0;
                                horizontal_3 := 0;
                                horizontal_4 := 0;
                                horizontal_5 := 0;

                                diagonal_1 := 0;
                                diagonal_2 := 0;
                                diagonal_3 := 0;
                                diagonal_4 := 0;
                                diagonal_5 := 0;

                                qtExterno := 0;
                                qtInterno := 0;

                                colunaNumero_Campos := '';

                                for uA := 1 to 15 do
                                begin
                                  // Não tem problema as colunasB não serão o último insert.
                                  colunaB_Valores :=
                                    colunaB_Valores + IntToStr(QuinzeBolas[uA]) + ', ';
                                  //colunaB_Campos := colunaB_Campos + Lotofacil_Coluna_B_Campos[uA] + ', ';

                                  strCombinado :=
                                    strCombinado +
                                    Lotofacil_Bolas_Combinadas[QuinzeBolas[uA]];

                                  // Aqui, iremos pegar o nome da coluna dos números: num_1 até num_25.
                                  colunaNumero_Campos :=
                                    colunaNumero_Campos +
                                    Lotofacil_Coluna_Numero[QuinzeBolas[uA]] + ', ';

                                  // Não precisamos pegar o valores do números pois o valor será 1.

                                  // Conta par e impar, já processados.
                                  if QuinzeBolas[uA] mod 2 = 0 then
                                    Inc(qtPares)
                                  else
                                    Inc(qtImpares);

                                  // Contar ítens por posição vertical.
                                  case QuinzeBolas[uA] of
                                    1, 6, 11, 16, 21: Inc(vertical_1);
                                    2, 7, 12, 17, 22: Inc(vertical_2);
                                    3, 8, 13, 18, 23: Inc(vertical_3);
                                    4, 9, 14, 19, 24: Inc(vertical_4);
                                    5, 10, 15, 20, 25: Inc(vertical_5);
                                  end;

                                  // Contar ítens na posição horizontal.
                                  case QuinzeBolas[uA] of
                                    1..5: Inc(Horizontal_1);
                                    6..10: Inc(Horizontal_2);
                                    11..15: Inc(Horizontal_3);
                                    16..20: Inc(Horizontal_4);
                                    21..25: Inc(Horizontal_5);
                                  end;

                                  // Contar ítens na diagonal.
                                  case QuinzeBolas[uA] of
                                    1, 7, 13, 19, 25: Inc(Diagonal_1);
                                    2, 8, 14, 20, 21: Inc(Diagonal_2);
                                    3, 9, 15, 16, 22: Inc(Diagonal_3);
                                    4, 10, 11, 17, 23: Inc(Diagonal_4);
                                    5, 6, 12, 18, 24: Inc(Diagonal_5);
                                  end;

                                  case QuinzeBolas[uA] of
                                    1..5: Inc(qtExterno);
                                    10, 15, 20, 25: Inc(qtExterno);
                                    21, 22, 23, 24: Inc(qtExterno);
                                    6, 11, 16: Inc(qtExterno);

                                    7, 8, 9, 12, 13, 14, 17, 18, 19:
                                      Inc(qtInterno);
                                  end;
                                end;

                                // Vamos gerar o insert para a tabela jogo_lotofacil.
                                strSqlInsert :=
                                  'INSERT INTO ltk.jogo_lotofacil(' +
                                  'jogo_tipo, qt_bolas, bolas_combinadas, '
                                  +
                                  'qt_bolas_base, bolas_combinadas_base, ' +
                                  'b_1, b_2, b_3, b_4, b_5,' +
                                  'b_6, b_7, b_8, b_9, b_10,' +
                                  'b_11, b_12, b_13, b_14, b_15,' +
                                  'par, impar, cmb_par_impar, rank_posicao, ';
                                // Há 25 nome de campos que começa com 'num_',
                                // os valores de tais campos terá o valor 1 se foi
                                // sorteado ou o valor 0 se não foi sorteado, então
                                // não há necessidade, de processar os 25 números.
                                // então, criamos uma variável que pegar os números que saíram
                                // e procurar em uma constante o nome da coluna do número correspondente.
                                strSqlInsert := strSqlInsert + colunaNumero_Campos;
                                strSqlInsert :=
                                  strSqlInsert + 'vrt_1, vrt_2, vrt_3, vrt_4, vrt_5,';
                                strSqlInsert :=
                                  strSqlInsert + 'hrz_1, hrz_2, hrz_3, hrz_4, hrz_5,';
                                strSqlInsert :=
                                  strSqlInsert +
                                  'diag_1, diag_2, diag_3, diag_4, diag_5,';
                                strSqlInsert := strSqlInsert + 'externo, interno)';

                                strSqlInsert := strSqlInsert + ' values (';
                                strSqlInsert :=
                                  strSqlInsert + QuotedStr('LOTOFACIL') + ', ';
                                strSqlInsert := strSqlInsert + '15, ';
                                strSqlInsert :=
                                  strSqlInsert + QuotedStr(strCombinado) + ', ';

                                // Observação: Aqui, o código não foi copiado por enganado,
                                // é por que esta tabela é usado para inserir subconjuntos também.
                                // então bola_qt pode ser diferente de bola_qt_base.
                                strSqlInsert := strSqlInsert + '15, ';
                                strSqlInsert :=
                                  strSqlInsert + QuotedStr(strCombinado) + ', ';

                                // Na linha abaixo, não precisamos inserir o ',', pois o último caractere
                                // armazenado na variável 'colunaB_Valores' é justamente o caractere ','.
                                strSqlInsert := strSqlInsert + colunaB_Valores;

                                // Inserir, par, impar e par_impar.
                                // par_impar, é um string com 2 números com 2 dígitos cada
                                // interseparados por '_', desta forma: '01_02'.
                                strSqlInsert :=
                                  strSqlInsert + IntToStr(qtPares) + ', ';
                                strSqlInsert :=
                                  strSqlInsert + IntToStr(qtImpares) + ', ';
                                strSqlInsert :=
                                  strSqlInsert +
                                  QuotedStr(Format('%.2d_%.2d', [qtPares, qtImpares])) + ', ';

                                // Conta cada combinação
                                Inc(qtRank);
                                if fStatus <> nil then
                                begin
                                  //synchronize(onStatus(qtRank));
                                end;
                                strSqlInsert := strSqlInsert + IntToStr(qtRank) + ', ';

                                // Na tabela, o valor do campo que começa com num_
                                // será 1, se foi selecionado, 0, senão, entretanto,
                                // no insert, colocamos somente os campos que foram
                                // selecionados então todos os 15 valores serão 1.
                                strSqlInsert := strSqlInsert + DupeString('1,', 15);

                                strTexto := 'Teste ' + DupeString('1, ', 15);

                                strSqlInsert :=
                                  strSqlInsert +
                                  Format('%d, %d, %d, %d, %d, ', [vertical_1,
                                  vertical_2, vertical_3, vertical_4, vertical_5]);

                                strSqlInsert :=
                                  strSqlInsert +
                                  Format('%d, %d, %d, %d, %d, ', [horizontal_1,
                                  horizontal_2, horizontal_3, horizontal_4,
                                  horizontal_5]);

                                strSqlInsert :=
                                  strSqlInsert +
                                  Format('%d, %d, %d, %d, %d, ', [diagonal_1,
                                  diagonal_2, diagonal_3, diagonal_4, diagonal_5]);

                                strSqlInsert :=
                                  strSqlInsert + IntToStr(qtExterno) + ', ';
                                strSqlInsert :=
                                  strSqlInsert + IntToStr(qtInterno) + ');';

                                {$ifdef LINUX}
                                strSqlInsert := strSqlInsert + #10;
                                {$else $ifdef WINDOWS}
                                strSqlInsert := strSqlInsert + #1310;
                                {$endif}

                                arquivoListaSql.Write(PChar(strSqlInsert)^,
                                  Length(strSqlInsert));

                                //exit;



                                //listaSqlInsert.SaveToFile('lotofacil_15_Números.txt');
                                //exit;




                                                  {

                                               "jogo_tipo, qt_bolas, bolas_combinadas, qt_bolas_base, bolas_combinadas_base,
                                                b_1, b_2, b_3, b_4, b_5, b_6, b_7, b_8, b_9, b_10, b_11, b_12,
                                                b_13, b_14, b_15, b_16, b_17, b_18, par, impar, cmb_par_impar,
                                                rank_posicao, num_1, num_2, num_3, num_4, num_5, num_6, num_7,
                                                num_8, num_9, num_10, num_11, num_12, num_13, num_14, num_15,
                                                num_16, num_17, num_18, num_19, num_20, num_21, num_22, num_23,
                                                num_24, num_25, vrt_1, vrt_2, vrt_3, vrt_4, vrt_5, hrz_1, hrz_2,
                                                hrz_3, hrz_4, hrz_5, diag_1, diag_2, diag_3, diag_4, diag_5,
                                                externo, interno)
                                                }

                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  // Gravar em um arquivo.
  //listaSqlMemoryStream.SaveToFile('lotofacil_15_numeros.sql');

  //'INSERT INTO ltk.jogo_lotofacil(jogo_tipo, qt_bolas, bolas_combinadas, qt_bolas_base, bolas_combinadas_base, b_1, b_2, b_3, b_4, b_5,b_6, b_7, b_8, b_9, b_10,b_11, b_12, b_13, b_14, b_15,par, impar, cmb_par_impar, num_1, num_2, num_3, num_4, num_5, num_6, num_7, num_8, num_9, num_10, num_11, num_12, num_13, num_14, num_15, vrt_1, vrt_2, vrt_3, vrt_4, vrt_5,hrz_1, hrz_2, hrz_3, hrz_4, hrz_5,diag_1, diag_2, diag_3, diag_4, diag_5,externo, interno) values (''LOTOFACIL'', 15, ''_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15'', 15, ''_01_02_03_04_05_06_07_08_09_10_11_12_13_14_15'', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 7, 8,  7_ 8, 1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3, 3, 3, 3, 5, 5, 5, 0, 3, 3, 3, 3, 9, 6)'

end;

procedure TLotofacilDatabaseThread.GerarLotofacil16Numeros;
begin

end;

procedure TLotofacilDatabaseThread.GerarLotofacil17Numeros;
begin

end;

procedure TLotofacilDatabaseThread.GerarLotofacil18Numeros;
begin

end;



end.
