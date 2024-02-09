import unittest
import upxfix
from memfiles import open, MemFile

suite "Testing x64 /bin/true":
  let 
    fSrc = memfiles.open("tests/files/true", mode=fmRead)
    magic = fSrc.getMagicOffset
    lInfoOffset = magic - 4
    pInfoOffset = lInfoOffset + sizeof(Linfo)
    fileSize = fSrc.recoverFileSize()
  var
    lInfo: Linfo
    pInfo: Pinfo
  
  test "UPX magic found":
    check magic == 0xec

  test "Struct offsets":
    check lInfoOffset == 0xe8
    check pInfoOffset == 0xf4

  test "Structs extraction":
    moveMem(addr lInfo, fSrc.mem + lInfoOffset, sizeof(Linfo))
    moveMem(addr pInfo, fSrc.mem + pInfoOffset, sizeof(Pinfo))
    check lInfo.checksum == 0x15EF3BCF
    check lInfo.magic == 0x21585055
    check lInfo.lsize == 0x954
    check lInfo.version == 0xD
    check lInfo.format == 0x16
    check pInfo.progid == 0
    check pInfo.fileSize == 0
    check pInfo.blockSize == 0
    check pInfo.isZeroed()

  test "Recover correct filesize":
    check fileSize == 0x6930

