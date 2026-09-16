unit GI_Cursor;

{$O-}
{$R-}
{$Q-}
{$B-}
{$A8}

interface

uses
  GI_Image,
  GI_MessageLoop,
  GR_GraphBuf,
  Types;

type

  TCursorGI = class;

  TCursorGI = class(TObjectGI)
    ImageControl: TImageGI;
    ImagePath: WideString;
    CursorHandles: array of Pointer;
    FrameIndices: array of Integer;
    FrameDelays: array of Integer;
    FrameIndex: Integer;
    AnimationTimer: PCallbackTimerGI;
    procedure Clear; override;
    procedure SetOrigin(Origin: TPoint); override;
    procedure SetActive(Enabled: Boolean); override;
    procedure Draw(ClipRect: TRect); override;
    constructor Create(Owner: TObjectGI);
    destructor Destroy; override;
    procedure SetImagePath(const Path: WideString);
    procedure RebuildSystemCursor;
    function CreateNativeCursor(Buffer: TGraphBufGR; Hotspot: TPoint): Pointer;
    procedure AdvanceAnimation(Timer: PCallbackTimerGI; UserData: Integer);
  end;

implementation

uses
  GameWindow,
  Classes,
  EC_Cache,
  EC_CacheGAI,
  EC_CacheGI,
  EC_Str,
  GR_Main,
  SysUtils,
  SDL2;

constructor TCursorGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  ImageControl := TImageGI.Create(Self);
  Active := False;
end;

destructor TCursorGI.Destroy;
var
  Index: Integer;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  for Index := 0 to High(CursorHandles) do
    if CursorHandles[Index] <> nil then
    begin
      SDL_FreeCursor(CursorHandles[Index]);
      CursorHandles[Index] := nil;
    end;
  ImagePath := '';
  CursorHandles := nil;
  FrameIndices := nil;
  FrameDelays := nil;
  inherited Destroy;
end;

procedure TCursorGI.Clear;
var
  Index: Integer;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  for Index := 0 to High(CursorHandles) do
    if CursorHandles[Index] <> nil then
    begin
      SDL_FreeCursor(CursorHandles[Index]);
      CursorHandles[Index] := nil;
    end;
  ImagePath := '';
  CursorHandles := nil;
  FrameIndices := nil;
  FrameDelays := nil;
  ImageControl.Clear;
end;

procedure TCursorGI.SetImagePath(const Path: WideString);
begin
  Clear;
  if ShowSystemMouse then
  begin
    if ImagePath <> Path then
      FrameIndex := 0;
    ImagePath := Path;
    RebuildSystemCursor;
  end
  else
  begin
    ImageControl.SetImagePath(Path);
    SetSize(ImageControl.GetContentSize);
    ImageControl.SetSize(ClientSize);
    ImageControl.RestartPlayback;
  end;
end;

procedure TCursorGI.SetActive(Enabled: Boolean);
begin
  Invalidate;
  inherited SetActive(Enabled);
  if ShowSystemMouse then
  begin
    if Enabled then
    begin
      if High(CursorHandles) >= 0 then
      begin
        FrameIndex := 0;
        SDL_SetCursor(CursorHandles[FrameIndex]);
        while ShowGameCursor(True) < 0 do
          ;
        if High(FrameIndices) > 0 then
        begin
          if AnimationTimer <> nil then
          begin
            MessageLoop.CancelCallbackTimer(AnimationTimer);
            AnimationTimer := nil;
          end;
          AnimationTimer :=
              MessageLoop.ScheduleCallbackTimer(
                  FrameDelays[FrameIndex],
                  FrameDelays[FrameIndex],
                  AdvanceAnimation
              );
        end;
      end;
    end
    else
    begin
      if AnimationTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := nil;
      end;
      while ShowGameCursor(False) >= 0 do
        ;
    end;
  end
  else
  begin
    ImageControl.SetActive(Enabled);
    ImageControl.RestartPlayback;
  end;
end;

procedure TCursorGI.SetOrigin(Origin: TPoint);
begin
  inherited SetOrigin(Origin);
  ImageControl.SetPosition(Classes.Point(-Origin.X, -Origin.Y));
  if ShowSystemMouse then
    RebuildSystemCursor;
end;

procedure TCursorGI.Draw(ClipRect: TRect);
begin
  inherited Draw(ClipRect);
end;

procedure TCursorGI.RebuildSystemCursor;
var
  GaiControl: TCGaiControlEC;
  GiControl: TCGiControlEC;
  Gai: TCGaiEC;
  Gi: TCGiEC;
  Index: Integer;
  Kind, Path: WideString;
  Buffer: TGraphBufGR;
  Hotspot: TPoint;
begin
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  for Index := 0 to High(CursorHandles) do
    if CursorHandles[Index] <> nil then
    begin
      SDL_FreeCursor(CursorHandles[Index]);
      CursorHandles[Index] := nil;
    end;
  CursorHandles := nil;
  FrameIndices := nil;
  FrameDelays := nil;
  Path := ImagePath;
  Kind := ExtractNextDelimitedPartW(Path, ',');
  if Kind = 'GAI' then
  begin
    GaiControl := TCGaiControlEC.Create;
    GlobalCache.ResetControl(GaiControl);
    GaiControl.SetCacheKey(Path);
    Buffer := TGraphBufGR.Create(False);
    Gai := AcquireCachedGai(GaiControl);
    try
      SetLength(CursorHandles, Gai.GetFrameCount);
      SetLength(FrameIndices, Gai.GetSequenceFrameCount(0));
      SetLength(FrameDelays, Gai.GetSequenceFrameCount(0));
      Gai.FillSequenceFrameIndexTable(0, Pointer(FrameIndices), 4);
      Gai.FillSequenceFrameDelayTable(0, Pointer(FrameDelays), 4);
      for Index := 0 to High(CursorHandles) do
      begin
        Gai.LoadFrameGi(Index).DecodeToGraphBuf(Buffer, False);
        Hotspot.X :=
            OriginPoint.X - (Gai.LoadFrameGi(Index).GetBoundsRect.Left - Gai.GetBoundsRect.Left);
        Hotspot.Y :=
            OriginPoint.Y - (Gai.LoadFrameGi(Index).GetBoundsRect.Top - Gai.GetBoundsRect.Top);
        CursorHandles[Index] := CreateNativeCursor(Buffer, Hotspot);
      end;
    finally
      GaiControl.Release;
    end;
    Buffer.Free;
    GaiControl.Free;
  end
  else if Kind = 'GI' then
  begin
    GiControl := TCGiControlEC.Create;
    GlobalCache.ResetControl(GiControl);
    GiControl.SetCacheKey(Path);
    Buffer := TGraphBufGR.Create(False);
    Gi := AcquireCachedGi(GiControl);
    try
      SetLength(CursorHandles, 1);
      SetLength(FrameIndices, 1);
      SetLength(FrameDelays, 1);
      FrameIndices[0] := 0;
      FrameDelays[0] := 0;
      Gi.Image.DecodeToGraphBuf(Buffer, False);
      Hotspot.X := OriginPoint.X;
      Hotspot.Y := OriginPoint.Y;
      CursorHandles[0] := CreateNativeCursor(Buffer, Hotspot);
    finally
      GiControl.Release;
    end;
    Buffer.Free;
    GiControl.Free;
  end;
  if (FrameIndex < 0) or (High(FrameIndices) < FrameIndex) then
    FrameIndex := 0;
  if Active then
  begin
    SDL_SetCursor(CursorHandles[FrameIndices[FrameIndex]]);
    while ShowGameCursor(True) < 0 do
      ;
    if High(FrameIndices) > 0 then
    begin
      if AnimationTimer <> nil then
      begin
        MessageLoop.CancelCallbackTimer(AnimationTimer);
        AnimationTimer := nil;
      end;
      AnimationTimer :=
          MessageLoop.ScheduleCallbackTimer(
              FrameDelays[FrameIndex],
              FrameDelays[FrameIndex],
              AdvanceAnimation
          );
    end;
  end;
end;

function TCursorGI.CreateNativeCursor(Buffer: TGraphBufGR; Hotspot: TPoint): Pointer;
var
  Surface: Pointer;
begin
  // The game's cursor images use the same BGRA bytes as the original DIB.
  // SDL copies the surface into the cursor, so the decoded frame can be reused.
  Surface :=
      SDL_CreateRGBSurfaceFrom(
          Buffer.GetPixels,
          Buffer.Width,
          Buffer.Height,
          32,
          Buffer.PitchBytes,
          $FF0000,
          $FF00,
          $FF,
          $FF000000
      );
  if Surface = nil then
    RaiseWideMessage('Cursor surface: ' + string(SDL_GetError));
  try
    Result := SDL_CreateColorCursor(Surface, Hotspot.X, Hotspot.Y);
    if Result = nil then
      RaiseWideMessage('Cursor: ' + string(SDL_GetError));
  finally
    SDL_FreeSurface(Surface);
  end;
end;

procedure TCursorGI.AdvanceAnimation(Timer: PCallbackTimerGI; UserData: Integer);
begin
  Inc(FrameIndex);
  if High(FrameIndices) < FrameIndex then
    FrameIndex := 0;
  SDL_SetCursor(CursorHandles[FrameIndices[FrameIndex]]);
  if AnimationTimer <> nil then
  begin
    MessageLoop.CancelCallbackTimer(AnimationTimer);
    AnimationTimer := nil;
  end;
  AnimationTimer :=
      MessageLoop.ScheduleCallbackTimer(
          FrameDelays[FrameIndex],
          FrameDelays[FrameIndex],
          AdvanceAnimation
      );
end;

end.
