module tosuke.smilebasic.vm.internal.pop;

///Popの実装
mixin template PopMixin(){

  ///初期化
  void initPopTable(){
    codeTable[0x0002] = &popNone;
    codeTable[0x0012] = &popGlobalVar16;
    codeTable[0x0022] = &popGlobalVar32;

    codeTable[0x0052] = &popVarString;
    codeTable[0x0062] = &popValue;
  }


  ///Pop対象なし(値を捨てる)
  void popNone(){
    valueStack.pop();
  }


  ///グローバル名前空間の変数(id長16bit)にPop
  void popGlobalVar16(){
    auto id = take().to!uint;
    currentSlot.globalVar[id] = valueStack.pop();
  }


  ///グローバル名前空間の変数(id長32bit)にPop
  void popGlobalVar32(){
    auto t = take(2);
    immutable id = t[0] << 16 | t[1];
    currentSlot.globalVar[id] = valueStack.pop();
  }


  ///文字列で指定された変数にPop
  void popVarString(){
    auto rawName = valueStack.pop().get!wstring;

    immutable r = getSymbol(rawName);

    auto name = r.name;
    auto slot = slots[r.slot];

    auto value = valueStack.pop();

    if(name in slot.globalVar){
      slot.globalVar[name] = value;
    }else{
      throw undefinedVariableError(rawName);
    }
  }


  ///スタック上の配列変数にインデックスを指定してPop
  void popValue(){
    auto arr = valueStack.pop(); //操作対象配列

    immutable num = take();
    auto i = new int[num]; //index
    foreach(ref a; i){
      a = valueStack.pop().toInteger;
    }

    auto expr = valueStack.pop(); //代入する値

    arr.indexAssign(expr, i); //代入
  }
}