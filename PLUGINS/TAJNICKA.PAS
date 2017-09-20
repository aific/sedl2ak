{$A-,B-,D-,E+,F+,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,0,55360}
program PlugIn;
uses tsuntd,stringy,crt2,dos;
var bck,tc,kac,pac,zvuk,pacient,poz,energia,uhadnute,x,l_energia:byte;
    f:file of byte;
    dir,strn,tema,on_screen,str1,str11,en:string;
    ch:char;
    reg:registers;
label 001;

procedure GotoXY(x,y:byte);assembler;
asm
       mov ah,02h
       xor bh,bh
       mov dh,y
       dec y
       mov dl,x
       dec x
       int 10h
end;

function ReadKey:char;assembler;
asm
 mov ax,00h
 int 16h
 xor ah,ah
end;

procedure TextColor(farba:byte);
begin
 tc:=farba;
end;

function WhereY:byte;assembler;
asm
 mov ah,03h
 xor bh,bh
 int 10h
 mov al,dh
 xor ah,ah
end;

function WhereX:byte;assembler;
asm
 mov ah,03h
 xor bh,bh
 int 10h
 mov al,dl
 xor ah,ah
end;

procedure ClrScr;
var farba:byte;
begin
 farba:=pac+bck*16;
 asm
  mov ax,0003h
  int 10h
  mov ax,0b800h
  mov es,ax
  xor di,di
  mov cx,80*25
  mov al,00h
  mov ah,farba
  @Mazanie:
   stosw
  loop @Mazanie
 end;
end;

function UnCode(z:string):string;
var a:word;
    zz:string;
begin
 zz:='';
 for a:=1 to length(z) do if ord(z[a])<253 then zz:=zz+chr(ord(z[a])-2);
 UnCode:=zz;
end;

procedure WrtLn(str:string);
var a,zn:byte;
    x,y:shortint;
label Dalej;
begin
   str:=str+#13+#10;
   tc:=tc+bck*16;
   for a:=1 to length(str) do begin
{     write(str[a]);}
     { My ULTIMATE solution of the Pentium II problem: }
     if (ord(str[a])=10) then else begin
     if (ord(str[a])=13) then begin
     if (y=24) then begin
      asm
       mov ax,0601h
       mov bh,pac
       xor cx,cx
       mov dh,24
       mov dl,79
       int 10h
      end;
      Dec(y);
     end;
      x:=0;
      asm
       mov ah,02h
       xor bh,bh
       mov dh,y
       inc dh
       xor dl,dl
       int 10h
      end;
      tc:=tc-bck*16;
      exit;
     end else begin
     zn:=ord(str[a]);
     x:=WhereX;
     y:=WhereY;
     if (x+1=80) and (y+1=25) then begin
      asm
       mov ax,0601h
       mov bh,pac
       xor cx,cx
       mov dh,24
       mov dl,79
       int 10h
      end;
      x:=0;
      asm
      mov ah,02h
      xor bh,bh
      mov dh,y
      xor dl,dl
      dec x
      int 10h
      end;
     end;
      asm
      mov ah,09h
      mov al,zn
      xor bh,bh
      mov bl,tc
      mov cx,1
      int 10h
      inc x
      { posun kurzor }
{L}      cmp x,80
       jne Dalej
{       mov ax,0601h
       mov bh,02h
       xor cx,cx
       mov dh,24
       mov dl,79}
       mov x,0
       inc y
       int 10h {EL}
      Dalej:
      mov ah,02h
      xor bh,bh
      mov dh,y
      mov dl,x
      int 10h
     end;
     end;
     end;
     { *** Pentium II LOGOUT *** }
     randomize;
     if zvuk=1 then begin
      if (a/2=a div 2) then Audio(20,1);
     end else if (a/2=a div 2) then DosDelay(1);
   end;
   tc:=tc-bck*16;
end;

procedure PlugIn_Test;
var kod:word;
begin
 if (ParamCount=0) then halt;
 dir:=ParamStr(1);
 assign(f,Dir+'plugins\0sedliak.pfg');
 reset(f);
 read(f,kac,pac,bck,pacient,zvuk);
 close(f);
 if pacient=0 then begin
  pac:=pac+kac;
  kac:=pac-kac;
  pac:=pac-kac;
 end;
end;

{--------[ program ]---------}
procedure Hadaj;
var x,y,pocet,a:byte;
label Hadaj1;
begin
 x:=0;
 textcolor(pac);
 ch:=upcase(readkey);
 for a:=1 to length(strn) do begin
  if ch=upcase(strn[a]) then begin
   gotoxy(poz+length(tema)+1+a,7);
   write(strn[a]);
   on_screen[a]:=strn[a];
   Inc(uhadnute);
   Inc(x);
  end;
 end;
 if x=0 then Dec(energia,10);
 Hadaj1:
 textcolor(kac);
end;

procedure WriteOnScreen;
var a:byte;
const podciarnik='_';
begin
 str1:='';
 for a:=1 to length(strn) do begin
  if (strn[a]<>' ') then str1:=str1+'_' else str1:=str1+' ';
  if (strn[a]<>' ') then if (strn[a]=',') then str1:=str1+#8+',';
  if (strn[a]<>' ') and (strn[a]<>',') then if (strn[a]='.') then str11:=str1+#8+'.';
 end;
 on_screen:=str1;
 poz:=round((80/2)-((length(str1)+length(tema)+3)/2));
 gotoxy(poz,7);
 textcolor(kac);
 wrtln(tema+': ');
 gotoxy(poz+length(tema)+2,7);
 textcolor(pac);
 wrtln(str1);
end;

procedure Dopln;
var a:byte;
begin
 textcolor(pac);
 for a:=1 to length(on_screen) do begin
  if on_screen[a]='_' then begin
   gotoxy(poz+length(tema)+1+a,7);
   write(strn[a]);
  end;
 end;
 textcolor(kac);
end;

procedure GetRandom;
var a,x,riadky:word;
    fl:text;
begin
 assign(fl,Dir+'plugins\data\tajnicka\tajnicka.pdr');
 reset(fl);
 riadky:=0;
 while not eof(fl) do begin
  readln(fl);
  Inc(riadky);
 end;
 close(fl);
 randomize;
 a:=random(riadky)+1;
 reset(fl);
 for x:=1 to a do readln(fl,str11);
 str1:=UnCode(str11);
 close(fl);
 tema:=GetString(':',Str1,1);
 strn:=GetString(':',Str1,2);
end;

begin
 poz:=1;
 PlugIn_Test;
 001:
 randomize;
 ClrScr;
 GetRandom;
 energia:=100;
 uhadnute:=0;
 textcolor(kac);
 str1:='';
 for x:=1 to length(strn) do if strn[x]<>' ' then on_screen:=on_screen+'_'
 else on_screen:=on_screen+' ';
 str1:='';
 WriteOnScreen;
 GotoXY(1,1);
 str(energia,en);
 textcolor(kac);
 WrtLn(' Psychicke zdravie');
 textcolor(pac);
 Write('       '+en+'%    ');
 repeat
  CursorOff;
  L_energia:=energia;
  Hadaj;
  if energia<>L_energia then begin
   GotoXY(1,2);
   str(energia,en);
   textcolor(pac);
   Write('       '+en+'%    ');
  end;
  if energia=0 then begin
   Dopln;
   gotoxy(1,18);
   if pacient=1 then WrtLn('Smola, pacient moj! Hras este raz? (a/n)')
    else WrtLn('smola, doktor! hrate este raz? (a/n)');
   Reg.AH := $0C;
   Reg.AL := $06;
   Reg.DL := $FF;
   MsDos(Reg);
   repeat
    ch:=upcase(readkey);
   until (ch='A') or (ch='N');
   if ch='A' then goto 001;
   CursorOff;
   halt;
  end;
 until on_screen=strn;
 gotoxy(1,18);
 if pacient=1 then WrtLn('Super, pacientik moj milucky! Zahras si este raz? (a/n)')
  else WrtLn('ste nejaky mudry, kacn! zahrali by ste si este raz? (a/n)');
 Reg.AH := $0C;
 Reg.AL := $06;
 Reg.DL := $FF;
 MsDos(Reg);
 repeat
  ch:=upcase(readkey);
 until (ch='A') or (ch='N');
 if ch='A' then goto 001;
 CursorOn;
end.