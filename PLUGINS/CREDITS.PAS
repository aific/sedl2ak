{$A-,B-,D-,E+,F+,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,0,655360}
program Kreditz;
uses dos,keyb,crt2,tsuntd;
var str,dir:string;
    f:text;
    cnt,tc,pac,kac,pacient,zvuk:byte;
    ch:char;

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

procedure ClrScr;assembler;
asm
 mov ax,0003h
 int 10h
 mov ax,0b800h
 mov es,ax
 xor di,di
 mov cx,80*25
 mov al,00h
 mov ah,tc
 @Mazanie:
  stosw
 loop @Mazanie
end;

procedure WrtLn(str:string);
var a,zn:byte;
    x,y:shortint;
label Dalej;
begin
   str:=str+#13+#10;
   for a:=1 to length(str) do begin
{     write(str[a]);}
     { My ULTIMATE solution to the Pentium II problem: }
     if (ord(str[a])=10) then else begin
     if (ord(str[a])=13) then begin
     if (y=24) then begin
      asm
       mov ax,0601h
       mov bh,tc
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
      exit;
     end else begin
     zn:=ord(str[a]);
     x:=WhereX;
     y:=WhereY;
     if (x+1=80) and (y+1=25) then begin
      asm
       mov ax,0601h
       mov bh,tc
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
   end;
end;

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


function UnCode(z:string):string;
var a:word;
    zz:string;
begin
 zz:='';
 for a:=1 to length(z) do if ord(z[a])<254 then zz:=zz+chr(ord(z[a])-1);
 UnCode:=zz;
end;

procedure PlugIn_Test;
var kod:word;
begin
 if (ParamCount=0) then halt;
 dir:=ParamStr(1);
 assign(f,Dir+'plugins\0sedliak.pfg');
 reset(f);
 read(f,kac,pac,pacient,zvuk);
 close(f);
 if pacient=0 then begin
  pac:=pac+kac;
  kac:=pac-kac;
  pac:=pac-kac;
 end;
end;

begin
 PlugIn_Test;
 randomize;
 ClearTA;
 clrscr;
 CursorOff;
 gotoxy(1,1);
 textcolor(12);
 wrtln('Jaj, tak ty si sa asi v dokumentacii docital, ze by tu mali byt nejake');
 wrtln('kreditz. Vela by si chcel... Ujujuj, pobavili sme seba vsetci!');
 cnt:=0;
 ch:=readkey;
 textcolor(7);
 CursorOn;
 ClearTA;
end.