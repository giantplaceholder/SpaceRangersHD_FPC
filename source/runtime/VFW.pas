unit VFW;

{$I GameOptions.inc}

interface

uses
  Types;

type

  IAVIFile = interface;

  IAVIStream = interface;

  IAVIStream = interface(IInterface)
    function Create(Param1: Integer; Param2: Integer): LongInt; stdcall;
    function Info(StreamInfoW: Pointer; Size: Integer): LongInt; stdcall;
    function FindSample(Position: Integer; Flags: Integer): Integer; stdcall;
    function ReadFormat(Position: Integer; Format: Pointer; var Size: Integer): LongInt; stdcall;
    function SetFormat(Position: Integer; Format: Pointer; Size: Integer): LongInt; stdcall;
    function Read(
        Start: Integer;
        Samples: Integer;
        Buffer: Pointer;
        Size: Integer;
        BytesRead: PInteger;
        SamplesRead: PInteger
    ): LongInt; stdcall;
    function Write(
        Start: Integer;
        Samples: Integer;
        Buffer: Pointer;
        Size: Integer;
        Flags: Cardinal;
        SamplesWritten: PInteger;
        BytesWritten: PInteger
    ): LongInt; stdcall;
    function Delete(Start: Integer; Samples: Integer): LongInt; stdcall;
    function ReadData(Chunk: Cardinal; Buffer: Pointer; var Size: Integer): LongInt; stdcall;
    function WriteData(Chunk: Cardinal; Buffer: Pointer; Size: Integer): LongInt; stdcall;
    function SetInfo(StreamInfoW: Pointer; Size: Integer): LongInt; stdcall;
  end;

  IAVIFile = interface(IInterface)
    function Info(FileInfoW: Pointer; Size: Integer): LongInt; stdcall;
    function GetStream(
        out Stream: IAVIStream;
        StreamType: Cardinal;
        Param: Integer
    ): LongInt; stdcall;
    function CreateStream(out Stream: IAVIStream; StreamInfoW: Pointer): LongInt; stdcall;
    function WriteData(Chunk: Cardinal; Buffer: Pointer; Size: Integer): LongInt; stdcall;
    function ReadData(Chunk: Cardinal; Buffer: Pointer; var Size: Integer): LongInt; stdcall;
    function EndRecord: LongInt; stdcall;
    function DeleteStream(StreamType: Cardinal; Param: Integer): LongInt; stdcall;
  end;

  TAVIStreamInfoA = packed record
    StreamType: Cardinal;
    Handler: Cardinal;
    Flags: Cardinal;
    Caps: Cardinal;
    Priority: Word;
    Language: Word;
    Scale: Cardinal;
    Rate: Cardinal;
    Start: Cardinal;
    Length: Cardinal;
    InitialFrames: Cardinal;
    SuggestedBufferSize: Cardinal;
    Quality: Cardinal;
    SampleSize: Cardinal;
    Frame: TRect;
    EditCount: Cardinal;
    FormatChangeCount: Cardinal;
    Name: array[0..63] of AnsiChar;
  end;

procedure AVIFileInit; stdcall; external 'AVIFIL32.DLL' name 'AVIFileInit';

procedure AVIFileExit; stdcall; external 'AVIFIL32.DLL' name 'AVIFileExit';

function AVIFileOpenA(
    var FileHandle: IAVIFile;
    FileName: PAnsiChar;
    Mode: Cardinal;
    Handler: Pointer
): Integer; stdcall; external 'AVIFIL32.DLL' name 'AVIFileOpenA';

function AVIFileGetStream(
    const FileHandle: IAVIFile;
    var Stream: IAVIStream;
    StreamType: Cardinal;
    Index: Integer
): Integer; stdcall; external 'AVIFIL32.DLL' name 'AVIFileGetStream';

function AVIStreamInfoA(
    const Stream: IAVIStream;
    var Info: TAVIStreamInfoA;
    Size: Integer
): Integer; stdcall; external 'AVIFIL32.DLL' name 'AVIStreamInfoA';

function AVIStreamReadFormat(
    const Stream: IAVIStream;
    Position: Integer;
    Format: Pointer;
    var FormatSize: Integer
): Integer; stdcall; external 'AVIFIL32.DLL' name 'AVIStreamReadFormat';

function AVIStreamRead(
    const Stream: IAVIStream;
    Start: Integer;
    Samples: Integer;
    Buffer: Pointer;
    BufferSize: Integer;
    BytesRead: PCardinal;
    SamplesRead: PCardinal
): Integer; stdcall; external 'AVIFIL32.DLL' name 'AVIStreamRead';

function AVIStreamLength(
    const Stream: IAVIStream
): Integer; stdcall; external 'AVIFIL32.DLL' name 'AVIStreamLength';

implementation

end.
