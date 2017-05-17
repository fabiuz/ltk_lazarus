unit uintralot_extrator;


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, uIntralot_extrator_de_resultados, idHttp, Grids,
  strUtils, EditBtn, idGlobal;

type

  { TfrmIntralot_Extrator }

  TfrmIntralot_Extrator = class(TForm)
    btnGerar_por_jogo: TButton;
    btnGerar_por_Data: TButton;
    btnAbrirDiretorio: TButton;
    btn_Parar_Jogo: TButton;
    cmbJogoTipo: TComboBox;
    dtData_Inicial: TDateEdit;
    dtData_Final: TDateEdit;
    edDiretorio: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    edJogo_Inicial: TLabeledEdit;
    edJogo_Final: TLabeledEdit;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    dlgDiretorio: TSelectDirectoryDialog;
    Label2: TLabel;
    mmLog: TMemo;
    mmPagina_Gerada: TMemo;
    grBolas_Extraidas: TStringGrid;
    procedure btnAbrirDiretorioClick(Sender: TObject);
    procedure btnGerar_por_DataClick(Sender: TObject);
    procedure btnGerar_por_jogoClick(Sender: TObject);
    procedure btn_Parar_JogoClick(Sender: TObject);
    procedure edDiretorioChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
  private
    strErro: string;
    objHttp: TidHttp;
    strJogo_Tipo: string;
    strIntervalo: string;
    diretorio_do_aplicativo: string;
    bParar_Extracao: boolean;

    function Criar_Diretorio: boolean;
    function Formatar_Jogo_para_url(var strJogo: string): boolean;
    function Gerar_Arquivos_dos_Jogos(strUrl_do_jogo: string): boolean;
    function gerar_url_por_data_do_jogo(var strUrl_do_Jogo: string;
      strJogo: string; strData_Inicial: string; strData_Final: string): boolean;
    function gerar_url_por_numero_do_jogo(var strUrl_do_Jogo: string;
      strJogo: string; iJogo_Inicial: integer; iJogo_Final: integer): boolean;
    function Paginador(strUrl: string; var lista_de_urls: TStrings): boolean;
    function Tag_Abre_e_Fecha(tokens_html: TStrings;
      strIdentificador_Tag: string; uIndice_Inicio: integer;
      uIndice_Fim: integer; out uIndice_Tag: integer): boolean;
    function Validar_Jogo(strJogo: string): boolean;
    function Validar_Url_do_Jogo(strUrl: string; link_url: string): boolean;
    { private declarations }
  public
    { public declarations }
  end;

implementation

uses uHtml_Analisador;



{$R *.lfm}

{ TfrmIntralot_Extrator }

function TFrmIntralot_Extrator.gerar_url_por_numero_do_jogo(
  var strUrl_do_Jogo: string; strJogo: string; iJogo_Inicial: integer;
  iJogo_Final: integer): boolean;
begin
  if not Validar_Jogo(strJogo) then
  begin
    strErro := 'Jogo inválido.';
    Exit(False);

  end;

  // Vamos criar a url do jogo:
  strUrl_do_Jogo := 'http://www.intralot.com.br/newsite/resultados/?';
  strUrl_do_jogo := strUrl_do_Jogo + Format(
    'jogo=%s&busca=numero&range=%d-%d', [strJogo, iJogo_Inicial, iJogo_Final]);
  Exit(True);
end;

function TFrmIntralot_Extrator.gerar_url_por_data_do_jogo(var strUrl_do_Jogo: string;
  strJogo: string; strData_Inicial: string; strData_Final: string): boolean;
begin
  if not Validar_Jogo(strJogo) then
  begin
    strErro := 'Jogo inválido.';
    Exit(False);
  end;

  // Vamos criar a url do jogo:
  strUrl_do_Jogo := 'http://www.intralot.com.br/newsite/resultados/?';
  strUrl_do_jogo := strUrl_do_Jogo + Format(
    'jogo=%s&busca=data&range=%s-%s', [strJogo, strData_Inicial, strData_Final]);
  Exit(True);
end;


// Esta função valida se o jogo está correto.
function TfrmIntralot_Extrator.Validar_Jogo(strJogo: string): boolean;
begin
  strJogo := LowerCase(strJogo);

  case strJogo of
    'todos':
      Result := True;
    'keno-minas':
      Result := True;
    'minas-5':
      Result := True;
    'multplix':
      Result := True;
    'loto-minas':
      Result := True;
    'totolot':
      Result := True;
    else
      Result := False;
  end;

end;


procedure TfrmIntralot_Extrator.btnAbrirDiretorioClick(Sender: TObject);
begin
  dlgDiretorio.InitialDir := '.';
  if dlgDiretorio.Execute then
  begin

    edDiretorio.Text := dlgDiretorio.FileName;
  end;
end;

procedure TfrmIntralot_Extrator.btnGerar_por_DataClick(Sender: TObject);
var
  strData_Inicial: string;
  strData_Final: string;
  strUrl_do_Jogo: string;
begin
  // Converte o nome do jogo para ser enviado pela url.
  strJogo_Tipo := cmbJogoTipo.Text;
  if not Formatar_jogo_para_url(strJogo_Tipo) then
  begin
    MessageDlg('Erro', 'Jogo inválido: ' + strJogo_Tipo, TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  // Vamos converter a data inicial e final para um tipo string.
  try
    strData_Inicial := FormatDateTime('ddmmyyyy', dtData_Inicial.Date);
    strData_Final := FormatDateTime('ddmmyyyy', dtData_Final.Date);
  except
    On exc: Exception do
    begin
      MessageDlg('Erro', 'Erro: ' + exc.Message, tMsgDlgtype.mtError, [mbOK], 0);
      Exit;
    end;
  end;

  strIntervalo := 'de_' + FormatDateTime('dd_mm_yyyy', dtData_Inicial.Date) +
    '_a_' + FormatDateTime('dd_mm_yyyy', dtData_Final.Date) + '_';

  strUrl_do_Jogo := '';

  gerar_url_por_data_do_jogo(strUrl_do_jogo, strJogo_Tipo, strData_Inicial,
    strData_Final);

  if not Gerar_ARquivos_dos_jogos(strUrl_do_jogo) then
  begin
    MessageDlg('Erro', strErro, tMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  MessageDlg('', 'Gerado com sucesso!!!', tmsgDlgtype.mtInformation, [mbOK], 0);

end;

procedure TfrmIntralot_Extrator.btnGerar_por_jogoClick(Sender: TObject);
var
  strUrl_do_Jogo: string;
  iJogo_Inicial: integer;
  iJogo_Final: integer;
begin
  // Converte o nome do jogo para ser enviado pela url.
  strJogo_Tipo := cmbJogoTipo.Text;
  if not Formatar_jogo_para_url(strJogo_Tipo) then
  begin
    MessageDlg('Erro', 'Jogo inválido: ' + strJogo_Tipo, TMsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;

  // Vamos pegar os valores referente ao jogo inicial e final.
  try
    iJogo_Inicial := StrToInt(trim(edJogo_Inicial.Text));
    iJogo_Final := StrToInt(trim(edJogo_Final.Text));
  except
    On exc: Exception do
    begin
      MessageDlg('Erro', 'Erro: ' + exc.Message, tMsgDlgType.mtError, [mbOK], 0);
      Exit;
    end;
  end;

  strIntervalo := format('intervalo_de_%.5d_a_%.5d_', [iJogo_inicial, iJogo_final]);

  // Vamos gerar a url do jogo:
  strUrl_do_Jogo := '';
  Gerar_url_por_numero_do_jogo(strUrl_do_Jogo, strJogo_Tipo, iJogo_Inicial, iJogo_Final);

  if not Gerar_Arquivos_dos_Jogos(strUrl_do_Jogo) then
  begin

    MessageDlg('Erro', strErro, TmsgDlgType.mtError, [mbOK], 0);
    Exit;
  end;


  MessageDlg('', 'Gerado com sucesso!!!', tmsgDlgtype.mtInformation, [mbOK], 0);

end;

procedure TfrmIntralot_Extrator.btn_Parar_JogoClick(Sender: TObject);
begin
  bParar_Extracao := True;
end;


// Esta função pega o nome do jogo que está na caixa de combinação: jogotipo
// e converte o nome do jogo para o nome do jogo que é utilizado na url.
// Estamos implementando somente os jogos 'Minas 5', 'Loto Minas' e 'Keno Minas'.
// Os 2 outros jogos, Totolot, não será implementando pois o jogador escolhe bilhete
// com o número já escolhido e, Multiplix, será em breve implementado.
function TFrmIntralot_Extrator.Formatar_Jogo_para_url(var strJogo: string): boolean;
begin
  case LowerCase(strJogo) of
    'minas 5': strJogo := 'minas-5';
    'keno minas': strJogo := 'keno-minas';
    'loto minas': strJogo := 'loto-minas';
    else
      Exit(False);
  end;
  Exit(True);
end;

function TFrmIntralot_Extrator.Criar_Diretorio: boolean;
var
  strDiretorio: TCaption;
  strData_Hora: string;
begin
  // Vamos retornar ao diretório do aplicativo.
  SetCurrentDir(diretorio_do_aplicativo);

  // Vamos criar a pasta primeiro.
  strDiretorio := edDiretorio.Text;
  if not DirectoryExists(strDiretorio) then
  begin
    strErro := 'Diretório inexistente.';
    Exit(False);
  end;

  {$IFDEF UNIX}
  if not AnsiEndsStr('/', strDiretorio) then
    strDiretorio := strDiretorio + '/';
  {$ELSE}
  if not AnsiEndStr('\', strDiretorio) then
    strDiretorio := strDiretoiro + '\';
  {$ENDIF}

  strData_Hora := FormatDateTime('YYYY_MM_DD-HH_NN', Now);
  strDiretorio := strDiretorio + strData_Hora;

  // Vamos tentar criar o diretório.
  try
    if not DirectoryExists(strDiretorio) then
      MkDir(strDiretorio);
  except
    On exc: Exception do
    begin
      strErro := exc.Message;
      Exit(False);
    end
  end;

  // Vamos tentar definir o diretório corrente para o Diretório que criarmos.
  if not SetCurrentDir(strDiretorio) then
  begin
    strErro := 'Não foi possível acessar o diretório: ' + strDiretorio;
  end;
  Exit(True);
end;

function TFrmIntralot_Extrator.Gerar_Arquivos_dos_Jogos(strUrl_do_jogo: string): boolean;
var
  lista_de_urls: TStrings;
  objTokens: Tfb_Tokenizador_Html;
  resultado_dos_jogos: TStrings;
  objIntralot_Resultados: Tfb_Intralot_Resultados;
  tokens_html: TStrings;
  iA: integer;
  strConteudo_html: string;
  lista_de_conteudo_html: TStrings;
begin
  lista_de_urls := TStrings(TStringList.Create);
  if not paginador(strUrl_do_jogo, lista_de_urls) then
  begin
    Exit(False);
  end;

  // Se após executar a função acima, a variável lista_de_urls, estiver vazia
  // então, quer dizer que não há página.
  // Então, devemos adicionar a url do jogo.
  if lista_de_urls.Count = 0 then
  begin
    lista_de_urls.Add(strUrl_do_Jogo);
  end;

  // Vamos criar o diretório se não existe e criar uma pasta com a data e horário atual.
  if not Criar_Diretorio then
  begin
    Exit(False);
  end;


  // Vamos criar o objeto TidHttp
  objHttp := TIdHttp.Create;
  objHttp.AllowCookies := True;
  objHttp.HandleRedirects := True;

  resultado_dos_jogos := TStrings(TStringList.Create);
  objIntralot_Resultados := Tfb_Intralot_Resultados.Create;
  objTokens := TFb_Tokenizador_Html.Create;
  tokens_html := TStrings(TStringList.Create);

  lista_de_conteudo_html := TStrings(TStringList.Create);

  mmLog.Clear;
  mmLog.Lines.Add('');


  iA := 0;
  while iA <= lista_de_urls.Count - 1 do
  begin
    try
      mmLog.Lines[0] := Format('Lendo: %.5d de %.5d', [iA + 1, lista_de_urls.Count]);
      mmLog.refresh;


      lista_de_conteudo_html.Add(objHttp.Get(lista_de_urls[iA],
        IndyTextEncoding_UTF8));

      objHttp.Disconnect;
    except
      On exc: Exception do
      begin
        if MessageDlg('Erro', 'Erro: ' + exc.Message + #13#10 +
          'Continuar.', TMsgDlgType.mtError, [mbYes, mbNo], 0) = mrYes then
          Dec(iA, 1)
        else
          Inc(iA, lista_de_urls.Count);
      end;
    end;
    Inc(iA);
    self.Refresh;

    // O usuário pressionou o botão de parar.
    if bParar_Extracao then
    begin
      if MessageDlg('',
        'Você deseja realmente, para o download das informações do site da intralot.',
        tMsgDlgType.mtInformation, [mbYes, mbNo], 0) = mrYes then
      begin
        bParar_Extracao := False;
        break;
      end
      else
      begin
        bParar_Extracao := False;
      end;
    end;
  end;




  // Vamos percorrer cada conteúdo e gerar os arquivos.
  //for iA := 0 to lista_de_urls.Count - 1 do begin

  iA := 0;
  while iA <= lista_de_conteudo_html.Count - 1 do
  begin
    mmLog.Lines[0] := Format('Lendo: %.5d de %.5d', [iA + 1, lista_de_urls.Count]);
    mmLog.Refresh;

    strConteudo_html := lista_de_conteudo_html.Strings[iA];

    if not objTokens.Analisar_Html(strConteudo_Html, tokens_html) then
    begin
      strErro := 'Não foi possível tokenizar o conteúdo html.';
      Exit(False);
    end;

    // Vamos analisar os tokens html e gerar o conteúdo do jogo.
    if not objIntralot_Resultados.extrair(resultado_dos_jogos, tokens_html) then
    begin
      strErro := 'Erro: ' + objIntralot_Resultados.ultimo_erro;
      mmLog.Lines.Add('Último erro: ' + strErro);
      Exit(False);
    end;

    // Vamos salvar os dados em um arquivo.
    resultado_dos_jogos.SaveToFile('jogo_' + strJogo_Tipo + '_' +
      strIntervalo + 'pagina_' +
      Format('%.4d', [iA + 1]) + '.csv');

    // Vamos apagar os resultados.
    resultado_dos_jogos.Clear;
    tokens_html.Clear;

    Inc(iA);
  end;
  mmLog.Lines.Add('Concluído com sucesso.');

  FreeAndNil(objHttp);
  FreeAndNil(objTokens);
  FreeAndNil(objIntralot_Resultados);
  FreeAndNil(resultado_dos_jogos);
  FreeAndNil(tokens_html);


  // Vamos alterar novamente para o diretório do aplicativo.
  SetCurrentdir(diretorio_do_aplicativo);

  Exit(True);
end;



procedure TfrmIntralot_Extrator.edDiretorioChange(Sender: TObject);
begin
  // Se o usuário não seleciona um diretório, ou deixa em branco, desativar controles.
  if Trim(edDiretorio.Text) = '' then
  begin
    self.btnGerar_por_jogo.Enabled := False;
    self.btnGerar_por_Data.Enabled := False;
  end
  else
  begin
    btnGerar_por_Jogo.Enabled := True;
    btnGerar_por_Data.Enabled := True;
  end;
end;

procedure TfrmIntralot_Extrator.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  FreeAndNil(mmLog);
end;

procedure TfrmIntralot_Extrator.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
end;

procedure TfrmIntralot_Extrator.FormCreate(Sender: TObject);
begin
  // Ao criar formulário, iremos adicionar os tipos de jogos á caixa de combinação.
  cmbJogoTipo.Items.Add('Minas 5');
  cmbJogoTipo.Items.Add('Loto Minas');
  cmbJogoTipo.Items.Add('Keno Minas');

  cmbJogoTipo.ItemIndex := 0;

  // Vamos definir o diretório para extração de jogos;
  edDiretorio.Text := './intralot/';

  // Vamos definir o diretório do aplicativo, pois quando alterarmos o diretório
  // corrente, devemos retornar ao diretório anterior.
  diretorio_do_aplicativo := GetCurrentDir;

  // Definir a data inicial para hoje.
  dtData_Inicial.Date := Now;
  dtData_Final.Date := Now;
  ;
end;

// Esta função verifica se a página html tem mais de uma, se tiver retorna todas as urls de
// cada página, na lista de string: 'lista_de_urls'.
function TFrmIntralot_Extrator.Paginador(strUrl: string;
  var lista_de_urls: TStrings): boolean;
var
  objToken: Tfb_Tokenizador_Html;
  tokens_html: TStrings;
  conteudo_html: string;
  uIndice: integer;
  uIndice_Final: integer;
  uIndice_Tag_Pagination_Final: integer;
  contador_de_paginas: integer;
  uIndice_Tag_UL_Final: integer;
  link_url: string;
  uPagina_Numero_Final: integer;
  iA: integer;
  tokens_temp: TStrings;
  pagina_estado: integer;
  ultima_pagina: integer;
begin
  if strUrl = '' then
  begin
    strErro := 'Erro, url inválida.';
    Exit(False);
  end;

  // Vamos baixar o conteúdo html e verificar se há página.
  if Assigned(objHttp) then
    objHttp.FreeInstance;

  objHttp := TIdHttp.Create;
  objHttp.AllowCookies := True;
  objHttp.HandleRedirects := True;
  try
    conteudo_html := objHttp.Get(strUrl, IndyTextEncoding_UTF8);
  except
    On exc: Exception do
    begin
      strErro := exc.Message;
    end;
  end;

  tokens_html := TStrings(TStringList.Create);

  // Vamos criar o objeto para analisar os tokens e retornar.
  objToken := Tfb_Tokenizador_Html.Create;

  // A função retorna o conteúdo html, separado em tokens html.
  // Será falso, se houver erro.
  if not objToken.Analisar_Html(conteudo_html, tokens_html) then
    Exit(False);

  tokens_temp := TStrings(TStringList.Create);
  tokens_temp.Assign(tokens_html);

  for iA := 0 to tokens_temp.Count - 1 do
  begin
    tokens_temp[iA] := Format('[%.8d]' + tokens_temp[iA], [iA]);
  end;

  tokens_temp.SaveToFile('tokens_paginador.txt');
  tokens_html.SaveToFile('tokens_html_2.txt');
  tokens_temp.Clear;
  FreeAndNil(tokens_Temp);


  // Vamos verificar se o conteúdo html tem o tag abaixo.
  // <div class="pagination">
  // Se houver tal tag, quer dizer que o intervalo de jogos não coube em única
  // página html, então devemos verificar quantas páginas são.
  // O que foi observado é que no contéudo html é apresentado a página atual
  // e um link para cada página seguinte, até um total de 8, mais a última página.
  // Se há mais de uma página, a url é codificada acrescentando '&page=' + o número da
  // página, por exemplo:

  // http://www.intralot.com.br/newsite/resultados/?jogo=minas-5&busca=numero&range=1-800&page=5

  // Então, no contéudo html, onde fica os links o layout é:
  // <div class="pagination">
  //      <ul>
  //          <li>1</li>
  //          <li>
  //              <a href="http://www.intralot.com.br/newsite/resultados/?jogo=minas-5&busca=numero&range=1-2000&page=2">2</a>
  //          </li>

  //          <li>
  //              <a href="http://www.intralot.com.br/newsite/resultados/?jogo=minas-5&busca=numero&range=1-2000&page=3">3</a>
  //          </li>

  //          Pode-se observar que o primeiro valor entre os tags'<li>' e '</li>', não indica um link, pois, é a página html
  //          atual.
  //          Para os próximos tags '<li>' e '</li>', indica um link.
  //          Pode-se observar que varia somente é o número da página que fica após '&page'.
  //          Se houver mais de 8 páginas, em uma única página html, haverá:
  //          1 tag '<li>' e '</li>', que indica a página atual, conforme descrito acima, entre
  //          tais tags, terá um número que indica a página atual do conteúdo html.
  //          7 tags '<li>' e '</li>', entre tais tags haverá o link para a próxima página.
  //          1 tag  '<li>' e '</li>', que indica a última página do intervalo de jogo.
  //          Entretanto, o tag de indica a última página ele tem um layout um pouco diferente, segue-se abaixo:

  //          <li style="margin-left:16px;">
  //              <a href="http://www.intralot.com.br/newsite/resultados/?jogo=minas-5&busca=numero&range=1-2000&page=76">76</a>
  //          </li>

  //          O que nosso algoritmo fará, vai verificar se há o tag: '<div class="pagination"> existe.
  //          Se existe, iremos percorrer cada contéudo entre os tags '<li>' e '<li>', para pegar
  //          o link das próximas páginas.
  //          Se o intervalo do jogo, gerar até 8 páginas, já temos todas as 8 urls, que precisamos.
  //          Entretanto, se houver mais de 8 páginas, simplesmente, iremos, identificar a última página e pronto.
  //          Não precisaremos abrir outros links para pegar as próximas páginas, simplesmente, iremos gerar
  //          automaticamente todas as páginas até chegar ao final.

  // Vamos verificar se há o tag abaixo:
  // <div class="pagination">

  // Vamos apontar para o primeiro '<div'.
  uIndice := tokens_html.IndexOf('<div');
  uIndice_Final := tokens_html.Count - 1;

  // Se retorna -1, quer dizer, que não há nem página, nem conteúdo das bolas.
  if uIndice = -1 then
  begin
    strErro := 'Não há o tag ''<div''.';
    Exit(False);
  end;

  // Vamos procurar os tokens: <div class="pagination">
  while uIndice <= uIndice_Final do
  begin
    if (tokens_html[uIndice + 0] = '<div') and
      (tokens_html[uIndice + 1] = 'class') and
      (tokens_html[uIndice + 2] = '=') and
      (tokens_html[uIndice + 3] = '"pagination"') and
      (tokens_html[uIndice + 4] = '>') then
    begin
      // Se encontramos o item, sair do loop.
      break;
    end;
    Inc(uIndice, 1);
  end;

  // Vamos verificar se a lista_de_url já foi criada, senão, iremos criá-la e inserir
  // a primeira url.
  if not Assigned(lista_de_urls) then
    lista_de_urls := TStrings(TStringList.Create);

  // O primeiro item da lista é a url fornecido no parâmetro.
  // lista_de_urls.Add(strUrl);

  // Se uIndice é maior que uIndice_Final, não encontramos nenhuma paginação, quer dizer
  // que o conteúdo cabe em uma única página.
  if uIndice > uIndice_Final then
  begin
    Exit(True);
  end;

  // Agora, devemos encontrar o tag de fechamento que corresponde ao tag: '<div class="pagination">
  uIndice_Tag_Pagination_Final := 0;

  if not tag_abre_e_fecha(tokens_html, 'div', uIndice, uIndice_Final,
    uIndice_Tag_Pagination_Final) then
  begin
    strErro := 'Tag ''</div>'' não localizado.';
    Exit(False);
  end;

  // Vamos fazer uIndice apontar após os tokens '"pagination"' e '>', ou seja,
  // apontará para '<ul>'
  Inc(uIndice, 5);

  // Se o tag não é '<ul>', é um erro.
  if tokens_html[uIndice] <> '<ul>' then
  begin
    strErro := 'Tag ''<ul>'' não localizados após o token ' +
      QuotedStr('"pagination"') + '>';
    Exit(False);
  end;

  // Se encontrarmos o tag '<ul>', devemos encontrar o tag de fechamento correspondente.
  // Tal tag fica antes do tag '</div>' que fecha o tag '<div class="pagination">'.
  if tokens_html[uIndice_Tag_Pagination_Final - 1] <> '</ul>' then
  begin
    strErro :=
      'Tag ''</ul>'' não localizado dentro do tag ''<div class="pagination">'' ... </div>';
    Exit(False);
  end;

  // Aqui, uIndice aponta para '<ul>', devemos apontar um token depois
  // O próximo token é '<li'>
  Inc(uIndice, 1);

  contador_de_paginas := 1;

  // Vamos percorrer cada conteúdo entre '<li>' e '</li>'.
  // No loop abaixo, iremos percorrer todo o conteúdo que está entre os tags: '<ul>' e '</ul>'

  // O tag de fechamento '</ul>', está um token antes do tag de fechamento '</div>' do tag
  // <div class="pagination">.
  // Nós não precisamos verificar pois fizermos no último if anterior.
  uIndice_Tag_UL_Final := uIndice_Tag_Pagination_Final - 1;

  // Aqui, a condição do loop é menor e não menor e igual, pois se for igual
  // no fim do loop, iremos apontar para o tag: '</ul>', que indicaria um erro.

  // Para conseguir analisar o contéudo do páginador iremos criar três estados
  // pagina_estado = 1, a primeira página
  // pagina_estado = 2, a segunda página mas não a última
  // pagina_estado = 3, a última página.

  // O primeiro estado, é a primeira página, se há mais de 1 página, devemos verificar
  // se a próxima página é a página seguinte ou se é a última página.
  pagina_estado := 1;

  tokens_temp := TStrings(TStringList.Create);
  for iA := 0 to tokens_html.Count - 1 do
  begin
    tokens_temp.Add(Format('[%10.d] %s', [iA, tokens_html.Strings[iA]]));
  end;
  tokens_Temp.SaveToFile('tokens_html.txt');

  FreeAndNil(tokens_Temp);


  //ultima_pagina := 1;

  while uIndice < uIndice_Tag_ul_final do
  begin
    // O primeiro estado é a primeira página
    case pagina_estado of
      1:
      begin
        if not ((tokens_html[uIndice] = '<li>') and (tokens_html[uIndice + 1] = '1') and
          (tokens_html[uIndice + 2] = '</li>')) then
        begin
          strErro := 'Era esperado os tokens da primeira página: <li>1</li>';
          exit(False);
        end;
        // Aponta após '</li>'.
        Inc(uIndice, 3);

        // Definir a variável link_url.
        // link_url, sempre tem aspas duplas
        link_url := '"' + strUrl + '&page=1' + '"';
        if not Validar_Url_do_jogo(strUrl, link_url) then
        begin
          strErro := 'Url inválida.';
          Exit(False);
        end;


        // Vai para o próximo estado.
        pagina_estado := 2;
        Continue;
      end;

      // O estado 2, indica as páginas que estão entre as página inicial e final.
      2:
      begin
        if not ((tokens_html[uIndice + 0] = '<li>') and
          (tokens_html[uIndice + 1] = '<a') and
          (tokens_html[uIndice + 2] = 'href') and
          (tokens_html[uIndice + 3] = '=') and
          // Na posição uIndice + 4, indica o link da página.
          (tokens_html[uIndice + 5] = '>') and
          // Na posição uIndice + 6, indica o número da página, iremos analisar posteriormente,
          // para ver se é um número válido.
          (tokens_html[uIndice + 7] = '</a>') and
          (tokens_html[uIndice + 8] = '</li>')) then
        begin
          // Se os tokens acima não são encontrados vamos verificar, se é a última página.
          pagina_estado := 3;
          Continue;
        end;
        // O campo na posição uIndice + 4, refere-se ao link para a próxima página.
        link_url := tokens_html[uIndice + 4];

        if not Validar_Url_do_jogo(strUrl, link_url) then
        begin
          strErro := 'Url inválida.';
          Exit(False);
        end;

        Inc(uIndice, 9);
      end;

      // Só chegaremos aqui, se no estado 2, os tokens não forem localizados.
      3:
      begin
        if not ((tokens_html[uIndice + 0] = '<li') and
          (tokens_html[uIndice + 1] = 'style') and
          (tokens_html[uIndice + 2] = '=') and
          (tokens_html[uIndice + 3] = '"margin-left:16px;"') and
          (tokens_html[uIndice + 4] = '>') and
          (tokens_html[uIndice + 5] = '<a') and
          (tokens_html[uIndice + 6] = 'href') and
          (tokens_html[uIndice + 7] = '=') and
          // O índice uIndice + 8, refere-se ao link para a próxima página.
          (tokens_html[uIndice + 9] = '>') and
          // O índice uIndice + 10 refere-se ao número da página.
          (tokens_html[uIndice + 11] = '</a>') and
          (tokens_html[uIndice + 12] = '</li>')) then
        begin
          strErro := 'Erro, era esperado os tokens nesta ordem: ' +
            '''<li style="margin-left:16px;">' +
            #13#10 + 'a href='' + url da próxima página + ''>''' +
            'número do jogo + ''</a>''';
          Exit(False);
        end;

        link_url := tokens_html[uIndice + 8];

        if not Validar_Url_do_jogo(strUrl, link_url) then
        begin
          strErro := 'Url inválida.';
          Exit(False);
        end;



        // Vamos apontar após o token: '</li>'
        Inc(uIndice, 13);

        // Vamos apontar para o próximo estado, 4
        // Entretanto, o estado 3, sempre é o última página,
        // Após o token '</li>', o loop deve terminar, senão, quer dizer, que há um erro.
        pagina_estado := 4;
      end;
      4:
      begin
        strErro :=
          'Era esperado o token ''</div>'' após o token ''</li>'' de da última página';
        Exit(False);
      end;
    end;

  end;

  // Aqui, iremos pegar a última página gerada do html.

  // Retirar aspas duplas.
  link_url := MidStr(link_url, 2, Length(link_url));
  link_url := Midstr(link_url, 1, Length(link_url) - 1);


  // Vamos apontar após '&page='
  link_url := MidStr(link_url, AnsiPos('&page=', link_url), Length(link_url));
  link_url := MidStr(link_url, 7, Length(link_url));
  link_url := Trim(link_url);

  // Vamos tentar converter em número
  // uPagina_Numero_Final refere-se ao número da última página.
  try
    uPagina_Numero_Final := StrToInt(link_url);
  except
    On exc: Exception do
    begin
      strErro := 'Erro, ' + exc.Message;
      Exit(False);
    end;
  end;

  // Vamos percorrer de 8 ao número final de página
  // Vamos gerar as links automaticamente.
  for iA := 1 to uPagina_Numero_Final do
  begin
    link_url := Format(strUrl + '&page=%d', [iA]);
    lista_de_urls.Add(link_url);
  end;


  Exit(True);
end;

{
    Função: Validar_Url_do_Jogo
    Parâmetros:
               strUrl: string;    Url do jogo a validar.

}

function TfrmIntralot_Extrator.Validar_Url_do_Jogo(strUrl: string;
  link_url: string): boolean;
var
  esquerda_url: string;
begin
  // Vamos retirar as aspas, se não há aspas, indicar erro.
  if (AnsiLeftStr(link_url, 1) <> '"') or (AnsiRightStr(link_url, 1) <> '"') then
  begin
    strErro := 'Aspa dupla não localizada, toda valor da propriedade ' +
      'na forma propriedade=valor, deve estar entre aspas.';
    Exit(False);
  end;

  // Vamos retirar as aspas duplas.
  link_url := MidStr(link_url, 2, Length(link_url));
  link_url := MidStr(link_url, 1, Length(link_url) - 1);

  // Vamos verificar se todos os caracteres de link_url até a quantidade
  // de caracteres iguais a strUrl é igual a strUrl, isto ocorre, pois
  // o que se altera é somente a parte final, onde é acrescentado
  // a palavra '&page=' + a posição da página.
  esquerda_url := LeftStr(link_url, Length(strUrl));


  if esquerda_url <> strUrl then
  begin
    strErro := 'Erro: Os primeiros ' + IntToStr(Length(strUrl)) +
      ' caracteres de ' + link_url + ' devem ser igual a ' + strUrl;
    Exit(False);
  end;

  // Vamos verificar se tem a palavra page.
  if Midstr(link_url, Length(strUrl) + 1, Length('&page=')) <> '&page=' then
  begin
    strErro := 'Erro, ''&page='' não localizado após ' + strUrl;
    Exit(False);
  end;

  // Vamos apontar para a palavra '&page'
  link_url := MidStr(link_url, AnsiPos('&page=', link_url), Length(link_url));

  // Vamos apontar após a palavra '&page='
  link_url := MidStr(link_url, 7, Length(link_url));

  // Vamos retirar espaços vazios.
  link_url := Trim(link_url);

  // Vamos converter em números, se não for possível, indicar um erro.
  try
    StrToInt(link_url);
  except
    On exc: Exception do
    begin
      strErro := 'Erro, ' + exc.Message;
      Exit(False);
    end;
  end;

  Exit(True);
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

    Os parâmetros são:
    tokens_html:                  O token a analisar.
    strIdentificador_Tag:         O identificador do tag a localizar.
    uIndice_Inicio:               O índice em tokens_html, em que a pesquisa começará.
    uIndice_Fim:                  O índice final em tokens_html, baseado em zero, em que a pesquisa terminará.
    uIndice_Tag:                  O índice em tokens_html, que o tag de fechamento correspondente foi localizado.

}
function TfrmIntralot_Extrator.Tag_Abre_e_Fecha(tokens_html: TStrings;
  strIdentificador_Tag: string; uIndice_Inicio: integer; uIndice_Fim: integer;
  out uIndice_Tag: integer): boolean;
var
  iA: integer;
  uTokens_Quantidade: integer;
  iTag_Div_Qt: integer;
begin
  // Vamos validar a informação entrada pelo usuário nos campos:
  // uIndice_Inicio e uIndice_Fim.

  if uIndice_Fim < uIndice_Inicio then
  begin
    strErro := 'Índice final menor que índice inicial.';
    Exit(False);
  end;

  if uIndice_Inicio < 0 then
  begin
    strErro := 'Índice inicial menor que zero.';
    Exit(False);
  end;

  // uIndice_Fim é baseado em zero, então deve ser menor que count -1.
  if uIndice_Fim > tokens_html.Count then
  begin
    strErro := 'Índice final maior que quantidade de ítens em tokens_html.';
    Exit(False);
  end;

  // iA, apontará para a posição que começaremos a escanear,
  // que corresponde a uIndice_Inicio;
  iA := uIndice_Inicio;
  uTokens_Quantidade := uIndice_Fim;

  // Deve haver um balanceamento entre todos os tags html
  // Neste caso, estamos verificando somente o tag '<div'
  iTag_Div_Qt := 0;

  while iA <= uTokens_Quantidade do
  begin

    if tokens_html.Strings[iA] = '<div' then
    begin
      // Quando em html, encontramos um tag, iniciando, por exemplo
      // '<div', isto quer dizer, que entre '<div' e '>', há propriedades
      // na forma propriedade=valor, então devemos localizar o token
      // '>', mas entre o token '<div' e '>', não pode haver token
      // nestes formatos: '<teste', '</teste>' e '<teste>'
      Inc(iA);

      while iA <= uTokens_Quantidade do
      begin
        // Temos que utilizar esta condição primeiro
        // Senão, quando entrar na condição abaixo dará um erro
        // pois, na segunda condição abaixo, estamos verificando
        // as extremidades esquerda e direita do string a procura
        // do caractere '<', e se o token for um único caractere,
        // a condição será satisfeita.
        if tokens_html.Strings[iA] = '>' then
        begin
          Inc(iTag_Div_Qt);
          Break;
        end;

        if (AnsiStartsStr('<', tokens_html.Strings[iA]) = True) or
          (AnsiEndsStr('>', tokens_html.Strings[iA]) = True) or
          ((AnsiStartsStr('<', tokens_html.Strings[iA]) = True) and
          (AnsiEndsStr('>', tokens_html.Strings[iA]) = True)) then
        begin

          strErro := 'Propriedade do tag ''<div'' inválida ' +
            'provavelmente, faltou o caractere ' + 'antes da propriedade.';
          Exit(False);

        end;
        Inc(iA);
      end;
    end;

    if tokens_html.Strings[iA] = '<div>' then
    begin
      Inc(iTag_Div_qt);
    end;
    if tokens_html.Strings[iA] = '</div>' then
    begin
      Dec(iTag_Div_Qt);
    end;

    // Se igual a zero, quer dizer, que encontramos nosso nosso
    // tag de fechamento.
    if iTag_Div_Qt = 0 then
    begin
      uIndice_Tag := iA;
      Exit(True);
    end;

    // Ao sair do loop, iA, sempre apontará para o tag de fechamento,
    // pois, se 'iTag_Div_Qt' é igual a zero, não haverá incremento
    // da variável iA.
    Inc(iA);
  end;

  if iTag_Div_Qt <> 0 then
    Result := False;

end;

end.
