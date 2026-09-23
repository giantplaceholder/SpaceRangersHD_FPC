unit EC_CacheGI;

{$I GameOptions.inc}

interface

uses
  Classes,
  EC_Buf,
  EC_Cache,
  GR_DX,
  GR_GraphBuf,
  GR_gi,
  Types,
  Direct3D9;

type

  TCGiControlEC = class;

  TCGiEC = class;

  TCGiControlEC = class(TCacheControlEC)
    procedure QueueLoadIfMissing(PendingLoads: TList); override;
    function CreateData: TCacheDataEC; override;
    function AcquireData: TCacheDataEC; override;
  end;

  TCGiEC = class(TCacheDataEC)
    Image: TgiGR;
    SurfaceCache: TTextureGR;
    UsesTiledSurfaces: Boolean;
    TileOrigins: array of TPoint;
    TileCount: Integer;
    procedure LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString); override;
    constructor Create;
    destructor Destroy; override;
    function GetTileOrigin(TileIndex: Integer): TPoint;
    function GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9;
    procedure ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString);
  end;

function AcquireCachedGi(Control: TCacheControlEC): TCGiEC;

implementation

uses
  EC_Mem,
  EC_Str,
  GR_Main,
  Math;

procedure TCGiControlEC.QueueLoadIfMissing(PendingLoads: TList);
var
  Control: TCGiControlEC;
begin
  if RetainCount > 0 then
    Exit;
  if BoundData <> nil then
    Exit;
  if HasEmptyCacheKey then
    Exit;
  if GlobalCache.FindDataByKeyAndClass(CacheKey, TCGiEC) = nil then
  begin
    Control := TCGiControlEC.Create;
    GlobalCache.ResetControl(Control);
    Control.SetCacheKey(CacheKey);
    PendingLoads.Add(Control);
  end;
end;

function TCGiControlEC.CreateData: TCacheDataEC;
begin
  Result := TCGiEC.Create;
end;

function AcquireCachedGi(Control: TCacheControlEC): TCGiEC;
begin
  Result := Control.AcquireDataFromConfig(TCGiEC) as TCGiEC;
end;

function TCGiControlEC.AcquireData: TCacheDataEC;
begin
  Result := AcquireCachedGi(Self);
end;

constructor TCGiEC.Create;
begin
  inherited Create;
  Image := TgiGR.Create;
  SurfaceCache := nil;
  UsesTiledSurfaces := False;
  TileCount := 0;
end;

destructor TCGiEC.Destroy;
begin
  Image.Free;
  if SurfaceCache <> nil then
  begin
    FreeTextureCache(SurfaceCache);
    SurfaceCache := nil;
    UsesTiledSurfaces := False;
    SetLength(TileOrigins, 0);
    TileCount := 0;
  end;
  inherited Destroy;
end;

function TCGiEC.GetTileOrigin(TileIndex: Integer): TPoint;
begin
  Result := TileOrigins[TileIndex];
end;

function TCGiEC.GetOrCreateSurface(SurfaceIndex: Integer): IDirect3DTexture9;
var
  Texture: IDirect3DTexture9;
  ImageSize: TPoint;
  Locked: TD3DLockedRect;
  TileIndex, Columns, Rows, TileWidth, TileHeight, Column, Row: Integer;
  Origin: TPoint;

  function GiTileDivideRoundUp(Value, Divisor: Integer): Integer;
  begin
    Result := (Divisor - 1 + Value) div Divisor;
  end;
begin
  if SurfaceCache = nil then
    SurfaceCache := CreateTextureCache;
  Texture := SurfaceCache.GetSurface(SurfaceIndex);
  if (Texture = nil) and (Image <> nil) and not UsesTiledSurfaces then
  begin
    ImageSize := Image.GetContentSize;
    if (ImageSize.X = 0) or (ImageSize.Y = 0) then
    begin
      Result := nil;
      Exit;
    end;
    if (MaxTextureSize.X < ImageSize.X) or (MaxTextureSize.Y < ImageSize.Y) then
    begin
      UsesTiledSurfaces := True;
      Columns := GiTileDivideRoundUp(ImageSize.X, MaxTextureSize.X);
      Rows := GiTileDivideRoundUp(ImageSize.Y, MaxTextureSize.Y);
      TileCount := Columns * Rows;
      SetLength(TileOrigins, TileCount);
      Row := 0;
      while Row < Rows do
      begin
        Column := 0;
        if MaxTextureSize.Y >= ImageSize.Y then
          TileHeight := ImageSize.Y
        else if (Row + 1) * MaxTextureSize.Y > ImageSize.Y then
          TileHeight := ImageSize.Y - MaxTextureSize.Y * Row
        else
          TileHeight := MaxTextureSize.Y;
        while Column < Columns do
        begin
          TileIndex := Row * Rows + Column;
          if MaxTextureSize.X >= ImageSize.X then
            TileWidth := ImageSize.X
          else if (Column + 1) * MaxTextureSize.X > ImageSize.X then
            TileWidth := ImageSize.X - MaxTextureSize.X * Column
          else
            TileWidth := MaxTextureSize.X;
          if (Image.Header.Format = 0) and (Image.Header.AlphaMask = 0) then
            Texture := GR_CreateTexture(TileWidth, TileHeight, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
          else
            Texture := GR_CreateTexture(TileWidth, TileHeight, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
          Origin := Classes.Point(MaxTextureSize.X * Column, MaxTextureSize.Y * Row);
          if Texture <> nil then
          begin
            Texture.LockRect(0, Locked, nil, 0);
            if Locked.Bits <> nil then
            begin
              Image.DecodeRawRegion(
                  Locked.Bits,
                  Locked.Pitch,
                  Origin.X,
                  Origin.Y,
                  TileWidth,
                  TileHeight,
                  True
              );
              Texture.UnlockRect(0);
            end;
          end;
          SurfaceCache.SetSurface(Texture, TileIndex);
          TileOrigins[TileIndex] := Origin;
          Inc(Column);
        end;
        Inc(Row);
      end;
      Texture := SurfaceCache.GetSurface(SurfaceIndex);
    end
    else
    begin
      if (Image.Header.Format = 0) and (Image.Header.AlphaMask = 0) then
        Texture := GR_CreateTexture(ImageSize.X, ImageSize.Y, D3DFMT_R5G6B5, D3DPOOL_MANAGED)
      else
        Texture := GR_CreateTexture(ImageSize.X, ImageSize.Y, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED);
      if Texture <> nil then
      begin
        Texture.LockRect(0, Locked, nil, 0);
        if Locked.Bits <> nil then
        begin
          Image.DecodeToPixels(Locked.Bits, Locked.Pitch, ImageSize.X, ImageSize.Y, True);
          Texture.UnlockRect(0);
        end;
      end;
    end;
    SurfaceCache.SetSurface(Texture, 0);
  end;
  Result := Texture;
end;

procedure TCGiEC.LoadFromConfigBuffer(SourceBuffer: TBufEC; const LoadOption: WideString);
begin
  ApplyWideScreenLayoutFixups(SourceBuffer, CacheKey);
  Image.LoadRawGiFromBuffer(SourceBuffer);
  ResidentBytes := Image.DataSize;
end;

procedure TCGiEC.ApplyWideScreenLayoutFixups(SourceBuffer: TBufEC; const ResourceKey: WideString);
var
  WorkingImage: TgiGR;
  Quiet: Boolean;
  SourceGraph, DestGraph: TGraphBufGR;
  VerticalAlign, ImageWidth, ImageHeight: Integer;
  Header: PgiHeaderGR;
  HeaderBytes: Pointer;
  Delta, Remainder, ExtraHeight: Integer;
  PreserveAlpha: Boolean;

  procedure RenderGiBufferToGraphBuf(SourceBuffer: TBufEC; DestGraphBuf: TGraphBufGR);
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.LoadRawGiFromBuffer(SourceBuffer);
    DestGraphBuf.AllocateRgbaTight(WorkingImage.GetContentSize.X, WorkingImage.GetContentSize.Y);
    WorkingImage.DecodeToGraphBuf(DestGraphBuf, False);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  procedure StoreGraphBufAsRawGiBuffer(
      DestBuffer: TBufEC;
      SourceGraphBuf: TGraphBufGR;
      StorageMode: Integer
  );
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFromGraphBuf(SourceGraphBuf, StorageMode);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  procedure StoreGraphBufAsGiBuffer(
      DestBuffer: TBufEC;
      SourceGraphBuf: TGraphBufGR;
      TopLeft: TPoint
  );
  begin
    WorkingImage := TgiGR.Create;
    WorkingImage.CreateFormat2FromGraphBuf(SourceGraphBuf, TopLeft);
    DestBuffer.Clear;
    DestBuffer.AddBytes(WorkingImage.Data, WorkingImage.DataSize);
    WorkingImage.ClearData;
    WorkingImage.Free;
  end;

  procedure LogWideScreenGiRescaleStart;
  begin
    if not Quiet then
      AppendLogTextThreadSafe('Rescaling ' + ResourceKey + '... ');
  end;

  procedure LogWideScreenGiRescaleDone;
  begin
    if not Quiet then
      AppendLogLineThreadSafe('ok');
  end;
begin
  ExtraHeight := ExtraScreenHeight;
  if ExtraHeight < 0 then
    ExtraHeight := 0;
  Quiet := False;
  if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.PanelMain2.' + GiResourceSuffix + 'BG') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(
        0,
        0,
        0,
        0,
        SourceGraph,
        Classes.Rect(0, 0, SourceGraph.Width, SourceGraph.Height),
        Classes.Rect(430, 0, 593, 0)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(
        SourceBuffer,
        DestGraph,
        Classes.Point(0, GameScreenHeight - DestGraph.Height - 1)
    );
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if ((ExtraScreenWidth > 0) or (ExtraHeight > 0))
      and (ResourceKey = 'Bm.FormMain2.2AnimMain') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, Max(Cardinal(GameScreenHeight), 768));
    Delta := (ExtraScreenWidth div 2 div 3) * 3;
    if Cardinal(GameScreenWidth) >= 1600 then
      Delta := Delta - 249;
    Remainder := ExtraHeight mod 3;
    if Remainder <> 0 then
      Remainder := 3 - Remainder;
    DestGraph.DrawNinePatch(
        0,
        0,
        Delta,
        0,
        SourceGraph,
        Classes.Rect(0, Remainder, 3, SourceGraph.Height),
        Classes.Rect(0, 0, 0, 765 - Remainder)
    );
    DestGraph.DrawNinePatch(
        Delta,
        0,
        0,
        0,
        SourceGraph,
        Classes.Rect(3, Remainder, SourceGraph.Width - 4, SourceGraph.Height),
        Classes.Rect(1005, 0, 0, 765 - Remainder)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormGov2.' + GiResourceSuffix + 'TWin') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := 3;
    Delta := (Min(ExtraScreenHeight, 250) div Delta) * Delta;
    DestGraph.AllocateRgbaTight(SourceGraph.Width, SourceGraph.Height + Delta);
    Remainder := (Delta div 3 div 4) * 3;
    Delta := Delta - Remainder;
    DestGraph.DrawNinePatch(
        0,
        0,
        DestGraph.Width,
        Delta + 530,
        SourceGraph,
        Classes.Rect(0, 0, SourceGraph.Width, 530),
        Classes.Rect(0, 380, 0, 147)
    );
    DestGraph.DrawNinePatch(
        0,
        Delta + 530,
        DestGraph.Width,
        Remainder + 90,
        SourceGraph,
        Classes.Rect(0, 530, SourceGraph.Width, SourceGraph.Height),
        Classes.Rect(0, 0, 0, 87)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormGov2.' + GiResourceSuffix + 'TWinB') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := (Min(ExtraScreenHeight, 250) div 3 div 4) * 3;
    DestGraph.AllocateRgbaTight(SourceGraph.Width, SourceGraph.Height + Delta);
    DestGraph.DrawNinePatch(
        0,
        0,
        DestGraph.Width,
        DestGraph.Height,
        SourceGraph,
        Classes.Rect(0, 0, SourceGraph.Width, SourceGraph.Height),
        Classes.Rect(0, 97, 0, 53)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ExtraHeight > 0) and (ResourceKey = 'Bm.FormInfo3.' + GiResourceSuffix + 'BG') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := 3;
    Delta := (Min(ExtraScreenHeight, 432) div Delta) * Delta;
    DestGraph.AllocateRgbaTight(SourceGraph.Width, SourceGraph.Height + Delta);
    DestGraph.DrawNinePatch(
        0,
        0,
        DestGraph.Width,
        DestGraph.Height,
        SourceGraph,
        Classes.Rect(0, 0, SourceGraph.Width, SourceGraph.Height),
        Classes.Rect(0, 449, 0, 148)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormShop2.2bg') then
  begin
    Delta := (ExtraScreenWidth div 198) * 198;
    if Delta > 198 then
      Delta := 198;
    if Delta <> 0 then
    begin
      LogWideScreenGiRescaleStart;
      SourceGraph := TGraphBufGR.Create(False);
      RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
      DestGraph := TGraphBufGR.Create(False);
      DestGraph.AllocateRgbaTight(SourceGraph.Width + Delta, SourceGraph.Height);
      DestGraph.DrawNinePatch(
          0,
          0,
          Delta div 2 + 226,
          34,
          SourceGraph,
          Classes.Rect(0, 0, 226, 34),
          Classes.Rect(225, 0, 0, 0)
      );
      DestGraph.DrawNinePatch(
          Delta div 2 + 226,
          0,
          0,
          34,
          SourceGraph,
          Classes.Rect(226, 0, 0, 34),
          Classes.Rect(326, 0, 213, 0)
      );
      DestGraph.DrawNinePatch(
          0,
          34,
          0,
          354,
          SourceGraph,
          Classes.Rect(0, 34, 0, 388),
          Classes.Rect(218, 0, 548, 0)
      );
      DestGraph.DrawNinePatch(
          0,
          388,
          Delta div 2 + 226,
          0,
          SourceGraph,
          Classes.Rect(0, 388, 226, 0),
          Classes.Rect(225, 0, 0, 0)
      );
      DestGraph.DrawNinePatch(
          Delta div 2 + 226,
          388,
          0,
          0,
          SourceGraph,
          Classes.Rect(226, 388, 0, 0),
          Classes.Rect(326, 0, 213, 0)
      );
      SourceGraph.Clear;
      SourceGraph.Free;
      StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
      DestGraph.Clear;
      DestGraph.Free;
      LogWideScreenGiRescaleDone;
    end;
  end
  else if (ExtraScreenWidth > 0)
      and ((ResourceKey = 'Bm.FormShop2.2Fei')
          or (ResourceKey = 'Bm.FormShop2.2Gaal')
          or (ResourceKey = 'Bm.FormShop2.2Peleng')
          or (ResourceKey = 'Bm.FormShop2.2People')) then
  begin
    Delta := (ExtraScreenWidth div 198) * 198;
    if Delta > 198 then
      Delta := 198;
    if Delta <> 0 then
    begin
      LogWideScreenGiRescaleStart;
      SourceGraph := TGraphBufGR.Create(False);
      RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
      DestGraph := TGraphBufGR.Create(False);
      DestGraph.AllocateRgbaTight(SourceGraph.Width + Delta, SourceGraph.Height);
      DestGraph.DrawNinePatch(
          0,
          0,
          0,
          0,
          SourceGraph,
          Classes.Rect(0, 0, 0, 0),
          Classes.Rect(121, 0, 483, 0)
      );
      SourceGraph.Clear;
      SourceGraph.Free;
      StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
      DestGraph.Clear;
      DestGraph.Free;
      LogWideScreenGiRescaleDone;
    end;
  end
  else if (ExtraHeight > 0)
      and ((ResourceKey = 'Bm.FormOptions2.' + GiResourceSuffix + 'Left')
          or (ResourceKey = 'Bm.FormOptions2.' + GiResourceSuffix + 'Right')) then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(SourceGraph.Width, ExtraScreenHeight + SourceGraph.Height);
    DestGraph.DrawNinePatch(
        0,
        0,
        37,
        DestGraph.Height,
        SourceGraph,
        Classes.Rect(0, 0, 37, SourceGraph.Height),
        Classes.Rect(0, 324, 0, 338)
    );
    DestGraph.DrawNinePatch(
        37,
        0,
        193,
        DestGraph.Height,
        SourceGraph,
        Classes.Rect(37, 0, 230, SourceGraph.Height),
        Classes.Rect(0, 280, 0, 375)
    );
    DestGraph.DrawNinePatch(
        230,
        0,
        513,
        DestGraph.Height,
        SourceGraph,
        Classes.Rect(230, 0, 743, SourceGraph.Height),
        Classes.Rect(0, 325, 0, 337)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ExtraScreenWidth > 0)
      and (ResourceKey = 'Bm.FormGameSet2.' + GiResourceSuffix + 'Footer') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(
        0,
        0,
        ExtraScreenWidth div 2 + 342,
        0,
        SourceGraph,
        Classes.Rect(0, 0, 342, 0),
        Classes.Rect(341, 0, 0, 0)
    );
    DestGraph.CopyRect32(
        Classes.Point(ExtraScreenWidth div 2 + 342, 0),
        SourceGraph,
        Classes.Rect(342, 0, 682, SourceGraph.Height)
    );
    DestGraph.DrawNinePatch(
        ExtraScreenWidth div 2 + 682,
        0,
        ExtraScreenWidth div 2 + 342,
        0,
        SourceGraph,
        Classes.Rect(682, 0, 0, 0),
        Classes.Rect(0, 0, 341, 0)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ResourceKey = 'Bm.FormIntro2.PanelTop') or (ResourceKey = 'Bm.FormEnd2.PanelTop') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph
        .DrawNinePatch(0, 0, 0, 0, SourceGraph, Classes.Rect(0, 0, 0, 0), Classes.Rect(0, 0, 0, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsRawGiBuffer(SourceBuffer, DestGraph, 1);
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ExtraScreenWidth > 0) and (ResourceKey = 'Bm.FormIntro2.PanelBottom') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(
        0,
        0,
        ExtraScreenWidth div 2 + 302,
        0,
        SourceGraph,
        Classes.Rect(0, 0, 302, 0),
        Classes.Rect(301, 0, 0, 0)
    );
    DestGraph.DrawNinePatch(
        ExtraScreenWidth div 2 + 302,
        0,
        0,
        0,
        SourceGraph,
        Classes.Rect(302, 0, 0, 0),
        Classes.Rect(420, 0, 301, 0)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsRawGiBuffer(SourceBuffer, DestGraph, 1);
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if ResourceKey = 'Bm.FormEnd2.PanelBottom' then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, SourceGraph.Height);
    DestGraph.DrawNinePatch(
        0,
        0,
        0,
        0,
        SourceGraph,
        Classes.Rect(0, 0, 0, 0),
        Classes.Rect(0, 0, 154, 0)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsRawGiBuffer(SourceBuffer, DestGraph, 1);
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if ((ExtraScreenWidth > 0) or (ExtraHeight > 0))
      and (ResourceKey = 'Bm.FormPQuest2.2Panel') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    DestGraph.AllocateRgbaTight(GameScreenWidth, GameScreenHeight);
    Delta := 39 - ExtraScreenWidth;
    if Delta < 0 then
      Delta := 0;
    DestGraph.DrawNinePatch(
        0,
        ExtraScreenHeight div 2 + 492,
        0,
        0,
        SourceGraph,
        Classes.Rect(Delta, 492, 0, 0),
        Classes.Rect(302 - Delta, 0, 760, 275)
    );
    DestGraph.DrawNinePatch(
        0,
        0,
        0,
        ExtraScreenHeight div 2 + 492,
        SourceGraph,
        Classes.Rect(Delta, 0, 0, 492),
        Classes.Rect(345 - Delta, 410, 717, 81)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if ((ExtraScreenWidth > 0) or (ExtraHeight > 0))
      and (((FindTextOffsetW(ResourceKey, 'Bm.FormPQuest2.2S') = 0)
              and IsIntegerTextW(
                  CopyWideStringUnchecked(ResourceKey, 18, Length(ResourceKey) - 17)))
          or ((FindTextOffsetW(ResourceKey, 'Bm.FormPQuest2.') = 0)
              and (FindTextOffsetW(ResourceKey, 'rescale') > 0))) then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    DestGraph := TGraphBufGR.Create(False);
    Delta := ExtraScreenWidth - 39;
    if Delta < 0 then
      Delta := 0;
    DestGraph.AllocateRgbaTight(SourceGraph.Width + Delta, SourceGraph.Height + ExtraHeight);
    DestGraph.DrawNinePatch(
        0,
        0,
        0,
        ExtraHeight div 2 + 500,
        SourceGraph,
        Classes.Rect(0, 0, 0, 500),
        Classes.Rect(289, 385, 289, 114)
    );
    DestGraph.DrawNinePatch(
        0,
        ExtraHeight div 2 + 500,
        0,
        0,
        SourceGraph,
        Classes.Rect(0, 500, 0, 0),
        Classes.Rect(289, 0, 289, 206)
    );
    SourceGraph.Clear;
    SourceGraph.Free;
    StoreGraphBufAsGiBuffer(SourceBuffer, DestGraph, Classes.Point(0, 0));
    DestGraph.Clear;
    DestGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else if (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'WBbg')
      or (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'CBbg')
      or (ResourceKey = 'Bm.FormRuins.' + GiResourceSuffix + 'DestroyerBridgebg') then
  begin
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    SourceGraph.RescaleRgbaLinear(GameScreenWidth, GameScreenHeight, True, 1, 1);
    StoreGraphBufAsGiBuffer(SourceBuffer, SourceGraph, Classes.Point(0, 0));
    SourceGraph.Clear;
    SourceGraph.Free;
    LogWideScreenGiRescaleDone;
  end
  else
  begin
    VerticalAlign := 1;
    PreserveAlpha := FindTextOffsetW(ResourceKey, 'Alpha') > 0;
    repeat
      if (ResourceKey = 'Bm.FormAbout2.Bg')
          or (ResourceKey = 'Bm.FormGameSet2.2bg')
          or (ResourceKey = 'Bm.FormOptions2.2Bg')
          or (ResourceKey = 'Bm.FormScore2.2bg')
          or (FindTextOffsetW(ResourceKey, 'Bm.City.') = 0)
          or ((FindTextOffsetW(ResourceKey, 'Bm.Gov.') = 0)
              and ((FindTextOffsetW(ResourceKey, 'MalocBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'MalocPirateBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'PelengBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'PelengPirateBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'PeopleBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'PeoplePirateBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'FeiBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'FeiPirateBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'GaalBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'GaalPirateBG') > 0)
                  or (FindTextOffsetW(ResourceKey, 'PirateBG') > 0))) then
        Break;
      if FindTextOffsetW(ResourceKey, 'Bm.FormRuins.') = 0 then
      begin
        if FindTextOffsetW(ResourceKey, 'BKbg') > 0 then
        begin
          VerticalAlign := 2;
          Break;
        end
        else if (FindTextOffsetW(ResourceKey, 'MCbg') > 0)
            or (FindTextOffsetW(ResourceKey, 'PBbg') > 0)
            or (FindTextOffsetW(ResourceKey, 'RCbg') > 0)
            or (FindTextOffsetW(ResourceKey, 'SBbg') > 0)
            or (FindTextOffsetW(ResourceKey, 'WBbg2') > 0)
            or ((FindTextOffsetW(ResourceKey, 'bg') > 0)
                and (FindTextOffsetW(ResourceKey, 'table') <= 0)) then
          Break;
      end;
      if FindTextOffsetW(ResourceKey, 'Bm.PlanetBG') = 0 then
      begin
        if SourceBuffer.DataSize < SizeOf(TgiHeaderGR) then
          Exit;
        HeaderBytes := AllocEC(SizeOf(TgiHeaderGR));
        System.Move(Pointer(SourceBuffer.Data)^, Pointer(HeaderBytes)^, SizeOf(TgiHeaderGR));
        Header := HeaderBytes;
        ImageWidth := Header.Bounds.Right - Header.Bounds.Left;
        ImageHeight := Header.Bounds.Bottom - Header.Bounds.Top;
        FreeEC(HeaderBytes);
        if (ImageWidth > 1024) or (ImageHeight > 768) then
          Break;
      end;
      if FindTextOffsetW(ResourceKey, 'Bm.FormLoad2.Shutter') <> 0 then
        Exit;
      PreserveAlpha := True;
      Quiet := True;
    until True;
    LogWideScreenGiRescaleStart;
    SourceGraph := TGraphBufGR.Create(False);
    RenderGiBufferToGraphBuf(SourceBuffer, SourceGraph);
    Delta := SourceGraph.Width;
    Remainder := SourceGraph.Height;
    SourceGraph.RescaleRgbaLinear(GameScreenWidth, GameScreenHeight, True, 1, VerticalAlign);
    if (Delta <> SourceGraph.Width) or (Remainder <> SourceGraph.Height) then
    begin
      if PreserveAlpha then
        StoreGraphBufAsGiBuffer(SourceBuffer, SourceGraph, Classes.Point(0, 0))
      else
        StoreGraphBufAsRawGiBuffer(SourceBuffer, SourceGraph, 1);
    end;
    SourceGraph.Clear;
    SourceGraph.Free;
    LogWideScreenGiRescaleDone;
  end;
end;

end.
