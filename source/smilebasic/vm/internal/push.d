module tosuke.smilebasic.vm.internal.push;

///Pushの実装
mixin template PushMixin(){

  ///初期化
  void initPushTable(){
    codeTable[0x0001] = &pushImm16;
    codeTable[0x0011] = &pushImm32;
    codeTable[0x0021] = &pushImm64f;
    codeTable[0x0031] = &pushString;
    codeTable[0x0041] = &pushGlobalVar16;
    codeTable[0x0051] = &pushGlobalVar32;

    codeTable[0x0081] = &pushVarString;
  }


  ///16bit整数をPush
  void pushImm16(){
    auto k = cast(short)take();
    valueStack.push(Value(k));
  }


  ///32bit整数をPush
  void pushImm32(){
    auto t = take(2);
    immutable k = t[0] << 16 | t[1];
    valueStack.push(Value(cast(int)k));
  }


  ///64bit浮動小数をPush
  void pushImm64f(){
    auto t = take(4);
    ulong k = t[0].to!ulong << 48 | t[1].to!ulong << 32 | t[2] << 16 | t[3];
    valueStack.push(Value(*(cast(double*)&k)));
  }


  ///文字列をPush
  void pushString(){
    import std.array : Appender;
    Appender!(wchar[]) str;
    while(true){
      auto a = cast(wchar)take();
      if(a == 0) break;
      str ~= a;
    }
    valueStack.push(Value(cast(wstring)(str.data)));
  }


  ///グローバル名前空間の変数(id長16bit)をPush
  void pushGlobalVar16(){
    auto id = take().to!uint;

    auto v = currentSlot.globalVar[id];
    if(v.isUndefined){
      throw new UseUndefinedVariableError();
    }

    valueStack.push(currentSlot.globalVar[id]);
  }


  ///グローバル名前空間の変数(id長32bit)をPush
  void pushGlobalVar32(){
    auto t = take(2);
    immutable id = t[0] << 16 | t[1];

    auto v = currentSlot.globalVar[id];
    if(v.isUndefined){
      throw new UseUndefinedVariableError();
    }

    valueStack.push(v);
  }


  ///文字列で指定された変数をPush
  void pushVarString(){
    wstring rawName = valueStack.pop().get!wstring;

    immutable r = getSymbol(rawName);

    auto name = r.name;
    auto num = r.slot;

    auto s = slots[num];

    if(name in s.globalVar){
      valueStack.push(s.globalVar[name]);
    }else{
      throw undefinedVariableError(rawName);
    }
  }
}