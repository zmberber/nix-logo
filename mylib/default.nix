{
  lib,
  tools,
  ...
}:
tools.setFromDirWithParam ./. { inherit lib; }
