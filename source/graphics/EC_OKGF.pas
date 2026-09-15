unit EC_OKGF;

{$O-}
{$R-}
{$Q-}
{$B-}
{$A8}

interface

uses
  Types;

type

  PointerToTOkgfReadContext = ^TOkgfReadContext;

  {$Z4}
  TOkgfImageKind = (
      oikUnknown = 0,
      oikBmp = 1,
      oikIndexedBmp = 2,
      oikJpeg = 3,
      oikPng = 4,
      oikIndexedPsd = 5,
      oikGrayscalePsd = 6,
      oikRgbPsd = 7,
      oikCmykPsd = 8
  );

  TOkgfReadContext = packed record
    CodecContext: Pointer;
    ImageKind: TOkgfImageKind;
    Width: Integer;
    Height: Integer;
    PaletteCount: Integer;
    SourceData: Pointer;
    SourceSize: Integer;
    OwnsSource: Integer;
  end;

  POkgfReadContext = PointerToTOkgfReadContext;

function OKGF_ZLib_UnCompress2(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer
): Integer; stdcall;

implementation

uses
  ZBase,
  ZInflate;

function OKGF_ZLib_UnCompress2(
    Dest: Pointer;
    DestCapacity: Integer;
    Source: Pointer;
    SourceSize: Integer
): Integer; stdcall;
var
  Magic, ExpectedSize: Cardinal;
  Stream: z_stream;
begin
  Result := 0;
  if SourceSize < 8 then
    Exit;
  Move(Source^, Magic, SizeOf(Magic));
  if LEtoN(Magic) <> $32304C5A then
    Exit;
  Move((PByte(Source) + 4)^, ExpectedSize, SizeOf(ExpectedSize));
  ExpectedSize := LEtoN(ExpectedSize);
  if ExpectedSize > Cardinal(DestCapacity) then
    Exit;
  // ZLib.dll $1000B920 accepts only ZL02. Unlike UnCompress, this export has
  // no nil-destination size query. Trailing compressed input is permitted.
  FillChar(Stream, SizeOf(Stream), 0);
  Stream.next_in := PByte(Source) + 8;
  Stream.avail_in := SourceSize - 8;
  Stream.next_out := Dest;
  Stream.avail_out := Cardinal(DestCapacity);
  if inflateInit(Stream) <> Z_OK then
    Exit;
  try
    if (inflate(Stream, Z_FINISH) = Z_STREAM_END) and (Stream.total_out = ExpectedSize) then
      Result := Stream.total_out;
  finally
    inflateEnd(Stream);
  end;
end;

end.
