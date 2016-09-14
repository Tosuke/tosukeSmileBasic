module tosuke.smilebasic.vm;

import tosuke.smilebasic.code.code;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.value;
import tosuke.smilebasic.utils;

import std.conv : to;
import std.experimental.logger;

class VM{
  VMCode[][] code;

  VMCode[] currentCode;

  uint pc;

  Stack!Value valueStack;

  void delegate()[0x1000] codeTable;

  this(){
    code = new VMCode[][](5);
    codeTable[] = (){assert(0, "Invalid Bytecode");};
    initCommandTable();
    initPushTable();
  }

  void set(int slot, VMCode[] _code){
    code[slot] = _code;
  }

  void run(int slot){
    currentCode = code[slot];

    while(pc < currentCode.length){
      VMCode code = take();
      codeTable[code]();
    }
  }

  VMCode take(){
    return currentCode[pc++];
  }

  VMCode[] take(uint a){
    pc += a;
    return a == 1 ? [currentCode[pc-a]] : currentCode[pc-a..pc];
  }

  void initCommandTable(){
    codeTable[0x0080] = &printCommand;
  }
  void initPushTable(){
    codeTable[0x0001] = &pushImm16;
    codeTable[0x0011] = &pushImm32;
    codeTable[0x0021] = &pushImm64f;
    codeTable[0x0031] = &pushString;
  }

  void printCommand(){
    int argNum = take();
    import std.array;
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
    import std.stdio;
    temp.data.write;
  }

  void pushImm16(){
    auto k = cast(short)take();
    valueStack.push(Value(k));
  }
  void pushImm32(){
    auto t = take(2);
    uint k = t[0] << 16 | t[1];
    valueStack.push(Value(cast(int)k));
  }
  void pushImm64f(){
    auto t = take(4);
    ulong k = t[0].to!ulong << 48 | t[1].to!ulong << 32 | t[2] << 16 | t[3];
    valueStack.push(Value(*(cast(double*)&k)));
  }
  void pushString(){
    auto length = take();
    valueStack.push(Value(cast(wstring)take(length)));
  }
}
