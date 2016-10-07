module tosuke.smilebasic.compiler.operation.command;

import tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;

import std.conv : to;


//Command
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
    public CommandType commandType() const {return type_;}
    private void commandType(CommandType p){type_ = p;}
  }

  abstract override string toString() const;
  abstract override int codeSize() const;
  abstract override VMCode[] code() const;
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

  override string toString() const{
    return "Command(Print)("~argNum.to!string~")";
  }

  override int codeSize() const{
    return 1+1;
  }

  override VMCode[] code() const{
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

  override string toString() const{
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

  override int codeSize() const{
    return 1;
  }

  override VMCode[] code() const{
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

  override string toString() const{
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

  override int codeSize() const{
    return 1;
  }
  override VMCode[] code() const{
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