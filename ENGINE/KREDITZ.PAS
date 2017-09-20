{$A-,B-,D-,E+,F+,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,0,655360}
program Kreditz;
uses dos,keyb,crt2;
var str:string;
    f:text;
    cnt,tc:byte;
    ch:char;

procedure Audio(a:word);assembler;
asm
 {---preparation for CRT passage---}
 {---passage from CRT:---}
        MOV	BX,SP
	MOV	BX,SS:[BX+4]
	MOV	AX,34DDH
	MOV	DX,0012H
	CMP	DX,BX
	JNC	@@2
	DIV	BX
	MOV	BX,AX
	IN	AL,61H
	TEST	AL,3
	JNZ	@@1
	OR	AL,3
	OUT	61H,AL
	MOV	AL,0B6H
	OUT	43H,AL
@@1:	MOV	AL,BL
	OUT	42H,AL
	MOV	AL,BH
	OUT	42H,AL
@@2:
end;

procedure NoSound;assembler;
asm
 {nosound CRT passage}
	IN	AL,61H
	AND	AL,0FCH
	OUT	61H,AL
end;

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
     { My ULTIMATE solve of the Pentium II problem: }
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
 for a:=1 to length(z) do if ord(z[a])<254 then zz:=zz+chr(ord(z[a])-2);
 UnCode:=zz;
end;

begin
 randomize;
 ClearTA;
 clrscr;
 assign(f,'zasoba\kreditz.pdr');
 reset(f);
 CursorOff;
 cnt:=0;
 while not eof(f) do begin
  readln(f,str);
  if Uncode(str[1])='$' then textcolor(10) else textcolor(2);
  if str='' then begin
   textcolor(0);
   str:='losos prababka';
  end;
  gotoxy(1,24);
  wrtln(UnCode(copy(str,2,length(str))));
  inc(cnt);
  if cnt=24 then begin
   ch:=readkey;
   cnt:=0;
  end;
  randomize;
  dosdelay(300);
  ClearTA;
 end;
 close(f);
 textcolor(7);
 write('');
 ch:=readkey;
 CursorOn;
 ClearTA;
end.