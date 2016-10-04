module tosuke.smilebasic.compiler.gencode;

import tosuke.smilebasic.compiler;

///中間表現コードからVM用バイトコードを生成する
VMCode[] genCode(OperationList list){
  import std.array : Appender;
  Appender!(VMCode[]) temp;
  foreach(op; list){
    temp ~= op.code;
  }
  return temp.data;
}
