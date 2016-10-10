module tosuke.smilebasic.compiler.operation.operation;

import tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;

import std.conv : to;

import std.container.dlist;

///中間表現コードの列
alias OperationList = DList!Operation;


///中間表現コードの種別
enum OperationType{
  ///値をPushする
  Push,
  ///値をPopする
  Pop,
  ///命令を実行する
  Command, 
  
  ///何もしない
  Empty,

  ///変数定義
  DefineVariable
}


///中間表現コード
abstract class Operation{

  ///初期化
  this(OperationType _type){
    type = _type;
  }

  ///中間表現コードの種別
  private OperationType type_;
  @property{
    ///ditto
    public OperationType type() const {return type_;}
    ///ditto
    private void type(OperationType o){type_ = o;}
  }

  ///行番号
  public int line;

  ///文字列化
  abstract override string toString() const;
  
  ///VMコード化したときの長さ
  abstract int codeSize() const;

  ///VMコード
  abstract VMCode[] code() const;
}


///何もしない
class EmptyOperation : Operation{
  ///初期化
  this(){
    super(OperationType.Empty);
  }

  override string toString() const {return "";}
  override int codeSize() const {return 0;}
  override VMCode[] code() const {return [];}
}


///単純変数の定義
class DefineScalarVariable : Operation{
  
  ///初期化
  this(wstring _name){
    super(OperationType.DefineVariable);
    name = _name;
  }

  ///定義する変数の名前
  private wstring name_;
  @property{
    ///ditto
    public wstring name() const {return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  override string toString() const{
    immutable n = name;
    return `Define(var '`~n.to!string~`')`;
  }

  override int codeSize() const {return 0;}
  override VMCode[] code() const {return [];}
}


///配列変数の定義(名前未解決)
class DefineArrayVariable : Operation{

  import tosuke.smilebasic.value : ValueType;

  ///初期化
  this(wstring _name, ushort _indexNum){
    super(OperationType.DefineVariable);
    name = _name;
    indexNum = _indexNum;
  }

  ///名前
  private wstring name_;
  @property{
    ///ditto
    public wstring name() const {return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  ///インデックスの数
  public ushort indexNum;

  override string toString() const {
    return `Define(var '`~name.to!string~`[]')`;
  }

  override int codeSize() const {
    throw unresolutedSymbolError(name);
  }

  override VMCode[] code() const {
    throw unresolutedSymbolError(name);
  }
}


///グローバルな配列変数の定義
class DefineGlobalArrayVariable : Operation{
  import tosuke.smilebasic.value : ValueType;

  ///初期化
  this(uint _id, ValueType _type, ushort _indexNum){
    super(OperationType.DefineVariable);
    id = _id;
    type = _type;
    indexNum = _indexNum;
  }

  ///メンバ変数
  private{
    uint id;
    ValueType type;
    ushort indexNum;
  }

  override string toString() const {
    return `Define(var '`~id.to!string~`[]')`;
  }

  override int codeSize() const {
    return 1 + 1 + 1 + 2;
  }

  override VMCode[] code() const {
    //CreateArray(type) indexNum
    //Pop gvar32
    immutable ushort op = (t){
      switch(t){
        case ValueType.Integer: return 0x0040;
        case ValueType.Floater: return 0x1040;
        case ValueType.String:  return 0x2040;
        default: assert(0);
      }
    }(type).to!ushort;
    
    return [op, indexNum, 0x0022, (id >>> 16) & 0xffff, id & 0xffff];
  }
}