program ltk;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  cmem,
  {$ENDIF}{$ENDIF}
  cthreads,
  cmem,
  Interfaces, // this includes the LCL widgetset
  Forms, uLtk, dmLtk, ugerador_aleatorio, uBanco_de_Dados, lazcontrols,
	uAtualizar, uConversor_Minas5, uHtml_Analisador, uLotofacil,
	ugerador_permutacao, uPermutador_Thread, uintralot_extrator,
uIntralot_extrator_de_resultados, gerador_de_arranjo, uLotofacilGerador;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TdmModulo, dmModulo);
  Application.CreateForm(TfrmGerador_Aleatorio, frmGerador_Aleatorio);
  Application.CreateForm(TfrmAtualizar, frmAtualizar);
			//Application.CreateForm(TfrmIntralot_Extrator, frmIntralot_Extrator);
   {
  Application.CreateForm(TfrmGerador_Combinacao,
 				    frmGerador_Combinacao);
}
  //Application.CreateForm(TfrmBanco_de_Dados, frmBanco_de_Dados);
  Application.Run;
end.

