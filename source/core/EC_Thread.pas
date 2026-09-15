unit EC_Thread;

{$O-}
{$R-}
{$Q-}
{$B-}
{$A8}

interface

uses
  EC_Struct,
  SyncObjs;

type

  TThreadEC = class;

  TThreadEC = class(TObjectEx)
    Lock: TCriticalSection;
    ThreadHandle: Cardinal;
    ThreadId: Cardinal;
    Priority: Byte;
    StopRequested: Boolean;
    Gap12: array[0..1] of Byte;
    StopEvent: Cardinal;
    Flag18: Boolean;
    Gap19: array[0..2] of Byte;
    ShutdownEvent: Cardinal;
    StartEvent: Cardinal;
    RunningEvent: Cardinal;
    IdleEvent: Cardinal;
    procedure Execute; virtual;
    constructor Create;
    destructor Destroy; override;
    procedure ProcessRequests;
    procedure SetPriority(Value: Byte);
    procedure SetFlag18;
    procedure ClearFlag18;
    procedure RequestStop;
    function IsStopRequested: Boolean;
    procedure SetStopRequested(Value: Boolean);
    procedure Start;
    function IsRunning: Boolean;
    function WaitForIdle(TimeoutMs: Cardinal): Boolean;
  end;

const

  ThreadPriorityLowest = 1;

  ThreadPriorityAboveNormal = 4;

  ThreadPriorityValues: array[0..6] of Integer = (-15, -2, -1, 0, 1, 2, 15);

function ThreadEntryEC(Thread: Pointer): Integer;

implementation

uses
  Windows,
  SysUtils,
  GR_Main;

function ThreadEntryEC(Thread: Pointer): Integer;
begin
  try
    TThreadEC(Thread).ProcessRequests;
  except
    on E: Exception do
      ;
  end;
  if TThreadEC(Thread).ThreadHandle <> 0 then
  begin
    CloseHandle(TThreadEC(Thread).ThreadHandle);
    TThreadEC(Thread).ThreadHandle := 0;
  end;
  TThreadEC(Thread).ThreadId := 0;
  Result := 0;
end;

constructor TThreadEC.Create;
begin
  inherited Create;
  Lock := TCriticalSection.Create;
  StopEvent := CreateEvent(nil, True, False, nil);
  if StopEvent = 0 then
    raise Exception.Create('TThreadEC.Create CreateEvent');
  ShutdownEvent := CreateEvent(nil, False, False, nil);
  if ShutdownEvent = 0 then
    raise Exception.Create('TThreadEC.Create CreateEvent');
  StartEvent := CreateEvent(nil, False, False, nil);
  if StartEvent = 0 then
    raise Exception.Create('TThreadEC.Create CreateEvent');
  RunningEvent := CreateEvent(nil, True, False, nil);
  if RunningEvent = 0 then
    raise Exception.Create('TThreadEC.Create CreateEvent');
  IdleEvent := CreateEvent(nil, True, True, nil);
  if IdleEvent = 0 then
    raise Exception.Create('TThreadEC.Create CreateEvent');
  ThreadHandle := BeginThread(nil, 0, @ThreadEntryEC, Self, CREATE_SUSPENDED, ThreadId);
  SetThreadPriority(ThreadHandle, THREAD_PRIORITY_NORMAL);
  ResumeThread(ThreadHandle);
end;

destructor TThreadEC.Destroy;
begin
  if ShutdownEvent <> 0 then
  begin
    SetEvent(ShutdownEvent);
    WaitForSingleObject(ThreadHandle, INFINITE);
  end;
  if IdleEvent <> 0 then
  begin
    CloseHandle(IdleEvent);
    IdleEvent := 0
  end;
  if StartEvent <> 0 then
  begin
    CloseHandle(StartEvent);
    StartEvent := 0
  end;
  if RunningEvent <> 0 then
  begin
    CloseHandle(RunningEvent);
    RunningEvent := 0
  end;
  if ShutdownEvent <> 0 then
  begin
    CloseHandle(ShutdownEvent);
    ShutdownEvent := 0
  end;
  if StopEvent <> 0 then
  begin
    CloseHandle(StopEvent);
    StopEvent := 0
  end;
  Lock.Free;
  inherited Destroy;
end;

procedure TThreadEC.ProcessRequests;
var
  Events: array[0..1] of THandle;
  WaitResult: Cardinal;
begin
  Events[0] := ShutdownEvent;
  Events[1] := StartEvent;
  while True do
  begin
    WaitResult := WaitForMultipleObjects(Length(Events), @Events, False, INFINITE);
    if WaitResult <> WAIT_OBJECT_0 + 1 then
      Break;
    Lock.Enter;
    try
      if not IsRunning then
      begin
        ResetEvent(StopEvent);
        StopRequested := False;
        ResetEvent(IdleEvent);
        SetEvent(RunningEvent);
      end;
    finally
      Lock.Leave;
    end;
    try
      Execute;
    except
      on E: Exception do
      begin
        AppendLogLineThreadSafe(E.Message);
        AppendLogLineThreadSafe('Thread exception');
        raise;
      end;
    end;
    Lock.Enter;
    try
      ResetEvent(RunningEvent);
      SetEvent(IdleEvent);
    finally
      Lock.Leave;
    end;
  end;
end;

procedure TThreadEC.Execute;
begin
  while not IsStopRequested do
    SysUtils.Sleep(100);
end;

procedure TThreadEC.SetPriority(Value: Byte);
begin
  Priority := Value;
  if ThreadHandle <> 0 then
    SetThreadPriority(ThreadHandle, ThreadPriorityValues[Value]);
end;

procedure TThreadEC.SetFlag18;
begin
  Flag18 := True;
end;

procedure TThreadEC.ClearFlag18;
begin
  Flag18 := False;
end;

procedure TThreadEC.RequestStop;
begin
  Lock.Enter;
  StopRequested := True;
  SetEvent(StopEvent);
  Lock.Leave;
end;

function TThreadEC.IsStopRequested: Boolean;
begin
  Lock.Enter;
  Result := StopRequested;
  Lock.Leave;
end;

procedure TThreadEC.SetStopRequested(Value: Boolean);
begin
  if Value then
    RequestStop
  else
  begin
    Lock.Enter;
    StopRequested := False;
    ResetEvent(StopEvent);
    Lock.Leave;
  end;
end;

procedure TThreadEC.Start;
begin
  Lock.Enter;
  try
    if IsRunning then
      Exit;
    ResetEvent(StopEvent);
    StopRequested := False;
    ResetEvent(IdleEvent);
    SetEvent(RunningEvent);
    SetEvent(StartEvent);
  finally
    Lock.Leave;
  end;
end;

function TThreadEC.IsRunning: Boolean;
begin
  Lock.Enter;
  Result := WaitForSingleObject(IdleEvent, 0) = WAIT_TIMEOUT;
  Lock.Leave;
end;

function TThreadEC.WaitForIdle(TimeoutMs: Cardinal): Boolean;
begin
  if WaitForSingleObject(IdleEvent, TimeoutMs) = WAIT_TIMEOUT then
    Result := False
  else
    Result := True;
end;

end.
