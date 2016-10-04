module tosuke.smilebasic.compiler.sourcemap;

import tosuke.smilebasic.compiler;
import std.conv : to;


///VMコードから行番号を求めるための表
public struct CodeMap{
  ///idを添字とし、値はvm上のアドレス。行の初めのアドレスが入る
  private int[] map;
  ///idを添字とし、値には行番号が入る
  private int[] list;

  ///初期化
  this(int[] _map, int[] _list){
    map = _map; list = _list;
  }

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

    return list[s(map, opecode)];
  }
}


///中間表現コードからCodeMapを得る
public CodeMap codeMap(OperationList olist){
  import std.array : Appender;
  Appender!(int[]) map, list;
  int cl = 0; //currentLine
  int cnt = 0;

  map ~= 0;
  list ~= 0;

  foreach(a; olist){
    if(a.line > cl){
      cl = a.line;
      map ~= cnt;
      list ~= cl;
    }
    cnt += a.codeSize;
  }
  map ~= cnt;
  list ~= cl;
 
  return CodeMap(map.data, list.data);
}

