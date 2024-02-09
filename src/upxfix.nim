from memfiles import open, MemFile
import strutils
import streams

const MAGIC = 0x21585055  # "UPX!"

type
  Linfo* = object
    checksum*: uint32
    magic*: uint32
    lSize*: uint16
    version*: uint8
    format*: uint8

  Pinfo* = object
    progid*: uint32
    fileSize*: uint32
    blockSize*: uint32

proc isZeroed*(pInfo: Pinfo): bool =
  return pInfo.fileSize == 0 or pInfo.blockSize == 0

proc `+`*(a: pointer, b: int): pointer = cast[pointer](cast[int](a) + b)

proc getMagicOffset*(s: MemFile): int =
  var 
    buf: uint32
    rPos: int
  while rPos < s.size:
    moveMem(addr buf, s.mem + rPos, sizeof(buf))
    if buf == MAGIC: return rPos
    rPos.inc(sizeof(buf))  # We assume the UPX! magic is aligned. Change to 1 if not

proc recoverFileSize*(s: MemFile): uint32 =
  moveMem(addr result, s.mem + (s.size - 12), sizeof(result))

proc fix(fileName: string, force = false) =
  var
    lInfo: Linfo
    pInfo: Pinfo
  let
    fSrc = memfiles.open(fileName, mode=fmRead)
    lInfoOffset = fSrc.getMagicOffset - 4
    pInfoOffset = lInfoOffset + sizeof(Linfo)

  if lInfoOffset <= 0:
    echo "Unable to find UPX magic."
    return

  moveMem(addr lInfo, fSrc.mem + lInfoOffset, sizeof(Linfo))
  moveMem(addr pInfo, fSrc.mem + pInfoOffset, sizeof(Pinfo))

  if not pInfo.isZeroed() or force:
    echo fileName & ": pInfo structure not zeroed."
    return

  let fileSize = fSrc.recoverFileSize()
  pInfo.fileSize = fileSize
  pInfo.blockSize = fileSize

  var fDst = newFileStream(fileName & ".fix", fmWrite)
  fDst.writeData(fSrc.mem, lInfoOffset)
  fDst.writeData(addr lInfo, sizeof(lInfo))
  fDst.writeData(addr pInfo, sizeof(pInfo))
  fDst.writeData(fSrc.mem + fDst.getPosition, fSrc.size - fDst.getPosition)
  echo fileName & ": fileSize recovered - 0x" & fileSize.toHex()

proc fixFiles(force = false, fileNames: seq[string]) {.used.} =
  if fileNames.len == 0:
    echo "no files provided, -h for help."
    return
  for f in fileNames: f.fix(force)

when isMainModule:
  import cligen
  dispatch fixFiles, cmdName="upxfix"
