program KACN_JE_PUDR;
uses crt,dos;
var f,g:text;
    Dir:DirStr;
    Name:NameStr;
    Ext:ExtStr;
    z:string;
    res,xx,wrt:word;
begin
 FSplit(ParamStr(0),Dir,Name,Ext);
 if ParamStr(3)='zxcvbnm' then begin
  assign(f,Dir+ParamStr(1));
  assign(g,Dir+ParamStr(2));
  {$I-}
  reset(f);
  rewrite(g);
  {$I+}
  while not eof(f) do begin
   readln(f,z);
   for xx:=1 to length(z) do if ord(z[xx])<253 then z[xx]:=chr(ord(z[xx])+2);
   writeln(g,z);
  end;
  close(f);
  close(g);
  halt;
 end;
 if ParamStr(3)='mnbvcxz' then begin
  assign(f,Dir+ParamStr(1));
  assign(g,Dir+ParamStr(2));
  {$I-}
  reset(f);
  rewrite(g);
  {$I+}
  while not eof(f) do begin
   readln(f,z);
   for xx:=1 to length(z) do if ord(z[xx])<253 then z[xx]:=chr(ord(z[xx])-2);
   writeln(g,z);
  end;
  close(f);
  close(g);
  halt;
 end;
end.
