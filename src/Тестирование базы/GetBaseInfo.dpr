program GetBaseInfo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UGlobal in '..\Shared units\UGlobal.pas';

var
FileName: string;
f: TextFile;
str: string[UGlobal.FragSize*4];
Elem, Uniq, tmp: int64;
entropy: double;
begin
  try
    if paramcount=1 then
      FileName:=paramstr(1)
    else
    begin
      write('Введите имя базы для проверки: ');
      readln(FileName);
    end;

    Elem:=0; Uniq:=0;
    AssignFile(f,FileName);
    reset(f);
      while not EOF(f) do
      begin
        read(f,str); readln(f,tmp);
        Elem:=Elem+tmp;
        Uniq:=Uniq+1;
      end;
    CloseFile(f);
    writeln('Уникальных фрагментов - ', Uniq);
    writeln('Всего фрагментов - ', Elem);
    writeln('В базе хранится информация о ', Elem/(UGlobal.FrameBaseSize):1:2,' кадрах');

    entropy:=0;
    reset(f);
      while not EOF(f) do
      begin
        read(f,str); readln(f,tmp);
        entropy:=entropy+(-tmp/Elem*(ln(tmp/Elem)/ln(2)));
      end;
    CloseFile(f);
    writeln('Энтропия - '+FloatToStrF(entropy,ffFixed,7,7));

    //FileName:='TR_'+FileName;
    AssignFile(f,'result.txt');
    if FileExists('result.txt') then
      Append(f)
    else
      rewrite(f);

    delete(FileName,pos('.',FileName),length(FileName));
    writeln(f,FileName+' '+inttostr(Elem)+' '+inttostr(Uniq)+' '+FloatToStrF(entropy,ffFixed,7,7));
    CloseFile(f);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
