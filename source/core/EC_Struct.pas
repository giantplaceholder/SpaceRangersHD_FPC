unit EC_Struct;

{$O-}
{$R-}
{$Q-}
{$B-}
{$A8}

interface

uses
  Types;

type

  TObjectEx = class;

  PointerToTPointF = ^TPointF;

  TPointF = record
    X: Single;
    Y: Single;
  end;

  PPointF = PointerToTPointF;

  TVector3D = record
    X: Double;
    Y: Double;
    Z: Double;
  end;

  TObjectEx = class(TObject)
    constructor Create;
    destructor Destroy; override;
  end;

var

  StartupCleanupObject: TObject;

function MakePointF(X: Single; Y: Single): TPointF;

function MakeVector3D(X: Double; Y: Double; Z: Double): TVector3D;

function TruncatePointF(Point: TPointF): TPoint;

function RoundPointF(Point: TPointF): TPoint;

function PointToPointF(Point: TPoint): TPointF;

function HalfPoint(Point: TPoint): TPoint;

function AddPoints(Left: TPoint; Right: TPoint): TPoint;

function SubtractPoints(Left: TPoint; Right: TPoint): TPoint;

function HalfPointF(Point: TPointF): TPointF;

function AddPointsF(Left: TPointF; Right: TPointF): TPointF;

function SubtractPointsF(Left: TPointF; Right: TPointF): TPointF;

function IntersectRects(out Intersection: TRect; const First: TRect; const Second: TRect): Boolean;

implementation

function MakePointF(X, Y: Single): TPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;

function MakeVector3D(X, Y, Z: Double): TVector3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function TruncatePointF(Point: TPointF): TPoint;
begin
  Result.X := Trunc(Point.X);
  Result.Y := Trunc(Point.Y);
end;

function RoundPointF(Point: TPointF): TPoint;
begin
  Result.X := Round(Point.X);
  Result.Y := Round(Point.Y);
end;

function PointToPointF(Point: TPoint): TPointF;
begin
  Result.X := Point.X;
  Result.Y := Point.Y;
end;

function HalfPoint(Point: TPoint): TPoint;
begin
  Result.X := Point.X div 2;
  Result.Y := Point.Y div 2;
end;

function AddPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;

function SubtractPoints(Left, Right: TPoint): TPoint;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;

function HalfPointF(Point: TPointF): TPointF;
begin
  Result.X := Point.X / 2;
  Result.Y := Point.Y / 2;
end;

function AddPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
end;

function SubtractPointsF(Left, Right: TPointF): TPointF;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
end;

function IntersectRects(out Intersection: TRect; const First, Second: TRect): Boolean;
// The native routine is handwritten assembly. Preserve its register saves and
// leave Intersection untouched on failure, including when it aliases an input.
asm
  PUSH ESI
  PUSH EDI
  PUSH ECX
  PUSH EBX
  MOV ESI, EDX
  MOV EDI, ECX
  MOV EBX, EAX
  MOV EAX, [EDI].TRect.Left
  CMP EAX, [ESI].TRect.Right
  JGE @@Empty
  MOV EAX, [EDI].TRect.Right
  CMP EAX, [ESI].TRect.Left
  JLE @@Empty
  MOV EAX, [EDI].TRect.Top
  CMP EAX, [ESI].TRect.Bottom
  JGE @@Empty
  MOV EAX, [EDI].TRect.Bottom
  CMP EAX, [ESI].TRect.Top
  JLE @@Empty
  MOV EAX, [EDI].TRect.Left
  MOV ECX, [ESI].TRect.Left
  CMP EAX, ECX
  JGE @@Left
  MOV EAX, ECX
@@Left:
  MOV [EBX].TRect.Left, EAX
  MOV EAX, [EDI].TRect.Right
  MOV ECX, [ESI].TRect.Right
  CMP EAX, ECX
  JLE @@Right
  MOV EAX, ECX
@@Right:
  MOV [EBX].TRect.Right, EAX
  MOV EAX, [EDI].TRect.Top
  MOV ECX, [ESI].TRect.Top
  CMP EAX, ECX
  JGE @@Top
  MOV EAX, ECX
@@Top:
  MOV [EBX].TRect.Top, EAX
  MOV EAX, [EDI].TRect.Bottom
  MOV ECX, [ESI].TRect.Bottom
  CMP EAX, ECX
  JLE @@Bottom
  MOV EAX, ECX
@@Bottom:
  MOV [EBX].TRect.Bottom, EAX
  XOR EAX, EAX
  INC EAX
  JMP @@Done
@@Empty:
  XOR EAX, EAX
@@Done:
  POP EBX
  POP ECX
  POP EDI
  POP ESI
end;

constructor TObjectEx.Create;
begin
  inherited Create;
end;

destructor TObjectEx.Destroy;
begin
  inherited Destroy;
end;

end.
