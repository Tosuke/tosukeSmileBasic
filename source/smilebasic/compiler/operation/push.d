module tosuke.smilebasic.compiler.operation.push;

import tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;

import std.conv : to;


//Push
///何をPushするか
enum PushType{
  ///16bit整数
  Imm16,
  ///32bit整数
  Imm32,
  ///64bit浮動小数
  Imm64f,
  ///文字列
  String,

  ///変数
  Variable
}


///スタックに対してPushする
abstract class Push : Operation{

  ///初期化
  this(PushType _type){
    pushType = _type;
    super(OperationType.Push);
  }

  ///何をPushするか
  private PushType type_;
  @property{
    ///ditto
    public PushType pushType() const {return type_;}
    private void pushType(PushType p){type_ = p;}
  }

  abstract override string toString() const;
  abstract override int codeSize() const;
  abstract override VMCode[] code() const;
}


///16bit整数をPushする
class PushImm16 : Push{

  ///初期化
  this(short _imm){
    super(PushType.Imm16);
    imm = _imm;
  }

  ///Pushする値
  public short imm;

  override string toString() const {
    return "Push(imm16)("~imm.to!string~")";
  }

  override int codeSize() const {
    return 1+1;
  }

  override VMCode[] code() const {
    return [0x0001, cast(ushort)imm];
  }
}


///32bit整数をPushする
class PushImm32 : Push{

  ///初期化
  this(int _imm){
    super(PushType.Imm32);
    imm = _imm;
  }

  ///Pushする値
  public int imm;

  override string toString() const {
    return "Push(Imm32)("~imm.to!string~")";
  }

  override int codeSize() const {
    return 1+2;
  }

  override VMCode[] code() const {
    uint k = cast(uint)imm;
    return [0x0011, (k >>> 16) & 0xffff, k & 0xffff];
  }
}


///64bit浮動小数をPushする
class PushImm64f : Push{

  ///初期化
  this(double _imm){
    super(PushType.Imm64f);
    imm = _imm;
  }

  ///Pushする値
  public double imm;

  override string toString() const{
    return "Push(Imm64f)("~imm.to!string~")";
  }

  override int codeSize() const {
    return 1 + 4;
  }

  override VMCode[] code() const {
    ulong k = *(cast(ulong*)&imm);
    return [0x0021, (k >>> 48) & 0xffff, (k >>> 32) & 0xffff, (k >>> 16) & 0xffff, k & 0xffff];
  }
}


///文字列をPushする
class PushString : Push{

  ///初期化
  this(wstring _imm){
    super(PushType.String);
    imm = _imm;
  }

  ///Pushする値
  public wstring imm;

  override string toString() const{
    return `Push(String)("`~imm.to!string~`")`;
  }

  override int codeSize() const {
    return 1 + imm.length.to!int + 1;
  }

  override VMCode[] code() const {
    return [cast(VMCode)0x0031] ~ (cast(VMCode[])imm) ~ [cast(VMCode)0];
  }
}


///単純変数をPushする(名前未解決)
class PushScalarVariable : Push{

  ///初期化
  this(wstring _name){
    super(PushType.Variable);
    name = _name;
  }

  ///Pushする変数の名前
  private wstring name_;
  @property{
    ///ditto
    public wstring name() const {return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  override string toString() const{
    return `Push(var)("`~name.to!string~`")`;
  }

  override int codeSize() const {
    throw unresolutedSymbolError(name);
  }

  override VMCode[] code() const {
    throw unresolutedSymbolError(name);
  }
}


///グローバルな単純変数をPushする
class PushGlobalScalarVariable : Push{

  ///初期化
  this(uint _id){
    super(PushType.Variable);
    id = _id;
  }

  ///Pushする変数のid
  private uint id_;
  @property{
    ///ditto
    public uint id() const {return id_;}
    ///ditto
    private void id(uint a){id_ = a;}
  }

  override string toString() const{
    if(id <= 0xffff){
      return `Push(gvar16)(`~id.to!string~`)`;
    }else{
      return `Push(gvar32)(`~id.to!string~`)`;
    }                 
  }

  override int codeSize() const {
    if(id <= 0xffff){
      return 1 + 1; //gvar16
    }else{
      return 1 + 2; //gvar32
    }
  }

  override VMCode[] code() const{
    if(id <= 0xffff){
      return [0x0041, id & 0xffff];
    }else{
      return [0x0051, (id >>> 16) & 0xffff, id & 0xffff];
    }
  }
}