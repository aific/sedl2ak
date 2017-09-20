{$A-,B-,D-,E+,F+,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,0,75360}
program CESTA_k_este_vacsiemu_PSYCHU;
uses dos,stringy,printer,crt2;
const Ver='2.00';
      KPW=2; { Kecs per word = jednotka zhovorcivosti Kacna }
var a,b,c:word; { pomocna premenna }
    Reg : Registers; { registre procesora }
    ch:char; { klasicka znakova premenna }
    keys:array[1..184] of byte;
    screen:array [1..4000] of byte;
    autoprint,zaznamy,kac,pac,tc,pozn,pacient:byte; { nastavenie prostredia }
    bck,klav, jazyk, grafika, zvukovka:byte; { yeah, prostredie }
    zvuk:byte; d:char;
    cena:longint; { cena za pobyt u Kacna }
    kec,kec2,kec3,kec4,kecy,odp1:string;
    f,f2:text; cf:file of byte;
    Dir:DirStr; Name:NameStr; Ext:ExtStr;
    year,month,day,dow, hour, min, sec, sec100:word;
    o,nahnevanost:word; prn,yesdef,medzera,iq0,mikita,magyar:boolean;
    print_err:boolean;

label 001,002,vyhodnotenie;

procedure DosDelay(zdrzanie:word);assembler;
asm
 mov ah,86h
 mov cx,1
 mov dx,zdrzanie
 int 15h
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

procedure GotoXY(x,y:byte);assembler;
asm
       mov ah,02h
       xor bh,bh
       mov dh,y
       mov dl,x
       int 10h
end;

function ReadKey(haha:boolean):char;
var klaves,pocet_k,hehe,wx,wy:byte;
begin
 wx:=whereX;
 wy:=whereY;
 gotoxy(20,30);
 asm
{  mov ax,00h
  int 16h
  xor ah,ah
  mov klaves,al}
  mov ah,01h
  int 21h
  xor ah,ah
  mov klaves,al
 end;
 gotoxy(wx,wy);
 readkey:=chr(klaves);
 if (haha=false) or (klaves=0) or (klaves<20) or (klaves=27) or (klaves=32) then begin readkey:=chr(klaves); exit; end;
 for pocet_k:=1 to 92 do begin
  hehe:=pocet_k*2;
  if klaves=keys[hehe-1] then readkey:=chr(keys[hehe]);
 end;
end;

procedure TextColor(farba:byte);
begin
 tc:=farba;
end;

procedure ClrScr;
var farba:byte;
    c_riadok:byte;
begin
 farba:=pac+bck*16;
  for c_riadok:=0 to 24 do
  asm
   mov ah,06h
   mov al,0
   mov bh,farba
   xor cx,cx
   mov dh,24
   mov dl,79
   int 10h
  end;
  gotoxy(0,0);
end;

procedure GetScr;
var x,y:byte;
    a,b:byte;
begin
 for y:=0 to 24 do begin
  for x:=0 to 79 do begin
   gotoxy(x,y);
   asm
    mov ah,08h
    xor bh,bh
    int 10h
    mov a,ah
    mov b,al
   end;
   screen[2*(80*y+x)]:=a;
   screen[2*(80*y+x)+1]:=b;
  end;
 end;
end;

procedure PutScr;
var x,y:byte;
    a,b:byte;
begin
 for y:=0 to 24 do begin
  for x:=0 to 79 do begin
   gotoxy(x,y);
   a:=screen[2*(80*y+x)];
   b:=screen[2*(80*y+x)+1];
   asm
    mov ah,09h
    mov al,b
    xor bh,bh
    mov bl,a
    xor cx,cx
    inc cx
    int 10h
   end;
  end;
 end;
end;

procedure WWrite(str:string);
var a,zn,farba:byte;
    x,y:shortint;
    zvyraznit:boolean;
label Dalej,Pokr;
begin
   zvyraznit:=false;
   str:=str+#13+#10;
   if prn=true then begin
    {$I-}
    write(lst,' '+#8);
    {$I+}
    if IOResult=0 then write(lst,str);
    ExitCode:=0;
    ErrorAddr:=nil;
   end;
   if zaznamy=1 then write(f2,str);
   for a:=1 to length(str) do begin
{     write(str[a]);}
     { My ULTIMATE solve of the Pentium II problem: }
     if zvyraznit then farba:=kac else farba:=pac;
     farba:=farba+bck*16;
     if str[a]='#' then begin
      if zvyraznit=false then zvyraznit:=true else zvyraznit:=false;
      goto Pokr;
     end;
     if (ord(str[a])=10) then else begin
     if (ord(str[a])=13) then begin
     if (y=24) then begin
      asm
       mov ax,0601h
       mov bh,farba
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
       mov bh,farba
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
      mov bl,farba
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
     Pokr:
   end;
end;

procedure Pomoc;
begin
 GetScr;
 ClrScr;
 gotoxy(0,24);
 CursorOff;
 wwrite('#SEDLIAK 2: CESTA K ESTE VACSIEMU PSYCHU                                 POMOC#'); dosdelay(8);
 wwrite('#-------------------------------------------------------------------------------#'); dosdelay(8);
 wwrite(' SEDLIAK je simulator rozhovoru so #psychiatrom# a zaroven #posunovacom# u drahy'); dosdelay(8);
 wwrite('(#PUDr.#) Michalom Kacabayom. Toto je strucny help k tomuto #perfektnemu# programu.'); dosdelay(8);
 wwrite('Takze, #kurzorom# je tu taka mala #sipocka#, ktora ukazuje dolava. To znamena,'); dosdelay(8);
 wwrite('ze niekde #<--- tam#. Za tuto sipku mozete pisat svoj #vykec# a po stlaceni'); dosdelay(8);
 wwrite('takeho #zaujimaveho# klavesu, akym #ENTER# urcite je, Vam #Kacn# odpovie. To je'); dosdelay(8);
 wwrite('vsetko #podstatne#, teraz uz len blbostky. Ak sa Vam tato #sranda# paci, napiste'); dosdelay(8);
 wwrite('autorovi SEDLIAKa, ktorym som ja a tu je moja #milucka# a #krasna# adresa:'); dosdelay(8);
 wwrite(' #inteligent Marek Hlavac#, #Jablonova 518/3#, #031 04 Liptovsky Mikulas#, #SR#.'); dosdelay(8);
 wwrite(''); dosdelay(8);
 wwrite('Ak chcete zazit nieco #super#, zapojte sa do projektu #SEDLIAK AWARDS#. Viac info'); dosdelay(8);
 wwrite('v subore #INFO/AWARDS.TXT#. V adresari INFO najdete tiez mnoho dalsich veciciek.'); dosdelay(8);
 wwrite('Teda #odporucam# pozriet sa na to. Kompletna dokumentacia k SEDLIAKovi je v'); dosdelay(8);
 wwrite('subore #INFO/SEDLIAK.TXT#.'); dosdelay(8);
 wwrite(' '); dosdelay(8);
 wwrite('V pripade, ze sa Vam #hnusia# tieto farby, spustite si #SETUP.BAT# a tam si to'); dosdelay(8);
 wwrite('nastavte #ako chcete#.'); dosdelay(8);
 wwrite(' '); dosdelay(8);
 wwrite('Vdaka za #pozornost#!'); dosdelay(8);
 wwrite(' '); dosdelay(8);
 wwrite('PS: A nechcete sa stat aj #oficialnym pacientom#?'); dosdelay(8);
 wwrite(' '); dosdelay(8);
 wwrite('Teraz mozete stlacit #ESC#.'); dosdelay(8);
 repeat
  ch:=readkey(true);
 until ch=#27;
 PutScr;
end;

procedure ReadLnT;
var posit,wxa,wya,znak_asc:byte;
    ch2:char;
begin
 kec:='';
 posit:=1;
 wxa:=wherex;
 wya:=wherey;
 ch:='~';
 repeat
  gotoxy(wxa,wya);
  write(kec+'');
  CursorOff;
  for a:=1 to 78-wxa-length(kec) do write(' ');
  if ch=#0 then ch:=readkey(false);
  ch:=readkey(true);
  gotoxy(wxa-1+posit,wherey);
  CursorOn;
  if ch=#8 then if posit>1 then begin
   delete(kec,posit-1,1);
   dec(posit);
  end;
  if ch=#0 then begin
   ch:=readkey(false);
   if ch=';' then Pomoc;
   ch:='ў';
  end;
  if (ch<>#0) and (ch<>#13) and (ch<>#27) and (ch<>#8) and (ch<>'ў')then begin
   if posit<75 then begin
    Insert(ch,kec,posit);
    {kec:=kec+ch}
    inc(posit);
   end;
  end;
 until ch=#13;
 write(' ',#8,' ',#8);
 writeln;
end;

function LZ3(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then s := '00' + s;
  if Length(s) = 2 then s := '0' + s;
  LZ3 := s;
end;

function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then s := '0' + s;
  LeadingZero := s;
end;

function UnCode(z:string):string;
var a:word;
    zz:string;
begin
 zz:='';
 for a:=1 to length(z) do if ord(z[a])<253 then zz:=zz+chr(ord(z[a])-2);
 UnCode:=zz;
end;

procedure R;
begin
 assign(cf,Dir+'sedliak.cfg');
 reset(cf);
 read(cf,kac,pac,bck,autoprint,zaznamy,pacient,zvuk,zvukovka,grafika,jazyk,klav,pozn);
 close(cf);
end;

procedure LoadKeyb; { klavesnica }
var subor:string;
    klaves,pocet_k:byte;
begin
 case klav of
  1:subor:='ibm.key';
  2:subor:='svkty.key';
  3:subor:='svktz.key';
  4:subor:='czety.key';
  5:subor:='czetz.key';
  6:subor:='czeam.key';
 end;
 assign(cf,Dir+'keybs\'+subor);
 reset(cf);
 for pocet_k:=1 to 184 do begin
  read(cf,klaves);
  keys[pocet_k]:=klaves;
 end;
 close(cf);
end;


function DenVT:string;
begin
 case dow of
  0:DenVT:='NEDELA  ';
  1:DenVT:='PONDELOK';
  2:DenVT:='UTOROK  ';
  3:DenVT:='STREDA  ';
  4:DenVT:='STVRTOK ';
  5:DenVT:='PIATOK  ';
  6:DenVT:='SOBOTA  ';
 end;
end;

procedure WrtLnPrn(str:string);
var a:byte;
begin
 if prn=true then begin
  {$I-}
  write(lst,' '+#8);
  {$I+}
  print_err:=false;
  if IOResult=0 then begin
   write(lst,str);
   print_err:=true;
  end;
  ExitCode:=0;
  ErrorAddr:=nil;
 end;
end;

procedure WrtLn(str:string);
var a,zn,pozc,nahoda:byte;
    x,y:shortint;
label Dalej;
begin
   str:=str+#13+#10;
   if prn=true then begin
    {$I-}
    write(lst,' '+#8);
    {$I+}
    if IOResult=0 then write(lst,str);
    ExitCode:=0;
    ErrorAddr:=nil;
   end;
   tc:=tc+bck*16;
   pozc:=pac+bck*16;
   if zaznamy=1 then write(f2,str);
   for a:=1 to length(str) do begin
{     write(str[a]);}
     { My ULTIMATE solution of the Pentium II problem: }
{     if ina_farba=true then begin
      if a/3=a div 3 then tc:=pac+bck*16 else tc:=kac+bck*16;
     end;}
     if (ord(str[a])=10) then else begin
     if (ord(str[a])=13) then begin
     if (y=24) then begin
      asm
       mov ax,0601h
       mov bh,pozc
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
       mov bh,pozc
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
      if (a/6=a div 6) then begin
       randomize;
       nahoda:=random(2);
       if nahoda=0 then begin
         DosDelay(10);
       end;
      end;
     end;{ else if (a/8=a div 8) then DosDelay(100);}
     if (a/6)=(a div 6) then DosDelay(100);
     if (a/4)=(a div 4) then DosDelay(10);
   end;
   tc:=tc-bck*16;
end;

procedure AntiVirus;
 procedure Infected(vname:string);
 begin
  ClrScr;
  WriteLn('Vbudovany antivirusovy test programu SEDLIAK:');
  WriteLn(' (!) ',vname);
  WriteLn;
  WriteLn(' (ESC) = koniec; (ENTER) = pokracovat');
  repeat
   ch:=readkey(true);
   if ch=#27 then begin
    clrscr;
    halt;
   end;
  until ch=#13;
  clrscr;
 end;

var ax2:word;
begin
 { Test pamate RAM na pritomnost virusu IDEA.6128
    = zdroj PC REVUE }
 asm
  mov ax,6969h
  int 21h
  mov ax2,ax
 end;
 if ax2=$696A then begin Infected('Virus IDEA.6128 najdeny v RAM!') end;
 { Teraz RAMku otestujem na virus Pojer = zdroj kniha Moderni pocitacove
   viry }
 asm
  mov ah,0ffh
  int 21h
  mov ax2,ax
 end;
 if ax2=$1234 then begin Infected('Virus POJER najdeny v RAM!') end;
end;

procedure PlugIn(subor:string);
var riadky,x:word;
    strn,kacn,pacn,ozvucenie,pacientx:string;
begin
 Str(kac,kacn);
 Str(pac,pacn);
 Str(pacient,pacientx);
 if zvuk=1 then ozvucenie:='1' else ozvucenie:='0';
 WrtLnPrn(#27+#71+'<yeoman system message> Activating plugin '+subor+'...'+#13+#10+#27+#64);
 if zaznamy=1 then writeln(f2,'<yeoman system message> Activating plugin '+subor+'...');
 SwapVectors;
 Exec('plugins\'+subor,dir);
 SwapVectors;
 if DosError=8 then begin
  WrtLn('Preboha, co je toto za srotovsky kompjuter! Malo RAMky!');
 end else if DosError<>0 then begin
  WrtLn('Chyba pri spustani pluginu! (pozri INFO\SEDLIAK.TXT)');
 end else begin
  riadky:=0;
  if pacient=1 then assign(f,Dir+'zasoba\continue.pdr') else assign(f,Dir+'zasoba\pontinue.pdr');
  reset(f);
  while not eof(f) do begin
   readln(f);
   Inc(riadky);
  end;
  close(f);
  a:=random(riadky)+1;
  reset(f);
  for x:=1 to a do begin
   readln(f,strn);
  end;
  close(f);
  ClrScr;
  gotoxy(0,24);
  CursorOff;
  if pacient=1 then wrtln(UnCode(strn)) else wrtln('> '+LoCased(UnCode(strn)));
 end;
end;

procedure Vyber(kolko:word);
var x:word;
    odpoved:string;
begin
 if pacient=1 then assign(f,Dir+'zasoba\slova'+LZ3(random(kpw)+1)+'.pdr')
 else assign(f,Dir+'zasoba\plova'+LZ3(random(kpw)+1)+'.pdr');
 reset(f);
 for x:=1 to kolko do readln(f,odpoved);
 if copy(UnCode(odpoved),1,1)='*' then begin
  PlugIn(copy(UnCode(odpoved),2,length(odpoved)-1));
  exit;
 end;
 if pacient=1 then WrtLn(UnCode(odpoved)) else WrtLn('> '+LoCased(UnCode(odpoved)));
 close(f);
end;

function Slovo3:boolean;
const predpona:array[1..10] of string = ('','ne','pre','vy','za','pri','od','na','po','pred');
var xxx,m,wrd:word;
    str,vzor:string;
    pred:word;
begin
 slovo3:=false;
 xxx:=0;
 a:=0;
 repeat
  Inc(xxx);
  a:=GetPos(' ',kec,xxx);
 until a=length(kec)+1;
 a:=xxx;
 assign(f,Dir+'zasoba\slovicka.pdr');
 reset(f);
 wrd:=0;
 while not eof(f) do begin
  readln(f,str);
  Inc(wrd);
  str:=UnCode(str);
  vzor:=UpCased(GetString('|',str,2));
  str:=GetString('|',str,1);
  for xxx:=1 to a do begin
   if str=GetString(' ',kec,xxx) then begin
    close(f);
    Vyber(wrd);
    slovo3:=true;
    exit;
   end;
   if (vzor='Q') and (Pos(str,kec)<>0) then begin {staci, ked sa v slove retazec nachadza}
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
   end;
   if vzor='PEKNY' then begin
    for pred:=1 to 10 do begin
     if (predpona[pred]+copy(str,1,length(str)-1)+'ou'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'ej'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'ymi'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'ych'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'ym'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'om'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'u'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'emu'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'i'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'eho'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'e'=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str))=GetString(' ',kec,xxx)) or
     (predpona[pred]+copy(str,1,length(str)-1)+'a'=GetString(' ',kec,xxx)) then begin
      close(f);
      Vyber(wrd);
      slovo3:=true;
      exit;
     end;
    end;
   end;
   if vzor='S' then begin {stroj}
    if copy(str,length(str)-1,2)='el' then delete(str,length(str)-1,1);
    if (str+'e'=GetString(' ',kec,xxx)) or
    (str+'och'=GetString(' ',kec,xxx)) or
    (str+'ov'=GetString(' ',kec,xxx)) or
    (str+'ove'=GetString(' ',kec,xxx)) or
    (str+'ovy'=GetString(' ',kec,xxx)) or
    (str+'ova'=GetString(' ',kec,xxx)) or
    (str+'mi'=GetString(' ',kec,xxx)) or
    (str+'ami'=GetString(' ',kec,xxx)) or
    (str+'om'=GetString(' ',kec,xxx)) or
    (str+'ovom'=GetString(' ',kec,xxx)) or
    (str+'ovu'=GetString(' ',kec,xxx)) or
    (str+'oveho'=GetString(' ',kec,xxx)) or
    (str+'ovej'=GetString(' ',kec,xxx)) or
    (str+'om'=GetString(' ',kec,xxx)) or
    (str+'a'=GetString(' ',kec,xxx)) or
    (str+'i'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;
   if vzor='DL' then begin {dlan}
    if copy(str,length(str)-1,length(str))='en' then delete(str,length(str)-1,1);
    if (str+'e'=GetString(' ',kec,xxx)) or
    (str+'i'=GetString(' ',kec,xxx)) or
    (str+'iam'=GetString(' ',kec,xxx)) or
    (str+'ou'=GetString(' ',kec,xxx)) or
    (str+'iach'=GetString(' ',kec,xxx)) or
    (str+'ina'=GetString(' ',kec,xxx)) or
    (str+'ami'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

 if vzor='SLOVESO1' then begin {SLOVESO1}
   for pred:=1 to 10 do begin
    if (predpona[pred]+str+'m'=GetString(' ',kec,xxx)) or
    (predpona[pred]+str=GetString(' ',kec,xxx)) or
    (predpona[pred]+str+'me'=GetString(' ',kec,xxx)) or
    (predpona[pred]+str+'s'=GetString(' ',kec,xxx)) or
    (predpona[pred]+copy(str,1,length(str)-1)+'u'=GetString(' ',kec,xxx)) or
    (predpona[pred]+str+'eme'=GetString(' ',kec,xxx)) or
    (predpona[pred]+str+'nie'=GetString(' ',kec,xxx)) or
    (predpona[pred]+str+'te'=GetString(' ',kec,xxx)) or
    (predpona[pred]+copy(str,1,length(str)-1)=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
    end;
   end;

   if vzor='K' then begin {kost}
    if (str+'i'=GetString(' ',kec,xxx)) or
    (str+'iam'=GetString(' ',kec,xxx)) or
    (str+'iach'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

   if vzor='M' then begin {mesto}
    if (copy(str,1,length(str)-1)+'a'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'u'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'am'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'e'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ach'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'om'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ami'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

   if vzor='SR' then begin {srdce}
    if (copy(str,1,length(str)-1)+'ia'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'a'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'u'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'iam'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'i'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'iach'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'om'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ami'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

   if vzor='V' then begin {vysvedcenie}
    if (copy(str,1,length(str)-2)+'ia'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'i'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'iu'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'iam'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'ie'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'iach'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'im'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-2)+'iami'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

 if vzor='DI' then begin {dievca}
    if (copy(str,1,length(str)-1)+'ata'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ence'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ata'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'at'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'eniec'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'atu'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'atam'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'encom'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ati'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'atach'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'encoch'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'atom'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'atami'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'encami'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

   if vzor='H' then begin        {hrdina}
    if (copy(str,1,length(str)-1)+'ovia'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ami'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ov'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ova'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ove'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ovi'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'om'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ovho'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ovu'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'a'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'u'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

   if vzor='D' then begin {dub}
    if copy(str,length(str)-1,2)='ok' then delete(str,length(str)-1,1);
    if copy(str,length(str)-1,2)='og' then delete(str,length(str)-1,1);
    if copy(str,length(str)-1,2)='ol' then delete(str,length(str)-1,1);
    if (str+'e'=GetString(' ',kec,xxx)) or
    (str+'y'=GetString(' ',kec,xxx)) or
    (str+'och'=GetString(' ',kec,xxx)) or
    (str+'ov'=GetString(' ',kec,xxx)) or
    (str+'ove'=GetString(' ',kec,xxx)) or
    (str+'ovy'=GetString(' ',kec,xxx)) or
    (str+'ova'=GetString(' ',kec,xxx)) or
    (str+'mi'=GetString(' ',kec,xxx)) or
    (str+'om'=GetString(' ',kec,xxx)) or
    (str+'ovom'=GetString(' ',kec,xxx)) or
    (str+'ovu'=GetString(' ',kec,xxx)) or
    (str+'oveho'=GetString(' ',kec,xxx)) or
    (str+'ovej'=GetString(' ',kec,xxx)) or
    (str+'a'=GetString(' ',kec,xxx)) or
    (str+'e'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

   if vzor='CH' then begin {chlap}
    o:=0;
    if (copy(str,length(str)-1,2)='er') then delete(str,length(str)-1,1);
    if (copy(str,length(str)-1,2)='ec') then delete(str,length(str)-1,1);

    if (str+'i'=GetString(' ',kec,xxx)) or
    (str+'ovi'=GetString(' ',kec,xxx)) or
    (str+'ov'=GetString(' ',kec,xxx)) or
    (str+'och'=GetString(' ',kec,xxx)) or
    (str+'ove'=GetString(' ',kec,xxx)) or
    (str+'ov'=GetString(' ',kec,xxx)) or
    (str+'ova'=GetString(' ',kec,xxx)) or
    (str+'ovia'=GetString(' ',kec,xxx)) or
    (str+'om'=GetString(' ',kec,xxx)) or
    (str+'ovom'=GetString(' ',kec,xxx)) or
    (str+'ovu'=GetString(' ',kec,xxx)) or
    (str+'ovho'=GetString(' ',kec,xxx)) or
    (str+'ovej'=GetString(' ',kec,xxx)) or
    (str+'a'=GetString(' ',kec,xxx)) or
    (str+'i'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'i'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
    if copy(str,length(str),1)='k' then begin
     if copy(str,1,length(str)-1)+'ci'=GetString(' ',kec,xxx) then begin
      close(f);
      Vyber(wrd);
      slovo3:=true;
      exit;
     end;
    end;
   end;

   if vzor='Z' then begin {zena}
    if (copy(str,1,length(str)-1)+'am'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'y'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'e'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'u'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ou'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'in'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ina'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ine'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'inom'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'inu'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'inho'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'inej'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ach'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ami'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-1)+'ach'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;
   if vzor='U' then begin {ulica}
    o:=1;
    if (copy(str,length(str)-1,2)='en') then begin{OOOOOOOOOOOOOOOX}
     delete(str,length(str)-1,1);
     o:=0;
    end;
    if (copy(str,1,length(str)-o)+'e'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'i'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'u'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'ou'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'in'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'ina'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'ine'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'inom'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'inu'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'inho'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'inej'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'iach'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'ami'=GetString(' ',kec,xxx)) or
    (copy(str,1,length(str)-o)+'iam'=GetString(' ',kec,xxx)) then begin
     close(f);
     Vyber(wrd);
     slovo3:=true;
     exit;
    end;
   end;

  end;
  end;
  slovo3:=false;
  close(f);
end;

function StOtazka:boolean;
var str,o1,o2,o3,o4,o5:string;
begin
 StOtazka:=false;
 if pacient=1 then assign(f,Dir+'zasoba\standard.pdr') else assign(f,Dir+'zasoba\pstndard.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f,str);
  readln(f,o1);
  readln(f,o2);
  readln(f,o3);
  readln(f,o4);
  readln(f,o5);
  readln(f);
  if UnCode(str)=kec then begin
   StOtazka:=true;
   a:=random(5)+1;
   if pacient=1 then begin
    case a of
     1: wrtln(UnCode(o1));
     2: wrtln(UnCode(o2));
     3: wrtln(UnCode(o3));
     4: wrtln(UnCode(o4));
     5: wrtln(UnCode(o5));
    end;
   end
   else begin
    case a of
     1: wrtln('> '+LoCased(UnCode(o1)));
     2: wrtln('> '+LoCased(UnCode(o2)));
     3: wrtln('> '+LoCased(UnCode(o3)));
     4: wrtln('> '+LoCased(UnCode(o4)));
     5: wrtln('> '+LoCased(UnCode(o5)));
    end;
   end;
  end;
 end;
 close(f);
end;

function Number:boolean;
var xxx,code:word;
    t:string;
    num:longint;
label NumVypis;
begin
 Number:=false;
 xxx:=0;
 a:=0;
 repeat
  Inc(xxx);
  a:=GetPos(' ',kec,xxx);
 until a=length(kec)+1;
 assign(f,Dir+'zasoba\cislovky.pdr');
 reset(f);
 repeat
  a:=xxx;
  readln(f,t);
  if Pos(UnCode(t),kec)<>0 then begin
   Number:=true;
   close(f);
   goto NumVypis;
  end;
  for xxx:=1 to a do begin
   val(GetString(' ',kec,xxx),num,code);
   if code=0 then begin
    Number:=true;
    close(f);
    goto NumVypis;
   end;
  end;
 until eof(f);
 close(f);
 exit;
 NumVypis:
  if pacient=1 then assign(f,'zasoba\num.pdr') else assign(f,'zasoba\pnum.pdr');
  reset(f);
  while not eof(f) do begin
   readln(f);
   Inc(code);
  end;
  close(f);
  a:=random(code)+1;
  reset(f);
  for xxx:=1 to a do begin
   readln(f,t);
  end;
  close(f);
  if pacient=1 then wrtln(UnCode(t)) else wrtln('> '+LoCased(UnCode(t)));
end;

procedure Dianie;
var riadky,x:word;
    oldcol:byte;
    str:string;
begin
 riadky:=0;
 if pacient=1 then assign(f,Dir+'zasoba\dianie.pdr') else assign(f,Dir+'zasoba\pdianie.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,str);
 end;
 close(f);
 oldcol:=kac;
 kac:=pozn;
 tc:=kac;
 wrtln('< '+UnCode(str)+' >');
 tc:=oldcol;
 kac:=oldcol;
end;

procedure Neviem;
var riadky,x:word;
    str:string;
begin
 riadky:=0;
 if pacient=1 then assign(f,Dir+'zasoba\dontknow.pdr') else assign(f,Dir+'zasoba\pdntknow.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,str);
 end;
 close(f);
 if pacient=1 then wrtln(UnCode(str)) else wrtln('> '+LoCased(UnCode(str)));
end;

procedure Grazel(subor:string);
var riadky,x:word;
    str:string;
begin
 riadky:=0;
 assign(f,Dir+subor);
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,str);
 end;
 close(f);
 if pacient=0 then wrtln('> '+UnCode(str)) else wrtln(UnCode(str));
end;

procedure Diagnozy;
var riadky,x:word;
    str:string;
begin
 riadky:=0;
 assign(f,Dir+'zasoba\diagnoza.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,str);
 end;
 close(f);
 wrtln('Diagnoza - '+UnCode(str));
end;

procedure Dovidenia;
var riadky,x:word;
    str:string;
begin
 riadky:=0;
 if pacient=1 then assign(f,Dir+'zasoba\goodbye.pdr') else assign(f,Dir+'zasoba\pgoodbye.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,str);
 end;
 close(f);
 if pacient=0 then wrtln('> '+UnCode(str)) else wrtln(UnCode(str));
end;

procedure Liecba;
var riadky,x:word;
    str:string;
begin
 riadky:=0;
 assign(f,Dir+'zasoba\liecba.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,str);
 end;
 close(f);
 wrtln('Liecba   - '+UnCode(str));
end;

procedure Present;
var riadky,x:word;
    sr,yr,o1,o2,o3:string;
begin
 getdate(year,month,day,dow);
 sr:='';
 str(day,yr);
 sr:=yr+'.';
 str(month,yr);
 sr:=sr+yr+'.';
 if (day=13) and (dow=5) then begin
  if pacient=1 then wrtln('Vitaj! Dnes je piatok trinasteho! (moj stastny den)')
  else wrtln('> dobry den, doktor! piatok trinasteho je veru dnes!');
  iq0:=true;
  exit;
 end;
 if (day=1) and (month=4) then iq0:=true;
 str(year-1986,yr);
 if (day=23) and (month=6) then begin
  if pacient=1 then wrtln('Ahoj! Moj stvoritel Marek Hlavac ma dnes narodeniny! Ma '+yr+' rokov.')
  else wrtln('> dopocul som sa, ze tvoj stvoritel ma dnes '+yr+' rokov.');
  exit;
 end;
 if pacient=1 then assign(f,Dir+'zasoba\days.pdr') else Assign(f,Dir+'zasoba\pdays.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f,yr);
  readln(f,o1);
  readln(f,o2);
  readln(f,o3);
  if UnCode(yr)=sr then begin
   randomize;
   riadky:=random(3); { nie riadky, ale randomovka }
   case riadky of
    0:wrtln(UnCode(o1)+#13+#10);
    1:wrtln(UnCode(o2)+#13+#10);
    2:wrtln(UnCode(o3)+#13+#10);
   end;
   close(f);
   exit;
  end;
 end;
 close(f);
 riadky:=0;
 if pacient=1 then assign(f,Dir+'zasoba\present.pdr') else assign(f,Dir+'zasoba\ppresent.pdr');
 reset(f);
 while not eof(f) do begin
  readln(f);
  Inc(riadky);
 end;
 close(f);
 a:=random(riadky)+1;
 reset(f);
 for x:=1 to a do begin
  readln(f,sr);
 end;
 close(f);
 if pacient=1 then wrtln(UnCode(sr)) else wrtln('> '+LoCased(UnCode(sr)));
end;

procedure QuitKacn;
var cena_x:string;
begin
 Diagnozy;
 Liecba;
 if pacient=1 then begin
  Str(cena,cena_x);
  wrtln('Cena     - '+cena_x+' Sk');
  wrtln(' ');
 end;
end;

begin
 if (ParamStr(1)<>'qwerty0987654321~') and (ParamStr(2)<>'/*-+') then begin
  pac:=7;
  clrscr;
  writeln('Virtual Psycho System');
  writeln('Copyright (c) Aific 1998-2000 by Marek Hlavac');
  writeln;
  writeln('Run SEDLIAK.BAT, please.');
  halt;
 end;
 GetDir(0,Dir);
 Dir:=Dir+'\';
 R;
 LoadKeyb;
 if ParamStr(3)='1' then pacient:=0;
 if ParamStr(3)='2' then pacient:=1;
 if pacient=0 then begin
  pac:=pac+kac;
  kac:=pac-kac;
  pac:=pac-kac;
 end;
 textcolor(kac);
 clrscr;
 randomize;
 CursorOff;
 randomize;
 Reg.AH := $0C;
 Reg.AL := $06;
 Reg.DL := $FF;
 MsDos(Reg);
 AntiVirus;
 if autoprint=1 then begin
  {$I-}
  writeln(lst,' ');
  {$I+}
  if IOResult=0 then prn:=true else prn:=false;
  if prn=true then begin
   GetTime(hour,min,sec,sec100);
   GetDate(year,month,day,dow);
   wrtlnprn(#13+#10);
   writeln(lst,#27+#71+'SEDLIAK verzia '+Ver+'        CESTA K ESTE VACSIEMU PSYCHU');
   writeln(lst,'Copyright (c) Aific 1998-2000 by Marek Hlavac - ZAZNAM Z ROZHOVORU');
   writeln(lst,'DATUM: ',DenVT,' ',day,'.',month,'.',year,'  CAS: ',LeadingZero(hour),':',LeadingZero(min),
   ':',LeadingZero(sec),',',LeadingZero(sec100));
   writeln(lst,'------------------------------------------------------------------'+#27+#64);
  end;
 end;
 kec:='';
 kec2:='Program Copyright (c) Aific 1998-2000 by NIQ Marek Hlavac';
 kec3:='SEDLIAK v.2.00 - CESTA K ESTE VACSIEMU PSYCHU - full version';
 if zaznamy=1 then begin
  assign(f2,Dir+'zaznamy\zaznamy.txt');
  {$I-}
  reset(f2);
  {$I+}
  if IOresult<>0 then begin
   rewrite(f2);
   close(f2);
  end;
  GetDate(year,month,day,dow);
  GetTime(hour,min,sec,sec100);
  append(f2);
  writeln(f2,'SEDLIAK verzia '+Ver+'                CESTA K ESTE VACSIEMU PSYCHU');
  writeln(f2,'Copyright (c) Aific 1998-2000 by Marek Hlavac - ZAZNAM Z ROZHOVORU');
  writeln(f2,'DATUM: ',DenVT,' ',day,'.',month,'.',year,'  CAS: ',LeadingZero(hour),':',LeadingZero(min),
  ':',LeadingZero(sec),',',LeadingZero(sec100));
  writeln(f2,'------------------------------------------------------------------');
 end;
 CursorOff;
{ ThirdTalker;}
 gotoxy(0,24);
 Present;
 cena:=69; { pociatocna cena }
 repeat
  Reg.AH := $0C;
  Reg.AL := $06;
  Reg.DL := $FF;
  MsDos(Reg);
  if pacient=1 then write('> ');
  CursorOn;
  readlnT;
  CursorOff;
  Inc(cena,17);
  kecy:=kec;
  Xlat(kec,';.,:"''-=/!?<>+-*()[]%','                     ');
  kec:=getcore(kec);
  kec:=LoCased(kec);
  medzera:=false;
  c:=0;
  b:=length(kec);
  repeat
   Inc(c);
   if c>b then break;
   if (kec[c]<>#32) then medzera:=false;
   if (kec[c]=#32) and (medzera=true) then begin
    Dec(c);
    delete(kec,c,1);
    goto 002;
   end;
   if (kec[c]=#32) then medzera:=true;
   002:
  until false;
  if zaznamy=1 then begin
   if pacient=1 then writeln(f2,'> '+kecy) else writeln(f2,kecy);
  end;
  if pacient=1 then wrtlnprn('> '+#27+#52+kecy+#13+#10+#27+#64) else
   wrtlnprn(#27+#64+kecy+#13+#10);
  if (GetCore(kecy)='') then goto 001;
  if LoCased(kecy)='.cls' then begin
   clrscr;
   goto 001;
  end;
  if LoCased(kecy)='.iq0 on' then begin
   if iq0 then
    WrtLn('Kamos, cheat je uz aktivovany, tak daj pokoj.'+#13+#10)
   else begin
    WrtLn('LET''S CHEAT! Kecam uplne odveci!'+#13+#10);
    iq0:=true;
   end;
   goto 001;
  end;
  if LoCased(kecy)='.iq0 off' then begin
   if iq0 then begin
    WrtLn('CHEAT JE V HAJI! Uz som "rozumnejsi".'+#13+#10);
    iq0:=false end
   else begin
    WrtLn('Neotravuj. Cheat nie je aktivovany.'+#13+#10);
   end;
   goto 001;
  end;
  if LoCased(kecy)='.magyar on' then begin
   if magyar then
    WrtLn('Nem tudom, kekes, nem tudom.')
   else begin
    magyar:=true;
    WrtLn('Igen.'+#13+#10);
   end;
   goto 001;
  end;
  if LoCased(kecy)='.mikita on' then begin
   if mikita then
    WrtLn('Vacsi grazel uz neexistuje!'+#13+#10)
   else begin
    mikita:=true;
    WrtLn('COME ON EVERYBODY AND CHEAT! Budem ti nadavat!'+#13+#10);
   end;
   goto 001;
  end;
  if LoCased(kecy)='.magyar off' then begin
   if magyar then begin
    WrtLn('Tudom. Nem magyar.');
    magyar:=false end
   else begin
    WrtLn('A co som Madar?');
   end;
   goto 001;
  end;
  if LoCased(kecy)='.mikita off' then begin
   if mikita then begin
    WrtLn('I AM GOING TO BE A NORMAL MAN AGAIN! CHEAT IS NOW DEACTIVATED!'+#13+#10);
    mikita:=false end
   else begin
    WrtLn('Ani nie som grazel!'+#13+#10);
   end;
   goto 001;
  end;
  if LoCased(kecy)='.time' then begin
   GetTime(hour,min,sec,sec100);
   odp1:=LeadingZero(hour)+':'+LeadingZero(min);
   WrtLn('Wohoha! Ako chces, kajo, yeah, tu mas (mozno) presny cas: '+odp1);
   kecy:='.time';
   goto 001;
  end;
  if (LoCased(kecy)='.pohreb') and (pacient=0) then begin
   ClrScr;
   WrtLn('MOJE ZAZITKY Z POHREBU PACIENTA: ');
   WrtLn(' Vykec farara: "Zdechni!"');
   WrtLN(' Pacient     : "Nechce sa mi!"');
   WrtLN(' Vykec farara: (tattattatta) "...a sme radi, ze tento clovek pred svojim killom navstivil psychiatra"');
   WrtLn(' Kacn        : "Dakujem za podporu, pater Ralf."');
   WrtLn(' (Vtaky odleteli a napichli sa na trnie.)');
   WrtLn('');
   WrtLn('       лллллллл');
   WrtLn('       лллллллл');
   WrtLn('       лллллллл');
   WrtLn('  лллллchudatkaлллл');
   WrtLn('  лллллvtakyллллллл');
   WrtLn('       лллллллл');
   WrtLn('       лллллллл');
   WrtLn('       лллллллл');
   WrtLn('       лллллллл');
   WrtLn('       лллллллл');
   WrtLn('');
   nahnevanost:=0;
   goto 001;
  end;
  Vyhodnotenie:
  a:=random(10);
  if a=0 then Dianie;
  if nahnevanost>7 then begin
   kec2:=kec;
   kec3:=kec2;
   kec4:=kec3;
  end;
  if (kec=kec2) and (kec=kec3) and (kec=kec4) then begin
   if pacient=1 then begin
    if nahnevanost<3 then begin
    a:=random(4);
    case a of
     0: wrtln('Pacient moj, mna tymto nenastves...');
     1: wrtln('Ja som este kludas...');
     2: wrtln('Vies hovorit daco ine?');
     3: wrtln('Snad ma nechces nahnevat?');
    end;
   end;
   if (nahnevanost>2) and (nahnevanost<6) then begin
    a:=random(4);
    case a of
     0: wrtln('Pocuvaj, uz s tym prestan!');
     1: wrtln('Bud uz konecne ticho!');
     2: wrtln('Radsej mlc!');
     3: wrtln('Sklapni!');
    end;
   end;
   if (nahnevanost>5) and (nahnevanost<8) then begin
    a:=random(4);
    case a of
     0: wrtln('Aaaaaaargh!');
     1: wrtln('Whoa, nieeeeeeeeeeeeeeeee...');
     2: wrtln('Stop! Mlc! Cuuuuuuuuuuus!');
     3: wrtln('Strielam... tatatatata');
    end;
   end;
   if nahnevanost=8 then wrtln('(...Kacn sa psychicky zrutil...)');
   if nahnevanost=9 then wrtln('(...Kacn je zruteny....)');
   if nahnevanost=10 then wrtln('(Nepocujes, Kacn je zruteny!)');
   if nahnevanost=11 then wrtln('(...uz sa rozklada...)');
   if nahnevanost=12 then wrtln('(...je rozlozeny na mikroskopicke ciastocky...)');
   if nahnevanost>12 then wrtln('(...)');
   if nahnevanost<14 then Inc(nahnevanost);
   end else begin
    if nahnevanost<3 then begin
    a:=random(4);
    case a of
     0: wrtln('> pan doktor, stalo sa vam nieco?');
     1: wrtln('> kacn, uz sa nejako opakujes!');
     2: wrtln('> pudr. michal kacabaya, co sa s vami deje?');
     3: wrtln('> nejako vam zasibava!');
    end;
   end;
   if (nahnevanost>2) and (nahnevanost<6) then begin
    a:=random(4);
    case a of
     0: wrtln('> zobudte sa, pan psychiater!');
     1: wrtln('> doktor, nepatrite na psychiatriu?');
     2: wrtln('> cus uz dokelu, Kacn!');
     3: wrtln('> shut up, my dear doctor!');
    end;
   end;
   if (nahnevanost>5) and (nahnevanost<8) then begin
    a:=random(4);
    case a of
     0: wrtln('> kaacaaabaaaayaaaaa! tiichooo!');
     1: wrtln('> uz stacilo! mam dost!');
     2: wrtln('> mam novu motorovu pilu...');
     3: wrtln('> psychiater sprosty, este raz zo seba nieco vykecas a killnem ta!');
    end;
   end;
   if nahnevanost=8 then wrtln('> (...pacientovi sa zle dycha...)');
   if nahnevanost=9 then wrtln('> (...prestava dychat....)');
   if nahnevanost=10 then wrtln('> (...nebije mu srdce...)');
   if nahnevanost=11 then wrtln('> (...v ordinacii to smrdi hnilobou...)');
   if nahnevanost=12 then wrtln('> (...uz mu asi niet pomoci...)');
   if nahnevanost>12 then wrtln('> (...mal by si ho pochovat...)');
   if nahnevanost<14 then Inc(nahnevanost);
   end;
   goto 001;
  end;
  if nahnevanost<8 then nahnevanost:=0;
  if (kec='vytlac rozhovor') or (kec='tlac rozhovor') or
  (kec='zapni tlac') then begin
   if prn=true then begin
    wrtln('Uz ho tlacim!');
    goto 001;
   end;
   {$I-}
   write(lst,#13+#10);
   {$I+}
   if IOResult<>0 then begin
    wrtln('Nemas zapnutu tlaciaren!');
    goto 001;
   end;
   wrtln('Fajn, odteraz tlacim nas rozhovor!');
   prn:=true;
   GetTime(hour,min,sec,sec100);
   GetDate(year,month,day,dow);
   writeln(lst,#27+#71+'SEDLIAK verzia '+Ver+'           CESTA K ESTE VACSIEMU PSYCHU');
   writeln(lst,'Copyright (c) Aific 1998-2000 by Marek Hlavac - ZAZNAM Z ROZHOVORU');
   writeln(lst,'DATUM: '+DenVT+' ',day,'.',month,'.',year,'  CAS: ',LeadingZero(hour),':',LeadingZero(min),
   ':',LeadingZero(sec),',',LeadingZero(sec100));
   writeln(lst,'------------------------------------------------------------------'+#27+#64);
   goto 001;
  end;
  if (kec='netlac rozhovor') or (kec='vypni tlac') or (kec='prestan tlacit')
  then begin
   if prn=false then begin
    wrtln('Pche, netlacil som ho!');
   end;
   prn:=false;
   wrtln('Tvoje prianie je mi rozkazom!!!');
   goto 001;
  end;
  if mikita then begin
   Grazel('zasoba\mukutu.pdr');
   goto 001;
  end;
  if magyar then begin
   Grazel('zasoba\magyar.pdr');
   goto 001;
  end;
  if iq0 then begin
   a:=random(kpw)+1;
   assign(f,Dir+'zasoba\slova0'+LeadingZero(a)+'.pdr');
   reset(f);
   o:=0;
   while not eof(f) do begin
    readln(f);
    Inc(o);
   end;
   close(f);
   reset(f);
   for a:=1 to random(o)+1 do readln(f,odp1);
   WrtLn(UnCode(odp1)+#13+#10);
   close(f);
   goto 001;
  end;
  yesdef:=true;
  if (StOtazka=false) then begin
   if (Slovo3=false) then begin
    if (Number=false) then begin
     Neviem;
     yesdef:=false;
    end;
   end;
  end;
  001:
  kec4:=kec3;
  kec3:=kec2;
  kec2:=kec;
 until getcore(Kecy)='';
 if nahnevanost<8 then Dovidenia;
 WrtLn(' ');
 if nahnevanost>7 then begin
  if pacient=1 then
   WrtLn('...Kacn je psychicky uplne na dne a nie je schophny urcit diagnozu...')
  else
   WrtLn('...Sorry, pacient sa uz neda vyhodit z ordinacie, pretoze zhnil...');
 end else if pacient=1 then QuitKacn;
 if zaznamy=1 then close(f2);
 ch:=readkey(true);
 Reg.AH := $0C;
 Reg.AL := $06;
 Reg.DL := $FF;
 MsDos(Reg);
 CursorOn;
end.