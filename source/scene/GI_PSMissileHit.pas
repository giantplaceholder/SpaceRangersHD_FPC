unit GI_PSMissileHit;
// Unit bracket (inferred): .text 0x0069B05C..0x0069B27B; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Unit bracket (inferred): .itext 0x0087796C..0x00877973; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.
// Native animation palette resources; this effect uses the shared GAI control.

interface

type
  TGAISet = array[0..0] of WideString;
  TMissileHitAnimationPaths = array of TGAISet;

procedure LoadMissileHitAnimationPaths; // @addr $69B080

var
  MissileHitAnimationPaths: array of TGAISet; // @addr $88AF2C

implementation

// @unit-initialization $87796C
// @unit-finalization $69B23C

uses SysUtils, Math, EC_BlockPar, EC_Str, Globals;

{ @routine $69B080 LoadMissileHitAnimationPaths }
procedure LoadMissileHitAnimationPaths;
var
  Block, PaletteBlock: TBlockParEC;
  Index, BlockCount, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.MissileHit.Palettes');
  BlockCount := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to BlockCount - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(MissileHitAnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      if PaletteBlock.CountParams('GAI') > 0 then
        MissileHitAnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
    end;
  end;
end;
{ @end $69B080 }

end.
