program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  RegExpr;

const MassiveOfOperators: array [1..47] of string =('[^+][+][^+,=]','[^-][-][^-,=]','[*][^=]','[/][^=]','[%][^=]','\+\+','\+\=',
                                                '[^>,<,!,=,+,-,*,\/,%,&,^,|][=][^=]','\-\=','\*\=','\/\=','\%\=','\-\-',
                                                '\~','[^&][&][^=,&]','[^|][|][^=,|]','[\^][^=]','\>{2}[^=]','\>{3}[^=]',
                                                '\<{2}[^=]','\&\=','\|\=','\^\=','>>=','>>>=','<<=','==','\!\=',
                                                '[^>][>][^>,=]','[^<][<][^<,=]','[^>]>=','[^<]<=','\|\|','\&\&',
                                                '[!][^=]',' instanceof ','[(, ]byte ','[(, ]short ','[(, ]int ',
                                                '[(, ]long ','[(, ]float ','[(, ]double ','[(, ]boolean ','[(, ]string ',
                                                '[(, ]char ','[(, ]void ','[(, ]new ');

var
  RegEx,RegExString:TRegExpr;
  InputString:string;
  CountIf,CountOperator,MaximumLevelNest:integer;
  ArrayNamesOfMethods:array of string;
  IsCorrectFileName:boolean;

procedure ReadCodeFromFile();
var
    NewFile:textfile;
    FileName:string;
    Buf:string;
    begin
        FileName:='D:\\Doce.txt';
        if FileExists(FileName) then
          begin
            AssignFile(NewFile,FileName);
            Reset(NewFile);
            while Eof(Newfile)<>true do
              begin
                readln(Newfile,Buf);
                InputString:=InputString + Buf + #13#10;
              end;
               CloseFile(NewFile);
               IsCorrectFileName:=true;
          end
        else
            IsCorrectFileName:=false;
    end;

procedure DeleteCommentsFromCode ();
  begin
    RegEx.ModifierS:=true;
    RegEx.InputString := InputString;
    RegEx.Expression := '(\/[*]{1,2}).*?(\*\/)';
    InputString := RegEx.Replace(InputString,'');
    RegEx.Expression := '(\/\/).*?\n';
    InputString := RegEx.Replace(InputString,'');
    RegEx.ModifierS:=false;
    RegEx.Expression:='(\".*\")|(\''.*\'')';
    InputString := RegEx.Replace(InputString,'');
  end;

function FillVariableBySpaces (SpaceCount:integer):string;
const
  Space = ' ';
var
  IndexSpace:integer;
begin
  Result:='';
  for IndexSpace:=1 to SpaceCount do
    result:=result + Space;
end;

function CheckForElseIf (CheckString:string):boolean;
begin
  Result:=false;
  RegExString.ModifierS:=true;
  RegExString.ModifierI:=true;
  RegExString.Expression:='(else *if)|(\?)';
  if RegExString.Exec(CheckString) then
    Result:=true;
end;

procedure StringReplace (StringPosition,StringLength:integer);
var
  Spaces:string;
begin
  Delete(InputString,StringPosition,StringLength);
  Spaces:=FillVariableBySpaces(StringLength);
  Insert(Spaces,InputString,StringPosition);
end;

procedure FindNumberMaximumlevelIf ();
var
  TempMaximumlevel,Countelseif,Nextposition:integer;
  CheckMatch:string;
  begin
    RegEx.ModifierI:=true;
    RegEx.ModifierS:=true;
    RegEx.Expression := '\bif\b.+?\{';
    RegExString := TRegExpr.Create;

    if regex.Exec(Inputstring) then
      repeat
        inc(CountIf);
        TempMaximumlevel:=1;
        RegEx.Expression:='(\bif\b)|(\}[ ,\n\r\t]*\belse\b[ ,\n\r\t]*[if,{]*)|(\})|(\?)|(\:[^?,:]*?\;)';
        Countelseif:=0;
        repeat
          regex.execpos(regex.MatchPos[0]+regex.MatchLen[0]);

          if MaximumLevelNest < TempMaximumlevel then
            MaximumLevelNest:=TempMaximumlevel;

          CheckMatch:=LowerCase(regex.Match[0]);
          if CheckMatch[1] = ':' then
            begin
              dec(TempMaximumLevel,1);
              dec(CountElseIf,1);
            end

          else if CheckMatch = '}' then
            begin
              dec(TempMaximumlevel,Countelseif+1);
              if Countelseif > 0 then
              Countelseif:=0;
            end

          else if CheckMatch = 'if' then
            begin
              Inc(CountIf);
              inc(TempMaximumlevel);
            end

          else if CheckForElseIf(CheckMatch) then
            begin
              StringReplace(RegEx.MatchPos[0],RegEx.MatchLen[0]);
              inc(CountIf);
              inc(TempMaximumlevel);
              inc(CountElseIf);
            end;
        until TempMaximumlevel=0;

        Nextposition:=regex.MatchPos[0]+regex.MatchLen[0];

        if Nextposition > 0 then
          RegEx.Expression := '\bif\b.+?\{'
        else
          break;
      until not (regex.Execpos(Nextposition));
      RegExString.free;
      inc(CountOperator,CountIf);
  end;

procedure FindNumberTernaryOperator ();
var
    CountTernaryOperator,TempMaximumLevel,NextPosition:integer;
    CheckMatch:string;
begin
  RegEx.ModifierI:=true;
  RegEx.ModifierS:=true;
  RegEx.Expression := '\?.*?\:';
  RegExString := TRegExpr.Create;
  CountTernaryOperator:=0;
  if regex.Exec(Inputstring) then
      repeat
        inc(CountTernaryOperator);
        TempMaximumlevel:=1;
        RegEx.Expression:='\?.*?\:|\;';
        repeat
          regex.execpos(regex.MatchPos[0]+regex.MatchLen[0]);

          if MaximumLevelNest < TempMaximumlevel then
            MaximumLevelNest:=TempMaximumlevel;

          CheckMatch:=LowerCase(regex.Match[0]);
          if CheckMatch[1] = ';' then
            begin
              TempMaximumLevel:=0
            end

            else if CheckMatch[1] = '?' then
                begin
                  Inc(CountTernaryOperator);
                  inc(TempMaximumlevel);
                end
        until TempMaximumlevel=0;

        Nextposition:=regex.MatchPos[0]+regex.MatchLen[0];

        if Nextposition > 0 then
          RegEx.Expression := '\?.*?\:'
        else
          break;
      until not (regex.Execpos(Nextposition));
      RegExString.free;
      inc(CountOperator,CountTernaryOperator);
end;

procedure FindNamesOfMethods ();
const
  ArrayTypesIdentifiers:array [1..10] of string = ('byte','short','int','long','float',
                                                    'double','boolean','string','char','void');
var
  MassiveElementNumber,LetterCount:integer;
  MethodName:string;
begin
  RegEx.ModifierS:=true;
  RegEx.ModifierI:=true;
  for MassiveElementNumber:=1 to length(ArrayTypesIdentifiers) do
    begin
       RegEx.Expression := ArrayTypesIdentifiers[MassiveElementNumber] + '[ ,a-z,0-9,_,\n]*\(';
       if regex.Exec(Inputstring) then
         repeat
           MethodName:=regex.Match[0];
            LetterCount:=length(ArrayTypesIdentifiers[MassiveElementNumber])+1;
           while Methodname[LetterCount] = ' 'do
            inc(LetterCount);
           delete(MethodName,1,LetterCount-1);
            LetterCount:=0;
           while MethodName[length(MethodName)-LetterCount-1] = ' ' do
            inc(LetterCount);
           delete(MethodName,length(methodName)-LetterCount,LetterCount+1);
           setlength(ArrayNamesOfMethods,length(ArrayNamesOfMethods)+1);
           ArrayNamesOfMethods[length(ArrayNamesOfMethods)-1]:=MethodName
         until not (regex.ExecNext);
    end;
end;

procedure FindNumberMethodsCalls ();
var
  MassiveElementNumber:integer;
begin
  for MassiveElementNumber:=1 to length(ArrayNamesOfMethods)-1 do
    begin
      RegEx.Expression:=ArrayNamesOfMethods[MassiveElementNumber];
      if regex.Exec(Inputstring) then
        repeat
          inc(CountOperator);
        until not (regex.ExecNext);
    end;
    if length(ArrayNamesOfMethods) > 0 then
      dec(CountOperator,length(ArrayNamesOfMethods));
end;

procedure FindNumberOperators ();
var
  MassiveElementNumber:integer;
begin
  CountOperator:=0;
  for MassiveElementNumber:=1 to length(MassiveOfOperators) do
    begin
      RegEx.Expression:=MassiveOfOperators[MassiveElementNumber];
      If RegEx.Exec(Inputstring) then
        repeat
          inc(CountOperator);
        until not (regex.ExecNext);
    end;
  FindNumberMethodsCalls();
end;


begin
  SetConsoleCp(1251);
  SetConsoleOutputCP(1251);
  RegEx := TRegExpr.create;
  ReadCodeFromFile();
  if IsCorrectFileName = true then
    begin
      DeleteCommentsFromCode();
      FindNamesOfMethods();
      FindNumberOperators();
      FindNumberMaximumlevelIf();
      Writeln(InputString);
      FindNumberTernaryOperator();
      Writeln('Абсолютная сложность программы = ',CountIf);
      Writeln('Максимальная вложенность операторов условия = ',MaximumLevelNest);
      Writeln('Общее количество операторов = ',CountOperator);
      Writeln('Относительная сложность программы = ', CountIf/CountOperator:0:3);
      readln;
    end
  else
    begin
      Writeln('File not found!');
      Readln;
    end;

end.
