{
  Autor: Fábio Moura de Oliveira
  Data:  29/11/2015

  A classe gera todas as permutações possíveis para um jogo, por exemplo, se o jogo
  tiver as bolas: 1, 2, 3, 4, 5, 6, 7.
  A classe irá gera os jogos:



}

{include }

unit   {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  cmem,
  {$ENDIF}{$ENDIF}

uPermutador_Thread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


type
  TPermutador_Status_Erro = procedure(strErro: string) of object;
  TPermutador_Status = procedure(strStatus: string) of object;
  TPermutador_Status_Concluido = procedure(strStatus:string) of object;

  { TPermutador_Thread }

  TPermutador_Thread = class(TThread)
  private
    // Arranjo que guardará as bolas do jogo.
    iBolas: array of integer;

    // Se a bola existe na posicao especificada, será true, senão falso.
    bola_existe: array[0..99] of boolean;

    // O nome do jogo.
    jogo_tipo: string;

    // O menor número que a bola pode ter no jogo.
    bola_minima: integer;

    // O maior número que a bola pode ter no jogo.
    bola_maxima: integer;

    // A quantidade de bolas a jogar.
    quantidade_de_bolas_a_jogar: integer;

    // Quantas bolas tem o jogo.
    quantidade_de_bolas_no_jogo: integer;

    // Indica a quantidade de bolas que o jogador pode jogar.
    minima_qt_de_bolas_a_jogar: integer;
    maxima_qt_de_bolas_a_jogar: integer;

    // Indica a quantidade de bolas que é sorteada.
    quantidade_de_bolas_sorteadas: integer;

    // Indica uma descrição do erro.
    strErro: string;

    // Indica a quantidade de linhas no arquivo a ser gravado.
    quantidade_de_linhas_por_arquivo: integer;

    // Indica a quantidade de permutações já realizada, a medida que uma nova permutação
    // é criada, esta variável é incrementada em um.
    qRank: qWord;

    status_erro: TPermutador_Status_Erro;
    status: TPermutador_Status_Erro;
    status_concluido: TPermutador_Status_Concluido;

    pasta_de_destino: string;

    bInterromper_Permutacao : boolean;

		procedure Atualizar_Tela;
  procedure Bolas_Combinadas(strTexto: array of string);
  procedure Criar_Arranjo;
	procedure Gerar_Cabecalho(var strCabecalho: AnsiString);
	function Gerar_Insert(iRank: QWord; var strSql: string;
				const bolas: array of integer; const posicoes_nas_bolas: array of integer
			): string;
	procedure Gerar_Permutacao_csv(iRank: QWord; var strTexto_csv: string;
				const todas_as_bolas_do_jogo: array of integer;
			const indice_das_bolas: array of integer);
	procedure Gravar_Arquivo(strJogo: string; qt_bolas: integer;
				var objMemoria: TMemoryStream; var iContador_de_Arquivo: Integer);
	procedure Gravar_Dados(var objMemoria: TMemoryStream; strTexto: string);
    procedure Permutar_Jogo;
		function Quantidade_de_Permutacoes(total_de_bolas: Integer;
					qt_de_bolas_no_subconjunto: Integer): QWord;
    function Validar_Campos(strPasta: string; strJogo: string;
      bolas_qt: integer; qt_linhas_por_arquivo: integer): boolean;
    function Validar_Jogo(strJogo: string): boolean;
		function Validar_Linhas_por_Arquivo(linhas_por_arquivo: integer): boolean;
    function Validar_Pasta(strPasta: string): boolean;
    function Validar_Quantidade_de_Bolas(bolas_qt: integer): boolean;

  public
    procedure Execute; override;
    procedure Parar_Permutacao;

  public
    property permutador_erro_status: TPermutador_Status_Erro write status_erro;
    property permutador_status: TPermutador_Status write status;
    property permutador_status_concluido: TPermutador_Status_Concluido write status_concluido;

  public
    //constructor Create(Criar_Suspenso: boolean);

    // Quando o usuário criar o objeto, ele deve informar a quantidade de bolas
    // que ele pode jogar para o jogo.
    constructor Create(Criar_Suspenso: boolean; strPasta: string;
      strJogo: string; bolas_qt: integer; linhas_por_arquivo: integer);

  end;



implementation
uses strUtils, dialogs;

const
  strJogo_Tipo: array[0..7] of string = ('DUPLASENA', 'LOTOFACIL',
    'LOTOMANIA', 'MEGASENA', 'QUINA', 'INTRALOT_MINAS_5',
    'INTRALOT_LOTOMINAS', 'INTRALOT_KENO_MINAS');

{ TPermutador_Thread }

procedure TPermutador_Thread.Execute;

begin
  // Criar e dimensiona o arranjo.
  Criar_Arranjo;

  Permutar_Jogo;

end;

procedure TPermutador_Thread.Parar_Permutacao;
begin
      bInterromper_Permutacao := true;
end;

procedure TPermutador_Thread.Atualizar_Tela;
begin
     Status(Format('Lidos: %.10d', [qRank]));
end;

procedure TPermutador_Thread.Permutar_Jogo;
var
  objMemoria: TMemoryStream;
  objArquivo: TFileStream;
  strSql: ansistring;
	iA: Integer;
	iB: Integer;
	iC: Integer;
	iD: Integer;
	iE: Integer;
	iPar: Integer;
	iImpar: Integer;
	qRank_Posicao: QWord;
	strTexto: String;
	iContagem_de_Linha: Integer;
	iContador_de_Arquivo: Integer;
  strStream: TStringStream;
	pBuffer: PChar;
	iPosicao: Integer;
	strArquivo: String;
	ind_1: Integer;
	ind_2: Integer;
	ind_3: Integer;
	ind_4: Integer;
	ind_5: Integer;
	ind_6: Integer;
	ind_7: Integer;
	ind_8: Integer;
	ind_9: Integer;
	ind_10: Integer;
	ind_11: Integer;
	ind_12: Integer;
	ind_13: Integer;
	ind_14: Integer;
	ind_15: Integer;
	qPermutacoes: QWord;

  strPasta_Anterior: string;
	strData_Hora: String;
	strCabecalho: String;
	ind_16: Integer;
begin



  // Guarda a quantidade total de números permutados.
  qPermutacoes := QWord(1);

  // Vamos definir o diretório atual e guardar o diretório anterior.
  strPasta_Anterior := GetCurrentDir;

  // Criar pasta com data e horário atual.
  strData_Hora := FormatDateTime('dd_mm_yyy-hh_nn_ss', Now);

  // Vamos verificar a pasta informada pelo usuário existe.
  if not DirectoryExists(pasta_de_destino) then begin
    if Status_Erro <> nil then begin
      Status_Erro('Pasta ' + QuotedStr(pasta_de_destino) + ' não existe.');
      Exit;
    end;
	end;

  // Vamos tentar alterar a pasta
  if not SetCurrentDir(pasta_de_destino) then begin
    MessageDlg('Erro', 'Não foi possível acessar o diretório: ' + QuotedStr(pasta_de_destino), TMsgDlgType.mtError,
    [mbOk], 0);
    Exit;
	end;

  // Vamos criar a pasta no diretório informado pelo usuário.
  // Vamos verificar se o diretório não existe.
  if not DirectoryExists(strData_Hora) then begin
    CreateDir(strData_Hora);
	end;

  // Vamos alterar para este diretório.
  // Vamos tentar alterar a pasta
  if not SetCurrentDir(strData_Hora) then begin
    MessageDlg('Erro', 'Não foi possível acessar o diretório: ' + QuotedStr(pasta_de_destino), TMsgDlgType.mtError,
    [mbOk], 0);
    Exit;
	end;

  objMemoria := TMemoryStream.Create;
  qRank_Posicao := 0;
  iContador_de_Arquivo := 1;
  iContagem_de_Linha := 0;
  strSql := '';

  // Toda vez que um arquivo for gerado, a primeira linha deve ter o cabecalho.
  strCabecalho := '';
  Gerar_Cabecalho(strCabecalho);

  strTexto := '';


  if jogo_tipo = 'LOTOFACIL' then
  begin
    case quantidade_de_bolas_a_jogar of
      16:
      begin
				    for ind_1 := bola_minima to bola_maxima do
				    for ind_2 := ind_1 + 1 to bola_maxima do
				    for ind_3 := ind_2 + 1 to bola_maxima do
				    for ind_4 := ind_3 + 1 to bola_maxima do
				    for ind_5 := ind_4 + 1 to bola_maxima do
				    for ind_6 := ind_5 + 1 to bola_maxima do
				    for ind_7 := ind_6 + 1 to bola_maxima do
				    for ind_8 := ind_7 + 1 to bola_maxima do
				    for ind_9 := ind_8 + 1 to bola_maxima do
				    for ind_10 := ind_9 + 1 to bola_maxima do
				    for ind_11 := ind_10 + 1 to bola_maxima do
				    for ind_12 := ind_11 + 1 to bola_maxima do
				    for ind_13 := ind_12 + 1 to bola_maxima do
				    for ind_14 := ind_13 + 1 to bola_maxima do
				    for ind_15 := ind_14 + 1 to bola_maxima do
				    for ind_16 := ind_15 + 1 to bola_maxima do
            begin
                  // Se é a primeira vez, iContagem_linha é igual a 0.
                  if iContagem_de_Linha = 0 then begin
                     Gravar_Dados(objMemoria, strCabecalho);
									end;

                  Inc(qRank_Posicao);

                  // Iremos fazer um teste com Synchronize, por isto preciso desta variável.
                  Inc(qRank);

                  Gerar_Permutacao_csv(qRank_Posicao, strTexto, ibolas,
                  [ind_1, ind_2, ind_3, ind_4, ind_5, ind_6, ind_7, ind_8, ind_9, ind_10, ind_11, ind_12, ind_13, ind_14, ind_15, ind_16]);

                  Gravar_Dados(objMemoria, strTexto);

                  if status <> nil then begin
						         //Status(Format('Lidos: %.10d', [qRank_Posicao]));
                     Synchronize(@Atualizar_Tela);
						      end;

                  // Se a variável quantidade_de_linhas_por_arquivo é igual a 0,
                  // quer dizer, que o usuário quer somente um único arquivo.
                  if quantidade_de_linhas_por_arquivo = 0 then
                  begin
                     continue;
									end;


                  Inc(iContagem_de_Linha);

                  if iContagem_de_linha > quantidade_de_linhas_por_arquivo then
                  begin
                    iContagem_de_Linha := 0;
                    Gravar_Arquivo(jogo_tipo, quantidade_de_bolas_a_jogar, objMemoria, iContador_de_Arquivo);
                  end;

                  // Se o usuário solicitou parar a permutação, sair do loop for.
                  if bInterromper_Permutacao then
                  begin
                    // Devemos gravar o que ainda resta gravar.
                    iContagem_de_Linha := 0;
                    Gravar_Arquivo(jogo_tipo, quantidade_de_bolas_a_jogar, objMemoria, iContador_de_arquivo);
                    Exit;
									end;

            end;

            // Se sobrou linhas, iContagem_de_Linha é diferente de zero.
						if (iContagem_de_Linha > quantidade_de_linhas_por_arquivo) and
               (quantidade_de_linhas_por_arquivo <> 0)  then
            begin
						      iContagem_de_Linha := 0;
                  Gravar_Arquivo(jogo_tipo, quantidade_de_bolas_a_jogar, objMemoria, iContador_de_Arquivo);
                  Exit;
						end;


            // Se quantidade_de_linhas_por_arquivo é zero, quer dizer que o usuário quer um único arquivo.
            // Iremos gravar então.
            if quantidade_de_linhas_por_arquivo = 0 then
            begin
              iContador_de_Arquivo := 1;
              Gravar_Arquivo(jogo_tipo, quantidade_de_bolas_a_jogar, objMemoria, iContador_de_Arquivo);
            end;

            if status_concluido <> nil then
            begin
              Status_Concluido('OK');
						end;
			end;


    end;
end;

end;



procedure TPermutador_Thread.Gravar_Arquivo(strJogo: string; qt_bolas: integer;
  var objMemoria: TMemoryStream; var iContador_de_Arquivo: Integer);
var
			strArquivo: String;
begin
  strArquivo := strjogo + '_' + IntToStr(qt_bolas) + '_permutacao_arquivo_' + format('%.5d', [iContador_de_Arquivo]) + '.csv';
  Inc(iContador_de_Arquivo);

  objMemoria.SaveToFile(strArquivo);
  objMemoria.Clear;
end;

procedure TPermutador_Thread.Gravar_Dados(var objMemoria: TMemoryStream; strTexto: string);
var
			iPosicao: Integer;
begin
		  for iPosicao := 1 to Length(strTexto) do begin
		      objMemoria.WriteByte(Byte(strTexto[iPosicao]));
		  end;
		  objMemoria.WriteByte(13);
		  objMemoria.WriteByte(10);
end;

// Este procedure gera cada as permutações das bolas, e separa cada campo com o caractere ';'.
procedure TPermutador_Thread.Gerar_Permutacao_csv(iRank: QWord; var strTexto_csv: string;const todas_as_bolas_do_jogo: array of integer; const indice_das_bolas: array of integer);
var
			uIndice: LongInt;
			strBolas_Combinadas: String;
			strBolas: String;
			strIndice: String;
			iPar: Integer;
			iImpar: Integer;
			iA: Integer;
			uBola_Numero: LongInt;
			iSoma_das_Bolas: Integer;
			iSoma_Posicional_das_Bolas: Integer;
begin
     strTexto_csv := jogo_tipo + ';';
     strTexto_csv := strTexto_csv + IntToStr(quantidade_de_bolas_a_jogar) + ';';

     // O campo bolas_combinadas fica neste formato: _01_02.
     // O arranjo 'indice_das_bolas' guarda o valor do índice que devemos
     // acessar no arranjo 'bolas'.

     strBolas_Combinadas := '';
     strBolas := '';
     strIndice := '';
     iPar := 0;
     iImpar := 0;
     iSoma_das_Bolas := 0;
     iSoma_Posicional_das_Bolas := 0;

     for iA := Low(indice_das_bolas) to High(indice_das_bolas) do
     begin
       uIndice := indice_das_bolas[iA];
       uBola_Numero := todas_as_bolas_do_jogo[uIndice];

       // Para economizar código, para não executarmos duas vezes o loop for,
       // iremos, neste caso, formar as bolas combinadas e formar as bolas separadas, por ';'
       strBolas_Combinadas := strBolas_Combinadas + Format('_%.2d', [uBola_Numero]);
       strBolas := strBolas + IntToStr(uBola_Numero) + ';';
       strIndice := strIndice + IntToStr(uIndice) + ';';

       // Também por questão de desempenho, iremos contabilizar a quantidade de números
       // pares e ímpares, se assim não o fizessemos devemos executar este loop, outra vez.
       if uBola_Numero mod 2 = 0 then Inc(iPar) else Inc(iImpar);

       // Aqui, iremos utilizar um outro arranjo, onde cada índice, indica o índice
       // no arranjo todas_as_bolas_do_jogo, ele será true, somente se aquele bola
       // no índice em todas_as_bolas_do_jogo exista.
       // Aqui, não iremos verificar a faixa, não é necessário.
       bola_existe[uBola_Numero] := true;

       iSoma_das_Bolas := iSoma_das_Bolas + uBola_Numero;
       iSoma_Posicional_das_bolas := iSoma_Posicional_das_Bolas + uIndice;

		 end;

     strTexto_csv := strTexto_csv + strBolas_Combinadas + ';' ;

     // Não precisamos colocar ';' no final, pois ao sair do loop, já há um ';'.
     strTexto_csv := strTexto_csv + strBolas;

     // Os campos b1 a b50, não foram totalmente preenchidos, devemos fazê-lo.
     strTexto_csv := strTexto_csv + DupeString('0;', 50 - quantidade_de_bolas_a_jogar);

     // Vamos preencher os campos 'par', 'impar', 'cmb_par_impar'.

     strTexto_csv := strTexto_csv + IntToStr(iPar) + ';';
     strTexto_csv := strTexto_csv + IntToStr(iImpar) + ';';
     strTexto_csv := strTexto_csv + Format('%.2d_%.2d', [iPar, iImpar]) + ';';

     // Campo iRank, fornecido nos argumentos do procedimento.
     strTexto_csv := strTexto_csv + IntToStr(iRank) + ';';

     // Campos soma_das_bolas, soma_posicional_das_bolas.
     strTexto_csv := strTexto_csv + IntToStr(iSoma_das_Bolas) + ';';
     strTexto_csv := strTexto_csv + IntToStr(iSoma_Posicional_das_Bolas) + ';';

     // Campos pos_1 a pos_50.
     // Nós, já pegamos os índice ao executarmos o primeiro for acima.
     // Simplesmente, iremos inserí-lo no texto.
     strTexto_csv := strTexto_csv + strIndice;

     // Os campos pos_1 a pos_50 não foram preenchidos totalmente, devemos preencher os restantes.
     strTexto_csv := strTexto_csv + DupeString('0;', 50 - quantidade_de_bolas_a_jogar);

     // No caso do campo num_0 a num_99, o campo será 1 se a bola que corresponde
     // àquele campo exista na permutação, será 0, caso contrário. Exemplo:
     // Bola 5, o campo corresponde é num_5, então, num_5, será 1.
     // No loop for anterior, há um arranjo 'bola_existe' que guarda se a bola
     // existe na permutação ou não, o valor do índice do arranjo corresponde ao
     // número da bola, então iremos percorrer o arranjo e inserir a informação desejada.

     for iA := Low(bola_existe) to High(bola_existe) do
     begin

       if bola_existe[iA] then begin
         strTexto_csv := strTexto_csv + '1';
       end else begin
         strTexto_csv := strTexto_csv + '0';
       end;

       // O campo num_99 é o último da linha, não pode ter ';' no final.
       if iA <> High(bola_existe) then
          strTexto_csv := strTexto_csv + ';';

       // Aqui, já iremos definir o valor do índice corresponde para falso
       // pois, não precisaremos ao final do loop resetar tudo para falso.
       bola_existe[iA] := false;

     end;

end;




procedure TPermutador_Thread.Gerar_Cabecalho(var strCabecalho: AnsiString);
var
			iA: Integer;
begin
  // Vamos definir o cabeçalho que será utilizado na primeira linha de cada arquivo *.csv.
  strCabecalho := 'jogo_tipo;qt_bolas;bolas_combinadas;';

  // Campos b1 a b50
  for iA := 1 to 50 do begin
    strCabecalho := strCabecalho + 'b' + IntToStr(iA) + ';';
	end;

  // Campos par, impar, cmb_par_impar
  strCabecalho := strCabecalho + 'par;impar;cmb_par_impar;';

  // Campo rank_posicao
  strCabecalho := strCabecalho + 'rank_posicao;';

  // Campos soma_das_bolas e soma_posicional_das_bolas
  strCabecalho := strCabecalho + 'soma_das_bolas;soma_posicional_das_bolas;';

  // Campos pos_1 a pos_50
  for iA := 1 to 50 do begin
    strCabecalho := strCabecalho + 'pos_' + IntToStr(iA) + ';';
	end;

  // Campos num_0 a num_99
  for iA := 0 to 99 do begin
    strCabecalho := strCabecalho + 'num_' + IntToStr(iA);

    // Aqui, o campo num_99 é o último campo da linha, não devemos colocar
    // após ele o ponto e vírgula:
    if iA <> 99 then
       strCabecalho := strCabecalho + ';';

	end;

end;

// Retorna a quantidade de números permutados, na matemática, existe uma fórmula, chama-se:
// Arranjo: n!/(n-p)! * p!
function TPermutador_Thread.Quantidade_de_Permutacoes(total_de_bolas:Integer; qt_de_bolas_no_subconjunto:Integer): QWord;
var
  qPermutacoes :QWord;
	qDiferenca_Permutacoes: QWord;
	qDiferenca: Integer;
	qSub_Permutacoes: QWord;
	iA: Integer;
begin
     // Vamos calcular n!
     // n, aqui, é representado, pelo argumento: 'total_de_bolas';
     qPermutacoes := 1;
     for iA := 1 to total_de_bolas do begin
       qPermutacoes *= QWord(iA);
		 end;

     // Vamos calcular p!
     // p, aqui, é representado pelo argumento: qt_bolas_no_subconjunto
     qSub_Permutacoes := 1;
     for iA := 1 to qt_de_bolas_no_subconjunto do begin
       qSub_Permutacoes *= QWord(iA);
		 end;

     // Vamos calcular (n-p),
     // n, aqui, é representado pelo argumento: 'total_de_bolas';
     // p, aqui, é representado pelo argumento: 'qt_de_bolas_no_subconjunto'.
     qDiferenca := qWord(total_de_bolas - qt_de_bolas_no_subconjunto);

     qDiferenca_Permutacoes := 1;
     for iA := 1 to qDiferenca do begin
       qDiferenca_Permutacoes *= qWord(iA);
		 end;

     Result := qPermutacoes div ((qDiferenca_Permutacoes)* qSub_Permutacoes);

end;

// Esta função gerar o contéudo do insert
function TPermutador_Thread.Gerar_Insert(iRank: QWord; var strSql: string;const bolas: array of integer; const posicoes_nas_bolas: array of integer): string;
var
  qt_bolas:integer;
	iPar: Integer;
	iImpar: Integer;
	iBola_Numero: Integer;
	iSoma: Integer;
	iA: Integer;
	iSoma_Posicional: Integer;
begin
      strSql := 'Insert into ltk.jogo_combinacoes(';
      strSql := strSql + 'jogo_tipo, qt_bolas, bolas_combinadas, ';

      // Inseri os strings b1, b2, conforme a quantidade de bolas.
      qt_bolas := Length(posicoes_nas_bolas);

      for iA := 1 to qt_bolas do begin
        strSql := strSql + 'b' + IntToStr(iA) + ', ';
      end;

      strSql := strSql + 'par, impar, cmb_par_impar, ';
      strSql := strSql + 'rank_posicao, ';
      strSql := strSql + 'soma_das_bolas, soma_posicional_das_bolas, ';

      // Insere os campos pos_1, pos_2, conforme a quantidade de bolas a serem jogadas.
      for iA := 1 to qt_bolas do begin
        strSql := strSql + 'pos_' + IntToStr(iA) + ', ';
      end;

      // Os campos num_1, num_2, só devemos definir o valor 1 somente para
      // os números que estão na permutação, por exemplo, se há o número 5,
      // então o campo num_5 será igual a 1.
      // Para isso, o arranjo posicoes_bola quando as posições dos números que
      // iremos pegar no arranjo bolas.
      iBola_Numero := 0;
      for iA := 0 to qt_bolas - 1 do begin
          iBola_Numero := posicoes_nas_bolas[iA];
           strSql := strSql + Format('num_%d, ', [bolas[iBola_Numero]]);
      end;

      // O último campo termina com ', ', devemos retirá-lo.
      strSql := Trim(strSql);
      strSql := AnsiMidStr(strSql, 1, Length(strSql)-1);

      strSql := strSql + ') values (';
      strSql := strSql + quotedStr(jogo_tipo) + ', ';
      strSql := strSql + quotedStr(IntToStr(qt_bolas)) + ', ';


      // Bolas combinadas fica neste formato: _01_02
      // Em sql, texto que tem ficar entre aspas simples, por isto, começamos
      // com uma aspas simples.
      strSql := strSql + '''';
      for iA := 0 to qt_bolas - 1 do begin
           strSql := strSql + Format('_%.2d', [bolas[posicoes_nas_bolas[iA]]]);
      end;
      strSql := strSql + ''', ';

      for iA := 0 to qt_bolas - 1 do begin
        iBola_Numero := posicoes_nas_bolas[iA];
        strSql := strSql + QuotedStr(Format('%d', [bolas[iBola_Numero]])) + ', ';
			end;


      // Vamos pecorrer cada bola que está no arranjo 'bolas', entretanto,
      // iremos pegar somente bolas nas posições definidas no arranjo posicoes_nas_bolas.
      iPar := 0;
      iImpar := 0;
      iBola_Numero := 0;

      for iA := Low(posicoes_nas_bolas) to High(posicoes_nas_bolas) do begin
          iBola_Numero := bolas[posicoes_nas_bolas[iA]];

          if iBola_Numero mod 2 = 0 then Inc(iPar) else Inc(iImpar);
      end;

      // Campos: par, impar e cmb_par_impar
      strSql := strSql + QuotedStr(IntToStr(iPar)) + ', ';
      strSql := strSql + QuotedStr(IntToStr(iImpar)) + ', ';
      strSql := strSql + QuotedStr(Format('%.2d_%.2d', [iPar, iImpar])) + ', ';

      // Campo: cmbRank
      strSql := strSql + QuotedStr(IntToStr(iRank)) + ', ';

      // Campo soma_das_bolas e soma_posicional_das_bolas.
      iSoma := 0;
      iSoma_Posicional := 0;

      for iA := 0 to qt_bolas - 1 do begin
          iSoma := iSoma + bolas[posicoes_nas_bolas[iA]];
          iSoma_Posicional := iSoma_Posicional + posicoes_nas_bolas[iA];
      end;

      strSql := strSql + QuotedStr(IntToStr(iSoma)) + ', ';
      strSql := strSql + QuotedStr(IntToStr(iSoma_Posicional)) + ', ';

      // Campos p1, p2, e assim por diante.
      for iA := 0 to qt_bolas - 1 do begin
          strSql := strSql + QuotedStr(IntToSTr(posicoes_nas_bolas[iA])) + ', ';
      end;

      // Campos num_0, num_1 e assim por diante.
      // Na tabela, todos os campos padrão valor 0, então devemos
      // definir somente os campos que procurarmos.

      // Aqui, nós estamos definindo todos os valores dos campos dos números
      // que queremos em 1, o que não queremos será 0, simplesmente,
      // iremos repetir o 1 igual a quantidade de bolas a jogar.

      strSql := strSql + DupeString(QuotedStr('1') + ', ', qt_bolas - 1);

      // Observe que fizermos qt_bolas - 1, por que o último campo
      // não pode termina em ','
      strSql := strSql + QuotedStr('1') + '); ';

end;



// Retorna um string no formato: '_01_02_03_04_05'
procedure TPermutador_Thread.Bolas_Combinadas(strTexto: array of string);
var
			iA: Integer;
begin
  for iA := Low(strTexto) to High(strTexto) do begin
    ;
	end;
end;


procedure TPermutador_Thread.Criar_Arranjo;
var
			iA: Integer;
begin
  // Nos iremos gerar as permutações percorrendo as bolas da menor para
  // a maior.
  // Entre, arranjos dinâmicos em FreePascal, são baseados em zero.
  // Isto é conveniente, quando a menor bola é zero, tal qual no jogo
  // Lotomania.
  // Entretanto, quando a bola mínima do jogo não é zero, praticamente,
  // ficaria para nós meio incomodo, por exemplo,
  // Na lotofacil a bola mínima é 1 e a máxima é 25.
  // Quando criarmos o arranjo, no nosso arranjo o índice 0 do arranjo
  // corresponderá à bola 1, e o índice 24, corresponderá à bola 25.
  // Então, para evitarmos isto, iremos toda vez que a bola miníma for diferente
  // de zero, criarmos um arranjo com a quantidade de ítens igual a quantidade_de_bolas
  // mais 1, aí, simplesmente, nós iremos associar o índice 1 do arranjo à
  // bola 1.

  if bola_minima = 0 then
  begin
    SetLength(iBolas, quantidade_de_bolas_no_jogo);
  end
  else
  begin
    SetLength(iBolas, quantidade_de_bolas_no_jogo + 1);
  end;

  for iA := bola_minima to bola_maxima do
  begin
    iBolas[iA] := iA;
  end;
end;


constructor TPermutador_Thread.Create(Criar_Suspenso: boolean;
  strPasta: string; strJogo: string; bolas_qt: integer; linhas_por_arquivo: integer);
begin
  //inherited Create(Criar_Suspenso);
  FreeOnTerminate := True;


  if not Validar_Campos(strPasta, strJogo, bolas_qt, linhas_por_arquivo) then
  begin
    raise Exception.Create(strErro);
  end;

end;

// Esta função valida todos os campos, que necessitamos antes de executar a thread.
function TPermutador_Thread.Validar_Campos(strPasta: string; strJogo: string;
			bolas_qt: integer; qt_linhas_por_arquivo: integer): boolean;
begin
  if not Validar_Pasta(strPasta) then
  begin
    Exit(False);
  end;

  if not Validar_Jogo(strJogo) then
  begin
    Exit(False);
  end;

  if not Validar_Quantidade_de_Bolas(bolas_qt) then
  begin
    Exit(False);
  end;

  if not Validar_Linhas_por_Arquivo(qt_linhas_por_arquivo) then
  begin
    Exit(False);
  end;

  Exit(True);
end;

// Devemos verificar se o destino onde ficarão os arquivos exista.
function TPermutador_Thread.Validar_Pasta(strPasta: string): boolean;
begin
  if not DirectoryExists(strPasta) then
  begin
    strErro := 'Diretório inexistente.';
    Exit(False);
  end;

  self.pasta_de_destino:= strPasta;
  Exit(true);
end;

// Cada jogo, tem uma quantidade de bolas mínima e máxima que o jogador deve jogar.
// Esta função faz esta verificação.
function TPermutador_Thread.Validar_Quantidade_de_Bolas(bolas_qt: integer): boolean;
begin
  if (bolas_qt < minima_qt_de_bolas_a_jogar) or
    (bolas_qt > maxima_qt_de_bolas_a_jogar) then
  begin
    strErro := 'Quantidade de bolas fora do intervalo válido.';
    Exit(False);
  end;
  quantidade_de_bolas_a_jogar := bolas_qt;

  Exit(true);
end;

function TPermutador_Thread.Validar_Jogo(strJogo: string): boolean;
var
  bExiste: boolean;
  iA: integer;
begin

  // Vamos verificar se o jogo existe.
  // Iremos percorrer cada valor do arranjo e verificar se é igual
  // ao string fornecido, se for, iremos imediatamente sair do loop for.
  // Entretanto, se percorrermos todos os ítens do arranjo e não encontrarmos
  // um valor igual a strJogo, a variável bExiste ainda terá o valor que foi
  // definida antes de entrar no loop for que é false.
  // Então, isto confirma que nenhum jogo foi encontrado.
  bExiste := False;
  for iA := Low(strJogo_TiPo) to High(strJogo_Tipo) do
  begin
    if strJogo_Tipo[iA] = strJogo then
    begin
      bExiste := True;

      // Se acharmos o jogo, já iremos configurá-lo.
      if strJogo_Tipo[iA] = 'LOTOFACIL' then
      begin
        bola_minima := 1;
        bola_maxima := 25;
        quantidade_de_bolas_no_jogo := 25;
        minima_qt_de_bolas_a_jogar := 15;
        maxima_qt_de_bolas_a_jogar := 18;
        quantidade_de_bolas_sorteadas := 15;

        break;
      end;

      if strJogo_Tipo[iA] = 'LOTOMANIA' then
      begin
        bola_minima := 0;
        bola_maxima := 99;
        quantidade_de_bolas_no_jogo := 100;
        minima_qt_de_bolas_a_jogar := 50;
        maxima_qt_de_bolas_a_jogar := 50;
        quantidade_de_bolas_sorteadas := 20;

        break;
      end;

      if strJogo_Tipo[iA] = 'MEGASENA' then
      begin
        bola_minima := 1;
        bola_maxima := 60;
        quantidade_de_bolas_no_jogo := 60;
        minima_qt_de_bolas_a_jogar := 6;
        maxima_qt_de_bolas_a_jogar := 15;
        quantidade_de_bolas_sorteadas := 6;

        break;
      end;

      if strJogo_Tipo[iA] = 'DUPLASENA' then
      begin
        bola_minima := 1;
        bola_maxima := 50;
        quantidade_de_bolas_no_jogo := 50;
        minima_qt_de_bolas_a_jogar := 6;
        maxima_qt_de_bolas_a_jogar := 15;
        quantidade_de_bolas_sorteadas := 6;

        break;
      end;

      if strJogo_Tipo[iA] = 'QUINA' then
      begin
        bola_minima := 1;
        bola_maxima := 80;
        quantidade_de_bolas_no_jogo := 80;
        minima_qt_de_bolas_a_jogar := 5;
        maxima_qt_de_bolas_a_jogar := 7;
        quantidade_de_bolas_sorteadas := 5;

        break;
      end;

      if strJogo_Tipo[iA] = 'INTRALOT_MINAS_5' then
      begin
        bola_minima := 1;
        bola_maxima := 34;
        quantidade_de_bolas_no_jogo := 34;
        minima_qt_de_bolas_a_jogar := 5;
        maxima_qt_de_bolas_a_jogar := 5;
        quantidade_de_bolas_sorteadas := 5;

        break;
      end;

      if strJogo_Tipo[iA] = 'INTRALOT_LOTOMINAS' then
      begin
        bola_minima := 1;
        bola_maxima := 38;
        quantidade_de_bolas_no_jogo := 38;
        minima_qt_de_bolas_a_jogar := 6;
        maxima_qt_de_bolas_a_jogar := 6;
        quantidade_de_bolas_sorteadas := 6;

        break;
      end;

      if strJogo_Tipo[iA] = 'INTRALOT_KENO_MINAS' then
      begin
        bola_minima := 1;
        bola_maxima := 80;
        quantidade_de_bolas_no_jogo := 80;
        minima_qt_de_bolas_a_jogar := 1;
        maxima_qt_de_bolas_a_jogar := 10;
        quantidade_de_bolas_sorteadas := 20;

        break;
      end;
    end;
  end;

  if not bExiste then
  begin
    strErro := 'Jogo não localizado: ' + strJogo;
    Exit(False);
  end
  else
  begin
    jogo_tipo := strJogo;
    Exit(True);
  end;
end;

function TPermutador_Thread.Validar_Linhas_por_Arquivo(linhas_por_arquivo:
  integer): boolean;
begin
  if (linhas_por_arquivo < 0) then
  begin
    linhas_por_arquivo := 0;
  end;
  quantidade_de_linhas_por_arquivo := linhas_por_arquivo;
  Exit(True);
end;

end.
