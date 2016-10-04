module tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import std.conv : to;
import std.container.dlist;

///中間表現コードの列
alias OperationList = DList!Operation;


///中間表現コードの種別
enum OperationType{
  ///値をPushする
  Push, //値とかをPushする
  ///命令を実行する
  Command, 
  
  ///何もしない
  Empty
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
    public OperationType type(){return type_;}
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
  String
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
