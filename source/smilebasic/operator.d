module tosuke.smilebasic.operator;

import tosuke.smilebasic.error;
import tosuke.smilebasic.value;
import tosuke.smilebasic.compiler.node;
import std.conv : to;
import std.experimental.logger;

///初期化
static this() {
  initBinaryOpTable();
  initUnaryOpTable();
}

///単項演算子の種類
enum UnaryOp {
  ///単項-演算子
  Neg,
  ///not演算子
  Not,
  ///!演算子
  LogicalNot,
}

///単項演算
Value unaryOp(UnaryOp op, Value a) {
  return unaryOpTable[op](a);
}

///二項演算子の種類
enum BinaryOp {
  /// *演算子
  Mul,
  /// /演算子
  Div,
  /// div演算子
  IntDiv,
  /// mod演算子
  Mod,
  //-------------
  /// +演算子
  Add,
  /// -演算子
  Sub,
  //-------------
  /// <<演算子
  LShift,
  /// >>演算子
  RShift,
  //-------------
  /// ==演算子
  Eq,
  /// !=演算子
  NotEq,
  /// <演算子
  Less,
  /// >演算子
  Greater,
  /// <=演算子
  LessEq,
  /// >=演算子
  GreaterEq,
  //-------------
  /// and演算子
  And,
  /// or演算子
  Or,
  /// xor演算子
  Xor,
  //-------------
  /// &&演算子
  LogicalAnd,
  /// ||演算子
  LogicalOr,
}

///二項演算
Value binaryOp(BinaryOp op, Value a, Value b) {
  return binaryOpTable[op](a, b);
}

//UnaryOpの実装
private alias UnaryOpFunc = Value function(Value);

private UnaryOpFunc[UnaryOp.max + 1] unaryOpTable;

private void initUnaryOpTable() {
  unaryOpTable[UnaryOp.Neg] = &negOp;
  unaryOpTable[UnaryOp.Not] = &notOp;
  unaryOpTable[UnaryOp.LogicalNot] = &logicalNotOp;
}

/// 単項-演算子
Value negOp(Value a) {
  return -a;
}

/// not演算子
Value notOp(Value a) {
  return ~a;
}

/// !演算子
Value logicalNotOp(Value a) {
  if (a.isArithmeticValue) {
    return Value(!a.toBoolean);
  }
  else {
    throw imcompatibleTypeError("!", a);
  }
}

//BinaryOpの実装
private alias BinaryOpFunc = Value function(Value, Value);
private BinaryOpFunc[BinaryOp.max + 1] binaryOpTable;

private void initBinaryOpTable() {
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

/// *演算子
Value mulOp(Value a, Value b) {
  return a * b;
}

/// /演算子
Value divOp(Value a, Value b) {
  return a / b;
}

/// div演算子
Value intDivOp(Value a, Value b) {
  if (a.isArithmeticValue && b.isArithmeticValue) {
    return Value(a.toInteger / b.toInteger);
  }
  else {
    throw imcompatibleTypeError("div", a, b);
  }
}

/// mod演算子
Value modOp(Value a, Value b) {
  return a % b;
}

/// +演算子
Value addOp(Value a, Value b) {
  return a + b;
}

/// -演算子
Value subOp(Value a, Value b) {
  return a - b;
}

/// <<演算子
Value leftShiftOp(Value a, Value b) {
  return a << b;
}

/// >>演算子
Value rightShiftOp(Value a, Value b) {
  return a >> b;
}

/// ==演算子
Value eqOp(Value a, Value b) {
  if (a.type == ValueType.String && b.isArithmeticValue) {
    return Value(3);
  }
  else {
    try {
      return Value(a == b);
    }
    catch (TypeMismatchError e) {
      throw imcompatibleTypeError("==", a, b);
    }
  }
}

/// !=演算子
Value notEqOp(Value a, Value b) {
  if (a.type == ValueType.String && b.isArithmeticValue) {
    return Value(3);
  }
  else {
    try {
      return Value(a != b);
    }
    catch (TypeMismatchError e) {
      throw imcompatibleTypeError("!=", a, b);
    }
  }
}

/// <演算子
Value lessOp(Value a, Value b) {
  if (a.type == ValueType.String && b.isArithmeticValue) {
    return Value(3);
  }
  else {
    try {
      return Value(a < b);
    }
    catch (TypeMismatchError e) {
      throw imcompatibleTypeError("<", a, b);
    }
  }
}

/// >演算子
Value greaterOp(Value a, Value b) {
  if (a.type == ValueType.String && b.isArithmeticValue) {
    return Value(3);
  }
  else {
    try {
      return Value(a > b);
    }
    catch (TypeMismatchError e) {
      throw imcompatibleTypeError(">", a, b);
    }
  }
}

/// <=演算子
Value lessEqOp(Value a, Value b) {
  if (a.type == ValueType.String && b.isArithmeticValue) {
    return Value(3);
  }
  else {
    try {
      return Value(a <= b);
    }
    catch (TypeMismatchError e) {
      throw imcompatibleTypeError("<=", a, b);
    }
  }
}

/// >=演算子
Value greaterEqOp(Value a, Value b) {
  if (a.type == ValueType.String && b.isArithmeticValue) {
    return Value(3);
  }
  else {
    try {
      return Value(a >= b);
    }
    catch (TypeMismatchError e) {
      throw imcompatibleTypeError(">=", a, b);
    }
  }
}

/// and演算子
Value andOp(Value a, Value b) {
  return a & b;
}

/// or演算子
Value orOp(Value a, Value b) {
  return a | b;
}

/// xor演算子
Value xorOp(Value a, Value b) {
  return a ^ b;
}

/// &&演算子
Value logicalAndOp(Value a, Value b) {
  if (!isArrayValue(a) && !isArrayValue(b)) {
    if (a.toBoolean) {
      if (b.toBoolean) {
        return Value(b.toBoolean);
      }
      else {
        return Value(false);
      }
    }
    else {
      return Value(false);
    }
  }
  else {
    throw imcompatibleTypeError("&&", a, b);
  }
}

/// ||演算子
Value logicalOrOp(Value a, Value b) {
  if (!isArrayValue(a) && !isArrayValue(b)) {
    if (a.toBoolean) {
      return Value(a.toBoolean);
    }
    else if (b.toBoolean) {
      return Value(b.toBoolean);
    }
    else {
      return Value(false);
    }
  }
  else {
    throw imcompatibleTypeError("||", a, b);
  }
}
