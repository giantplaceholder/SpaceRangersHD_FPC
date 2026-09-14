unit GI_PSWeapon14Vertix;
// Native animation palette resources; this effect uses the shared GAI control.

interface

type
  TGAISet = array[0..0] of WideString;
  TWeapon14AnimationPaths = array of TGAISet;

procedure LoadWeapon14AnimationPaths; // @addr $695CC8

var
  Weapon14AnimationPaths: array of TGAISet; // @addr $88AEF8

implementation

// @unit-initialization $87794C
// @unit-finalization $695E74

uses SysUtils, Math, EC_BlockPar, EC_Str, Globals;

{ @routine $695CC8 LoadWeapon14AnimationPaths }
procedure LoadWeapon14AnimationPaths;
var
  Block, PaletteBlock: TBlockParEC;
  Index, BlockCount, Count: Integer;
  Text: WideString;
begin
  Block := GameDataConfig.GetBlockByPath('SE.Weapon.13.Palettes');
  BlockCount := Block.GetBlockCount;
  Count := 0;
  for Index := 0 to BlockCount - 1 do
    Count := Math.Max(Count, ExtractDigitsToIntW(Block.GetBlockNameByIndex(Index)) + 1);
  SetLength(Weapon14AnimationPaths, Count);
  for Index := 0 to Count - 1 do
  begin
    Text := IntToStr(Index);
    if Block.CountBlocks(Text) <> 0 then
    begin
      PaletteBlock := Block.GetBlockByPath(Text);
      if PaletteBlock.CountParams('GAI') > 0 then
        Weapon14AnimationPaths[Index][0] := PaletteBlock.GetParam('GAI');
    end;
  end;
end;
{ @end $695CC8 }

end.
