unit SE_StarsField;
// Unit bracket (inferred): .text 0x00823880..0x00823BFC; inclusive evidence, not full bounds. See docs/declarations.md#unit-coverage-and-address-brackets.

interface

uses Classes, EC_BlockPar, EC_Struct, GI_MessageLoop, GI_SimpleImage, GI_InfiniteImage, SE_Space, Types;

type
  TStarsFieldSE = class(TObjectSE) // @size $58

  public
    ImagePath: WideString; // @offset $4C
    InfiniteImage: TInfiniteImageGI; // @offset $50
    StaticImage: TSimpleImageGI; // @offset $54
    procedure AttachToSpace(ASpace: TSpaceSE); override; // @addr $823948
    procedure DetachFromSpace; override; // @addr $823A94
    procedure LoadTemplate(Block: TBlockParEC); override; // @addr $823AFC
    procedure QueueImageLoad(PendingLoads: TList; Owner: TObjectGI); override; // @addr $823B78
  end;

implementation

uses GlobalsV, GI_Image;
{ @routine $823948 TStarsFieldSE_AttachToSpace }
procedure TStarsFieldSE.AttachToSpace(ASpace: TSpaceSE);
begin
  if IsAttachedToSpace then Exit;
  inherited AttachToSpace(ASpace);
  if StaticBackground then
  begin
    StaticImage := TSimpleImageGI.Create(Space.MapPanel);
    StaticImage.SetDepthByName(DepthExpression);
    StaticImage.SetPositionModeW(False);
    StaticImage.SetImageKindX(ikxLeftFill);
    StaticImage.SetImageKindY(ikyTopFill);
    StaticImage.SetPosition(Classes.Point(-Space.MapPanel.OriginPoint.X, -Space.MapPanel.OriginPoint.Y));
    StaticImage.SetSize(Classes.Point(Space.MapPanel.ClientSize.X, Space.MapPanel.ClientSize.Y));
    StaticImage.SetImagePath(ImagePath);
  end
  else
  begin
    InfiniteImage := TInfiniteImageGI.Create(Space.MapPanel);
    InfiniteImage.SetDepthByName(DepthExpression);
    InfiniteImage.SetPositionModeW(True);
    InfiniteImage.SetImagePath(ImagePath);
  end;
end;
{ @end $823948 }

{ @routine $823A94 TStarsFieldSE_DetachFromSpace }
procedure TStarsFieldSE.DetachFromSpace;
begin
  if not IsAttachedToSpace then Exit;
  if InfiniteImage <> nil then
  begin
    Space.MapPanel.FreeOwnedChild(InfiniteImage);
    InfiniteImage := nil;
  end;
  if StaticImage <> nil then
  begin
    Space.MapPanel.FreeOwnedChild(StaticImage);
    StaticImage := nil;
  end;
  inherited DetachFromSpace;
end;
{ @end $823A94 }

{ @routine $823AFC TStarsFieldSE_LoadTemplate }
procedure TStarsFieldSE.LoadTemplate(Block: TBlockParEC);
begin
  inherited LoadTemplate(Block);
  ImagePath := Block.GetParam('Image');
end;
{ @end $823AFC }

{ @routine $823B78 TStarsFieldSE_QueueImageLoad }
procedure TStarsFieldSE.QueueImageLoad(PendingLoads: TList; Owner: TObjectGI);
begin
  if StaticBackground then
    with TSimpleImageGI.Create(Owner) do
    begin
      SetImagePath(Self.ImagePath);
      QueueImageLoad(PendingLoads);
      Free;
    end
  else
    with TInfiniteImageGI.Create(Owner) do
    begin
      SetImagePath(Self.ImagePath);
      QueueImageLoad(PendingLoads);
      Free;
    end;
end;
{ @end $823B78 }

end.
