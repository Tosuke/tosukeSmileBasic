module tosuke.smilebasic.operator;

import tosuke.smilebasic.value;
import tosuke.smilebasic.node : Node, ValueNode;
import std.conv : to;

enum UnaryOp{
  Neg,
  Not,
  LogicalNot,
}
Value unaryOp(UnaryOp op, Node a){
  return unaryOp(op, (cast(ValueNode)a).value);
}
Value unaryOp(UnaryOp op, Value a){
  return unaryOpTable[op](a);
}

enum BinaryOp{
	Mul,
	Div,
  IntDiv,
  Mod,
//-------------
  Add,
  Sub,
//-------------
  LShift,
  RShift,
//-------------
  Eq,
  NotEq,
  Less, //<
  Greater, //>
  LessEq,
  GreaterEq,
//-------------
  And,
  Or,
  Xor,
//-------------
  LogicalAnd,
  LogicalOr,
}

alias UnaryOpFunc = Value function(Value);

private UnaryOpFunc[UnaryOp.max + 1] unaryOpTable;

void initUnaryOpTable(){
  unaryOpTable[UnaryOp.Neg] = &negOp;
  unaryOpTable[UnaryOp.Not] = &notOp;
  unaryOpTable[UnaryOp.LogicalNot] = &logicalNotOp;
}

Value negOp(Value a){
  switch(a.type){
    case ValueType.Integer: return Value(-(a.data.get!int));
    case ValueType.Floater: return Value(-(a.data.get!double));
    default: assert(0);
  }
}
Value notOp(Value a){
  switch(a.type){
    case ValueType.Integer: return Value(~(a.data.get!int));
    case ValueType.Floater: return Value(~(a.data.get!double.to!int));
    default: assert(0);
  }
}
Value logicalNotOp(Value a){
  switch(a.type){
    case ValueType.Integer: return Value(cast(int)!(a.data.get!int));
    case ValueType.Floater: return Value(cast(int)!(a.data.get!double));
    default: assert(0);
  }
}
