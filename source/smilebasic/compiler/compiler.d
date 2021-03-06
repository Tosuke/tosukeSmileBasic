module tosuke.smilebasic.compiler.compiler;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm.slot;
import tosuke.smilebasic.error;
import tosuke.smilebasic.value;

import std.algorithm, std.range, std.array;
import std.conv : to;

///スロットをコンパイルする
auto compile(Slot slot) {
  auto compiler = Compiler(slot);
  compiler.compile;
  return compiler.slot;
}

private struct Compiler {
  this(Slot slot_) {
    slot = slot_;
  }

  public Slot slot;

  public void compile() {
    auto ast = buildAST(slot.source);
    ast = ast.constantFolding;
    version (none)
      std.stdio.writeln(ast);

    auto list = genList(ast);
    version (none)
      std.stdio.writeln(list[]);
    list = compile(list);

    slot.codemap = list.codeMap;
    slot.vmcode = genCode(list);
    version (none)
      std.stdio.writeln(slot.vmcode[]);
  }

  private Node buildAST(string[] src) {

    auto parser = new Parser;

    Appender!(Node[]) list;

    foreach (i, s; src[]) {
      Node n;
      try {
        n = parser.parse(s);
        n.line = i.to!int + 1;
      }
      catch (SyntaxError e) {
        e.line = i.to!int + 1;
        throw e;
      }

      list ~= n.children;
    }

    return new DocumentNode(list.data);
  }

  private {
    bool inGlobal = true;
    bool isDefint = false;
    bool isStrict = false;
  }

  private auto compile(OperationList list) {

    //variables definition & resolution
    variableResolute(list);

    //structions resotetion
    structionResolute(list);

    //functions & labels definition
    labelDefinition(list);

    //functions & labels resolution
    labelResolution(list);

    return list;
  }

  mixin VariableDefinition;
  mixin StructionResolution;
  mixin LabelDefinition;
}

///変数の名前定義・解決
mixin template VariableDefinition() {

  ///解決処理
  private void variableResolute(ref OperationList list) {
    foreach (ref op; list) {
      try {
        op = (o) {
          if (cast(DefineScalarVariable) o) {
            //単純変数を定義
            return define(o.to!DefineScalarVariable);
          }
          if (cast(DefineArrayVariable) o) {
            //配列変数を定義
            return define(o.to!DefineArrayVariable);
          }
          if (cast(PushScalarVariable) o) {
            //単純変数の名前解決(式)
            return resolute(o.to!PushScalarVariable);
          }
          if (cast(PopScalarVariable) o) {
            //単純変数の名前解決(代入文)
            return resolute(op.to!PopScalarVariable);
          }
          return o;
        }(op);

      }
      catch (SmileBasicError e) {
        e.line = op.line;
        throw e;
      }
    }
  }

  ///単純変数を定義
  private Operation define(DefineScalarVariable op) {
    if (inGlobal) {
      //グローバル変数
      defineScalar(slot.globalVar, op.name);
    }
    else {
      //TODO:ローカル変数
      assert(0);
    }

    return op;
  }

  ///配列変数を定義
  private Operation define(DefineArrayVariable op) {
    if (inGlobal) {
      //グローバル変数
      defineArray(slot.globalVar, op.name);

      auto id = slot.globalVar.idof(op.name);
      ValueType type = (n) {
        switch (n) {
        case '%':
          return ValueType.Integer;
        case '#':
          return ValueType.Floater;
        case '$':
          return ValueType.String;
        default:
          return isDefint ? ValueType.Integer : ValueType.Floater;
        }
      }(op.name[$ - 1]);

      return new DefineGlobalArrayVariable(id, type, op.indexNum);
    }
    else {
      //TODO:ローカル変数
      assert(0);
    }
  }

  ///単純変数の名前解決(式として利用時)
  private Operation resolute(PushScalarVariable op) {
    if (inGlobal || op.name in slot.globalVar) {
      //グローバル変数
      if (op.name !in slot.globalVar) {
        if (!isStrict) {
          defineScalar(slot.globalVar, op.name);
        }
        else {
          //TODO:StrictモードとUndefinedVariableErrorの実装
          assert(0);
        }
      }
      auto id = slot.globalVar.idof(op.name);
      return new PushGlobalScalarVariable(id);

    }
    else {
      //TODO:ローカル変数
      assert(0);
    }
  }

  ///単純変数の名前解決(代入文として利用時)
  private Operation resolute(PopScalarVariable op) {
    if (inGlobal || op.name in slot.globalVar) {
      //グローバル変数
      if (op.name !in slot.globalVar) {
        if (!isStrict) {
          defineScalar(slot.globalVar, op.name);
        }
        else {
          //TODO:StrictモードとUndefinedVariableErrorの実装
          assert(0);
        }
      }
      auto id = slot.globalVar.idof(op.name);
      return new PopGlobalScalarVariable(id);

    }
    else {
      //TODO:ローカル変数
      assert(0);
    }
  }

  //ユーティリティ
  ///単純変数の定義
  private auto defineScalar(ref SymbolTable!Value var, wstring name) {

    auto value = (n) {
      switch (n[$ - 1]) {
      case '$':
        return Value(ValueType.String);
      case '%':
        return Value(ValueType.Integer);
      case '#':
        return Value(ValueType.Floater);
      default:
        return Value(isDefint ? ValueType.Integer : ValueType.Floater);
      }
    }(name);

    var.add(name, value);

    return var;
  }

  ///配列変数の定義
  private auto defineArray(ref SymbolTable!Value var, wstring name) {
    var.add(name, Value(ValueType.Array));
    return var;
  }
}

///ラベルの名前定義・解決
mixin template LabelDefinition() {

  ///ラベル・関数の名前定義
  private void labelDefinition(ref OperationList list) {
    uint count = 0; //命令のVM上の位置
    foreach (ref op; list) {
      try {
        op = (o) {
          if (cast(DefineLabel) o) {
            //ラベルの定義
            return define(o.to!DefineLabel, count);
          }
          return o;
        }(op);
      }
      catch (SmileBasicError e) {
        e.line = op.line;
        throw e;
      }

      count += op.codeSize();
    }
  }

  ///ラベル・関数の名前解決
  private void labelResolution(ref OperationList list) {
    foreach (ref op; list) {
      try {
        op = (o) {
          if (cast(GotoWithLabelCommand) o) {
            //gotoのラベルを解決
            return resolute(o.to!GotoWithLabelCommand);
          }
          return o;
        }(op);
      }
      catch (SmileBasicError e) {
        e.line = op.line;
        throw e;
      }
    }
  }

  ///ラベルの定義
  private Operation define(DefineLabel op, uint count) {
    if (inGlobal) {
      //グローバル空間のラベル
      Pointer p;
      p.count = count;

      slot.globalLabel.add(op.name, p);
    }
    else {
      //TODO:ローカルラベル
      assert(0);
    }
    return new EmptyOperation();
  }

  ///gotoのラベルを解決
  private Operation resolute(GotoWithLabelCommand op) {
    uint addr;
    if (inGlobal) {
      //グローバル空間
      if (op.name in slot.globalLabel) {
        addr = slot.globalLabel[op.name].count;
      }
      else {
        throw undefinedLabelError(op.name);
      }
    }
    else {
      //ローカル空間
    }

    return new GotoCommand(addr);
  }
}

///構造文の解決
mixin template StructionResolution() {

  ///構造文の解決
  //root
  private void structionResolute(ref OperationList list) {
    uint count = 0;
    foreach (i, ref op; list[]) {
      count += op.codeSize;

      try {
        op = (o) {
          if (cast(IfThenCommand) o) {
            //if文
            return ifResolute(list[i + 1 .. $], count);
          }
          if (cast(ElseCommand) o) {
            //else文の部品
            throw new ElseWithoutIfError;
          }
          if (cast(EndifCommand) o) {
            //endif文
            throw new EndifWithoutIfError;
          }
          return o;
        }(op);
      }
      catch (SmileBasicError e) {
        e.line = op.line;
        throw e;
      }
    }
  }

  ///if文
  private Operation ifResolute(OperationList list, uint count) {
    uint endifAddr;
    Operation operation = null;

    foreach (i, ref op; list[]) {
      count += op.codeSize;

      try {
        op = (o) {
          if (cast(IfThenCommand) o) {
            //if文
            return ifResolute(list[i + 1 .. $], count);
          }
          return o;
        }(op);

        if (cast(ElseCommand) op) {
          //else文
          op = new EmptyOperation;
          operation = new GotoNotIfCommand(count);
        }
        if (cast(EndifCommand) op) {
          //endif文
          op = new EmptyOperation;
          endifAddr = count;

          foreach (ref ope; list[]) {
            ope = (o) {
              if (cast(GotoEndifCommand) o) {
                //endifへ移動
                return new GotoCommand(endifAddr);
              }
              return o;
            }(ope);
          }

          if (operation is null) {
            operation = new GotoNotIfCommand(endifAddr);
          }
          break;
        }
      }
      catch (SmileBasicError e) {
        e.line = op.line;
      }
    }

    if (operation is null) {
      throw new ThenWithoutEndifError;
    }
    else {
      return operation;
    }
  }
}
