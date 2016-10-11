module tosuke.smilebasic.vm.vm;

import tosuke.smilebasic.vm;
import tosuke.smilebasic.value;
import tosuke.smilebasic.utils;
import tosuke.smilebasic.error;

import std.conv : to;
import std.experimental.logger;


///仮想マシン
class VM{
  private{
    ///スロット
    Slot[] slots;
    Slot currentSlot() @property { return slots[currentSlotNumber]; }

    VMCode[] currentCode() @property { return currentSlot.vmcode;}

    ///プログラムカウンタ
    uint pc;
    uint currentSlotNumber;

    Stack!Value valueStack;

    ///命令表
    void delegate()[0x10000] codeTable;
  }

  
  ///初期化
  this(){
    slots = new Slot[5];
    foreach(ref a; slots) a = new Slot();

    codeTable[] = (){ assert(0, "Invalid Bytecode"); };
    initCommandTable;
    initPushTable;
    initPopTable;
  }


  ///スロットをvmに関連付ける
  void set(int slotNum, Slot slot)
  in{
    assert(0 <= slotNum && slotNum <= 4);
  }body{
    slots[slotNum] = slot;
  }


  ///指定スロットを実行する
  void run(int slotNum)
  in{
    assert(0 <= slotNum && slotNum <= 4);
  }body{
    currentSlotNumber = slotNum;
    pc = 0;

    while(pc < currentCode.length){
      auto pcBak = pc;
      VMCode code = take();
      try{
        codeTable[code]();
      }catch(SmileBasicError e){
        auto codemap = currentSlot.codemap;
        e.line = codemap.search(pcBak);
        throw e;
      }
      
    }
  }

private:
  ///PCを1つ進め、値を得る
  private VMCode take(){
    return currentCode[pc++];
  }


  ///任意の個数PCを進め、値を得る
  private VMCode[] take(uint a){
    pc += a;
    return a == 1 ? [currentCode[pc-a]] : currentCode[pc-a..pc];
  }


  //初期化
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

    codeTable[0x0080] = &printCommand;
  }


  ///初期化
  void initPushTable(){
    codeTable[0x0001] = &pushImm16;
    codeTable[0x0011] = &pushImm32;
    codeTable[0x0021] = &pushImm64f;
    codeTable[0x0031] = &pushString;
    codeTable[0x0041] = &pushGlobalVar16;
    codeTable[0x0051] = &pushGlobalVar32;
  }


  ///初期化
  void initPopTable(){
    codeTable[0x0002] = &popNone;
    codeTable[0x0012] = &popGlobalVar16;
    codeTable[0x0022] = &popGlobalVar32;

    codeTable[0x0052] = &popValue;
  }

  void unaryOp(string op)(){
    auto a = valueStack.pop;
    valueStack.push(mixin(op~"(a)"));
  }

  void binaryOp(string op)(){
    auto a = valueStack.pop;
    auto b = valueStack.pop;

    valueStack.push(mixin(op~"(a, b)"));
  }

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

  void printCommand(){
    immutable argNum = take();
    import std.array : Appender;
    import std.conv : to;

    Appender!wstring temp;
    foreach(a; 0..argNum){
      auto v = valueStack.pop();
      temp ~= (o){
        switch(o){
          case ValueType.Integer: return v.get!int.to!wstring;
          case ValueType.Floater: return v.get!double.to!wstring;
          case ValueType.String: return v.get!wstring;
          default: assert(0);
        }
      }(v.type);
    }
    import std.stdio : write;
    temp.data.write;
  }

  void pushImm16(){
    auto k = cast(short)take();
    valueStack.push(Value(k));
  }

  void pushImm32(){
    auto t = take(2);
    immutable k = t[0] << 16 | t[1];
    valueStack.push(Value(cast(int)k));
  }

  void pushImm64f(){
    auto t = take(4);
    ulong k = t[0].to!ulong << 48 | t[1].to!ulong << 32 | t[2] << 16 | t[3];
    valueStack.push(Value(*(cast(double*)&k)));
  }

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

  void pushGlobalVar16(){
    auto id = take().to!uint;
    valueStack.push(currentSlot.globalVar[id]);
  }

  void pushGlobalVar32(){
    auto t = take(2);
    immutable id = t[0] << 16 | t[1];
    valueStack.push(currentSlot.globalVar[id]);
  }

  void popNone(){
    valueStack.pop();
  }

  void popGlobalVar16(){
    auto id = take().to!uint;
    currentSlot.globalVar[id] = valueStack.pop();
  }

  void popGlobalVar32(){
    auto t = take(2);
    immutable id = t[0] << 16 | t[1];
    currentSlot.globalVar[id] = valueStack.pop();
  }

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

  void createArray(T)(){
    immutable num = take();
    auto index = new int[num];
    foreach(ref a; index){
      a = valueStack.pop().toInteger;
    }

    ArrayValue arr = new TypedArrayValue!T(index);
    valueStack.push(Value(arr));
  }
}
