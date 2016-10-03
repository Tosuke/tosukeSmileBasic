module tosuke.smilebasic.compiler.gencode;

import tosuke.smilebasic.compiler;

VMCode[] genCode(OperationList list){
  import std.array;
  Appender!(VMCode[]) temp;
  foreach(op; list){
    temp ~= op.code;
  }
  return temp.data;
}
