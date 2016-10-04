module tosuke.smilebasic.compiler.sourcemap;

import tosuke.smilebasic.compiler;
import std.conv : to;


///VMコードから行番号を求めるための表
public struct CodeMap{
  ///行番号を添字とし、値はvm上のアドレス。行の初めのアドレスが入る
  int[] data;

  ///data[line]<=opecode<data[line+1]となるlineを探す
  public int search(int opecode){
    int s(int[] a, int b){
      if(a.length <= 2){
        return 0;
      }else{
        auto k = a.length / 2;
        if(opecode < a[k]){
          return s(a[0..k + 1], b);
        }else{
          return s(a[k..$], b) + k.to!int;
        }
      }
    }

    return s(data, opecode);
  }
}


///中間表現コードからCodeMapを得る
public CodeMap codeMap(OperationList list){
  import std.array : Appender;
  Appender!(int[]) map;
  int cl = 0; //currentLine
  int cnt = 0;

  map ~= 0;
  foreach(a; list){
    if(a.line > cl){
      cl = a.line;
      map ~= cnt;
    }
    cnt += a.codeSize;
  }
  map ~= cnt;

  CodeMap cm;
  cm.data = map.data;
  return cm;
}


unittest{
  CodeMap m;
  m.data = [0, 1, 10, int.max];
  assert(m.search(1) == 1);
  assert(m.search(4) == 1);
  assert(m.search(11) == 2);
}
