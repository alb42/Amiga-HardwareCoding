{$inline on}
{$packset 1}
{$packenum 1}
{$PACKRECORDS 2}


{.$define FOR_AGA}
type
  PGfxBase = ^TGfxBase;
  TGfxBase = record
    t: array[1..33] of Byte;
    ActiView: Pointer;
    copinit: Pointer;
  end;


  TDMAFlag = (dmaSET, dmaBBUSY, dmaBZERO, dmaRES2, dmaRES1, dmaBLTPRI, dmaDMAEN, dmaBPLEN, dmaCOPEN, dmaBLTEN, dmaSPREN, dmaDSKEN, dmaAUS3EN, dmaAUD2EN, dmaAUD1EN, dmaAUD0EN);
  TDMAFlags = set of TDMAFlag;
  PDMAFlags = ^TDMAFlags;
(*
  {$ifdef FOR_AGA}
  TColType = LongWord;
  {$else}
  TColType = Word;
  {$endif}*)

var
  GFXBase: Pointer;

procedure LoadView(View: Pointer location 'a1'); syscall GfxBase 222;
procedure WaitTOF(); syscall GFXBase 270;


const
  Color00 = $180;
  Color01 = $182;
  Color02 = $182;
  Color03 = $183;
  Color04 = $184;
  Color05 = $185;
  Color06 = $186;
  Color07 = $187;
  Color08 = $188;
  Color09 = $189;
  Color10 = $18a;
  Color11 = $18b;
  Color12 = $18c;
  Color13 = $18d;
  Color14 = $18e;
  Color15 = $18f;
  Color16 = $190;
  Color17 = $191;
  Color18 = $192;
  Color19 = $193;
  Color20 = $194;
  Color21 = $195;
  Color22 = $196;
  Color23 = $197;
  Color24 = $198;
  Color25 = $199;
  Color26 = $19a;
  Color27 = $19b;
  Color28 = $19c;
  Color29 = $19d;
  Color30 = $19e;
  Color31 = $19f;


  WaitY   = $ff00;
  WaitXY  = $fffe;

const
  HWBASE = $DFF000;
  COLBASE: Word = $180;
  BPLCONBase: Word = $100;
  DMACONBase: Word = $96;
  CopLC1: Word = $80;
  CopJmp1: Word = $88;

  BPL1PTH: Word = $e0;
  BPL1PTL: Word = $e2;

  BPLCON0: Word = $100;
  BPLCON1: Word = $102;

  BPL1MOD: Word = $108;
  BPL2MOD: Word = $10A;

  DIWSTRT: Word = $8E;
  DIWSTOP: Word = $90;

  DDFSTRT: Word = $92;
  DDFSTOP: Word = $94;

  CIAAPRA = $BFE001;
{$ifdef FOR_AGA}
  MAXCOLOR = 255;
{$else}
  MAXCOLOR = 31;
{$endif}

// Get Custom register address by Offset to $DFF00
function GetCAddress(Offset: Word): Pointer; inline;
begin
  GetCAddress := Pointer(HWBase + Offset);
end;


procedure AddValueToCopList(var CopList: PWord; Reg: Word; Value: Word); inline; overload;
begin
  CopList^ := Reg;
  Inc(CopList);
  CopList^ := Value;
  Inc(CopList);
end;

procedure AddValueToCopList(var CopList: PWord; Reg: Word; Value: Pointer); inline; overload;
begin
  CopList^ := Reg;
  Inc(CopList);
  CopList^ := (NativeUInt(Value) shr 16) and $FFFF;
  Inc(CopList);
  //
  CopList^ := Reg + 2;
  Inc(CopList);
  CopList^ := NativeUInt(Value) and $FFFF;
  Inc(CopList);
end;

procedure AddWaitXYToCopList(var CopList: PWord; X: Word; Y: Word); inline; overload;
begin
  CopList^ := X shl 8 or Y;
  Inc(CopList);
  CopList^ := WaitXY;
  Inc(CopList);
end;

{type
  TScreenMode = (HIRES = 15, OneBitplane=12, HAM = 11, DPF=10, COLOR = 09, GAUD= 08, UHRES=07, SHRES=06, BYPASS=05, BPU3=4, LPEN=03, LACE=02, ERSY=01, ESCENA=0);

procedure SetScreenMode([])}

procedure SetBitplanePointer(Num: Byte; Addr: Pointer); inline;
begin
  //Addr := Pointer(Swap(PtrUInt(Addr)));
  PPointer(GetCAddress(BPL1PTH + (4*Num)))^ := Addr;
end;

function GetBitplanePointer(Num: Byte; Addr: Pointer): Pointer; inline;
begin
  GetBitplanePointer := PPointer(GetCAddress(BPL1PTH + (4*Num)))^;
end;


function IsLeftMousePressed: Boolean; inline;
begin
  IsLeftMousePressed :=(PByte(CIAAPRA)^ and (1 shl 6)) = 0
end;

procedure StartCopper; inline;
begin
  PWord(GetCAddress(CopJmp1))^ := 0;
end;

function ReadCopperList: Pointer; inline;
begin
  ReadCopperList := PPointer(GetCAddress(CopLC1))^;
end;

procedure WriteCopperList(Value: Pointer); inline;
begin
  PPointer(GetCAddress(CopLC1))^ := Value;
end;

function ReadDMACON: TDMAFlags; inline;
begin
  ReadDMACON := PDMAFlags(GetCAddress(DMACONBase))^;
end;

procedure WriteDMACON(Value: TDMAFlags); inline;
begin
  PDMAFlags(GetCAddress(DMACONBase))^ := Value;
end;

function ReadBPLCON3: Word; inline;
begin
  ReadBPLCON3 := PWord(GetCAddress(BPLCONBase + $6))^;
end;

procedure WriteBPLCON3(Value: Word); inline;
begin
  PWord(GetCAddress(BPLCONBase + $6))^ := Value;
end;


procedure BackToSystemCopperList; inline;
begin
  WriteCopperList(PGfxBase(GFXBase)^.copinit);
  StartCopper;
  WriteDMACON([dmaSET, dmaDMAEN, dmaBPLEN, dmaCOPEN, dmaBLTEN, dmaSPREN]);
end;

(*
procedure SetColor(Idx: Byte; Color: TColType);
var
  Adr: PWord;
  {$ifdef FOR_AGA}
  HiRGB, LoRGB: Word;
  Bank, Re: Byte;
  {$endif}
begin
  if Idx <= MAXCOLOR then
  begin
    {$ifdef FOR_AGA}
    // Choose BANK
    Bank := Idx div 32;
    Re := Idx mod 32;
    Adr := GetCAddress(COLBASE + Re);
    WriteBPLCON3(Bank shl 13);
    HiRGB := ((color and $f00000) shr 12) or ((Color and $f000) shr 8) or ((Color and $f0) shr 4);
    Adr^ := HiRGB;
    WriteBPLCON3((Bank shl 13) or (1 shl 9));
    LoRGB := ((color and $0f0000) shr 8) or ((Color and $0f00) shr 4) or (Color and $0f);
    Adr^ := LoRGB;
    {$else}
    Adr := GetCAddress(COLBASE + Idx);
    Adr^ := Color;
    {$endif}
  end;
end;*)
