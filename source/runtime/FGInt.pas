{License, info, etc
 ------------------
This implementation is made by me, Walied Othman, to contact me
mail to rainwolf@submanifold.be or triade@submanifold.be ,
always mention wether it 's about the FGInt or about the 6xs,
preferably in the subject line.
This source code is free, but only to other free software,
it's a two-way street, if you use this code in an application from which
you won't make any money of (e.g. software for the good of mankind)
then go right ahead, I won't stop you, I do demand acknowledgement for
my work.  However, if you're using this code in a commercial application,
an application from which you'll make money, then yes, I charge a
license-fee, as described in the license agreement for commercial use, see
the textfile in this zip-file.
If you 're going to use these implementations, let me know, so I ca, put a link
on my page if desired, I 'm always curious as to see where the spawn of my
mind ends up in.  If any algorithm is patented in your country, you should
acquire a license before using this software.  Modified versions of this
software must contain an acknowledgement of the original author (=me).

This implementation is available at
http://www.submanifold.be

copyright 2000, Walied Othman
This header may not be removed.}

unit FGInt;

{$I GameOptions.inc}

interface

uses
  SysUtils;

type

  {$Z1}
  TCompare = (Lt = 0, St = 1, Eq = 2, Er = 3);

  {$Z1}
  TSign = (negative = 0, positive = 1);

  TFGInt = record
    Sign: TSign;
    Gap1: array[0..2] of Byte;
    Number: array of LongWord;
  end;

var

  chr64: array[1..64] of Char = (
      'a',
      'A',
      'b',
      'B',
      'c',
      'C',
      'd',
      'D',
      'e',
      'E',
      'f',
      'F',
      'g',
      'G',
      'h',
      'H',
      'i',
      'I',
      'j',
      'J',
      'k',
      'K',
      'l',
      'L',
      'm',
      'M',
      'n',
      'N',
      'o',
      'O',
      'p',
      'P',
      'q',
      'Q',
      'r',
      'R',
      's',
      'S',
      't',
      'T',
      'u',
      'U',
      'v',
      'V',
      'w',
      'W',
      'x',
      'X',
      'y',
      'Y',
      'z',
      'Z',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '+',
      '='
  );

procedure zeronetochar8(var g: char; const x: AnsiString);

procedure zeronetochar6(var g: integer; const x: AnsiString);

procedure initialize8(var trans: array of AnsiString);

procedure initialize6(var trans: array of AnsiString);

procedure FGIntDecodeBase64(const str64: AnsiString; var str256: AnsiString);

procedure ConvertBase256to2(const str256: AnsiString; var str2: AnsiString);

procedure ConvertBase2to256(str2: AnsiString; var str256: AnsiString);

procedure FGIntToBase2String(const FGInt: TFGInt; var S: AnsiString);

procedure Base2StringToFGInt(S: AnsiString; var FGInt: TFGInt);

procedure FGIntFromBytes(str256: AnsiString; var FGInt: TFGInt);

procedure Base10StringToFGInt(Base10: AnsiString; var FGInt: TFGInt);

procedure FGIntClear(var FGInt: TFGInt);

function FGIntCompareAbs(const FGInt1: TFGInt; const FGInt2: TFGInt): TCompare;

procedure FGIntAdd(const FGInt1: TFGInt; const FGInt2: TFGInt; var Sum: TFGInt);

procedure FGIntChangeSign(var FGInt: TFGInt);

procedure FGIntSub(var FGInt1: TFGInt; var FGInt2: TFGInt; var dif: TFGInt);

procedure FGIntMulByIntbis(var FGInt: TFGInt; by: LongWord);

procedure FGIntDivByIntBis(var FGInt: TFGInt; by: LongWord; var modres: LongWord);

procedure FGIntAbs(var FGInt: TFGInt);

procedure FGIntCopy(const FGInt1: TFGInt; var FGInt2: TFGInt);

procedure FGIntShiftRightBy31(var FGInt: TFGInt);

procedure FGIntSubBis(var FGInt1: TFGInt; const FGInt2: TFGInt);

procedure FGIntMul(const FGInt1: TFGInt; const FGInt2: TFGInt; var Prod: TFGInt);

procedure FGIntSquare(const FGInt: TFGInt; var Square: TFGInt);

procedure FGIntShiftLeftBy31(var FGInt: TFGInt);

procedure FGIntDivMod(
    var FGInt1: TFGInt;
    var FGInt2: TFGInt;
    var QFGInt: TFGInt;
    var MFGInt: TFGInt
);

procedure FGIntMod(var FGInt1: TFGInt; var FGInt2: TFGInt; var MFGInt: TFGInt);

procedure FGIntMulMod(
    var FGInt1: TFGInt;
    var FGInt2: TFGInt;
    var base: TFGInt;
    var FGIntres: TFGInt
);

procedure FGIntModBis(const FGInt: TFGInt; var FGIntOut: TFGInt; b: LongWord; head: LongWord);

procedure FGIntMulModBis(
    const FGInt1: TFGInt;
    const FGInt2: TFGInt;
    var Prod: TFGInt;
    b: LongWord;
    head: LongWord
);

procedure FGIntMontgomeryMod(
    const GInt: TFGInt;
    const base: TFGInt;
    const baseInv: TFGInt;
    var MGInt: TFGInt;
    b: Longword;
    head: LongWord
);

procedure FGIntMontgomeryModExp(
    var FGInt: TFGInt;
    var exp: TFGInt;
    var modb: TFGInt;
    var res: TFGInt
);

procedure FGIntGCD(const FGInt1: TFGInt; const FGInt2: TFGInt; var GCD: TFGInt);

procedure FGIntModInv(const FGInt1: TFGInt; const base: TFGInt; var Inverse: TFGInt);

implementation

uses
  Math;

procedure zeronetochar8(var g: char; const x: AnsiString);
var
  i: Integer;
  b: byte;
begin
  b := 0;
  for i := 1 to 8 do
  begin
    if copy(x, i, 1) = '1' then
      b := b or (1 shl (8 - I));
  end;
  g := chr(b);
end;

procedure zeronetochar6(var g: integer; const x: AnsiString);
var
  I: Integer;
begin
  G := 0;
  for I := 1 to Length(X) do
  begin
    if I > 6 then
      Break;
    if X[I] <> '0' then
      G := G or (1 shl (6 - I));
  end;
  Inc(G);
end;

procedure initialize8(var trans: array of AnsiString);
var
  c1, c2, c3, c4, c5, c6, c7, c8: integer;
  x: AnsiString;
  g: char;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
              for c7 := 0 to 1 do
                for c8 := 0 to 1 do
                begin
                  x :=
                      chr(48 + c1)
                          + chr(48 + c2)
                          + chr(48 + c3)
                          + chr(48 + c4)
                          + chr(48 + c5)
                          + chr(48 + c6)
                          + chr(48 + c7)
                          + chr(48 + c8);
                  zeronetochar8(g, x);
                  trans[ord(g)] := x;
                end;
end;

procedure initialize6(var trans: array of AnsiString);
var
  c1, c2, c3, c4, c5, c6: integer;
  x: AnsiString;
  g: integer;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
            begin
              x :=
                  chr(48 + c1)
                      + chr(48 + c2)
                      + chr(48 + c3)
                      + chr(48 + c4)
                      + chr(48 + c5)
                      + chr(48 + c6);
              zeronetochar6(g, x);
              trans[ord(chr64[g])] := x;
            end;
end;

procedure FGIntDecodeBase64(const str64: AnsiString; var str256: AnsiString);
var
  temp: AnsiString;
  trans: array[0..255] of AnsiString;
  i, len8: longint;
  g: char;
begin
  initialize6(trans);
  temp := '';
  for i := 1 to length(str64) do
    temp := temp + trans[ord(str64[i])];
  str256 := '';
  len8 := length(temp) div 8;
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(temp, 1, 8));
    str256 := str256 + g;
    delete(temp, 1, 8);
  end;
end;

procedure ConvertBase256to2(const str256: AnsiString; var str2: AnsiString);
var
  trans: array[0..255] of AnsiString;
  i: longint;
begin
  str2 := '';
  initialize8(trans);
  for i := 1 to length(str256) do
    str2 := str2 + trans[ord(str256[i])];
end;

procedure ConvertBase2to256(str2: AnsiString; var str256: AnsiString);
var
  i, len8: longint;
  g: char;
begin
  str256 := '';
  while (length(str2) mod 8) <> 0 do
    str2 := '0' + str2;
  len8 := length(str2) div 8;
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(str2, 1, 8));
    str256 := str256 + g;
    delete(str2, 1, 8);
  end;
end;

procedure FGIntToBase2String(const FGInt: TFGInt; var S: AnsiString);
var
  i: LongWord;
  j: integer;
begin
  S := '';
  for i := 1 to FGInt.Number[0] do
  begin
    for j := 0 to 30 do
      if (1 and (FGInt.Number[i] shr j)) = 1 then
        S := '1' + S
      else
        S := '0' + S;
  end;
  while (length(S) > 1) and (S[1] = '0') do
    delete(S, 1, 1);
  if S = '' then
    S := '0';
end;

procedure Base2StringToFGInt(S: AnsiString; var FGInt: TFGInt);
var
  i, j, size: LongWord;
begin
  while (S[1] = '0') and (length(S) > 1) do
    delete(S, 1, 1);
  size := length(S) div 31;
  if (length(S) mod 31) <> 0 then
    size := size + 1;
  SetLength(FGInt.Number, (size + 1));
  FGInt.Number[0] := size;
  j := 1;
  FGInt.Number[j] := 0;
  i := 0;
  while length(S) > 0 do
  begin
    if S[length(S)] = '1' then
      FGInt.Number[j] := FGInt.Number[j] or (1 shl i);
    i := i + 1;
    if i = 31 then
    begin
      i := 0;
      j := j + 1;
      if j <= size then
        FGInt.Number[j] := 0;
    end;
    delete(S, length(S), 1);
  end;
  FGInt.Sign := positive;
end;

procedure FGIntFromBytes(str256: AnsiString; var FGInt: TFGInt);
var
  temp1: AnsiString;
  i: longint;
  trans: array[0..255] of AnsiString;
begin
  temp1 := '';
  initialize8(trans);
  for i := 1 to length(str256) do
    temp1 := temp1 + trans[ord(str256[i])];
  while (temp1[1] = '0') and (temp1 <> '0') do
    delete(temp1, 1, 1);
  Base2StringToFGInt(temp1, FGInt);
end;

procedure Base10StringToFGInt(Base10: AnsiString; var FGInt: TFGInt);
var
  i, size: LongWord;
  j: word;
  S, x: AnsiString;
  sign: TSign;

  procedure GIntDivByIntBis1(var GInt: TFGInt; by: LongWord; var modres: word);
  var
    i, size, rest, temp: LongWord;
  begin
    size := GInt.Number[0];
    temp := 0;
    for i := size downto 1 do
    begin
      temp := temp * 10000;
      rest := temp + GInt.Number[i];
      GInt.Number[i] := rest div by;
      temp := rest mod by;
    end;
    modres := temp;
    while (GInt.Number[size] = 0) and (size > 1) do
      size := size - 1;
    if size <> GInt.Number[0] then
    begin
      SetLength(GInt.Number, size + 1);
      GInt.Number[0] := size;
    end;
  end;

begin
  while (not (Base10[1] in ['-', '0'..'9'])) and (length(Base10) > 1) do
    delete(Base10, 1, 1);
  if copy(Base10, 1, 1) = '-' then
  begin
    Sign := negative;
    delete(Base10, 1, 1);
  end
  else
    Sign := positive;
  while (length(Base10) > 1) and (copy(Base10, 1, 1) = '0') do
    delete(Base10, 1, 1);
  size := length(Base10) div 4;
  if (length(Base10) mod 4) <> 0 then
    size := size + 1;
  SetLength(FGInt.Number, size + 1);
  FGInt.Number[0] := size;
  for i := 1 to (size - 1) do
  begin
    x := copy(Base10, length(Base10) - 3, 4);
    FGInt.Number[i] := StrToInt(x);
    delete(Base10, length(Base10) - 3, 4);
  end;
  FGInt.Number[size] := StrToInt(Base10);

  S := '';
  while (FGInt.Number[0] <> 1) or (FGInt.Number[1] <> 0) do
  begin
    GIntDivByIntBis1(FGInt, 2, j);
    S := inttostr(j) + S;
  end;
  if S = '' then
    S := '0';
  FGIntClear(FGInt);
  Base2StringToFGInt(S, FGInt);
  FGInt.Sign := sign;
end;

procedure FGIntClear(var FGInt: TFGInt);
begin
  FGInt.Number := nil;
end;

function FGIntCompareAbs(const FGInt1, FGInt2: TFGInt): TCompare;
var
  size1, size2, i: LongWord;
begin
  FGIntCompareAbs := Er;
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 > size2 then
    FGIntCompareAbs := Lt
  else if size1 < size2 then
    FGIntCompareAbs := St
  else
  begin
    i := size2;
    while (FGInt1.Number[i] = FGInt2.Number[i]) and (i > 1) do
      i := i - 1;
    if FGInt1.Number[i] = FGInt2.Number[i] then
      FGIntCompareAbs := Eq
    else if FGInt1.Number[i] < FGInt2.Number[i] then
      FGIntCompareAbs := St
    else if FGInt1.Number[i] > FGInt2.Number[i] then
      FGIntCompareAbs := Lt;
  end;
end;

procedure FGIntAdd(const FGInt1, FGInt2: TFGInt; var Sum: TFGInt);
var
  i, size1, size2, size, rest, Trest: LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 < size2 then
    FGIntAdd(FGInt2, FGInt1, Sum)
  else
  begin
    if FGInt1.Sign = FGInt2.Sign then
    begin
      Sum.Sign := FGInt1.Sign;
      setlength(Sum.Number, (size1 + 2));
      rest := 0;
      for i := 1 to size2 do
      begin
        Trest := FGInt1.Number[i];
        Trest := Trest + FGInt2.Number[i];
        Trest := Trest + rest;
        Sum.Number[i] := Trest and 2147483647;
        rest := Trest shr 31;
      end;
      for i := (size2 + 1) to size1 do
      begin
        Trest := FGInt1.Number[i] + rest;
        Sum.Number[i] := Trest and 2147483647;
        rest := Trest shr 31;
      end;
      size := size1 + 1;
      Sum.Number[0] := size;
      Sum.Number[size] := rest;
      while (Sum.Number[size] = 0) and (size > 1) do
        size := size - 1;
      if Sum.Number[0] <> size then
        SetLength(Sum.Number, size + 1);
      Sum.Number[0] := size;
    end
    else
    begin
      if FGIntCompareAbs(FGInt2, FGInt1) = Lt then
        FGIntAdd(FGInt2, FGInt1, Sum)
      else
      begin
        SetLength(Sum.Number, (size1 + 1));
        rest := 0;
        for i := 1 to size2 do
        begin
          Trest := 2147483648;
          TRest := Trest + FGInt1.Number[i];
          TRest := Trest - FGInt2.Number[i];
          TRest := Trest - rest;
          Sum.Number[i] := Trest and 2147483647;
          if (Trest > 2147483647) then
            rest := 0
          else
            rest := 1;
        end;
        for i := (size2 + 1) to size1 do
        begin
          Trest := 2147483648;
          TRest := Trest + FGInt1.Number[i];
          TRest := Trest - rest;
          Sum.Number[i] := Trest and 2147483647;
          if (Trest > 2147483647) then
            rest := 0
          else
            rest := 1;
        end;
        size := size1;
        while (Sum.Number[size] = 0) and (size > 1) do
          size := size - 1;
        if size <> size1 then
          SetLength(Sum.Number, size + 1);
        Sum.Number[0] := size;
        Sum.Sign := FGInt1.Sign;
      end;
    end;
  end;
end;

procedure FGIntChangeSign(var FGInt: TFGInt);
begin
  if FGInt.Sign = negative then
    FGInt.Sign := positive
  else
    FGInt.Sign := negative;
end;

procedure FGIntSub(var FGInt1, FGInt2, dif: TFGInt);
begin
  FGIntChangeSign(FGInt2);
  FGIntAdd(FGInt1, FGInt2, dif);
  FGIntChangeSign(FGInt2);
end;

procedure FGIntMulByIntbis(var FGInt: TFGInt; by: LongWord);
var
  i, size, rest: LongWord;
  Trest: int64;
begin
  size := FGInt.Number[0];
  Setlength(FGInt.Number, size + 2);
  rest := 0;
  for i := 1 to size do
  begin
    Trest := FGInt.Number[i];
    TRest := Trest * by;
    TRest := Trest + rest;
    FGInt.Number[i] := Trest and 2147483647;
    rest := Trest shr 31;
  end;
  if rest <> 0 then
  begin
    size := size + 1;
    FGInt.Number[size] := rest;
  end
  else
    SetLength(FGInt.Number, size + 1);
  FGInt.Number[0] := size;
end;

procedure FGIntDivByIntBis(var FGInt: TFGInt; by: LongWord; var modres: LongWord);
var
  i, size: LongWord;
  temp, rest: int64;
begin
  size := FGInt.Number[0];
  temp := 0;
  for i := size downto 1 do
  begin
    temp := temp shl 31;
    rest := temp or FGInt.Number[i];
    FGInt.Number[i] := rest div by;
    temp := rest mod by;
  end;
  modres := temp;
  while (FGInt.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> FGInt.Number[0] then
  begin
    SetLength(FGInt.Number, size + 1);
    FGInt.Number[0] := size;
  end;
end;

procedure FGIntAbs(var FGInt: TFGInt);
begin
  FGInt.Sign := positive;
end;

procedure FGIntCopy(const FGInt1: TFGInt; var FGInt2: TFGInt);
begin
  FGInt2.Sign := FGInt1.Sign;
  FGInt2.Number := nil;
  FGInt2.Number := Copy(FGInt1.Number, 0, FGInt1.Number[0] + 1);
end;

procedure FGIntShiftRightBy31(var FGInt: TFGInt);
var
  size, i: LongWord;
begin
  size := FGInt.Number[0];
  if size > 1 then
  begin
    for i := 1 to size - 1 do
    begin
      FGInt.Number[i] := FGInt.Number[i + 1];
    end;
    SetLength(FGInt.Number, Size);
    FGInt.Number[0] := size - 1;
  end
  else
    FGInt.Number[1] := 0;
end;

procedure FGIntSubBis(var FGInt1: TFGInt; const FGInt2: TFGInt);
var
  i, size1, size2, rest, Trest: LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  rest := 0;
  for i := 1 to size2 do
  begin
    Trest := (2147483648 or FGInt1.Number[i]) - FGInt2.Number[i] - rest;
    if (Trest > 2147483647) then
      rest := 0
    else
      rest := 1;
    FGInt1.Number[i] := Trest and 2147483647;
  end;
  for i := size2 + 1 to size1 do
  begin
    Trest := (2147483648 or FGInt1.Number[i]) - rest;
    if (Trest > 2147483647) then
      rest := 0
    else
      rest := 1;
    FGInt1.Number[i] := Trest and 2147483647;
  end;
  i := size1;
  while (FGInt1.Number[i] = 0) and (i > 1) do
    i := i - 1;
  if i <> size1 then
  begin
    SetLength(FGInt1.Number, i + 1);
    FGInt1.Number[0] := i;
  end;
end;

procedure FGIntMul(const FGInt1, FGInt2: TFGInt; var Prod: TFGInt);
var
  i, j, size, size1, size2, rest: LongWord;
  Trest: int64;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  size := size1 + size2;
  SetLength(Prod.Number, (size + 1));
  for i := 1 to size do
    Prod.Number[i] := 0;

  for i := 1 to size2 do
  begin
    rest := 0;
    for j := 1 to size1 do
    begin
      Trest := FGInt1.Number[j];
      Trest := Trest * FGInt2.Number[i];
      Trest := Trest + Prod.Number[j + i - 1];
      Trest := Trest + rest;
      Prod.Number[j + i - 1] := Trest and 2147483647;
      rest := Trest shr 31;
    end;
    Prod.Number[i + size1] := rest;
  end;

  Prod.Number[0] := size;
  while (Prod.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> Prod.Number[0] then
  begin
    SetLength(Prod.Number, size + 1);
    Prod.Number[0] := size;
  end;
  if FGInt1.Sign = FGInt2.Sign then
    Prod.Sign := Positive
  else
    prod.Sign := negative;
end;

procedure FGIntSquare(const FGInt: TFGInt; var Square: TFGInt);
var
  size, size1, i, j, rest: LongWord;
  Trest: int64;
begin
  size1 := FGInt.Number[0];
  size := 2 * size1;
  SetLength(Square.Number, (size + 1));
  Square.Number[0] := size;
  for i := 1 to size do
    Square.Number[i] := 0;
  for i := 1 to size1 do
  begin
    Trest := FGInt.Number[i];
    Trest := Trest * FGInt.Number[i];
    Trest := Trest + Square.Number[2 * i - 1];
    Square.Number[2 * i - 1] := Trest and 2147483647;
    rest := Trest shr 31;
    for j := i + 1 to size1 do
    begin
      Trest := FGInt.Number[i] shl 1;
      Trest := Trest * FGInt.Number[j];
      Trest := Trest + Square.Number[i + j - 1];
      Trest := Trest + rest;
      Square.Number[i + j - 1] := Trest and 2147483647;
      rest := Trest shr 31;
    end;
    Square.Number[i + size1] := rest;
  end;
  Square.Sign := positive;
  while (Square.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> (2 * size1) then
  begin
    SetLength(Square.Number, size + 1);
    Square.Number[0] := size;
  end;
end;

procedure FGIntShiftLeftBy31(var FGInt: TFGInt);
var
  f1, f2: LongWord;
  i, size: longint;
begin
  size := FGInt.Number[0];
  SetLength(FGInt.Number, size + 2);
  f1 := 0;
  for i := 1 to (size + 1) do
  begin
    f2 := FGInt.Number[i];
    FGInt.Number[i] := f1;
    f1 := f2;
  end;
  FGInt.Number[0] := size + 1;
end;

procedure FGIntDivMod(var FGInt1, FGInt2, QFGInt, MFGInt: TFGInt);
var
  one, zero, temp1, temp2: TFGInt;
  s1, s2: TSign;
  j, s, t: LongWord;
  i: int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> St then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    SetLength(QFGInt.Number, (s + 2));
    QFGInt.Number[0] := s + 1;
    for t := 1 to s do
    begin
      FGIntShiftLeftBy31(temp1);
      QFGInt.Number[t] := 0;
    end;
    j := s + 1;
    QFGInt.Number[j] := 0;
    while FGIntCompareAbs(MFGInt, FGInt2) <> St do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> St do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl 31;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntbis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          QFGInt.Number[j] := QFGInt.Number[j] + i;
          if FGIntCompareAbs(MFGInt, temp2) <> St then
          begin
            QFGInt.Number[j] := QFGInt.Number[j] + i;
            FGIntSubBis(MFGInt, temp2);
          end;
          FGIntClear(temp2);
        end
        else
        begin
          QFGInt.Number[j] := QFGInt.Number[j] + 1;
          FGIntSubBis(MFGInt, temp1);
        end;
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> Eq then
        begin
          FGIntShiftRightBy31(temp1);
          j := j - 1;
        end;
    end;
  end
  else
    Base10StringToFGInt('0', QFGInt);
  s := QFGInt.Number[0];
  while (s > 1) and (QFGInt.Number[s] = 0) do
    s := s - 1;
  if s < QFGInt.Number[0] then
  begin
    setlength(QFGInt.Number, s + 1);
    QFGInt.Number[0] := s;
  end;
  QFGInt.Sign := positive;

  FGIntClear(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> Eq then
    begin
      FGIntadd(QFGInt, one, temp1);
      FGIntClear(QFGInt);
      FGIntCopy(temp1, QFGInt);
      FGIntClear(temp1);
      FGIntsub(FGInt2, MFGInt, temp1);
      FGIntClear(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntClear(temp1);
    end;
    if s2 = positive then
      QFGInt.Sign := negative;
  end
  else
    QFGInt.Sign := s2;
  FGIntClear(one);
  FGIntClear(zero);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;

procedure FGIntMod(var FGInt1, FGInt2, MFGInt: TFGInt);
var
  one, zero, temp1, temp2: TFGInt;
  s1, s2: TSign;
  s, t: LongWord;
  i: int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> St then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    for t := 1 to s do
      FGIntShiftLeftBy31(temp1);
    while FGIntCompareAbs(MFGInt, FGInt2) <> St do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> St do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl 31;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntbis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          if FGIntCompareAbs(MFGInt, temp2) <> St then
            FGIntSubBis(MFGInt, temp2);
          FGIntClear(temp2);
        end
        else
          FGIntSubBis(MFGInt, temp1);
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> Eq then
          FGIntShiftRightBy31(temp1);
    end;
  end;

  FGIntClear(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> Eq then
    begin
      FGIntSub(FGInt2, MFGInt, temp1);
      FGIntClear(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntClear(temp1);
    end;
  end;
  FGIntClear(one);
  FGIntClear(zero);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;

procedure FGIntMulMod(var FGInt1, FGInt2, base, FGIntres: TFGInt);
var
  temp: TFGInt;
begin
  FGIntMul(FGInt1, FGInt2, temp);
  FGIntMod(temp, base, FGIntres);
  FGIntClear(temp);
end;

procedure FGIntModBis(const FGInt: TFGInt; var FGIntOut: TFGInt; b, head: LongWord);
var
  i: LongWord;
begin
  if b <= FGInt.Number[0] then
  begin
    SetLength(FGIntOut.Number, (b + 1));
    for i := 0 to b do
      FGIntOut.Number[i] := FGInt.Number[i];
    FGIntOut.Number[b] := FGIntOut.Number[b] and head;
    i := b;
    while (FGIntOut.Number[i] = 0) and (i > 1) do
      i := i - 1;
    if i < b then
      SetLength(FGIntOut.Number, i + 1);
    FGIntOut.Number[0] := i;
    FGIntOut.Sign := positive;
  end
  else
    FGIntCopy(FGInt, FGIntOut);
end;

procedure FGIntMulModBis(const FGInt1, FGInt2: TFGInt; var Prod: TFGInt; b, head: LongWord);
var
  i, j, size, size1, size2, t, rest: LongWord;
  Trest: int64;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  size := min(b, size1 + size2);
  SetLength(Prod.Number, (size + 1));
  for i := 1 to size do
    Prod.Number[i] := 0;

  for i := 1 to size2 do
  begin
    rest := 0;
    t := min(size1, b - i + 1);
    for j := 1 to t do
    begin
      Trest := FGInt1.Number[j];
      Trest := Trest * FGInt2.Number[i];
      Trest := Trest + Prod.Number[j + i - 1];
      Trest := Trest + rest;
      Prod.Number[j + i - 1] := Trest and 2147483647;
      rest := Trest shr 31;
    end;
    if (i + size1) <= b then
      Prod.Number[i + size1] := rest;
  end;

  Prod.Number[0] := size;
  if size = b then
    Prod.Number[b] := Prod.Number[b] and head;
  while (Prod.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size < Prod.Number[0] then
  begin
    SetLength(Prod.Number, size + 1);
    Prod.Number[0] := size;
  end;
  if FGInt1.Sign = FGInt2.Sign then
    Prod.Sign := Positive
  else
    prod.Sign := negative;
end;

procedure FGIntMontgomeryMod(
    const GInt, base, baseInv: TFGInt;
    var MGInt: TFGInt;
    b: Longword;
    head: LongWord
);
var
  m, temp, temp1: TFGInt;
  r: LongWord;
begin
  FGIntModBis(GInt, temp, b, head);
  FGIntMulModBis(temp, baseInv, m, b, head);
  FGIntMul(m, base, temp1);
  FGIntClear(temp);
  FGIntAdd(temp1, GInt, temp);
  FGIntClear(temp1);
  MGInt.Number := copy(temp.Number, b - 1, temp.Number[0] - b + 2);
  MGInt.Sign := positive;
  MGInt.Number[0] := temp.Number[0] - b + 1;
  FGIntClear(temp);
  if (head shr 30) = 0 then
    FGIntDivByIntBis(MGInt, head + 1, r)
  else
    FGIntShiftRightBy31(MGInt);
  if FGIntCompareAbs(MGInt, base) <> St then
    FGIntSubBis(MGInt, base);
  FGIntClear(temp);
  FGIntClear(m);
end;

procedure FGIntMontgomeryModExp(var FGInt, exp, modb, res: TFGInt);
var
  temp2, temp3, baseInv, r, zero: TFGInt;
  i, j, t, b, head: LongWord;
  S: AnsiString;
begin
  Base2StringToFGInt('0', zero);
  FGIntMod(FGInt, modb, res);
  if FGIntCompareAbs(res, zero) = Eq then
  begin
    FGIntClear(zero);
    Exit;
  end
  else
    FGIntClear(res);
  FGIntClear(zero);

  FGIntToBase2String(exp, S);
  t := modb.Number[0];
  b := t;

  if (modb.Number[t] shr 30) = 1 then
    t := t + 1;
  SetLength(r.Number, (t + 1));
  r.Number[0] := t;
  r.Sign := positive;
  for i := 1 to t do
    r.Number[i] := 0;
  if t = modb.Number[0] then
  begin
    head := 2147483647;
    for j := 29 downto 0 do
    begin
      head := head shr 1;
      if (modb.Number[t] shr j) = 1 then
      begin
        r.Number[t] := 1 shl (j + 1);
        break;
      end;
    end;
  end
  else
  begin
    r.Number[t] := 1;
    head := 2147483647;
  end;

  FGIntModInv(modb, r, temp2);
  if temp2.Sign = negative then
    FGIntCopy(temp2, BaseInv)
  else
  begin
    FGIntCopy(r, BaseInv);
    FGIntSubBis(BaseInv, temp2);
  end;
  //   FGIntBezoutBachet(r, modb, temp2, BaseInv);
  FGIntAbs(BaseInv);
  FGIntClear(temp2);
  FGIntMod(r, modb, res);
  FGIntMulMod(FGInt, res, modb, temp2);
  FGIntClear(r);

  for i := length(S) downto 1 do
  begin
    if S[i] = '1' then
    begin
      FGIntmul(res, temp2, temp3);
      FGIntClear(res);
      FGIntMontgomeryMod(temp3, modb, baseinv, res, b, head);
      FGIntClear(temp3);
    end;
    FGIntSquare(temp2, temp3);
    FGIntClear(temp2);
    FGIntMontgomeryMod(temp3, modb, baseinv, temp2, b, head);
    FGIntClear(temp3);
  end;
  FGIntClear(temp2);
  FGIntMontgomeryMod(res, modb, baseinv, temp3, b, head);
  FGIntCopy(temp3, res);
  FGIntClear(temp3);
  FGIntClear(baseinv);
end;

procedure FGIntGCD(const FGInt1, FGInt2: TFGInt; var GCD: TFGInt);
var
  k: TCompare;
  zero, temp1, temp2, temp3: TFGInt;
begin
  k := FGIntCompareAbs(FGInt1, FGInt2);
  if (k = Eq) then
    FGIntCopy(FGInt1, GCD)
  else if (k = St) then
    FGIntGCD(FGInt2, FGInt1, GCD)
  else
  begin
    Base10StringToFGInt('0', zero);
    FGIntCopy(FGInt1, temp1);
    FGIntCopy(FGInt2, temp2);
    while (temp2.Number[0] <> 1) or (temp2.Number[1] <> 0) do
    begin
      FGIntMod(temp1, temp2, temp3);
      FGIntCopy(temp2, temp1);
      FGIntCopy(temp3, temp2);
      FGIntClear(temp3);
    end;
    FGIntCopy(temp1, GCD);
    FGIntClear(temp2);
    FGIntClear(zero);
  end;
end;

procedure FGIntModInv(const FGInt1, base: TFGInt; var Inverse: TFGInt);
var
  zero, one, r1, r2, r3, tb, gcd, temp, temp1, temp2: TFGInt;
begin
  Base10StringToFGInt('1', one);
  FGIntGCD(FGInt1, base, gcd);
  if FGIntCompareAbs(one, gcd) = Eq then
  begin
    FGIntcopy(base, r1);
    FGIntcopy(FGInt1, r2);
    Base10StringToFGInt('0', zero);
    Base10StringToFGInt('0', inverse);
    Base10StringToFGInt('1', tb);

    repeat
      FGIntClear(r3);
      FGIntdivmod(r1, r2, temp, r3);
      FGIntCopy(r2, r1);
      FGIntCopy(r3, r2);

      FGIntmul(tb, temp, temp1);
      FGIntsub(inverse, temp1, temp2);
      FGIntClear(inverse);
      FGIntClear(temp1);
      FGIntCopy(tb, inverse);
      FGIntCopy(temp2, tb);

      FGIntClear(temp);
    until FGIntCompareAbs(r3, zero) = Eq;

    if inverse.Sign = negative then
    begin
      FGIntadd(base, inverse, temp);
      FGIntCopy(temp, inverse);
    end;

    FGIntClear(tb);
    FGIntClear(r1);
    FGIntClear(r2);
  end;
  FGIntClear(gcd);
  FGIntClear(one);
end;

end.
