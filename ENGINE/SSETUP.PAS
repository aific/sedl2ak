program Setup;
uses dos,crt2;
var ch:char;
    menu,kac,pac,tc,pozn:byte;
    f:file of byte;
    bck, autoprint, zaznamy, pacient, zvukovka, zvuk, grafika, jazyk, klav:byte;
    change:boolean;
    kacabaya:string;
    Dir:DirStr;
    Name:NameStr;
    Ext:ExtStr;

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
 mov ah,01h
 int 21h
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

procedure ClrScr;assembler;
asm
 mov ax,0003h
 int 10h
 mov ax,0b800h
 mov es,ax
 xor di,di
 mov cx,80*25
 mov ax,0200h
 @Mazanie:
  stosw
 loop @Mazanie
 mov ah,02h
 xor bh,bh
 xor dh,dh
 xor dl,dl
 int 10h
end;

procedure WrtLn(str:string);
var a,zn:byte;
    x,y:shortint;
    vram_pos, farba_pos:word;
label Dalej;
begin
   textcolor(tc);
   str:=str+#13+#10;
   for a:=1 to length(str) do begin
{     write(str[a]);}
     { My ULTIMATE solve of the Pentium II problem: }
     if (ord(str[a])=10) then else begin
     if (ord(str[a])=13) then begin
     if (y=24) then begin
      asm
       mov ax,0601h
       mov bh,02h
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
       mov bh,07h
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
   end;
end;

procedure R;
begin
 assign(f,Dir+'sedliak.cfg');
 reset(f);
 read(f,kac,pac,bck,autoprint,zaznamy,pacient,zvuk,zvukovka,grafika,jazyk,klav,pozn);
 close(f);
end;

procedure Prostredie;
begin
 textcolor(10);
 clrscr;
 wrtln(' SEDLIAK verzia 2.00 SETUP         Copyright (c) Aific 1998-1999 by Marek Hlavac'+#13+#10);
 gotoxy(1,18);
 textcolor(10);
 gotoxy(24,6);
 wrtln('FARBA TEXTU - KACN.............'+#13+#10);
 gotoxy(24,7);
 wrtln('FARBA TEXTU - PACIENT..........'+#13+#10);
 gotoxy(24,8);
 wrtln('FARBA TEXTU - POZNAMKY.........'+#13+#10);
 gotoxy(24,9);
 wrtln('FARBA POZADIA..................'+#13+#10);
 gotoxy(24,10);
 wrtln('AUTOMATICKA TLAC...............'+#13+#10);
 gotoxy(24,11);
 wrtln('TVORBA ZAZNAMOV................'+#13+#10);
 gotoxy(24,12);
 wrtln('UPRATOVANIE ORDINACIE..........'+#13+#10);
 gotoxy(24,13);
 wrtln('KTO CHCES BYT?.................'+#13+#10);
 gotoxy(24,14);
 wrtln('ZVUKOVA KARTA..................'+#13+#10);
 gotoxy(24,15);
 wrtln('GRAFICKA KARTA.................'+#13+#10);
 gotoxy(24,16);
 wrtln('MEDZINARODNA JAZYKOVA PODPORA..'+#13+#10);
 gotoxy(24,17);
 wrtln('KLAVESNICA.....................'+#13+#10);
 gotoxy(24,18);
 wrtln('ORIGINALNE NASTAVENIE'+#13+#10);
 gotoxy(24,19);
 wrtln('KONIEC + ULOZENIE ZMIEN'+#13+#10);
 kacabaya:='ўўўўўўўўўўўўўўўў';
 change:=true;
 repeat
  if change=true then begin
   textcolor(2);
   gotoxy(56,10);
   if autoprint=1 then wrtln('hej') else wrtln('nie');
   gotoxy(56,11);
   if zaznamy=1 then wrtln('hej') else wrtln('nie');
   gotoxy(56,12);
   if zvuk=1 then wrtln('hej') else wrtln('nie');
   gotoxy(56,13);
   if pacient=1 then wrtln('pacient    ');
   if pacient=0 then wrtln('Kacn       ');
   gotoxy(56,14);
   case zvukovka of
    1:wrtln('PC Vykecavac       ');
    2:wrtln('VybuchovacZvuku    ');
    3:wrtln('VybuchovacZvuku 2.0');
    4:wrtln('Adlib Zlato        ');
    5:wrtln('Generalmajor MIDI  ');
    6:wrtln('PsychoSound (yeah) ');
   end;
   gotoxy(56,15);
   case grafika of
    1:wrtln('CGA              ');
    2:wrtln('EGA              ');
    3:wrtln('VGA              ');
    4:wrtln('SuperVGA         ');
    5:wrtln('SDK              ');
    6:wrtln('SMK              ');
    7:wrtln('SNS              ');
    8:wrtln('HZDS             ');
    9:wrtln('S4 KVARTETO 64-  ');
   10:wrtln('Cirrus Nelogic   ');
   11:wrtln('OpityScreen Profi');
   end;
   gotoxy(56,16);
   case jazyk of
    1:wrtln('slovencina   ');
    2:wrtln('madarcina    ');
    3:wrtln('cestina      ');
    4:wrtln('rustina      ');
    5:wrtln('svahilcina   ');
    6:wrtln('arabcina     ');
    7:wrtln('cinstina     ');
    8:wrtln('japoncina    ');
    9:wrtln('esperanto    ');
   10:wrtln('kacnovcina   ');
   11:wrtln('zvieracia rec');
   end;
   gotoxy(56,17);
   case klav of
    1:wrtln('IBM             ');
    2:wrtln('slovenska QWERTY');
    3:wrtln('slovenska QWERTZ');
    4:wrtln('ceska QWERTY    ');
    5:wrtln('ceska QWERTZ    ');
    6:wrtln('ceska amaterska ');
   end;
   textcolor(kac);
   gotoxy(56,6);
   wrtln('ллл');
   textcolor(pac);
   gotoxy(56,7);
   wrtln('ллл');
   textcolor(pozn);
   gotoxy(56,8);
   wrtln('ллл');
   if bck=0 then begin
    textcolor(2);
    gotoxy(56,9);
    wrtln('cierna');
   end else begin
    textcolor(bck);
    gotoxy(56,9);
    wrtln('ллл   ');
   end;
  end;
  change:=false;
  textcolor(0);
  CursorOff;
  gotoxy(19,5+menu-1);
  textcolor(0);
  write('     ');
  gotoxy(19,5+menu+1);
  textcolor(0);
  write('     ');
  gotoxy(19,5+menu);
  textcolor(2);
  write(''+kacabaya[menu]+'  ');
  gotoxy(100,100);
  ch:=readkey;
  if ch=#0 then begin
   ch:=readkey;
   if ch='H' then if menu>1 then Dec(menu);
   if ch='P' then if menu<14 then Inc(menu);
  end;
  if ch=#13 then begin
   if menu=1 then if kac<15 then Inc(kac) else kac:=1;
   if menu=2 then if pac<15 then Inc(pac) else pac:=1;
   if menu=3 then if pozn<15 then Inc(pozn) else pozn:=1;
   if menu=4 then if bck<7 then Inc(bck) else bck:=0;
   if menu=5 then if autoprint=1 then autoprint:=0 else autoprint:=1;
   if menu=6 then if zaznamy=1 then zaznamy:=0 else zaznamy:=1;
   if menu=7 then if zvuk=1 then zvuk:=0 else zvuk:=1;
   if menu=8 then if pacient=1 then pacient:=0 else pacient:=1;
   if menu=9 then if zvukovka=6 then zvukovka:=1 else Inc(zvukovka);
   if menu=10 then if grafika=11 then grafika:=1 else Inc(grafika);
   if menu=11 then if jazyk=11 then jazyk:=1 else Inc(jazyk);
   if menu=12 then if klav=6 then klav:=1 else Inc(klav);
   if menu=13 then begin
    zaznamy:=0;
    klav:=1;
    pozn:=7;
    pacient:=1;
    zvukovka:=1;
    grafika:=1;
    bck:=0;
    jazyk:=2;
    autoprint:=0;
    kac:=10;
    pac:=2;
    zvuk:=1;
   end;
   change:=true;
  end;
 until (ch=#13) and (menu=14);
 assign(f,Dir+'sedliak.cfg');
 rewrite(f);
 write(f,kac,pac,bck,autoprint,zaznamy,pacient,zvuk,zvukovka,grafika,jazyk,klav,pozn);
 close(f);
 assign(f,Dir+'plugins\0sedliak.pfg');
 rewrite(f);
 write(f,kac,pac,bck,pacient,zvuk,klav);
 close(f);
end;

begin
 if ParamStr(1)<>'prababka' then begin
  halt;
 end;
 GetDir(0,Dir);
 Dir:=Dir+'\';
 menu:=1;
 textcolor(7);
 clrscr;
 R;
 Prostredie;
 textcolor(7);
 clrscr;
end.