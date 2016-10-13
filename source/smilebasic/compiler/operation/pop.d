module tosuke.smilebasic.compiler.operation.pop;

import tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;

import std.conv : to;

//Pop
///どこにPopするか
enum PopType{
  ///どこにもしない(値を捨てる)
  None,
  ///変数
  Variable,
  ///スタック上の配列
  Value
}


///値をPopする
abstract class Pop : Operation{

  ///初期化
  this(PopType _type){
    popType = _type;
    super(OperationType.Pop);
  }

  ///どこにPopするか
  private PopType type_;
  @property{
    ///ditto
    public PopType popType() const {return type_;}
    ///ditto
    private void popType(PopType a){type_ = a;}
  }

  abstract override string toString() const;
  abstract override int codeSize() const;
  abstract override VMCode[] code() const;
}


///どこにもPopしない(値を捨てる)
class PopNone : Pop{

  ///初期化
  this(){
    super(PopType.None);
  }

  override string toString() const{
    return `Pop(none)`;
  }

  override int codeSize() const{
    return 1;
  }

  override VMCode[] code() const{
    return [0x0002];
  }
}


///単純変数にPopする(名前未解決)
class PopScalarVariable : Pop{

  ///初期化
  this(wstring _name){
    super(PopType.Variable);
    name = _name;
  }

  ///Popする変数の名前
  private wstring name_;
  @property{
    ///ditto
    public wstring name() const {return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  override string toString() const{
    return `Pop(var)(`~name.to!string~`)`;
  }

  override int codeSize() const {
    throw unresolutedSymbolError(name);
  }

  override VMCode[] code() const {
    throw unresolutedSymbolError(name);
  }
}


///グローバルな単純変数にPopする
class PopGlobalScalarVariable : Pop{

  ///初期化
  this(uint _id){
    super(PopType.Variable);
    id = _id;
  }

  ///Popする変数のid
  private uint id_;
  @property{
    ///ditto
    public uint id() const {return id_;}
    ///ditto
    private void id(uint a){id_ = a;}
  }

  override string toString() const{
    if(id <= 0xffff){
      return `Pop(gvar16)(`~id.to!string~`)`;
    }else{
      return `Pop(gvar32)(`~id.to!string~`)`;
    }
  }

  override int codeSize() const {
    return id <= 0xffff ? 1 + 1 : 1 + 2;
  }

  override VMCode[] code() const {
    if(id <= 0xffff){
      //Pop(gvar16)
      return [0x0012, id & 0xffff];
    }else{
      //Pop(gvar32)
      return [0x0022, (id >>> 16) & 0xffff, id & 0xffff];
    }
  }
}


///文字列で指定された変数に対してPopする
class PopVariableString : Pop{

  ///初期化
  this(){
    super(PopType.Variable);
  }

  override string toString() const {
    return `Pop(var str)`;
  }

  override int codeSize() const {
    return 1;
  }

  override VMCode[] code() const {
    return [0x0052];
  }
}


///スタック上の配列にインデックスを指定してPopする(その配列は暗黙的にPop noneされる)
class PopIndexValue : Pop{

  ///初期化
  this(ushort _indexNum){
    indexNum = _indexNum;
    super(PopType.Value);
  }

  ///インデックスの数
  private ushort indexNum;

  override string toString() const {
    return `Pop(index value)`;
  }

  override int codeSize() const {
    return 1 + 1;
  }

  override VMCode[] code() const {
    return [0x0062, indexNum];
  }
}