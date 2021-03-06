module tosuke.smilebasic.vm.vm;

import tosuke.smilebasic.vm;
import tosuke.smilebasic.value;
import tosuke.smilebasic.utils;
import tosuke.smilebasic.error;

import std.conv : to;
import std.experimental.logger;

//実装
import tosuke.smilebasic.vm.internal.command;
import tosuke.smilebasic.vm.internal.push;
import tosuke.smilebasic.vm.internal.pop;

///仮想マシン
class VM {
  private {
    ///スロット
    Slot[] slots;
    Slot currentSlot() @property const {
      return cast(Slot)(slots[currentSlotNumber]);
    }

    VMCode[] currentCode() @property const {
      return currentSlot.vmcode;
    }

    ///プログラムカウンタ
    uint pc;
    uint currentSlotNumber;

    Stack!Value valueStack;

    ///命令表
    void delegate()[0x10000] codeTable;

    //状態
    ///グローバルである(DEF内でない)か？
    bool inGlobal = true;
  }

  ///初期化
  this() {
    slots = new Slot[5];
    foreach (ref a; slots)
      a = new Slot();

    initCodeTable;
  }

  ///スロットをvmに関連付ける
  void set(int slotNum, Slot slot)
  in {
    assert(0 <= slotNum && slotNum <= 4);
  }
  body {
    slots[slotNum] = slot;
  }

  ///指定スロットを実行する
  void run(int slotNum)
  in {
    assert(0 <= slotNum && slotNum <= 4);
  }
  body {
    currentSlotNumber = slotNum;
    pc = 0;

    while (pc < currentCode.length) {
      auto pcBak = pc;
      VMCode code = take();
      try {
        codeTable[code]();
      }
      catch (SmileBasicError e) {
        auto codemap = currentSlot.codemap;
        e.line = codemap.search(pcBak);
        throw e;
      }

    }
  }

private:
  ///PCを1つ進め、値を得る
  private VMCode take() {
    return currentCode[pc++];
  }

  ///任意の個数PCを進め、値を得る
  private VMCode[] take(uint a) {
    pc += a;
    return a == 1 ? [currentCode[pc - a]] : currentCode[pc - a .. pc];
  }

  //初期化
  private void initCodeTable() {
    codeTable[] = () { assert(0, "Invalid Bytecode"); };

    initCommandTable;
    initPushTable;
    initPopTable;
  }

  mixin CommandMixin;

  mixin PushMixin;

  mixin PopMixin;

  ///文字列からシンボルとスロットを得る
  auto getSymbol(in wstring rawName) const {
    import std.string : toLower;
    import std.regex : ctRegex, matchFirst;
    import std.typecons : Tuple;

    wstring name = rawName.toLower;
    int num = currentSlotNumber;

    auto regex = ctRegex!`^((?P<slot>\d+):)(?P<name>.+)`w;
    auto match = rawName.matchFirst(regex);
    if (!match.empty) {
      num = match["slot"].to!int;
      if (0 <= num && num < slots.length) {
        name = match["name"].toLower;
      }
      else {
        num = currentSlotNumber;
      }
    }

    Tuple!(wstring, "name", int, "slot") r;
    r.name = name;
    r.slot = num;

    return r;
  }

  ///任意アドレス・スロットにgotoする
  void gotoBase(uint addr, int slot = -1) {
    pc = addr;
    currentSlotNumber = slot == -1 ? currentSlotNumber : slot;
  }
}
