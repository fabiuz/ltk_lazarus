unit uIntralot;

{$mode objfpc}{$H+}
{**
   Autor: Fábio Moura de Oliveira
   Data:  26/10/2015, 23:04

   Esta unidade analisa o conteúdo html gerado pelo site www.intralot.com.br
   e recupera as informações dos concursos já realizados para os jogos, 'Minas5'
   e 'LOTOMANIA'.

   O site funciona assim, quando você entra na home page principal de um jogo
   específico, é exibido o resultado do concurso mais recente para aquele jogo.
   Até aí tudo bem, entretanto, se quiser recuperar outros concursos anteriores,
   o usuário deve selecionar o número do concurso ou a data e apertar o botão
   'buscar'. O processo para 1 ou alguns jogos é simples, entretanto, se desejarmos,
   por exemplo, recuperar 50, 100 ou mais concursos, este processo de selecionar
   concurso ou data e apertar o botão 'BUSCAR' torna-se inconveniente e suscetível
   a erro.

   Aí vem a pergunta, pra que recuperar 50 ou mais números, simples, talvez desejamos
   importar tal informação em um banco de dados, para realizar algumas
   análises em tais números, por exemplo, qual o número que mais sai.
   Há duas formas de importarmos tal informação para um banco de dados, manualmente,
   ou, automaticamente, preciso a segunda forma, este será o objetivo ao utilizar
   esta classe.

   Mais para isso, eu devo analisar o arquivo html e detectar onde tal informação
   está.
   Mas como fazer para recuperar a informação para um jogo específico, o resultado
   dos jogos por exemplo: minas5, fica em:

   http://www.intralot.com.br/newsite/minas5/resultado/

   entretanto, quando você acessar tal link, você verá o concurso mais recente
   para este jogo.

   Hoje, 31/10/2015, detectei que quando entra na url abaixo:

         http://www.intralot.com.br/newsite/minas5/resultado/

   é gerado um conteúdo html para os jogos mais recentes, vi que havia exatamente,
   os últimos 100 jogos, mais recentes. O layout de onde fica a informação
   do jogo é um pouco diferente do formato para a outra url:

   http://www.intralot.com.br/newsite/minas5/resultado/?sorteio=716&data=Data+do+sorteio

   Utilizando a url acima, verifiquei vários jogos e todos tem o mesmo layout.
   Irei colocar no analisador as 2 situações.









   Para acessar outros jogos, você deve inserir no final da url acima,
   parâmetros de consultas, por exemplo, na forma:

          ?sorteio=716&data=Data+do+sorteio

   No site, podemos escolher duas formas, pelo número do sorteio ou pela data.
   Quando preenchermos o campo sorteio, por exemplo, com o número 716, a forma
   do parâmetro da consulta enviado quando clicarmos no botão 'buscar' é:

          ?sorteio=716&data=Data+do+sorteio

   Entretanto, se escolher, a data, por exemplo, 23/10/2015, o parâmetro enviado
   quando clicamos no botão 'buscar' é:

   sorteio=Digite+o+número+do+sorteio+e+confira+seu+resultado&data=23%2F10%2F2015

   Observe como foi formatada a data, no lugar do '/', foi inserido o '%2F', pois
   a barra não é permitida na url quando a mesma está como parâmetro de consulta.

   E se escolhermos, o sorteio e a data e clicarmos no botão 'buscar' a página
   enviada será:

   ?sorteio=716&data=23%2F10%2F2015

   Depois que o servidor retorna com a resposta, o conteúdo html é retornado.
   Então, o objetivo desta unidade, é utilizar as classes abaixo para analisar
   o html e retornar as informações para um sorteio específico.


   De acordo com minha análise, a informação fica disponível, quando no html
   for encontrado a seguintes caracteres:
       <div id="sorteio" class="sorteio">

   Em seguida, é informado a data e hora e o número do jogo, no nosso exemplo,
   estaremos utilizando o jogo 716:

       <div hora="23/10/2015, às 20:00" jogo="716">

   Em seguida, vem a informação das bolas, que começa com as palavras abaixo:

       <div class="bolas">

   Depois, destas palavras, vem todas as bolas do jogo, como estamos utilizando
   html, toda a informação está entre tags html, neste formato:

         <span class="bolao">
               <p> 11 </p>
         </span>

         <span class="bolao">
               <p> 15 </p>
         </span>

         <span class="bolao">
               <p> 16 </p>
         </span>

         <span class="bolao">
               <p> 24 </p>
         </span>

         <span class="bolao">
               <p> 25 </p>
         </span>
      </div>

      Observa, que as bolas deste jogo, está entre os tags <p> </p>.
      No final, há o tag </div>, este tag, fecha o tag <div class="bolao">.

      Em seguida, vem a informação dos ganhadores, número de acertos e valor
      ganho. Na página html onde fica esta informação, há uma linha separação
      as bolas das informações de ganhadores. Tal informação é descrita pelo
      nomenclatura abaixo:

      <span class="line"></span>
      <p class="confira">Confira o número de ganhadores desse sorteio.</p>

      <div class="ganhadores">

           <div class="ganhador">

              <p class="numeros">5</p>
              <p class="acertos">Acertos</p>
              <p class="pessoas">0 ganhador</p>
              <p class="valor">R$ 0,00</p>

          </div>

          <span class="separador"></span>

          <div class="ganhador">

              <p class="numeros">4</p>
              <p class="acertos">Acertos</p>
              <p class="pessoas">5 ganhadores</p>
              <p class="valor">R$ 457,07</p>

          </div>

          <span class="separador"></span>

          <div class="ganhador">

              <p class="numeros">3</p>
              <p class="acertos">Acertos</p>
              <p class="pessoas">104 ganhadores</p>
              <p class="valor">R$ 25,00</p>

          </div>

          <span class="separador"></span>

          <div class="ganhador">

              <p class="numeros">2</p>
              <p class="acertos">Acertos</p>
              <p class="pessoas">1.046 ganhadores</p>
              <p class="valor">R$ 2,00</p>

          </div>

          <span class="separador"></span>

      </div>
   </div>
 </div>

       Dos últimos 3 tags '</div>' cada um fecha um tag '<div' especifíco.

       O primeiro fecha o tag: '<div class="ganhadores">'
       O segundao fecha o tag: '<div hora="23/10/2015, às 20:00" jogo="716">'
       O terceiro fecha o tag: '<div id="sorteio" class="sorteio">'

 Ou seja, o último tag, encerra os dados que são necessários para podermos
 recuperar as informações que precisamos.

 E se o usuário digitar um jogo que não existe ou uma data em que não ocorreu jogo.
 Neste caso, podermos considerar jogo inexistente,
 se não achamos a sentença: '<div id="sorteio" class="sorteio">', ou podermos
 tentar localizar a sentença:

        <p class="resultado">Nenhum resultado encontrado para exibição.</p>

 pois fiz vários testes, pesquisando jogos inexistentes e sempre retornava
 a sentença acima.



**}



interface

uses
  Classes, SysUtils, Contnrs;

type
  TResultado = record
    strJogo: AnsiString;
    strData: AnsiString;
    iBolas: array of integer;

    iGanhador_6_numeros: Integer;
    iDinheiro_6_numeros: Integer;

    iGanhador_5_numeros: Integer;
    iDinheiro_5_numeros: Currency;

    iGanhador_4_numeros: Integer;
    iDinheiro_4_numeros: Currency;

    iGanhador_3_numeros: Integer;
    iDinheiro_3_numeros: Integer;
  end;

type
  { TIntralot }

  TIntralot = class
    private
      Data: TDateTime;

      iBolas: array of integer;

      function Tag_Abre_e_Fecha(tokens_html: TStrings; uIndice_Inicio: Integer; out
			uIndice_Tag: Integer; out strErro: AnsiString): boolean;
      function Validar_Data_Hora(strData_Hora: string; var strData: string;
			var strHora: string; out strErro: string): boolean;

      function Verificar_Pilha(strToken_Temp: String; var uIndice: Integer;
        strErro: string): boolean;




    public
      tags_pilha: TStack;
      strResultado: AnsiString;                         // Resultado no formato: 'JOGO';'DATA';BOLA1;BOLA2;BOLA3;BOLA4;BOLA5

      strResultado_Lista: TStrings;                     // Uma lista de resultados, no formato de 'strResultado';

    public
      function Analisar(strJogo: AnsiString; tokens_html: TStrings;
			var todos_jogos: TStrings; out strErro: AnsiString): boolean;
      function Analisar(strJogo: AnsiString; tokens_html: array of TStrings; out strErro: AnsiString): boolean;

      destructor destroy; override;


  end;

implementation

uses strutils;

{ TIntralot }

// Esta função coloca os tags html na pilha, para podermos realizar a validação

function TIntralot.Verificar_Pilha(strToken_Temp: String; var uIndice: Integer;
  strErro: string): boolean;
var
  strToken_na_Pilha: AnsiString;
begin
    // Se não contém '<' e/ou '>', retorna, pois não é um tag html
    // Aqui, não se considera um erro, pois todos os tags html, passaram aqui.

    if (pos('<', strToken_Temp) = 0) or (pos('>', strToken_Temp) = 0) then begin
       strErro := '';
       Exit(true);
    end;

    case strToken_Temp[1] of
         '<':
           begin
                 case strToken_Temp[2] of
                      '/':
		        begin
		              if AnsiEndsStr('>', strToken_Temp) = true then begin
		                 // Se o token atual é um tag de fechamento, devemos
		                 // verificar se o token na pilha, é o tag de abertura
		                 // correspondente.
		                 // Por exemplo, se o tag de fechamento é '</p>'
		                 // então, devemos encontrar o tag '<p>', se não,
		                 // indicaremos um erro.

		                 // Vamos verificar se a pilha não está vazia.
		                 // Se sim, quer dizer que não há tag correspondente, indicar
		                 // como um erro.
		                 if tags_pilha.Count = 0 then begin
		                    strErro := 'Tag ''' + strToken_Temp + ' inválido.' + #13#10 +
		                               'Tag ''' + AnsiReplaceStr(strToken_Temp, '/', '') +
		                               ' não localizado.';
		                    Exit(false);
					         end;

		                 // Vamos retirar item da pilha.
		                 tags_pilha.Pop;
		                 Exit(True);
			      end else begin
		                    strErro := 'Tag de fechamento inválido.';
		                    Exit(false);
			      end;
		      end
		      else begin
		            // Se o segundo caractere é diferente '/', então é um tag
		            // de abertura, simplesmente, adicionar à pilha
		            // Aqui, não iremos verificar se o tag termina com '>'
		            // pois, quando há um tag de abertura, se, por exemplo
		            // o token é '<p' sem o '>', quer dizer que há propriedades
		            // após o token, então devemos aguardar, até chegarmos
		            // ao caractere '>', situação esta será analisada
		            // em outra estrutura case.
		            tags_pilha.Push(Pointer(strToken_Temp));
		      end;
		 end;
	   end;

         // Se encontramos o terminador de tag, verificar se é um tag de abertura
         // ou fechamento.
         '>':
           begin
                 if tags_pilha.Count = 0 then begin
                    strErro := 'Caractere terminador de tag: ''>'' localizado, entretanto, ' +
                               'Caractere iniciador de tag + identificador de tag, não localizado.';
                    Exit(false);
                 end;

                 strToken_na_pilha := AnsiString(tags_pilha.Pop);

                 // Se termina em '>', indica tag inválido.
                 if AnsiEndsStr('>', strToken_na_Pilha) = true then begin
                    strErro := 'Caractere terminador de tag: ''>'' localizado, entretanto, ' +
                               'token de tag anterior termina em ''>'', era esperado ' +
                               'caractere ''<'' + ''identificador''';
                    Exit(false);
                 end else begin
                     // Se chegamos até aqui, quer dizer que o último tag na pilha, não termina em '>'
                       strToken_na_pilha := strToken_na_Pilha + '>';
                       tags_pilha.Push(Pointer(strToken_na_Pilha));
                 end;

           end;
		  else begin
		  Exit(True);
		  end;
    end;


end;

function TIntralot.Analisar(strJogo: AnsiString; tokens_html: TStrings;
  var todos_jogos: TStrings; out  strErro: AnsiString): boolean;
var
  uIndice: Integer;
  bTag_Encontrado: Boolean;
  uTokens_Quantidade: Integer;

  strData: AnsiString;
  strHora: AnsiString;

  strToken_Data_Hora: AnsiString;
  iJogo: Integer;
  strToken_Temp: AnsiString;
  iTag_Div_qt: Integer;
  iA: Integer;
  iTag_Div_Fecha_Posicao: Integer;

  lista_de_jogos: TStrings;
  iBola_Numero: Integer;
  uBolas_Encontradas: Integer;
  iBola_Ganhadores: Integer;
  iBola_Sorteio: Integer;
  uIndice_Final: Integer;
  strJogo_Linha: String;
  strCabecalho: String;

begin
     // Vamos verificar se os parâmetros foram fornecidos pelo usuário
     if (strJogo <> 'MINAS5') and (strJogo <> 'LOTOMINAS') then begin
        Raise Exception.Create('Jogo inválido!!!');
        Exit(false);
     end;

     if Assigned(tokens_html) = false then begin
        Raise Exception.Create('Argumento tokens_html é ''nil''.');
        Exit(false);
     end;

     // Vamos verificar se o usuário forneceu

     // Vamos procurar o tag que inicializa as informações do jogo.

     uIndice := tokens_html.IndexOf('<div');
     if uIndice = -1 then begin
        strErro := 'tag ''<div'' não localizado.';
        Exit(false);
     end;


     // Vamos percorrer a lista de string para procurar a sequência abaixo:
     // <div id = "sorteio" class = "sorteio" >

     // Vamos guardar a quantidade de tokens que existe na lista.
     uTokens_Quantidade := tokens_html.Count - 1;

     // Nós iremos procurar 8 tokens, então, nosso loop deve parar quando faltar
     // 8 tokens, pois senão dará uma exceção de faixa no arranjo.
     uTokens_Quantidade := uTokens_Quantidade - 8;

     bTag_Encontrado := false;
     while uIndice <= uTokens_Quantidade do begin
       // Se encontrarmos, iremos sair do loop.
       if (tokens_html[uIndice] = '<div') and
          (tokens_html[uIndice + 1] = 'id') and
          (tokens_html[uIndice + 2] = '=') and
          (tokens_html[uIndice + 3] = '"sorteio"') and
          (tokens_html[uIndice + 4] = 'class') and
          (tokens_html[uIndice + 5] = '=') and
          (tokens_html[uIndice + 6] = '"sorteio"') and
          (tokens_html[uIndice + 7] = '>') then begin
             bTag_Encontrado := true;
             break;
          end;
       Inc(uIndice);
     end;

     // Se foi encontrado, bTag_Encontrado é igual a true.
     if bTag_Encontrado = false then begin
           strErro := 'Erro, não encontrado a sequência: ' + #13#10 +
                      '<div id="sorteio" class="sorteio" style="overflow: hidden;"';
           Exit(false);
     end;

     // Vamos procurar o '</div>' que corresponde ao tag que encontrarmos, iremos percorrer
     // somente os tokens que estão entre <div e </div>
     // Se não encontrarmos, sairemos

     uIndice_Final := 0;

     if Tag_Abre_e_Fecha(tokens_html, uIndice, uIndice_Final, strErro) = false then begin
        Exit(False);
     End;






     // Vamos criar a pilha de tags, como ela vai funcionar:
     // Toda vez que um token começa com '<', quer dizer, que um tag foi encontrado.
     // Então, iremos verificar, se o próximo caractere é diferente de '/', se sim
     // iremos adicionar este token, na pilha, depois quando encontrarmos o '>' que fecha
     // este tag, iremos substituir o último token da pilha, com o token que começa
     // com '</' + identificador + '>', aí quando continuando a analisar encontrarmos
     // o caractere '<' seguido de '/' e terminado com '>', quer dizer que o tag
     // de fechamento foi encontrado, então devemos verificar se este tag é igual
     // ao tag na pilha, se não for há um erro de sintaxe, então devemos sair do loop.

     tags_pilha := TStack.Create;

     // Nosso primeiro tag, na pilha, será '<div', então quando a pilha ficar vazia, quer dizer
     // que analisamos todo o conteúdo do jogo.
     // Há vários tags aninhados, até chegarmos onde queremos.
     // Então, iremos colocar nosso primeiro tag, então quando o tag correspondente
     // for encontrado, ele será retirado da pilha e a pilha ficará então
     // igual a zero.
     // Haja vista, que isto pode não ocorrer, mas se ocorrer isto será detectado
     // e o programa avisa onde ocorreu o problema.

     strToken_Temp := '<div>';
     tags_pilha.push(Pointer(strToken_Temp));

     // Antes de entrar no loop, iremos apontar uIndice para depois do caractere
     // '>', pois no loop anterior, pesquisamos 8 tokens de uma vez só, então,
     // devemos incrementar 8 e não 9, por que, o primeiro é zero, o segundo é 1.
     Inc(uIndice, 8);


     // Esta lista de string, guarda cada informação do jogo.
     lista_de_Jogos := TStringList.Create;

     while uIndice < uIndice_Final do begin
           // Os próximo token deve estar neste formato:
           // <div jogo = "723" hora = "31/10/2015, às 20:00" >
           // se não estiver, iremos sair do loop e retornar
           // com o valor falso.
           // Não iremos verificar, o valor da propriedade 'jogo', nem
           // o valor da propriedade 'hora' ainda.
           // Primeiro, verificaremos se os tokens '<div', 'jogo', '=',
           // 'hora', '=' e '>', estão nas posições corretas.

           // Aqui, sempre verificaremos se não estão nas posições corretas.
           // Na condição abaixo, se uma das condições é falsa, o operador not
           // vai inverter para verdadeira, para podermos entrar e informar
           // que há erro.
           if not((tokens_html.Strings[uIndice] = '<div') and
              (tokens_html.Strings[uIndice + 1] = 'jogo') and
              (tokens_html.Strings[uIndice + 2] = '=') and
               // Iremos verificar o valor das propriedades depois.
              (tokens_html.Strings[uIndice + 4] = 'hora') and
              (tokens_html.Strings[uIndice + 5] = '=') and
              (tokens_html.Strings[uIndice + 7] = '>')) then begin
                 strErro := 'uIndice = ' + IntToStr(uIndice) + 'Era esperado 8 tokens: ' + #13#10 +
                            '<div jogo = hora = >' + #13#10 +
                            'mais os valores das propriedades após os tokens ''=''';
                 Exit(False);
	   end;

           // Se chegarmos aqui, quer dizer, que os tokens estão na posição correta.
           // Vamos verificar se inicia e termina com aspas duplas.
           // Vamos verificar o valor para a propriedade 'jogo'
           strToken_Temp := tokens_html.Strings[uIndice + 3];

           // Se um das aspas não está, então sair indicando erro.
           if (AnsiStartsStr('"', strToken_Temp) = false) or
              (AnsiEndsStr('"', strToken_Temp) = false) then begin
                 strErro := 'uIndice = ' + IntToStr(uIndice) + 'Valor para a propriedade ''jogo'', deve estar entre' +
                            'aspas duplas.' + #1310 +
                            'Incorreto: ' + strToken_Temp;
                 Exit(False);
	   end;

           // Verificar se o token é um número válido, vamos retirar as aspas duplas.
           strToken_Temp := AnsiReplaceStr(strToken_Temp, '"', '');

           // Vamos tentar converter para número.
           try
              iJogo := StrToInt(strToken_Temp);
	   except
             On exc: Exception do begin
                strErro := exc.Message;
                Exit(False);
	     end;
	   end;

           // Os jogos serão preenchidos nesta forma:
           // Jogo_Tipo, Concurso, Data Sorteio, Bola1, Bola2, Bola3, Bola4, Bola5

           lista_de_jogos.Add('INTRALOT_MINAS_5');        // Jogo_Tipo;
           lista_de_jogos.Add(IntToStr(iJogo));           // Concurso


           // Vamos verificar o valor para a propriedade 'hora'
           strToken_Temp := tokens_html.Strings[uIndice + 6];

           // Se um das aspas não está, então sair indicando erro.
           if (AnsiStartsStr('"', strToken_Temp) = false) or
              (AnsiEndsStr('"', strToken_Temp) = false) then begin
                 strErro := 'uIndice = ' + IntToStr(uIndice) + 'Valor para a propriedade ''hora'', deve estar entre' +
                            'aspas duplas.' + #1310 +
                            'Incorreto: ' + strToken_Temp;
                 Exit(False);
	   end;

           // Validar campos data e hora, se a função executar com sucesso
           // Irá retornar a data e hora. Senão, retornará falso
           if Validar_Data_Hora(strToken_Temp, strData, strHora, strErro) = false then begin
              Exit(false);
	   end;

           lista_de_jogos.Add(strData);

           // Se chegamos até aqui, quer dizer que o formato:
           // <div jogo = "723" hora = "31/10/2015, às 20:00" >
           // está correto.
           // Mas antes, devemos inserir o tag na pilha.
           strToken_Temp := '<div>';
           tags_pilha.Push(Pointer(strToken_Temp));

           // Vamos fazer uIndice apontar depois do token '>'
           Inc(uIndice, 8);

           // Agora vamos verificar os próximos tokens, deve estar neste formato:
           // <div class = "bolas" >

           if not((tokens_html.Strings[uIndice] = '<div') and
              (tokens_html.Strings[uIndice + 1] = 'class') and
              (tokens_html.Strings[uIndice + 2] = '=') and
              (tokens_html.strings[uIndice + 3] = '"bolas"') and
              (tokens_html.Strings[uIndice + 4] = '>')) then begin
                 strErro := 'Era esperado os tokens nesta ordem: ' +
                            '<div class = "bolas" >';
                 Exit(False);
	   end;

           // Mais um tag de abertura, iremos adicionar à pilha.
           strToken_Temp := '<div>';
           tags_Pilha.Push(Pointer(strToken_Temp));

           // Dentro do elemento <div class="bolas">, vários
           // tags neste formato:
           // <span class = "bolao">
           //       <p>08</p>
           // </span>

           // Vamos apontar uIndice para depois do caractere '>'
           Inc(uIndice, 5);
           uTokens_Quantidade := tokens_html.Count-1;

           // Este tag:
           // <div class = "bolas"> é o mais profundo, é onde está as bolas.
           // Iremos localiza onde está o tag de fechamento '</div'>
           // Pois, iremos fazer o loop, várias vezes.

           // Como já encontrarmos, um tag de abertura, quando encontrarmos
           // o tag de fechamento, iremos decrementar esta variável.
           iTag_Div_qt := 1;

           // Vamos percorrer até encontrar o tag ou o fim do string
           iA := uIndice;


           // Deve haver um balanceamento entre todos os tags html
           // Neste caso, estamos verificando somente o tag '<div'
           while iA <= uTokens_Quantidade do begin

                 if tokens_html.Strings[iA] = '<div' then begin
                    // Quando em html, encontramos um tag, iniciando, por exemplo
                    // '<div', isto quer dizer, que entre '<div' e '>', há propriedades
                    // na forma propriedade=valor, então devemos localizar o token
                    // '>', mas entre o token '<div' e '>', não pode haver token
                    // nestes formatos: '<teste', '</teste>' e '<teste>'
                    Inc(iA);

                    while iA <= uTokens_Quantidade do begin
                          if (AnsiStartsStr('<', tokens_html.Strings[iA]) = true) or
                             (AnsiEndsStr('>', tokens_html.Strings[iA]) = true) or
                             ((AnsiStartsStr('<', tokens_html.Strings[iA]) = true) and
                              (AnsiEndsStr('>', tokens_html.Strings[iA]) = true)) then begin

			      strErro := 'uIndice = ' + IntToStr(uIndice) + 'Propriedade do tag ''<div'' inválida ' +
                                         'provavelmente, faltou o caractere ' +
                                         'antes da propriedade.';
                              Exit(false);

			  end;
                          if tokens_html.Strings[iA] = '>' then begin
                             Inc(iTag_Div_Qt);
                             Break;
                          end;

                          Inc(iA);
		    end;
                 end;



                 if tokens_html.Strings[iA] = '<div>' then begin
                    Inc(iTag_Div_qt);
		 end;
                 if tokens_html.Strings[iA] = '</div>' then begin
                    Dec(iTag_Div_Qt);
		 end;

                 // Se igual a zero, quer dizer, que encontramos nosso nosso
                 // tag de fechamento.
                 if iTag_Div_Qt = 0 then begin
                    Break;
		 end;

                 // Ao sair do loop, iA, sempre apontará para o tag de fechamento,
                 // pois, se 'iTag_Div_Qt' é igual a zero, não haverá incremento
                 // da variável iA.
                 Inc(iA);
	   end;

           // Se iTag_Div_Qt <> 0, quer dizer, que algum tag 'div', não tem um
           // correspondente tag.
           if iTag_Div_Qt <> 0 then begin
              strErro := 'Tag ''div'' sem um outro tag correspondente.';
              Exit(False);
	   end;

           // Vamos guardar a posição do nosso tag 'div' de fechamento.
           iTag_Div_Fecha_Posicao := iA;

           // Nossa variável uIndice para o token depois do token '>'
           // Vou utilizar um loop para percorrer os tokens, que estarão
           // neste formato.
           // O objetivo de ter localizado o tag de fechamento do objeto
           // '<div class = "bolas">, é que não precisarei ficará verificando
           // depois do tag </span>, o que virá, eu sei

           // Após o tag '<div class="bolas">', haverá os tokens:
           // <span class="bolao">
           //       <p>8</p>
           // </span>
           //

           // Na Intralot Minas5, há 5 bolas sorteadas, então está variável
           // serve para detectarmos se houver mais de 5 bolas, sinalizar como
           // um erro.
           uBolas_Encontradas:= 0;

           while uIndice < iTag_Div_Fecha_Posicao do begin
                 if (tokens_html.Strings[uIndice] = '<span') and
                    (tokens_html.Strings[uIndice + 1] = 'class') and
                    (tokens_html.Strings[uIndice + 2] = '=') and
                    (tokens_html.Strings[uIndice + 3] = '"bolao"') and
                    (tokens_html.Strings[uIndice + 4] = '>') and
                    (tokens_html.Strings[uIndice + 5] = '<p>') and
                    (tokens_html.Strings[uIndice + 7] = '</p>') and
                    (tokens_html.Strings[uIndice + 8] = '</span>') then
                 begin
                    // Vamos tentar converter o número armazenado.
                    // O número está entre os pares '<p>' e '</p>':
                    try
                       iBola_Numero := StrToInt(tokens_html.Strings[uIndice + 6]);

                       // Bolas no jogo Intralot Minas 5, no intervalo de 1 a 34.
                       // Vamos validar está situação.
                       if iBola_Numero in [1..34] = false then begin
                          strErro := 'uIndice = ' + IntToStr(uIndice) + 'Número de bola inválido: ''' +
                                      tokens_html.Strings[uIndice + 6] + #1013 +
                                     'Intervalo válido: de 1 a 34.';
                          Exit(false);
		       end;



                       // Se chegarmos aqui, não houve erro.
                       lista_de_jogos.Add(IntToStr(iBola_Numero));
                       Inc(uBolas_Encontradas);

                       if uIndice = 1039 then
                       begin
                          ;
		       end;


                       // Se há mais de 5 bolas, indicar um erro.
                       if uBolas_Encontradas = 6 then begin
                          strErro := 'uIndice = ' + IntToStr(uIndice) + 'O jogo Intralot Minas 5, é sorteado somente ' +
                                     '5 números, encontrado mais de 5 números.';
                          Exit(False);
		       end;

		    except
                      On Exc: Exception do
                      begin
                            strErro := Exc.Message;
                            Exit(False);
		      end;
		    end;
		 end;

                 // Vamos incrementar para depois do token: '</span>'
                 Inc(uIndice, 9);
           end;

           // Vamos verificar se uBolas_Encontradas é diferente de 5, se for
           // é um erro.
           if uBolas_Encontradas <> 5 then begin
              strErro := 'uIndice = ' + IntToStr(uIndice) + 'O jogo Intralot Minas 5, é sorteado 5 números, entretanto, ' +
                         ' no conteúdo html, há menos bolas.';
              Exit(False);
	   end;

           // Se chegarmos aqui quer dizer que uIndice aponta para o token '</div>'
           // do tag: <div class="bolas";

           if tokens_html.Strings[uIndice] <> '</div>' then begin
              strErro := 'uIndice = ' + IntToStr(uIndice) + 'Era esperado o token ''</div>'' após ''</span>''';
              Exit(False);
	   end;

           // Se chegamos aqui, achamos o token '</div>';
           // Retirar da pilha de tags.
           if tags_pilha.Count > 0 then begin
              tags_pilha.Pop;
	   end;

           // Apontar para depois de '</div>'.
           Inc(uIndice);

           // Depois de '</div', há, os tokens:
           // <span class="line"></span>
           // <p class="confira">Confira o número de ganhadores desse sorteio.</p>

           // Vamos verificar
           if not((tokens_html.Strings[uIndice] = '<span') and
              (tokens_html.Strings[uIndice + 1] = 'class') and
              (tokens_html.Strings[uIndice + 2] = '=') and
              (tokens_html.Strings[uIndice + 3] = '"line"') and
              (tokens_html.Strings[uIndice + 4] = '>') and
              (tokens_html.Strings[uIndice + 5] = '</span>') and
              (tokens_html.Strings[uIndice + 6] = '<p') and
              (tokens_html.Strings[uIndice + 7] = 'class') and
              (tokens_html.Strings[uIndice + 8] = '=') and
              (tokens_html.Strings[uIndice + 9] = '"confira"') and
              (tokens_html.Strings[uIndice + 10] = '>') and
              (tokens_html.Strings[uIndice + 11] =
              'Confira o número de ganhadores desse sorteio.') and
              (tokens_html.Strings[uIndice + 12] = '</p>')) then
              begin
                 strErro := 'uIndice = ' + IntToStr(uIndice) + 'Era esperado após ''</span>'', os tokens: ' + #13#10 +
                            '<span class="line"></span>' + #13#10 +
                            '<p class="confira">Confira o número de ganhadores desse sorteio.</p>' + #13#10 +
                            'mas, não localizado.';
                 Exit(False);
	      end;

           // Vamos apontar depois do caractere </p>
           Inc(uIndice, 13);

           // Se chegarmos aqui, que dizer que os próximos tokens são:
           // <div class = "ganhadores">
           if not((tokens_html.Strings[uIndice] = '<div') and
              (tokens_html.Strings[uIndice + 1] = 'class') and
              (tokens_html.Strings[uIndice + 2] = '=') and
              (tokens_html.Strings[uIndice + 3] = '"ganhadores"') and
              (tokens_html.Strings[uIndice + 4] = '>')) then
              begin
                   // Se não acharmos nenhum dos tokens, sair.
                   strErro := 'uIndice = ' + IntToStr(uIndice) + 'Era esperado ''<div class="ganhadores">''';
                   Exit(False);
	      end;

           // Vamos apontar após o token '>'
           Inc(uIndice, 5);

           // Se chegarmos aqui, quer dizer, que os próximos tokens indicam
           // A quantidade de bolas acertadas, a quantidade de ganhadores e
           // O valor em real ganho:
           // Na Intralot_Minas_5, você pode ganhar se acertar 5, 4, 3 e 2 números.
           // No contéudo html, esta informação é composta da seguinte forma:
           //
           // <div class="ganhador">
           //      <p> class="numeros">5</p>
           //      <p> class="numeros">Acertos</p>
           //      <p> class="pessoas">0 ganhador</p>
           //      <p> class="valor">R$ 0,00</P>
           // </div>
           // <span class="separador"></span>

           // Como na Intralot Minas 5, você ganha com 5, 4, 3 e 2 números, haverá
           // este layout html, repetindo 4 vezes, 1 para cada tipo de número de bolas
           // ganho.

           // Ao invés de repetirmos isto 4 vezes, utilizaremos um loop
           // Mas como fazer pra indicar

           // Como há 4 modalidade para ganhar no Intralot Minas 5, utilizaremos
           // um loop de 1 a 4.
           // Antes de entrar no loop
           // uÍndice está apontando para '<div'

           for iA := 1 to 4 do begin
               if not((tokens_html.Strings[uIndice] = '<div') and
                  (tokens_html.Strings[uIndice + 1] = 'class') and
                  (tokens_html.Strings[uIndice + 2] = '=') and
                  (tokens_html.Strings[uIndice + 3] = '"ganhador"') and
                  (tokens_html.Strings[uIndice + 4] = '>') and
                  (tokens_html.Strings[uIndice + 5] = '<p') and
                  (tokens_html.Strings[uIndice + 6] = 'class') and
                  (tokens_html.Strings[uIndice + 7] = '=') and
                  (tokens_html.Strings[uIndice + 8] = '"numeros"') and
                  (tokens_html.Strings[uIndice + 9] = '>') and
                  // Iremos analisar o argumento 10 posteriormente.
                  (tokens_html.Strings[uIndice + 11] = '</p>') and
                  (tokens_html.Strings[uIndice + 12] = '<p') and
                  (tokens_html.Strings[uIndice + 13] = 'class') and
                  (tokens_html.Strings[uIndice + 14] = '=') and
                  (tokens_html.Strings[uIndice + 15] = '"acertos"') and
                  (tokens_html.Strings[uIndice + 16] = '>') and
                  (tokens_html.Strings[uIndice + 17] = 'Acertos') and
                  (tokens_html.Strings[uIndice + 18] = '</p>') and
                  (tokens_html.Strings[uIndice + 19] = '<p') and
                  (tokens_html.Strings[uIndice + 20] = 'class') and
                  (tokens_html.Strings[uIndice + 21] = '=') and
                  (tokens_html.Strings[uIndice + 22] = '"pessoas"') and
                  (tokens_html.Strings[uIndice + 23] = '>') and
                  // Iremos analisar o argumento 24 posteriormente.
                  (tokens_html.Strings[uIndice + 25] = '</p>') and
                  (tokens_html.Strings[uIndice + 26] = '<p') and
                  (tokens_html.Strings[uIndice + 27] = 'class') and
                  (tokens_html.Strings[uIndice + 28] = '=') and
                  (tokens_html.Strings[uIndice + 29] = '"valor"') and
                  (tokens_html.Strings[uIndice + 30] = '>') and
                  // Iremos analisar o argumento 31 posteriormente.
                  (tokens_html.Strings[uIndice + 32] = '</p>') and
                  (tokens_html.Strings[uIndice + 33] = '</div>') and
                  (tokens_html.Strings[uIndice + 34] = '<span') and
                  (tokens_html.Strings[uIndice + 35] = 'class') and
                  (tokens_html.Strings[uIndice + 36] = '=') and
                  (tokens_html.Strings[uIndice + 37] = '"separador"') and
                  (tokens_html.Strings[uIndice + 38] = '>') and
                  (tokens_html.Strings[uIndice + 39] = '</span>')) then
		                 begin
		                     strErro := 'uIndice = ' + IntToStr(uIndice) + 'Era esperado após: ''<div class = "ganhadores">'', ' +
		                                 'os tokens: ' + #13#10 +
		                                 '<div class="ganhador">' + #1310 +
		                                 '     <p> class="numeros">5</p>'  +
		                                 '     <p> class="numeros">Acertos</p>' +
		                                 ' e outros tokens.';
		                      Exit(False);
		                 end;

		                 // Se chegarmos aqui, quer dizer que os tokens estão corretos.
		                 try
		                    // Vamos tentar converter, para número.
		                    iBola_Sorteio := StrToInt(tokens_html.Strings[uIndice + 10]);

		                    // O conteúdo html no site, a ordem é 5, 4, 3, 2
		                    // para o valor entre o tag '<p class="numeros">' e '</p>'.
		                    // Então, iremos validar isto.
		                    // Se ia:
		                    // igual a 1, então iBola_Sorteio tem que ser igual a 5.
		                    // igual a 2, então iBola_Sorteio tem que ser igual a 4.

		                    if 6 - iA <> iBola_Sorteio then begin
		                       strErro := 'Após o token ''<p class="numeros">''' +
		                                  'Era esperado o valor ' + IntToStr(6 - iA);
		                       Exit(false);
				    end;

              		         except On exc: Exception do
		                        begin
		                             strErro := Exc.Message;
		                             Exit(False);
		                        end;
			         end;


		                    // Vamos analisar agora:
		                    // <p class="pessoas"> </p>
                                    // O valor entre '<p class="pessoas"' e '</p>'
                                    // é formado desta maneira '99 ganhadores'.
                                    // Então, para pegar o número, iremos substituir
                                    // a palavra 'ganhadores', por, '' (vázio).

                                    if AnsiEndsStr('ganhador', tokens_html.Strings[uIndice + 24]) = true then begin
                                        strToken_Temp := AnsiReplaceStr(tokens_html.Strings[uIndice + 24], 'ganhador', '');
				    end else begin
                                        strToken_Temp := AnsiReplaceStr(tokens_html.Strings[uIndice + 24], 'ganhadores', '')
				    end;
                                    // Retirar espaço depois do número.
                                    strToken_Temp := Trim(strToken_Temp);

                                    // Vamos retirar o caractere '.', que no Brasil é separador de milhares
                                    // Pois a função IntToStr considera o ponto '.' como um separador de decimal
                                    // Pois é uma função criada por americanos.
                                    strToken_Temp := AnsiReplaceStr(strToken_Temp, '.', '');

                                    try
                                       iBola_Ganhadores := StrToInt(strToken_Temp);
				    except
                                      On exc:Exception do begin
                                          strErro := Exc.Message;
                                          Exit(False);
				    end;


	       end;
               Inc(uIndice, 40);
	   end;

           // Após sairmos o uIndice estará na posição correta, não precisamos fazer nada.
           // Vamos verificar se existe o tag '</div>',
           // Este tag de fechamento '</div>', corresponde ao tag:
           // <div class="ganhadores">
           if tokens_html.Strings[uIndice] <> '</div>' then begin
              strErro := 'uIndice = ' + IntToStr(uIndice) + 'Tag de fechamento ''</div>'', que corresponde ao ' +
                         'tag de abertura ''<div class="ganhadores">'', não localizado.';
              Exit(False);
	   end;

           // Ao chegarmos aqui, devemos verificar se existe um outro tag de fechamento
           // Este tag de fechamento corresponde ao tag de abertura:
           // <div jogo="999" hora="99/99/9999", às 20:00">

           // Vamos incrementar para apontar para o próximo token.
           Inc(uIndice, 1);

           if tokens_html.Strings[uIndice] <> '</div>' then begin
              strErro := 'uIndice = ' + IntToStr(uIndice) + 'Tag de fechamento ''</div>'', que corresponde ao ' +
                         'tag de abertura ''<div jogo="999" hora="99/99/9999",' +
                         ' às 20:00">'', não localizado.';
              Exit(False);
	   end;

           // Se chegarmos aqui, capturarmos toda a informação de um único jogo.
           // Vamos incrementar uIndice para apontar para o fim ou para o próximo jogo.
           Inc(uIndice, 1);

           // Vamos preencher as informações que encontramos
           strJogo_Linha := '';

           // O primeiro item em lista_de_jogos é Jogo_Tipo
           // O segundo é o número do Concurso
           // O terceiro é a data
           // Os próximos 5 ítens são as bolas.
           // Toda vez que chegarmos aqui, quer dizer, que a informação para um jogo
           // específico foi obtida.

           // Fizermos isto para poder dentro do loop, ter a vírgula após cada
           // parâmetro.
           strJogo_Linha := lista_de_jogos.Strings[0];

           for iA := 1 to lista_de_jogos.Count - 1 do begin
                 strJogo_Linha := strJogo_Linha + ';' + lista_de_Jogos.Strings[iA]
	   end;

           // Apaga para começar um novo jogo, se houver.
           lista_de_Jogos.Clear;

           // Acrescenta a informação do jogo, neste formato.
           todos_jogos.Add(strJogo_Linha);

           // Se houve mais jogos, o próximo token é provavelmente, '<div'
           // Senão, processamos todos os jogos, o próximo campo é '</div>'

           // O que acontece, se ocorrer um erro depois que capturamos por completo
           // um jogo, simplesmente, indicaremos sucesso, e definiremos a variável
           // strErro.
           if (tokens_html.Strings[uIndice] <> '</div>') and
              (tokens_html.Strings[uIndice] <> '<div') then begin
                 Result := True;
                 strErro := 'uIndice = ' + IntToStr(uIndice) + 'Foi capturado um ou mais jogos, entretanto, ocorreu um ' +
                            'ao tentar processar próximo jogo, ou chegou ao fim do jogo.';
                 Break;
	      end;
      end;

      // Sairmos do jogo, iremos acrescentar o cabeçalho do jogo.
      strCabecalho := 'JOGO_TIPO;CONCURSO;DATA SORTEIO;BOLA1;BOLA2;BOLA3;BOLA4;BOLA5';

      todos_jogos.Insert(0, strCabecalho);

      Result:= true;

end;

{
    Esta função verificar se um tag de abertura, tem seu tag respectivo de fechamento.
    Por exemplo, se analisarmos o tag '<div>', devemos localizar o tag '</div>',

    A função funciona assim:
    Um variável é atribuído o valor 1, pois temos um tag, por exemplo, '<div>'
    Ao percorrermos a lista de tokens, ao encontrarmos o tag de abertura:
    '<div>' ou '<div' seguido de '>', incrementaremos tal variável em 1.
    Ao encontrarmos o tag de fechamento decrementaremos tal variável em 1.

    Se durante percorrermos sequencialmente a lista de tokens, a variável torna-se zero, quer dizer
    que o tag de fechamento correspondente foi localizado. Devemos retornar da
    função com o valor 'True' e Indicar na variável uIndice_Tag, a posição baseada
    em zero, do tag de fechamento.

}
function TIntralot.Tag_Abre_e_Fecha(tokens_html: TStrings; uIndice_Inicio: Integer;
         out uIndice_Tag : Integer;  out strErro: AnsiString): boolean;
var
  iA: integer;
  uTokens_Quantidade: integer;
  iTag_Div_Qt: Integer;
begin

    // Vamos validar a entrada do usuário, às vezes, o usuário indicou uma posição
    // maior que a quantidade de elementos, ou menor, que a menor posição em tokens_html.
    if (uIndice_Inicio < 0) or (uIndice_Inicio > tokens_html.Count) then begin
       strErro := 'Posição inicial inválida, provavelmente, menor que zero ou maior que ' +
                  'a quantidade de tokens.';
       Exit(false);
    end;


    // iA, apontará para a posição que começaremos a escanear,
    // que corresponde a uIndice_Inicio;
    iA := uIndice_Inicio;
    uTokens_Quantidade := tokens_html.Count;

    // Deve haver um balanceamento entre todos os tags html
    // Neste caso, estamos verificando somente o tag '<div'
    iTag_Div_Qt := 0;

    while iA <= uTokens_Quantidade do begin

          if tokens_html.Strings[iA] = '<div' then begin
             // Quando em html, encontramos um tag, iniciando, por exemplo
             // '<div', isto quer dizer, que entre '<div' e '>', há propriedades
             // na forma propriedade=valor, então devemos localizar o token
             // '>', mas entre o token '<div' e '>', não pode haver token
             // nestes formatos: '<teste', '</teste>' e '<teste>'
             Inc(iA);

             while iA <= uTokens_Quantidade do begin
                   // Temos que utilizar esta condição primeiro
                   // Senão, quando entrar na condição abaixo dará um erro
                   // pois, na segunda condição abaixo, estamos verificando
                   // as extremidades esquerda e direita do string a procura
                   // do caractere '<', e se o token for um único caractere,
                   // a condição será satisfeita.
                   if tokens_html.Strings[iA] = '>' then begin
                      Inc(iTag_Div_Qt);
                      Break;
		   end;

                   if (AnsiStartsStr('<', tokens_html.Strings[iA]) = true) or
                      (AnsiEndsStr('>', tokens_html.Strings[iA]) = true) or
                      ((AnsiStartsStr('<', tokens_html.Strings[iA]) = true) and
                       (AnsiEndsStr('>', tokens_html.Strings[iA]) = true)) then begin

 		      strErro := 'Propriedade do tag ''<div'' inválida ' +
                                  'provavelmente, faltou o caractere ' +
                                  'antes da propriedade.';
                       Exit(false);

 		  end;
                  Inc(iA);
 	    end;
          end;

         if tokens_html.Strings[iA] = '<div>' then begin
             Inc(iTag_Div_qt);
 	 end;
          if tokens_html.Strings[iA] = '</div>' then begin
             Dec(iTag_Div_Qt);
 	 end;

          // Se igual a zero, quer dizer, que encontramos nosso nosso
          // tag de fechamento.
          if iTag_Div_Qt = 0 then begin
             uIndice_Tag := iA;
             Break;
 	 end;

          // Ao sair do loop, iA, sempre apontará para o tag de fechamento,
          // pois, se 'iTag_Div_Qt' é igual a zero, não haverá incremento
          // da variável iA.
          Inc(iA);
    end;

    Result:= true;
end;

function TIntralot.Analisar(strJogo: AnsiString;
  tokens_html: array of TStrings; out strErro: AnsiString): boolean;
begin

end;

destructor TIntralot.destroy;
begin
    if Assigned(tags_pilha) = true then
       FreeAndNil(tags_pilha);

    inherited destroy;
end;

function TIntralot.Validar_Data_Hora(strData_Hora: string; var strData: string;
  var strHora: string; out strErro: string): boolean;
var
  iVirgula: SizeInt;
  iDia: Integer;
  iMes: Integer;
  iAno: Integer;
  bAno_Bissexto: Boolean;
begin
     if (AnsiStartsStr('"', strData_Hora) <> true) or
        (AnsiEndsStr('"', strData_Hora) <> true) then begin
        strErro := 'O valor para atributo ''data'' do objeto ''<div class="slidesjs-control"' +
                  ' está inválido: aspas não encontrada.';
        exit(false);
     end;

     // O valor para a propriedade 'data' deve está formato conforme abaixo:
     // 31/10/2015, às 20:00

     // Primeiro, vamos retirar as aspas.
     strData_Hora := AnsiReplaceStr(strData_Hora, '"', '');

     // Vamos procurar a palavra ', às '
     if pos(', às ', strData_Hora) = 0 then begin
        strErro := 'Formato de data e hora inválido, formato correto deve ser: ' +
                  'dd/mm/yyy, às hh:mm';
        Exit(false);
     end;

     // Os números das datas, dia e mês, sempre formatados com dois dígitos.
     // Vamos analisar cada caractere.
     // Primeiro, iremos verificar se são só números válidos e a barra.

     iVirgula := pos('/', strData_Hora);
     if iVirgula <= 1 then begin
        strErro := 'Formato de data e hora inválido: ''/'' ausente.';
        Exit(false);
     end;

     try
     iDia := StrToInt(AnsiLeftStr(strData_Hora, iVirgula - 1));

     // Vamos apontar o string após a barra depois do dia.
     strData_Hora := AnsiMidStr(strData_Hora, iVirgula + 1, Length(strData_Hora));

     iVirgula := pos('/', strData_Hora);
     if iVirgula <= 1 then begin
        strErro := 'Formato de data e hora inválido: ''/'' ausente.';
        Exit(false);
     end;

     iMes := StrToInt(AnsiLeftStr(strData_Hora, iVirgula - 1));

     // Vamos apontar o string após a barra depois do mês.
     strData_Hora := AnsiMidStr(strData_Hora, iVirgula + 1, Length(strData_Hora));

     iVirgula := pos(',', strData_Hora);

     if iVirgula <= 1 then begin
        strErro := 'Formato de data e hora inválido: '','' ausente.';
        Exit(false);
     end;

     iAno := StrToInt(AnsiLeftStr(strData_Hora, iVirgula - 1));

     // Vamos apontar o string para depois da vírgula:
     strData_Hora := AnsiMidSTr(strData_Hora, iVirgula + 1, Length(strData_Hora));

     // Se está fora da faixa é inválido.
     if  (iDia in [1..31]) = false then begin
        strErro := 'Formato de Data inválido: ' +
                   'Dia não está no intervalo de 1 a 31.';
        Exit(false);
     end;

     // Vamos verificar se a data é válida.
     // Os meses que terminam com 30 são:
     // Abril, Junho, Setembro, Novembro
     // Se o dia for 31, e o mês for abril, junho, setembro ou novembro.
     // o formato de data está inválido.

     if (iDia = 31) and (iMes in [2, 4, 6, 9, 11]) then begin
        strErro := 'Formato de data invalido: ' + #10#13 +
                   'O último dia do mês de Abril, Junho, Setembro e ' + #10#13 +
                   'Novembro, é 30, entretanto, o dia fornecido é 31.';
        Exit(False);
     end;

     // Se o mês é fevereiro e o dia é maior que 29, indicar um erro.
     if (iDia > 29) and (iMes = 2) then begin
        strErro := 'Formato de data inválido: Mês de fevereiro termina em 28, ' +
                   'ou 29, se bissexto, entretanto, o dia fornecido é maior que ' +
                   '29.';
        Exit(false);
     end;

     // Vamos verificar, se o ano não for bissexto e o mês de fevereiro é 29
     // está errado, então.
     bAno_Bissexto := false;

     if ((iAno mod 4 = 0) and (iAno mod 100 <> 1)) or
        (iAno mod 400 = 0) then begin
           bAno_Bissexto := true;
     end;

     if (iDia = 29) and (bAno_Bissexto = false) and (iMes = 2) then begin
        strErro := 'Formato de data inválido: Dia é igual a ''29'' de ''fevereiro''' +
                   ' mas ano não é bissexto.';
        Exit(False);
     end;

     except
       // Se strToInt dar uma exceção indicando que o string não é um número
       // devemos retornar falso.
       On exc: Exception do begin
             strErro := exc.Message;
             Exit(false);
       end;
     end;

     // Vamos retornar as informações nas variáveis strData, strHora
     strData := Format('%d/%d/%d', [iDia, iMes, iAno]);
     strHora := '';

    Result:= true;
end;

end.

