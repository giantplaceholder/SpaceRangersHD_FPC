unit aCalc;
// Native wrappers occupy $4DC734..$4DC77F, separate from ThreadCalc.
// PACKAGEINFO visits aCalc immediately before its ThreadCalc dependency.

interface

uses ThreadCalc;

// UI-facing turn calculation wrappers.
procedure WaitForTurnCalculationUI; // @addr 0x4DC734
function IsTurnCalculationRunningUI: Boolean; // @addr 0x4DC73C
procedure CalculateGalaxyTurnAndWait; // @addr 0x4DC750
procedure QueueGalaxyTurnCalculation; // @addr 0x4DC75C
procedure CalculatePlayerStarTurnAndWait; // @addr 0x4DC764
procedure QueuePlayerStarTurnCalculation; // @addr 0x4DC770
procedure QueuePlayerStarPreparation; // @addr 0x4DC778

var
  TurnCalculationPhase: TTurnCalculationPhase; // @addr 0x88A23C

implementation

uses ThreadCalc;

{ @routine $4DC734 WaitForTurnCalculationUI }
procedure WaitForTurnCalculationUI;
begin
  WaitForTurnCalculation;
end;
{ @end $4DC734 }

{ @routine $4DC73C IsTurnCalculationRunningUI }
function IsTurnCalculationRunningUI: Boolean;
begin
  Result := IsTurnCalculationRunning;
end;
{ @end $4DC73C }

{ @routine $4DC750 CalculateGalaxyTurnAndWait }
procedure CalculateGalaxyTurnAndWait;
begin
  StartGalaxyTurnCalculation;
  WaitForTurnCalculation;
end;
{ @end $4DC750 }

{ @routine $4DC75C QueueGalaxyTurnCalculation }
procedure QueueGalaxyTurnCalculation;
begin
  StartGalaxyTurnCalculation;
end;
{ @end $4DC75C }

{ @routine $4DC764 CalculatePlayerStarTurnAndWait }
procedure CalculatePlayerStarTurnAndWait;
begin
  StartPlayerStarTurnCalculation;
  WaitForTurnCalculation;
end;
{ @end $4DC764 }

{ @routine $4DC770 QueuePlayerStarTurnCalculation }
procedure QueuePlayerStarTurnCalculation;
begin
  StartPlayerStarTurnCalculation;
end;
{ @end $4DC770 }

{ @routine $4DC778 QueuePlayerStarPreparation }
procedure QueuePlayerStarPreparation;
begin
  StartPlayerStarPreparation;
end;
{ @end $4DC778 }

end.
