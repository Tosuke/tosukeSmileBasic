module tosuke.smilebasic.operator;

import tosuke.smilebasic.value;
import tosuke.smilebasic.node : Node, ValueNode;
import std.conv : to;
import std.experimental.logger;

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
Value binaryOp(BinaryOp op, Node a, Node b){
  return binaryOp(op, (cast(ValueNode)a).value, (cast(ValueNode)b).value);
}
Value binaryOp(BinaryOp op, Value a, Value b){
  return binaryOpTable[op](a, b);
}

//UnaryOpの実装
private alias UnaryOpFunc = Value function(Value);

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
  return Value(~(a.toInteger));
}
Value logicalNotOp(Value a){
  return Value(cast(int)(a.toInteger != 0));
}

//BinaryOpの実装
private alias BinaryOpFunc = Value function(Value, Value);
private BinaryOpFunc[BinaryOp.max + 1] binaryOpTable;

void initBinaryOpTable(){
  binaryOpTable[BinaryOp.Mul] = &mulOp;
  binaryOpTable[BinaryOp.Div] = &divOp;
  binaryOpTable[BinaryOp.IntDiv] = &intDivOp;
  binaryOpTable[BinaryOp.Mod] = &modOp;

  binaryOpTable[BinaryOp.Add] = &addOp;
  binaryOpTable[BinaryOp.Sub] = &subOp;
}
Value mulOp(Value a, Value b){
  if(isArithmericValue(a) && isArithmericValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int * b.get!int);
    }else{
      return Value(a.toFloater * b.toFloater);
    }
  }else{
    assert(0, "Type Mismatch");
  }
}
Value divOp(Value a, Value b){
  if(isArithmericValue(a) && isArithmericValue(b)){
    return Value(a.toFloater / b.toFloater);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value intDivOp(Value a, Value b){
  if(isArithmericValue(a) && isArithmericValue(b)){
    return Value(a.toInteger / b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value modOp(Value a, Value b){
  if(isArithmericValue(a) && isArithmericValue(b)){
    return Value(a.toInteger % b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}

Value addOp(Value a, Value b){
  if(isArithmericValue(a) && isArithmericValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int + b.get!int);
    }else{
      return Value(a.toFloater + b.toFloater);
    }
  }else{
    assert(0, "Type Mismatch");
  }
}
Value subOp(Value a, Value b){
  if(isArithmericValue(a) && isArithmericValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int - b.get!int);
    }else{
      return Value(a.toFloater - b.toFloater);
    }
  }else{
    assert(0, "Type Mismatch");
  }
}
