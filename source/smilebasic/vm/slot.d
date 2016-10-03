module tosuke.smilebasic.vm.slot;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm;
import tosuke.smilebasic.error;

import std.array;
import std.conv;
import std.algorithm, std.string;

///ソースコードからSlotを生成する
Slot slot(string source){
  auto slot = new Slot;
  slot.source =  source
                .split("\n")
                .map!(a => a.strip)
                .filter!(a => a.length)
                .array;
  return slot;
}

///ソースコードとそれから生成されるデータをまとめるクラス
class Slot{
public:
  ///ソースコード
  string[] source;
  ///VM用バイトコード
  VMCode[] vmcode;
  ///VMアドレスとソースコードの対応表
  CodeMap codemap;

  ///ソースコードをコンパイルしてバイトコードなどのデータを生成する
  void compile(){
    
    auto ast = buildAST();
    version(none) ast = ast.constantFolding;

    auto list = genList(ast);
    codemap = list.codeMap;

    vmcode = genCode(list);
  }


  private Node buildAST(){
    
    auto parser = new Parser;

    Appender!(Node[]) list;

    foreach(i, s; source[]){
      Node n;
      try{
        n = parser.parse(s);
        n.line = i.to!int + 1;
      }catch(SyntaxError e){
        e.line = i.to!int + 1;
        throw e;
      }

      list ~= n.children;
    }

    return new DocumentNode(list.data);
  }
}