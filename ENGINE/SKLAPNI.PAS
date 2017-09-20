program Sklapni;
procedure NoSound;assembler;
asm
 {nosound CRT passage}
	IN	AL,61H
	AND	AL,0FCH
	OUT	61H,AL
end;
begin
 if ParamStr(1)<>'25890rp' then writeln('A bud uz konecne ticho!');
 nosound;
end.