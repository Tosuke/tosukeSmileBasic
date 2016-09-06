module tosuke.smilebasic.code.operation;

import std.conv : to;
import std.container.dlist;

alias OperationList = DList!Operation;

enum OperationType{
  Push, //値とかをPushする
  Command, //値をPopして何かしてPushする(即値読んでなんかする可能性もあり)
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

  abstract string toString();
}

//Push
enum PushType{ //何をPushするか
  Imm16
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

  abstract string toString();
}

class PushImm16 : Push{
  this(ushort _imm){
    super(PushType.Imm16);
    imm = _imm;
  }

  ushort imm;

  override string toString(){
    return "Push(imm16)("~imm.to!string~")";
  }
}

//Command
enum CommandType{
  Print
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

  abstract string toString();
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
}
