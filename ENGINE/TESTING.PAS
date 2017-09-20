program TestPSYCHO;
uses dos,keyb;
var ch:char;
    f:text;
    chyba:boolean;

label 001;

function ReadKey:char;assembler;
asm
 mov ah,01h
 int 21h
 xor ah,ah
end;

procedure TestFile(fl:string);
begin
 assign(f,fl);
 {$I-}
 reset(f);
 {$I+}
 if IOResult<>0 then begin
  write('Nemozem najst subor ',fl,'!'+#13+#10);
  chyba:=true;
  exit;
 end;
 close(f);
end;

begin
 chyba:=false;
 if (ParamStr(1)<>'qwerty0987654321~') and (ParamStr(2)<>'/*-+') then begin
  write('Do psychiatrickej liecebne sa vchadza pomocou suboru SEDLIAK.BAT.'
  +#13+#10);
  ch:=readkey;
  halt(0);
 end;
{ TestFile('TEST.BAT');
 TestFile('SEDLIAK.BAT');
 TestFile('KREDITZ.EXE');
 TestFile('P1234567.EXE');
 TestFile('P123456T.EXE');
 TestFile('SLOVA.PDR');
 TestFile('DONTKNOW.PDR');
 TestFile('STANDARD.PDR');
 TestFile('LIECBA.PDR');
 TestFile('DIAGNOZA.PDR');
 TestFile('MUKUTU.PDR');
 TestFile('PRESENT.PDR');
 TestFile('SEDLIAK.TXT');
 TestFile('KREDITZ.PDR');}
 {$I-}
 assign(f,'test.pdr');
 rewrite(f);
 {$I+}
 if IOResult<>0 then begin
  write('Na disk sa musia dat zapisovat udaje!'+#13+#10);
  chyba:=true;
  goto 001;
 end;
 close(f);
 erase(f);
 001:
 if Lo(DosVersion)<3 then begin
  writeln('SEDLIAK potrebuje MS-DOS minimalne verzie 3.0.');
  chyba:=true;
 end;
 ClearTA;
 if chyba then begin
  ch:=readkey;
  ClearTA;
  halt(1);
 end;
 ClearTA;
end.