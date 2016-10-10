module tosuke.smilebasic.vm.slot;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm;
import tosuke.smilebasic.error;
import tosuke.smilebasic.value;

import std.array;
import std.conv;
import std.algorithm, std.string;


///ソースコードからSlotを生成する
Slot slot(string source){
  auto slot = new Slot;
  slot.source =  source
                .split("\n")
                .array;
  return slot;
}


///ソースコードとそれから生成されるデータをまとめるクラス
public class Slot{

public:
  ///ソースコード
  string[] source;
  ///VM用バイトコード
  VMCode[] vmcode;
  ///VMアドレスとソースコードの対応表
  CodeMap codemap;


  ///グローバル変数
  SymbolTable!Value globalVar;


  ///初期化
  this(){
    globalVar = SymbolTable!Value(() => new DuplicateVariableError());
  }
}