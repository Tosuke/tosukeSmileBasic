module tosuke.smilebasic.operator;

import tosuke.smilebasic.error;
import tosuke.smilebasic.value;
import tosuke.smilebasic.ast.node : Node, ValueNode;
import std.conv : to;
import std.experimental.logger;

void initialize(){
  initBinaryOpTable();
  initUnaryOpTable();
}

enum UnaryOp{
  Neg,
  Not,
  LogicalNot,
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
Value binaryOp(BinaryOp op, Value a, Value b){
  return binaryOpTable[op](a, b);
}

//UnaryOpの実装
private alias UnaryOpFunc = Value function(Value);

private UnaryOpFunc[UnaryOp.max + 1] unaryOpTable;

private void initUnaryOpTable(){
  unaryOpTable[UnaryOp.Neg] = &negOp;
  unaryOpTable[UnaryOp.Not] = &notOp;
  unaryOpTable[UnaryOp.LogicalNot] = &logicalNotOp;
}

Value negOp(Value a){
  return -a;
}
Value notOp(Value a){
  return ~a;
}
Value logicalNotOp(Value a){
  if(a.isArithmeticValue){
    return Value(!a.toBoolean);
  }else{
    throw imcompatibleTypeError("!", a);
  }
}

//BinaryOpの実装
private alias BinaryOpFunc = Value function(Value, Value);
private BinaryOpFunc[BinaryOp.max + 1] binaryOpTable;

private void initBinaryOpTable(){
  binaryOpTable[BinaryOp.Mul] = &mulOp;
  binaryOpTable[BinaryOp.Div] = &divOp;
  binaryOpTable[BinaryOp.IntDiv] = &intDivOp;
  binaryOpTable[BinaryOp.Mod] = &modOp;

  binaryOpTable[BinaryOp.Add] = &addOp;
  binaryOpTable[BinaryOp.Sub] = &subOp;

  binaryOpTable[BinaryOp.LShift] = &leftShiftOp;
  binaryOpTable[BinaryOp.RShift] = &rightShiftOp;

  binaryOpTable[BinaryOp.Eq] = &eqOp;
  binaryOpTable[BinaryOp.NotEq] = &notEqOp;
  binaryOpTable[BinaryOp.Less] = &lessOp;
  binaryOpTable[BinaryOp.Greater] = &greaterOp;
  binaryOpTable[BinaryOp.LessEq] = &lessEqOp;

  binaryOpTable[BinaryOp.And] = &andOp;
  binaryOpTable[BinaryOp.Or] = &orOp;
  binaryOpTable[BinaryOp.Xor] = &xorOp;

  binaryOpTable[BinaryOp.LogicalAnd] = &logicalAndOp;
  binaryOpTable[BinaryOp.LogicalOr] = &logicalOrOp;
}
Value mulOp(Value a, Value b){
  return a * b;
}
Value divOp(Value a, Value b){
  return a / b;
}
Value intDivOp(Value a, Value b){
  if(a.isArithmeticValue && b.isArithmeticValue){
    return Value(a.toInteger / b.toInteger);
  }else{
    throw imcompatibleTypeError("div", a, b);
  }
}
Value modOp(Value a, Value b){
  return a % b;
}

Value addOp(Value a, Value b){
  return a + b;
}
Value subOp(Value a, Value b){
  return a - b;
}

Value leftShiftOp(Value a, Value b){
  return a << b;
}
Value rightShiftOp(Value a, Value b){
  return a >> b;
}

Value eqOp(Value a, Value b){
  if(a.type == ValueType.String && b.isArithmeticValue){
    return Value(3);
  }else{
    try{
      return Value(a == b);
    }catch(TypeMismatchError e){
      throw imcompatibleTypeError("==", a, b);
    }
  }
}
Value notEqOp(Value a, Value b){
  if(a.type == ValueType.String && b.isArithmeticValue){
    return Value(3);
  }else{
    try{
      return Value(a != b);
    }catch(TypeMismatchError e){
      throw imcompatibleTypeError("!=", a, b);
    }
  }
}
Value lessOp(Value a, Value b){
  if(a.type == ValueType.String && b.isArithmeticValue){
    return Value(3);
  }else{
    try{
      return Value(a < b);
    }catch(TypeMismatchError e){
      throw imcompatibleTypeError("<", a, b);
    }
  }
}
Value greaterOp(Value a, Value b){
  if(a.type == ValueType.String && b.isArithmeticValue){
    return Value(3);
  }else{
    try{
      return Value(a > b);
    }catch(TypeMismatchError e){
      throw imcompatibleTypeError(">", a, b);
    }
  }
}
Value lessEqOp(Value a, Value b){
  if(a.type == ValueType.String && b.isArithmeticValue){
    return Value(3);
  }else{
    try{
      return Value(a <= b);
    }catch(TypeMismatchError e){
      throw imcompatibleTypeError("<=", a, b);
    }
  }
}
Value greaterEqOp(Value a, Value b){
  if(a.type == ValueType.String && b.isArithmeticValue){
    return Value(3);
  }else{
    try{
      return Value(a >= b);
    }catch(TypeMismatchError e){
      throw imcompatibleTypeError(">=", a, b);
    }
  }
}

Value andOp(Value a, Value b){
  return a & b;
}
Value orOp(Value a, Value b){
  return a | b;
}
Value xorOp(Value a, Value b){
  return a ^ b;
}

Value logicalAndOp(Value a, Value b){
  if(!isArrayValue(a) && !isArrayValue(b)){
    if(a.toBoolean){
      if(b.toBoolean){
        return Value(b.toBoolean);
      }else{
        return Value(false);
      }
    }else{
      return Value(false);
    }
  }else{
    throw imcompatibleTypeError("&&", a, b);
  }
}
Value logicalOrOp(Value a, Value b){
  if(!isArrayValue(a) && !isArrayValue(b)){
    if(a.toBoolean){
      return Value(a.toBoolean);
    }else if(b.toBoolean){
      return Value(b.toBoolean);
    }else{
      return Value(false);
    }
  }else{
    throw imcompatibleTypeError("||", a, b);
  }
}
