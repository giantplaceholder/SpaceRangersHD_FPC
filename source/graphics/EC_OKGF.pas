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
): Integer; stdcall; external 'ZLib.dll' name 'OKGF_ZLib_UnCompress2';

implementation

uses
  GR_GraphBuf;

end.
