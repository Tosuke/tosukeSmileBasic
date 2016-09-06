module tosuke.smilebasic.operator;

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
  switch(a.type){
    case ValueType.Integer: return Value(-(a.data.get!int));
    case ValueType.Floater: return Value(-(a.data.get!double));
    default: assert(0, "Type Mismatch");
  }
}
Value notOp(Value a){
  return Value(~(a.toInteger));
}
Value logicalNotOp(Value a){
  if(isArithmeticValue(a)){
    return Value(!a.toBoolean);
  }else{
    assert(0, "Type Mismatch");
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
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int * b.get!int);
    }else{
      return Value(a.toFloater * b.toFloater);
    }
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    import std.array;
    return Value(a.get!wstring.replicate(b.toInteger));
  }else{
    assert(0, "Type Mismatch");
  }
}
Value divOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toFloater / b.toFloater);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value intDivOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger / b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value modOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger % b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}

Value addOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int + b.get!int);
    }else{
      return Value(a.toFloater + b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring ~ b.get!wstring);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value subOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int - b.get!int);
    }else{
      return Value(a.toFloater - b.toFloater);
    }
  }else{
    assert(0, "Type Mismatch");
  }
}

Value leftShiftOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger << b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value rightShiftOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger >> b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}

Value eqOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int == b.get!int);
    }else{
      return Value(a.toFloater == b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring == b.get!wstring);
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    return Value(3);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value notEqOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int != b.get!int);
    }else{
      return Value(a.toFloater != b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring != b.get!wstring);
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    return Value(3);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value lessOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int < b.get!int);
    }else{
      return Value(a.toFloater < b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring < b.get!wstring);
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    return Value(3);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value greaterOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int > b.get!int);
    }else{
      return Value(a.toFloater > b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring > b.get!wstring);
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    return Value(3);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value lessEqOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int <= b.get!int);
    }else{
      return Value(a.toFloater <= b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring <= b.get!wstring);
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    return Value(3);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value greaterEqOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    if(a.type == ValueType.Integer && b.type == ValueType.Integer){
      return Value(a.get!int >= b.get!int);
    }else{
      return Value(a.toFloater >= b.toFloater);
    }
  }else if(a.type == ValueType.String && b.type == ValueType.String){
    return Value(a.get!wstring >= b.get!wstring);
  }else if(a.type == ValueType.String && isArithmeticValue(b)){
    return Value(3);
  }else{
    assert(0, "Type Mismatch");
  }
}

Value andOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger & b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value orOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger | b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
}
Value xorOp(Value a, Value b){
  if(isArithmeticValue(a) && isArithmeticValue(b)){
    return Value(a.toInteger ^ b.toInteger);
  }else{
    assert(0, "Type Mismatch");
  }
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
    assert(0, "Type Mismatch");
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
    assert(0, "Type Mismatch");
  }
}
