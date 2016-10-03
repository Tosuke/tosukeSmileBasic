module tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import std.conv : to;
import std.container.dlist;

alias OperationList = DList!Operation;

enum OperationType{
  Push, //値とかをPushする
  Command, //値をPopして何かしてPushする(即値読んでなんかする可能性もあり)

  //埋めこみ情報系
  Empty,
  Line
}
abstract class Operation{
  this(OperationType _type){
    type = _type;
  }

  private OperationType type_;
  @property{
    public OperationType type(){return type_;}
    private void type(OperationType o){type_ = o;}
  }
  public int line; //行番号

  abstract override string toString();
  abstract int codeSize();
  abstract VMCode[] code();
}

class EmptyOperation : Operation{
  this(){
    super(OperationType.Empty);
  }

  override string toString(){return "";}
  override int codeSize(){return 0;}
  override VMCode[] code(){return [];}
}

class LineOperation : Operation{
  this(int _line){
    super(OperationType.Line);

    line = _line;
  }

  private int line_;
  @property{
    public int line(){return line_;}
    private void line(int a){line_ = a;}
  }

  override string toString(){return "Line("~line.to!string~")";}
  override int codeSize(){return 0;}
  override VMCode[] code(){return [];}
}

//Push
enum PushType{ //何をPushするか
  Imm16,
  Imm32,
  Imm64f, //64bit浮動小数
  String
}
abstract class Push : Operation{
  this(PushType _type){
    pushType = _type;
    super(OperationType.Push);
  }

  private PushType type_;
  @property{
    public PushType pushType(){return type_;}
    private void pushType(PushType p){type_ = p;}
  }

  abstract override string toString();
  abstract override int codeSize();
  abstract override VMCode[] code();
}

class PushImm16 : Push{
  this(short _imm){
    super(PushType.Imm16);
    imm = _imm;
  }

  short imm;

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

class PushImm32 : Push{
  this(int _imm){
    super(PushType.Imm32);
    imm = _imm;
  }

  int imm;

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

class PushImm64f : Push{
  this(double _imm){
    super(PushType.Imm64f);
    imm = _imm;
  }

  double imm;

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

class PushString : Push{
  this(wstring _imm){
    super(PushType.String);
    imm = _imm;
  }

  wstring imm;

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

//Command
enum CommandType{
  Print,
  UnaryOp,
  BinaryOp
}
abstract class Command : Operation{
  this(CommandType _type){
    commandType = _type;
    super(OperationType.Command);
  }

  private CommandType type_;
  @property{
    public CommandType commandType(){return type_;}
    private void commandType(CommandType p){type_ = p;}
  }

  abstract override string toString();
  abstract override int codeSize();
  abstract override VMCode[] code();
}

class PrintCommand : Command{
  this(ushort _argNum){
    super(CommandType.Print);
    argNum = _argNum;
  }

  ushort argNum;

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
class UnaryOpCommand : Command{
  this(UnaryOp _op){
    super(CommandType.UnaryOp);
    op = _op;
  }

  UnaryOp op;

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

class BinaryOpCommand : Command{
  this(BinaryOp _op){
    super(CommandType.BinaryOp);
    op = _op;
  }

  BinaryOp op;

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
