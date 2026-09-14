unit WStringUtils;
// Shared string helpers before NoSteamAchievemens. WStringUtils is the native
// linked unit in this dependency family; attribution is inferred from that context.

interface

type PStartupWideString = ^WideString;

function AllocateStartupWideString(Length: Integer): PStartupWideString; // @addr $59297C
function FreeStartupWideString(var Text: PStartupWideString): Boolean; // @addr $5929EC Does not clear the disposed pointer.

function TruncateStartupWideString(var Text: PStartupWideString): PStartupWideString; // @addr $5929AC @note "Shrinks a caller-provided WideString to its first zero. Requires a valid pointer and a terminator within the buffer."

implementation

{ @routine $59297C AllocateStartupWideString }
function AllocateStartupWideString(Length: Integer): PStartupWideString;
begin
  New(Result);
  SetLength(Result^, Length);
end;
{ @end $59297C }

{ @routine $5929AC TruncateStartupWideString }
function TruncateStartupWideString(var Text: PStartupWideString): PStartupWideString;
var Count: Integer;
begin
  Count := 0;
  while Text^[Count + 1] <> #0 do Inc(Count);
  SetLength(Text^, Count);
  Result := Text;
end;
{ @end $5929AC }

{ @routine $5929EC FreeStartupWideString }
function FreeStartupWideString(var Text: PStartupWideString): Boolean;
begin
  Result := False;
  if Text <> nil then
  begin
    Dispose(Text);
    Result := True;
  end;
end;
{ @end $5929EC }

end.
