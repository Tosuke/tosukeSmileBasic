module tosuke.smilebasic.vm.internal.command;

///コマンドの実装
mixin template CommandMixin(){

  ///初期化
  private void initCommandTable(){
    //UnaryOps
    codeTable[0x0000] = &unaryOp!"negOp";
    codeTable[0x1000] = &unaryOp!"notOp";
    codeTable[0x2000] = &unaryOp!"logicalNotOp";

    //BinaryOps
    codeTable[0x0010] = &binaryOp!"mulOp";
    codeTable[0x1010] = &binaryOp!"divOp";
    codeTable[0x2010] = &binaryOp!"intDivOp";
    codeTable[0x3010] = &binaryOp!"modOp";
    codeTable[0x4010] = &binaryOp!"addOp";
    codeTable[0x5010] = &binaryOp!"subOp";
    codeTable[0x6010] = &binaryOp!"leftShiftOp";
    codeTable[0x7010] = &binaryOp!"rightShiftOp";
    codeTable[0x8010] = &binaryOp!"andOp";
    codeTable[0x9010] = &binaryOp!"orOp";
    codeTable[0xA010] = &binaryOp!"xorOp";

    codeTable[0x0020] = &binaryOp!"eqOp";
    codeTable[0x1020] = &binaryOp!"notEqOp";
    codeTable[0x2020] = &binaryOp!"lessOp";
    codeTable[0x3020] = &binaryOp!"greaterOp";
    codeTable[0x4020] = &binaryOp!"lessEqOp";
    codeTable[0x5020] = &binaryOp!"greaterEqOp";

    //IndexOp
    codeTable[0x0030] = &indexOp;

    //CreateArrays
    codeTable[0x0040] = &createArray!int;
    codeTable[0x1040] = &createArray!double;
    codeTable[0x2040] = &createArray!StringValue;

    //Command Statements
    codeTable[0x0080] = &printCommand;

    //goto & gosub
    codeTable[0x0100] = &gotoAddr;
  }


  ///単項演算子
  void unaryOp(string op)(){
    auto a = valueStack.pop;
    valueStack.push(mixin(op~"(a)"));
  }


  ///二項演算子
  void binaryOp(string op)(){
    auto a = valueStack.pop;
    auto b = valueStack.pop;

    valueStack.push(mixin(op~"(a, b)"));
  }


  ///配列アクセス演算子
  void indexOp(){
    auto arr = valueStack.pop();
    
    immutable num = take();
    auto ind = new int[num];
    foreach(ref a; ind){
      a = valueStack.pop().toInteger;
    }
    
    auto v = arr.index(ind);
    valueStack.push(v);
  }


  ///コンソールへ出力
  void printCommand(){
    immutable argNum = take();
    import std.array : Appender;
    import std.conv : to;

    Appender!wstring temp;
    foreach(a; 0..argNum){
      auto v = valueStack.pop();
      temp ~= v.toStringValue;
    }
    import std.stdio : write;
    temp.data.write;
  }


  ///配列のメモリ確保
  void createArray(T)(){
    immutable num = take();
    auto index = new int[num];
    foreach(ref a; index){
      a = valueStack.pop().toInteger;
    }

    ArrayValue arr = new TypedArrayValue!T(index);
    valueStack.push(Value(arr));
  }


  ///アドレス指定goto
  void gotoAddr(){
    auto k = take(2);
    immutable addr = k[0] << 16 | k[1];
    pc = addr;
  }
}