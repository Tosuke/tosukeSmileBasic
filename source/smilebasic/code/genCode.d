module tosuke.smilebasic.code.gencode;

import tosuke.smilebasic.code.operation;
import tosuke.smilebasic.code.code;

VMCode[] genCode(OperationList list){
  import std.array;
  Appender!(VMCode[]) temp;
  foreach(op; list){
    temp ~= op.code;
  }
  return temp.data;
}
