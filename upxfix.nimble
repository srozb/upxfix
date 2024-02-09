# Package

version       = "0.1.0"
author        = "srozb"
description   = "Fix UPX l_info & p_info structs"
license       = "MIT"
srcDir        = "src"
binDir        = "release"
bin           = @["upxfix"]

task test, "Runs the test suite":
  exec "nim c -r tests/fix"


# Dependencies

requires "nim >= 2.0.0, cligen"
