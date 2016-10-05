module tosuke.smilebasic.compiler.symboltable;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;

import std.conv : to;

///シンボルを管理する
struct SymbolTable(T){
  private T[uint] data;
  private uint[wstring] table;
  private uint counter = 0; //Addされるたびにインクリメントされる

  ///重複エラーが発生したときにSmileBasicErrorを生成する関数
  private DuplicateSymbolError function() error;

  ///初期化
  this(DuplicateSymbolError function() error_){
    error = error_;
  }

  ///opIndex(key)
  public T opIndex(wstring key)
  in{
    assert(key in this);
  }body{
    return data[table[key]];
  }
  
  ///opIndexAssign(key)
  public void opIndexAssign(T value, wstring key)
  in{
    assert(key in this);
  }body{
    data[table[key]] = value;
  }

  ///remove
  public void remove(wstring key)
  in{
    assert(key in this);
  }body{
    data.remove(table[key]);
    table.remove(key);
  }

  ///add
  public void add(wstring key, T value){
    //名前衝突が発生した
    if(key in this){
      import std.format : format;
      auto e = error();
      e.detail = format("'%s' is already defined", key.to!string);
      throw e;
    }

    auto c = counter++;
    data[c] = value;
    table[key] = c;
  }

  ///Keyからidを得る
  public uint idof(wstring key)
  in{
    assert(key in this);
  }body{
    return table[key];
  }

  ///Keyが存在しているか？
  public bool opBinaryRight(string op : "in")(wstring key){
    return (key in table) != null;
  }

  ///opIndex(id)
  public T opIndex(uint id)
  in{
    assert(id in data);
  }body{
    return data[id];
  }

  ///opIndexAssign(id)
  public void opIndexAssign(T value, uint id)
  in{
    assert(id in data);
  }body{
    data[id] = value;
  }
}

unittest{
  auto table = SymbolTable!string(() => new DuplicateVariableError());
  table.add("hoge"w, "hogehogepiyopiyo");
  assert(table["hoge"w] == "hogehogepiyopiyo");
  auto id = table.idof("hoge"w);
  assert(table[id] == "hogehogepiyopiyo");
}