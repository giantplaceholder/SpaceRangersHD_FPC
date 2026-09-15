unit EC_Mem;

{$O-}
{$R-}
{$Q-}
{$B-}
{$A8}

interface

function AllocEC(ByteCount: Integer): Pointer;

function AllocClearEC(ByteCount: Integer): Pointer;

function ReAllocREC(Data: Pointer; ByteCount: Integer): Pointer;

procedure FreeEC(Data: Pointer);

function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;

function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;

function ReAllocFromHeapREC(Heap: Cardinal; Data: Pointer; ByteCount: Integer): Pointer;

procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer);

function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl;

procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl;

procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl;

procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl;

procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl;

procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl;

procedure WriteDoubleEC(Dest: Pointer; Value: Double); cdecl;

function ReadByteEC(Source: Pointer): Byte; cdecl;

function ReadWideCharEC(Source: Pointer): WideChar; cdecl;

function ReadWordEC(Source: Pointer): Word; cdecl;

function ReadDWordEC(Source: Pointer): Cardinal; cdecl;

function ReadIntegerEC(Source: Pointer): Integer; cdecl;

function ReadSingleEC(Source: Pointer): Single; cdecl;

function ReadDoubleEC(Source: Pointer): Double; cdecl;

implementation

uses
  GR_DX,
  GR_Main,
  SysUtils,
  Windows;

function AllocEC(ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(GetProcessHeap, 0, ByteCount);
  if Memory = nil then
  begin
    AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
    EvictTextureCaches(True);
    Memory := HeapAlloc(GetProcessHeap, 0, ByteCount);
    if Memory <> nil then
      AppendLogLineThreadSafe('success')
    else
    begin
      AppendLogLineThreadSafe('fail');
      LogMemoryUsage;
      raise Exception.Create('AllocEC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end;
  Result := Memory;
end;

function AllocClearEC(ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, ByteCount);
  if Memory = nil then
  begin
    AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
    EvictTextureCaches(True);
    Memory := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, ByteCount);
    if Memory <> nil then
      AppendLogLineThreadSafe('success')
    else
    begin
      AppendLogLineThreadSafe('fail');
      LogMemoryUsage;
      raise Exception.Create('AllocClearEC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end;
  Result := Memory;
end;

function ReAllocREC(Data: Pointer; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  if (ByteCount <= 0) and (Data <> nil) then
  begin
    HeapFree(GetProcessHeap, 0, Data);
    Memory := nil;
  end
  else if ByteCount <= 0 then
    Memory := nil
  else if (ByteCount > 0) and (Data <> nil) then
  begin
    Memory := HeapReAlloc(GetProcessHeap, 0, Data, ByteCount);
    if Memory = nil then
    begin
      AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
      EvictTextureCaches(True);
      Memory := HeapReAlloc(GetProcessHeap, 0, Data, ByteCount);
      if Memory <> nil then
        AppendLogLineThreadSafe('success')
      else
      begin
        AppendLogLineThreadSafe('fail');
        LogMemoryUsage;
        raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
      end;
    end;
  end
  else
  begin
    Memory := HeapAlloc(GetProcessHeap, 0, ByteCount);
    if Memory = nil then
    begin
      AppendLogTextThreadSafe('Failed to allocate memory, trying to free some textures... ');
      EvictTextureCaches(True);
      Memory := HeapAlloc(GetProcessHeap, 0, ByteCount);
      if Memory <> nil then
        AppendLogLineThreadSafe('success')
      else
      begin
        AppendLogLineThreadSafe('fail');
        LogMemoryUsage;
        raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
      end;
    end;
  end;
  Result := Memory;
end;

procedure FreeEC(Data: Pointer);
begin
  HeapFree(GetProcessHeap, 0, Data)
end;

function AllocFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(Heap, 0, ByteCount);
  if Memory = nil then
  begin
    raise Exception.Create('AllocEC. size=' + SysUtils.IntToStr(ByteCount));
  end;
  Result := Memory;
end;

function AllocClearFromHeapEC(Heap: Cardinal; ByteCount: Integer): Pointer;
var
  Memory: Pointer;
begin
  Memory := HeapAlloc(Heap, HEAP_ZERO_MEMORY, ByteCount);
  if Memory = nil then
  begin
    raise Exception.Create('AllocClearEC. size=' + SysUtils.IntToStr(ByteCount));
  end;
  Result := Memory;
end;

function ReAllocFromHeapREC(Heap: Cardinal; Data: Pointer; ByteCount: Integer): Pointer;

begin
  if (ByteCount <= 0) and (Data <> nil) then
  begin
    HeapFree(Heap, 0, Data);
    Data := nil;
  end
  else if ByteCount <= 0 then
    Data := nil
  else if (ByteCount > 0) and (Data <> nil) then
  begin
    Data := HeapReAlloc(Heap, 0, Data, ByteCount);
    if Data = nil then
    begin
      raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end
  else
  begin
    Data := HeapAlloc(Heap, 0, ByteCount);
    if Data = nil then
    begin
      raise Exception.Create('ReAllocREC. size=' + SysUtils.IntToStr(ByteCount));
    end;
  end;
  Result := Data;
end;

procedure FreeFromHeapEC(Heap: Cardinal; Data: Pointer);
begin
  HeapFree(Heap, 0, Data)
end;

function AddPointerOffset(Data: Pointer; ByteOffset: Integer): Pointer; cdecl;
asm
  MOV EAX, Data
  ADD EAX, ByteOffset
end;

procedure WriteByteEC(Dest: Pointer; Value: Byte); cdecl;
asm
  MOV EDX, Dest
  MOV AL, Value
  MOV [EDX], AL
end;

procedure WriteWordEC(Dest: Pointer; Value: Word); cdecl;
asm
  MOV EDX, Dest
  MOV AX, Value
  MOV [EDX], AX
end;

procedure WriteIntegerEC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;

procedure WriteInt32EC(Dest: Pointer; Value: Integer); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;

procedure WriteSingleEC(Dest: Pointer; Value: Single); cdecl;
asm
  MOV EDX, Dest
  MOV EAX, Value
  MOV [EDX], EAX
end;

procedure WriteDoubleEC(Dest: Pointer; Value: Double); cdecl;
asm
  PUSH EBX
  MOV EBX, Dest
  LEA EDX, Value
  MOV EAX, [EDX]
  MOV [EBX], EAX
  MOV EAX, [EDX + 4]
  MOV [EBX + 4], EAX
  POP EBX
end;

function ReadByteEC(Source: Pointer): Byte; cdecl;
asm
  MOV EAX, Source
  MOV AL, [EAX]
end;

function ReadWideCharEC(Source: Pointer): WideChar; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;

function ReadWordEC(Source: Pointer): Word; cdecl;
asm
  MOV EAX, Source
  MOV AX, [EAX]
end;

function ReadDWordEC(Source: Pointer): Cardinal; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;

function ReadIntegerEC(Source: Pointer): Integer; cdecl;
asm
  MOV EAX, Source
  MOV EAX, [EAX]
end;

function ReadSingleEC(Source: Pointer): Single; cdecl;
asm
  MOV EAX, Source
  FLD DWORD PTR [EAX]
end;

function ReadDoubleEC(Source: Pointer): Double; cdecl;
asm
  MOV EAX, Source
  FLD QWORD PTR [EAX]
end;

end.
