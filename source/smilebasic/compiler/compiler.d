module tosuke.smilebasic.compiler.compiler;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm.slot;
import tosuke.smilebasic.error;
import tosuke.smilebasic.value;

import std.algorithm, std.range, std.array;
import std.conv : to;

///スロットをコンパイルする
auto compile(Slot slot){
  auto compiler = Compiler(slot);
  compiler.compile;
  return compiler.slot;
}


private struct Compiler{
  this(Slot slot_){
    slot = slot_;
  }

  public Slot slot;

  public void compile(){
    auto ast = buildAST(slot.source);
    ast = ast.constantFolding;
    version(none) std.stdio.writeln(ast);

    auto list = genList(ast);
    list = compile(list);
    
    slot.codemap = list.codeMap;
    slot.vmcode = genCode(list);
  }

  private Node buildAST(string[] src){
    
    auto parser = new Parser;

    Appender!(Node[]) list;

    foreach(i, s; src[]){
      Node n;
      try{
        n = parser.parse(s);
        n.line = i.to!int + 1;
      }catch(SyntaxError e){
        e.line = i.to!int + 1;
        throw e;
      }

      list ~= n.children;
    }

    return new DocumentNode(list.data);
  }

  private{
    bool inGlobal = true;
    bool isDefint = false;
    bool isStrict = false;
  }

  private auto compile(OperationList list){

    foreach(ref op; list){
      try{
        if(cast(DefineScalarVariable)op){
          //単純変数を定義
          op = define(op.to!DefineScalarVariable);

        }else if(cast(PushScalarVariable)op){
          //単純変数の名前解決(式として利用時)
          op = resolute(op.to!PushScalarVariable);

        }else if(cast(PopScalarVariable)op){
          //単純変数の名前解決(代入文として利用時)
          op = resolute(op.to!PopScalarVariable);

        }else if(cast(DefineArrayVariable)op){
          //配列変数を定義
          op = define(op.to!DefineArrayVariable);

        }
      }catch(SmileBasicError e){
        e.line = op.line;
        throw e;
      }
      
    }

    return list;
  }

  private Operation define(DefineScalarVariable op){
    if(inGlobal){
      //グローバル変数
      defineScalar(slot.globalVar, op.name);
    }else{
      //TODO:ローカル変数
      assert(0);
    }

    return op;
  }

  private Operation define(DefineArrayVariable op){
    if(inGlobal){
      //グローバル変数
      defineArray(slot.globalVar, op.name);
      
      auto id = slot.globalVar.idof(op.name);
      ValueType type = (n){
        switch(n){
          case '%':  return ValueType.Integer;
          case '#':  return ValueType.Floater;
          case '$':  return ValueType.String;
          default:
            return isDefint ? ValueType.Integer : ValueType.Floater;
        }
      }(op.name[$-1]);

      return new DefineGlobalArrayVariable(id, type, op.indexNum);
    }else{
      //TODO:ローカル変数
      assert(0);
    }
  }

  private Operation resolute(PushScalarVariable op){
    if(inGlobal || op.name in slot.globalVar){
      //グローバル変数
      if(op.name !in slot.globalVar){
        if(!isStrict){
          defineScalar(slot.globalVar, op.name);                    
        }else{
          //TODO:StrictモードとUndefinedVariableErrorの実装
          assert(0);
        }
      }
      auto id = slot.globalVar.idof(op.name);
      return new PushGlobalScalarVariable(id);

    }else{
      //TODO:ローカル変数
      assert(0);
    }
  }

  private Operation resolute(PopScalarVariable op){
    if(inGlobal || op.name in slot.globalVar){
      //グローバル変数
      if(op.name !in slot.globalVar){
        if(!isStrict){
          defineScalar(slot.globalVar, op.name);                    
        }else{
          //TODO:StrictモードとUndefinedVariableErrorの実装
          assert(0);
        }
      }
      auto id = slot.globalVar.idof(op.name);
      return new PopGlobalScalarVariable(id);

    }else{
      //TODO:ローカル変数
      assert(0);
    }
  }

  private auto defineScalar(ref SymbolTable!Value var, wstring name){
  
    auto value = (n){
      switch(n[$-1]){
        case '$': return Value(ValueType.String);
        case '%': return Value(ValueType.Integer);
        case '#': return Value(ValueType.Floater);
        default:
          return Value(isDefint ? ValueType.Integer : ValueType.Floater);
      }
    }(name);

    var.add(name, value);

    return var;
  }

  private auto defineArray(ref SymbolTable!Value var, wstring name){
    var.add(name, Value(ValueType.Array));
    return var;
  }
}
