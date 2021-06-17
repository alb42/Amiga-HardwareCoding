program Copper;

// Forward declaration to the main program
function InitProgram: LongInt; forward;

// This function must stay as top first function to work
function Start: LongInt; cdecl; public name '_start';
begin
  Start := InitProgram;
end;

{$include Exec.inc}
{$include CustomChips.inc}

procedure DoCopperScreen;
var
  CLSize: Integer;
  CopperMem: Pointer;
  CopWrite: PWord;
  OldView: Pointer;
begin
  OldView := PGfxBase(GFXBase)^.ActiView;
  LoadView(nil);
  // 2 times because if Interlace, we need to wait 2 frames
  WaitTOF();
  WaitTOF();
  //
  CLSize := 10 * SizeOf(LongWord); // max 10 lines should be enough for now ;)
  CopperMem := ExecAllocMem(CLSize, MEMF_CHIP);
  CopWrite := CopperMem;
  //
  // Make Copperlist
  AddValueToCopList(CopWrite, Color00, $0000);
  AddWaitXYToCopList(CopWrite, $78, $0f);
  AddValueToCopList(CopWrite, Color00, $0f00);
  AddWaitXYToCopList(CopWrite, $d7, $0f);
  AddValueToCopList(CopWrite, Color00, $0fb0);
  AddWaitXYToCopList(CopWrite, $FF, $FF);
  //
  // Stop system
  Forbid();
  // enable my copperlist
  WriteDMACON([dmaSPREN, dmaCOPEN, dmaBPLEN, dmaDMAEN]);
  WriteCopperList(CopperMem);
  StartCopper;
  WriteDMACON([dmaSET, dmaCOPEN, dmaDMAEN]);
  // main loop
  repeat
    WaitTOF(); // prevents too fast looping
  until IsLeftMousePressed;
  // end
  //
  // restore old View
  LoadView(OldView);
  WaitTOF();
  BackToSystemCopperList;
  //
  Permit();
  ExecFreeMem(CopperMem, CLSize);
end;

function InitProgram: longint;
begin
  InitProgram := 5;
  GFXBase := OpenLibrary('graphics.library', 0);
  if Assigned(GFXBase) then
  begin
    // insert your program -->
    //
    DoCopperScreen;
    //
    // <-- insert your program
    InitProgram := 0;
  end;
  if Assigned(GFXBase) then CloseLibrary(GFXBase);
end;

begin
end.
