module tosuke.smilebasic.compiler.operation.define;

import tosuke.smilebasic.compiler.operation;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;

import std.conv : to;

///定義する
abstract class Define : Operation {

  ///初期化
  this(OperationType t) {
    super(t);
  }

  override abstract string toString() const;

  override abstract int codeSize() const;

  override abstract VMCode[] code() const;
}

///単純変数の定義
class DefineScalarVariable : Define {

  ///初期化
  this(wstring _name) {
    super(OperationType.DefineVariable);
    name = _name;
  }

  ///定義する変数の名前
  private wstring name_;
  @property {
    ///ditto
    public wstring name() const {
      return name_;
    }
    ///ditto
    private void name(wstring a) {
      name_ = a;
    }
  }

  override string toString() const {
    immutable n = name;
    return `Define(var '` ~ n.to!string ~ `')`;
  }

  override int codeSize() const {
    return 0;
  }

  override VMCode[] code() const {
    return [];
  }
}

///配列変数の定義(名前未解決)
class DefineArrayVariable : Define {

  import tosuke.smilebasic.value : ValueType;

  ///初期化
  this(wstring _name, ushort _indexNum) {
    super(OperationType.DefineVariable);
    name = _name;
    indexNum = _indexNum;
  }

  ///名前
  private wstring name_;
  @property {
    ///ditto
    public wstring name() const {
      return name_;
    }
    ///ditto
    private void name(wstring a) {
      name_ = a;
    }
  }

  ///インデックスの数
  public ushort indexNum;

  override string toString() const {
    return `Define(var '` ~ name.to!string ~ `[]')`;
  }

  override int codeSize() const {
    throw unresolutedSymbolError(name);
  }

  override VMCode[] code() const {
    throw unresolutedSymbolError(name);
  }
}

///グローバルな配列変数の定義
class DefineGlobalArrayVariable : Define {
  import tosuke.smilebasic.value : ValueType;

  ///初期化
  this(uint _id, ValueType _type, ushort _indexNum) {
    super(OperationType.DefineVariable);
    id = _id;
    type = _type;
    indexNum = _indexNum;
  }

  ///メンバ変数
  private {
    uint id;
    ValueType type;
    ushort indexNum;
  }

  override string toString() const {
    return `Define(var '` ~ id.to!string ~ `[]')`;
  }

  override int codeSize() const {
    return 1 + 1 + 1 + 2;
  }

  override VMCode[] code() const {
    //CreateArray(type) indexNum
    //Pop gvar32
    immutable ushort op = (t) {
      switch (t) {
      case ValueType.Integer:
        return 0x0040;
      case ValueType.Floater:
        return 0x1040;
      case ValueType.String:
        return 0x2040;
      default:
        assert(0);
      }
    }(type).to!ushort;

    return [op, indexNum, 0x0022, (id >>> 16) & 0xffff, id & 0xffff];
  }
}

///ラベルの定義
class DefineLabel : Define {

  ///初期化
  this(wstring _name) {
    name = _name;
    super(OperationType.DefineLabel);
  }

  ///ラベルの名前
  private wstring name_;
  @property {
    ///ditto
    public wstring name() const {
      return name_;
    }
    ///ditto
    private void name(wstring a) {
      name_ = a;
    }
  }

  override string toString() const {
    return `Define(label ` ~ name.to!string ~ `)`;
  }

  override int codeSize() const {
    return 0;
  }

  override VMCode[] code() const {
    return [];
  }
}
