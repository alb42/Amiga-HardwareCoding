var
  ExecBase: Pointer absolute 4;

const
  MEMF_CHIP = 1 shl 1;
  MEMF_CLEAR = 1 shl 16;

procedure CloseLibrary(libHandle: Pointer location 'a1'); SysCall ExecBase 414;
function OpenLibrary(LibName: PChar location 'a1'; LibVer: LongWord location 'd0'): Pointer; SysCall ExecBase 552;

procedure Forbid; syscall ExecBase 132;
procedure Permit; syscall ExecBase 138;
function ExecAllocMem(Size: LongWord location 'd0'; Req: LongWord location 'd1'): Pointer; syscall ExecBase 198;
procedure ExecFreeMem(Block: Pointer location 'a1'; Size: LongWord location 'd0'); syscall ExecBase 210;
