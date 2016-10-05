module tosuke.smilebasic.compiler.operation;

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
    public OperationType type(){return type_;}
    ///ditto
    private void type(OperationType o){type_ = o;}
  }

  ///行番号
  public int line;

  ///文字列化
  abstract override string toString();
  
  ///VMコード化したときの長さ
  abstract int codeSize();

  ///VMコード
  abstract VMCode[] code();
}


///何もしない
class EmptyOperation : Operation{
  ///初期化
  this(){
    super(OperationType.Empty);
  }

  override string toString(){return "";}
  override int codeSize(){return 0;}
  override VMCode[] code(){return [];}
}

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
    public PushType pushType(){return type_;}
    private void pushType(PushType p){type_ = p;}
  }

  abstract override string toString();
  abstract override int codeSize();
  abstract override VMCode[] code();
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

  override string toString(){
    return "Push(imm16)("~imm.to!string~")";
  }

  override int codeSize(){
    return 1+1;
  }

  override VMCode[] code(){
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

  override string toString(){
    return "Push(Imm32)("~imm.to!string~")";
  }

  override int codeSize(){
    return 1+2;
  }

  override VMCode[] code(){
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

  override string toString(){
    return "Push(Imm64f)("~imm.to!string~")";
  }

  override int codeSize(){
    return 1+4;
  }

  override VMCode[] code(){
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

  override string toString(){
    return `Push(String)("`~imm.to!string~`")`;
  }

  override int codeSize(){
    return 1 + imm.length.to!int + 1;
  }

  override VMCode[] code(){
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
    public wstring name(){return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  override string toString(){
    return `Push(var)("`~name.to!string~`")`;
  }

  override int codeSize(){
    throw new InternalError("symbol '"~name.to!string~"' is not resoluted");
  }

  override VMCode[] code(){
    throw new InternalError("symbol '"~name.to!string~"' is not resoluted");
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
    public uint id(){return id_;}
    ///ditto
    private void id(uint a){id_ = a;}
  }

  override string toString(){
    if(id <= 0xffff){
      return `Push(gvar16)(`~id.to!string~`)`;
    }else{
      return `Push(gvar32)(`~id.to!string~`)`;
    }                 
  }

  override int codeSize(){
    if(id <= 0xffff){
      return 1 + 1; //gvar16
    }else{
      return 1 + 2; //gvar32
    }
  }

  override VMCode[] code(){
    if(id <= 0xffff){
      return [0x0041, id & 0xffff];
    }else{
      return [0x0051, (id >>> 16) & 0xffff, id & 0xffff];
    }
  }
}



///どこにPopするか
enum PopType{
  ///どこにもしない(値を捨てる)
  None,
  ///変数
  Variable
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
    public PopType popType(){return type_;}
    ///ditto
    private void popType(PopType a){type_ = a;}
  }

  abstract override string toString();
  abstract override int codeSize();
  abstract override VMCode[] code();
}


///どこにもPopしない(値を捨てる)
class PopNone : Pop{

  ///初期化
  this(){
    super(PopType.None);
  }

  override string toString(){
    return `Pop(none)`;
  }

  override int codeSize(){
    return 1;
  }

  override VMCode[] code(){
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
    public wstring name(){return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  override string toString(){
    return `Pop(var)(`~name.to!string~`)`;
  }

  override int codeSize(){
    throw new InternalError("symbol '"~name.to!string~"' is not resoluted");
  }

  override VMCode[] code(){
    throw new InternalError("symbol '"~name.to!string~"' is not resoluted");
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
    public uint id(){return id_;}
    ///ditto
    private void id(uint a){id_ = a;}
  }

  override string toString(){
    if(id <= 0xffff){
      return `Pop(gvar16)(`~id.to!string~`)`;
    }else{
      return `Pop(gvar32)(`~id.to!string~`)`;
    }
  }

  override int codeSize(){
    return id <= 0xffff ? 1 + 1 : 1 + 2;
  }

  override VMCode[] code(){
    if(id <= 0xffff){
      //Pop(gvar16)
      return [0x0012, id & 0xffff];
    }else{
      //Pop(gvar32)
      return [0x0022, (id >>> 16) & 0xffff, id & 0xffff];
    }
  }
}


///Commandの種別
enum CommandType{
  ///Print文
  Print,
  ///単項演算子
  UnaryOp,
  ///二項演算子
  BinaryOp
}


///命令を実行する
abstract class Command : Operation{

  ///初期化
  this(CommandType _type){
    commandType = _type;
    super(OperationType.Command);
  }

  ///Commandの種別
  private CommandType type_;
  @property{
    ///ditto
    public CommandType commandType(){return type_;}
    private void commandType(CommandType p){type_ = p;}
  }

  abstract override string toString();
  abstract override int codeSize();
  abstract override VMCode[] code();
}


///Print文
class PrintCommand : Command{

  ///初期化
  this(ushort _argNum){
    super(CommandType.Print);
    argNum = _argNum;
  }

  ///引数の数
  private ushort argNum;

  override string toString(){
    return "Command(Print)("~argNum.to!string~")";
  }

  override int codeSize(){
    return 1+1;
  }

  override VMCode[] code(){
    return [0x0080, argNum];
  }
}


import tosuke.smilebasic.operator;
///単項演算子
class UnaryOpCommand : Command{

  ///初期化
  this(UnaryOp _op){
    super(CommandType.UnaryOp);
    op = _op;
  }

  ///演算子の種別
  private UnaryOp op;

  override string toString(){
    string temp = (a){
      switch(a){
        case UnaryOp.Neg:         return "-";
        case UnaryOp.Not:         return "not";
        case UnaryOp.LogicalNot:  return "!";
        default: assert(0);
      }
    }(op);
    return "Command(UnaryOp("~temp~"))";
  }

  override int codeSize(){
    return 1;
  }

  override VMCode[] code(){
    auto code = (a){
      switch(a){
        case UnaryOp.Neg:         return 0x0000;
        case UnaryOp.Not:         return 0x1000;
        case UnaryOp.LogicalNot:  return 0x2000;
        default: assert(0);
      }
    }(op).to!VMCode;
    return [code];
  }
}


///二項演算子
class BinaryOpCommand : Command{

  ///初期化
  this(BinaryOp _op){
    super(CommandType.BinaryOp);
    op = _op;
  }

  ///演算子の種別
  private BinaryOp op;

  override string toString(){
    string temp = (a){
      switch(a){
        case BinaryOp.Mul:        return "*";
        case BinaryOp.Div:        return "/";
        case BinaryOp.IntDiv:     return "div";
        case BinaryOp.Mod:        return "mod";
        //-----------------------------------
        case BinaryOp.Add:        return "+";
        case BinaryOp.Sub:        return "-";
        //-----------------------------------
        case BinaryOp.LShift:     return "<<";
        case BinaryOp.RShift:     return ">>";
        //-----------------------------------
        case BinaryOp.Eq:         return "==";
        case BinaryOp.NotEq:      return "!=";
        case BinaryOp.Less:       return "<";
        case BinaryOp.Greater:    return ">";
        case BinaryOp.LessEq:     return "<=";
        case BinaryOp.GreaterEq:  return ">=";
        //-----------------------------------
        case BinaryOp.And:        return "and";
        case BinaryOp.Or:         return "or";
        case BinaryOp.Xor:        return "xor";
        //-----------------------------------
        case BinaryOp.LogicalAnd: return "&&";
        case BinaryOp.LogicalOr:  return "||";

        default: assert(0);
      }
    }(op);

    return "Command(BinaryOp("~temp~"))";
  }

  override int codeSize(){
    return 1;
  }
  override VMCode[] code(){
    VMCode code = (a){
      switch(a){
        case BinaryOp.Mul:        return 0x0010;
        case BinaryOp.Div:        return 0x1010;
        case BinaryOp.IntDiv:     return 0x2010;
        case BinaryOp.Mod:        return 0x3010;
        //--------------------------------------
        case BinaryOp.Add:        return 0x4010;
        case BinaryOp.Sub:        return 0x5010;
        //--------------------------------------
        case BinaryOp.LShift:     return 0x6010;
        case BinaryOp.RShift:     return 0x7010;
        //--------------------------------------
        case BinaryOp.And:        return 0x8010;
        case BinaryOp.Or:         return 0x9010;
        case BinaryOp.Xor:        return 0xA010;
        //--------------------------------------
        case BinaryOp.Eq:         return 0x0020;
        case BinaryOp.NotEq:      return 0x1020;
        case BinaryOp.Less:       return 0x2020;
        case BinaryOp.Greater:    return 0x3020;
        case BinaryOp.LessEq:     return 0x4020;
        case BinaryOp.GreaterEq:  return 0x5020;
        //--------------------------------------
        default: assert(0);
      }
    }(op).to!VMCode;
    return [code];
  }
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
    public wstring name(){return name_;}
    ///ditto
    private void name(wstring a){name_ = a;}
  }

  override string toString(){
    return `Define(var '`~name.to!string~`')`;
  }

  override int codeSize(){return 0;}
  override VMCode[] code(){return [];}
}