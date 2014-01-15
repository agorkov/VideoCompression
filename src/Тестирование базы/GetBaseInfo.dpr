program GetBaseInfo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  UGlobal in '..\Shared units\UGlobal.pas',
  Math,
  Classes,
  UElem in '..\Shared units\UElem.pas',
  UList in 'UList.pas';

const
  FragLength = UGlobal.ElemH * UGlobal.ElemW * UGlobal.bpp;

procedure LoadData(var L: TRList);
var
  FS: TFileStream;
  tmpFrag: TRElem;
  m: int64;
begin
  InitList(L);
  FS := TFileStream.Create(Paramstr(1) + '.base', fmOpenRead);
  while not(FS.Position >= FS.Size) do
  begin
    FS.Read(tmpFrag, sizeof(TRElem));
    m := tmpFrag.count;
    AddID(L, m, 1);
  end;
  FS.Free;
end;

procedure WriteBaseInfo(L: TRList);
var
  F: TextFile;
  elem: TPElem;
  GlueInd: int64;
begin
  AssignFile(F, Paramstr(1) + '.txt');
  rewrite(F);
  writeln(F, 'Кадр                                   ', UGlobal.PicH, 'x', UGlobal.PicW);
  writeln(F, 'Окно                                   ', UGlobal.ElemH, 'x', UGlobal.ElemW);
  writeln(F, 'Бит на пиксел                          ', UGlobal.bpp);
  writeln(F, 'Количество элементов в передаче        ', GetNFilm(L), ' (', GetNFilm(L) * UGlobal.ElemSize / (UGlobal.PicW * UGlobal.PicH):5:4, ' кадров)');
  writeln(F, 'Количество уникальных элементов в базе ', GetNBase(L));
  writeln(F, 'Энтропия базы                          ', GetEntropy(L):5:4);
  writeln(F, 'Ожидаемая степень сжатия               ', CompLevel(L, 0):5:4);
  GlueInd := FingOptimalGlueInd(L);
  if GlueInd > 0 then
  begin
    writeln(F, 'Исключать из базы элементы <=          ', GetIDbyInd(L, GlueInd));
    writeln(F, 'Ожидаемая степень сжатия               ', FingGlueCompLevel(L, GlueInd):5:4);
  end
  else
    writeln(F, 'Прямая передача кодов неэффективна     ');
  elem := L.DLF^.next;
  while elem <> L.DLL do
  begin
    writeln(F, elem^.ID, ' ', elem^.count);
    elem := elem^.next;
  end;
  CloseFile(F);
end;

var
  L: TRList;

begin
  try
    LoadData(L);
    writeln('Данные считаны. Вычисление энтропии...');
    WriteBaseInfo(L);
  except
    on E: Exception do
      writeln(E.ClassName, ': ', E.Message);
  end;

end.
