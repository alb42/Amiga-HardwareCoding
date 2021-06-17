program sinus;

// Forward declaration to the main program
function InitProgram: LongInt; forward;

// This function must stay as top first function to work
function Start: LongInt; cdecl; public name '_start';
begin
  Start := InitProgram;
end;

{$include Exec.inc}
{$include CustomChips.inc}


const
  // size of my screen
  ScWidth = 320;
  ScHeight = 256;
  BitPlaneSize = (ScWidth * ScHeight) div 8;
  // sinus table a bit bigger than needed, but who cares ;)
  SinTable: array[0..640] of Word = (
    $0002,$0005,$0008,$000B,$000E,$0011,$0014,$0017,$001B,$001E,
    $0021,$0024,$0027,$002A,$002D,$0030,$0033,$0036,$0039,$003C,
    $003F,$0043,$0046,$0049,$004C,$004F,$0051,$0054,$0057,$005A,
    $005D,$0060,$0063,$0066,$0069,$006C,$006E,$0071,$0074,$0077,
    $007A,$007C,$007F,$0082,$0084,$0087,$008A,$008C,$008F,$0092,
    $0094,$0097,$0099,$009C,$009E,$00A1,$00A3,$00A5,$00A8,$00AA,
    $00AC,$00AF,$00B1,$00B3,$00B5,$00B8,$00BA,$00BC,$00BE,$00C0,
    $00C2,$00C4,$00C6,$00C8,$00CA,$00CC,$00CE,$00D0,$00D1,$00D3,
    $00D5,$00D7,$00D8,$00DA,$00DC,$00DD,$00DF,$00E0,$00E2,$00E3,
    $00E4,$00E6,$00E7,$00E8,$00EA,$00EB,$00EC,$00ED,$00EE,$00F0,
    $00F1,$00F2,$00F3,$00F4,$00F4,$00F5,$00F6,$00F7,$00F8,$00F8,
    $00F9,$00FA,$00FA,$00FB,$00FC,$00FC,$00FC,$00FD,$00FD,$00FE,
    $00FE,$00FE,$00FE,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,$00FF,
    $00FF,$00FF,$00FF,$00FE,$00FE,$00FE,$00FE,$00FD,$00FD,$00FC,
    $00FC,$00FC,$00FB,$00FA,$00FA,$00F9,$00F8,$00F8,$00F7,$00F6,
    $00F5,$00F4,$00F4,$00F3,$00F2,$00F1,$00F0,$00EE,$00ED,$00EC,
    $00EB,$00EA,$00E8,$00E7,$00E6,$00E4,$00E3,$00E2,$00E0,$00DF,
    $00DD,$00DC,$00DA,$00D8,$00D7,$00D5,$00D3,$00D1,$00D0,$00CE,
    $00CC,$00CA,$00C8,$00C6,$00C4,$00C2,$00C0,$00BE,$00BC,$00BA,
    $00B8,$00B5,$00B3,$00B1,$00AF,$00AC,$00AA,$00A8,$00A5,$00A3,
    $00A1,$009E,$009C,$0099,$0097,$0094,$0092,$008F,$008C,$008A,
    $0087,$0084,$0082,$007F,$007C,$007A,$0077,$0074,$0071,$006E,
    $006C,$0069,$0066,$0063,$0060,$005D,$005A,$0057,$0054,$0051,
    $004F,$004C,$0049,$0046,$0043,$003F,$003C,$0039,$0036,$0033,
    $0030,$002D,$002A,$0027,$0024,$0021,$001E,$001B,$0017,$0014,
    $0011,$000E,$000B,$0008,$0005,$0002,$FFFE,$FFFB,$FFF8,$FFF5,
    $FFF2,$FFEF,$FFEC,$FFE9,$FFE5,$FFE2,$FFDF,$FFDC,$FFD9,$FFD6,
    $FFD3,$FFD0,$FFCD,$FFCA,$FFC7,$FFC4,$FFC1,$FFBD,$FFBA,$FFB7,
    $FFB4,$FFB1,$FFAF,$FFAC,$FFA9,$FFA6,$FFA3,$FFA0,$FF9D,$FF9A,
    $FF97,$FF94,$FF92,$FF8F,$FF8C,$FF89,$FF86,$FF84,$FF81,$FF7E,
    $FF7C,$FF79,$FF76,$FF74,$FF71,$FF6E,$FF6C,$FF69,$FF67,$FF64,
    $FF62,$FF5F,$FF5D,$FF5B,$FF58,$FF56,$FF54,$FF51,$FF4F,$FF4D,
    $FF4B,$FF48,$FF46,$FF44,$FF42,$FF40,$FF3E,$FF3C,$FF3A,$FF38,
    $FF36,$FF34,$FF32,$FF30,$FF2F,$FF2D,$FF2B,$FF29,$FF28,$FF26,
    $FF24,$FF23,$FF21,$FF20,$FF1E,$FF1D,$FF1C,$FF1A,$FF19,$FF18,
    $FF16,$FF15,$FF14,$FF13,$FF12,$FF10,$FF0F,$FF0E,$FF0D,$FF0C,
    $FF0C,$FF0B,$FF0A,$FF09,$FF08,$FF08,$FF07,$FF06,$FF06,$FF05,
    $FF04,$FF04,$FF04,$FF03,$FF03,$FF02,$FF02,$FF02,$FF02,$FF01,
    $FF01,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01,$FF01,$FF02,
    $FF02,$FF02,$FF02,$FF03,$FF03,$FF04,$FF04,$FF04,$FF05,$FF06,
    $FF06,$FF07,$FF08,$FF08,$FF09,$FF0A,$FF0B,$FF0C,$FF0C,$FF0D,
    $FF0E,$FF0F,$FF10,$FF12,$FF13,$FF14,$FF15,$FF16,$FF18,$FF19,
    $FF1A,$FF1C,$FF1D,$FF1E,$FF20,$FF21,$FF23,$FF24,$FF26,$FF28,
    $FF29,$FF2B,$FF2D,$FF2F,$FF30,$FF32,$FF34,$FF36,$FF38,$FF3A,
    $FF3C,$FF3E,$FF40,$FF42,$FF44,$FF46,$FF48,$FF4B,$FF4D,$FF4F,
    $FF51,$FF54,$FF56,$FF58,$FF5B,$FF5D,$FF5F,$FF62,$FF64,$FF67,
    $FF69,$FF6C,$FF6E,$FF71,$FF74,$FF76,$FF79,$FF7C,$FF7E,$FF81,
    $FF84,$FF86,$FF89,$FF8C,$FF8F,$FF92,$FF94,$FF97,$FF9A,$FF9D,
    $FFA0,$FFA3,$FFA6,$FFA9,$FFAC,$FFAF,$FFB2,$FFB4,$FFB7,$FFBA,
    $FFBE,$FFC1,$FFC4,$FFC7,$FFCA,$FFCD,$FFD0,$FFD3,$FFD6,$FFD9,
    $FFDC,$FFDF,$FFE2,$FFE5,$FFE9,$FFEC,$FFEF,$FFF2,$FFF5,$FFF8,
    $FFFB,$FFFE,$0002,$0005,$0008,$000B,$000E,$0011,$0014,$0017,
    $001B,$001E,$0021,$0024,$0027,$002A,$002D,$0030,$0033,$0036,
    $0039,$003C,$003F,$0043,$0046,$0049,$004C,$004F,$0051,$0054,
    $0057,$005A,$005D,$0060,$0063,$0066,$0069,$006C,$006E,$0071,
    $0074,$0077,$007A,$007C,$007F,$0082,$0084,$0087,$008A,$008C,
    $008F,$0092,$0094,$0097,$0099,$009C,$009E,$00A1,$00A3,$00A5,
    $00A8,$00AA,$00AC,$00AF,$00B1,$00B3,$00B5,$00B8,$00BA,$00BC,
    $00BE,$00C0,$00C2,$00C4,$00C6,$00C8,$00CA,$00CC,$00CE,$00D0,
    $00D1,$00D3,$00D5,$00D7,$00D8,$00DA,$00DC,$00DD,$00DF,$00E0,
    $00E2,$00E3,$00E4,$00E6,$00E7,$00E8,$00EA,$00EB,$00EC,$00ED,
    $00EE,$00F0,$00F1,$00F2,$00F3,$00F4,$00F4,$00F5,$00F6,$00F7,
    $00F8,$00F8,$00F9,$00FA,$00FA,$00FB,$00FC,$00FC,$00FC,$00FD,
    $00FD,$00FE,$00FE,$00FE,$00FE,$00FF,$00FF,$00FF,$00FF,$00FF,
    $00ff);

var
  DOSBase: pointer;

function PutStr(const str: PChar location 'd1') : LongBool; syscall DOSBase 948;


procedure SetPoint(P: Pointer; x, y: LongInt);
var
  BP: PByte;
begin
  BP := P + (y * (ScWidth div 8));
  BP := BP + x div 8;
  BP^ := BP^ or (1 shl (7 - (x mod 8)));
end;

procedure ClearPoint(P: Pointer; x, y: LongInt);
var
  BP: PByte;
begin
  BP := P + (y * (ScWidth div 8));
  BP := BP + x div 8;
  BP^ := BP^ and not (1 shl (7 - (x mod 8)));
end;

const
  NumberOfPoints = 640;

procedure DoCopperScreen;
var
  CLSize: Integer;
  CopperMem: Pointer;
  CopWrite, PlanePos: PWord;
  OldView: Pointer;
  BitPlane: Pointer;
  i: Integer;
  x1,y1: Word;
  PointPos: Integer;
  Points: array[0..NumberOfPoints-1] of record
    x,y: Word;
  end;

procedure Redraw;
var
  nx, ny: Integer;
begin
  PointPos := (PointPos + 1) mod NumberOfPoints; // next point in Buffer
  // calculate Point
  nx := (159 + (SmallInt(SinTable[x1 and $1FF]) div 2)) mod 320;
  ny := (127 + (SmallInt(SinTable[(y1 + (y1 shr 6)) and $1FF])) div 2) mod 256;
  // clear the old point
  ClearPoint(BitPlane, Points[PointPos].X, Points[PointPos].Y);
  // set the point
  SetPoint(BitPlane, nx, ny);
  // remember the point for next cycle
  Points[PointPos].X := nx;
  Points[PointPos].Y := ny;
end;

begin
  x1 := 0;
  y1 := 0;
  PutStr('Start...');
  // remember old view
  OldView := PGfxBase(GFXBase)^.ActiView;
  LoadView(nil);
  // 2 times because if Interlace, we need to wait 2 frames
  WaitTOF();
  WaitTOF();

  // Create a bitplane
  BitPlane := ExecAllocMem(BitPlaneSize, MEMF_CHIP or MEMF_CLEAR);
  // set screen parameter, 1 bitplane
  PWord(GetCAddress(BPLCON0))^ := $1200;
  PWord(GetCAddress(BPLCON1))^ := $0000;

  PWord(GetCAddress(BPL1MOD))^ := 0;
  PWord(GetCAddress(BPL2MOD))^ := 0;

  PWord(GetCAddress(DIWSTRT))^ := $2c81;
  PWord(GetCAddress(DIWSTOP))^ := $2cc1;

  PWord(GetCAddress(DDFSTRT))^ := $0038;
  PWord(GetCAddress(DDFSTOP))^ := $00d0;
  //
  CLSize := 20 * SizeOf(LongWord); // max 20 lines should be enough for now ;)
  CopperMem := ExecAllocMem(CLSize, MEMF_CHIP);
  CopWrite := CopperMem;
  //
  // Make Copperlist
  PlanePos := CopWrite;
  AddValueToCopList(CopWrite, BPL1PTH, BitPlane);
  AddValueToCopList(CopWrite, Color00, $0000);
  AddValueToCopList(CopWrite, Color01, $0ccc);
  AddWaitXYToCopList(CopWrite, $78, $0f);
  AddValueToCopList(CopWrite, Color00, $0f00);
  AddValueToCopList(CopWrite, Color01, $0cf0);
  AddWaitXYToCopList(CopWrite, $d7, $0f);
  AddValueToCopList(CopWrite, Color00, $0fb0);
  AddValueToCopList(CopWrite, Color01, $00bc);
  AddWaitXYToCopList(CopWrite, $FF, $FF);
  // Stop system
  Forbid();
  // enable my copperlist
  WriteDMACON([dmaSPREN, dmaCOPEN, dmaBPLEN, dmaDMAEN]);
  WriteCopperList(CopperMem);
  StartCopper;
  WriteDMACON([dmaSET, dmaCOPEN, dmaBPLEN, dmaDMAEN]);
  // reset Points buffer
  for i := 0 to NumberOfPoints - 1 do
  begin
    Points[i].X := 0;
    Points[i].Y := 0;
  end;
  // main loop
  repeat
    WaitTOF(); // wait for vertical interrupt
    // draw lines
    for i := 1 to 200 do
    begin
      x1 := (x1 + 1) mod $FFFFFFF;
      y1 := (y1 + 1) mod $FFFFFFF;
      Redraw;
      if IsLeftMousePressed then
        Break;
    end;
  until IsLeftMousePressed;
  // end game
  //
  LoadView(OldView);
  WaitTOF();
  BackToSystemCopperList;
  //
  Permit();
  ExecFreeMem(CopperMem, CLSize);
  ExecFreeMem(BitPlane, BitPlaneSize);
  PutStr('...end'#10);
end;

function InitProgram: longint;
begin
  InitProgram := 5;
  DOSBase := OpenLibrary('dos.library',0);
  GFXBase := OpenLibrary('graphics.library', 0);
  if Assigned(DOSBase) and Assigned(GFXBase) then
  begin
    // insert your program -->
    //
    DoCopperScreen;
    //
    // <-- insert your program
    InitProgram := 0;
  end;
  if Assigned(DOSBase) then CloseLibrary(DOSBase);
  if Assigned(GFXBase) then CloseLibrary(GFXBase);
end;

begin
end.
