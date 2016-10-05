module tosuke.smilebasic.compiler.node.expression;

import tosuke.smilebasic.compiler.node;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.value;

import std.algorithm, std.array;
import std.conv : to;


//式の構成要素
///二項演算子
class BinaryOpNode : Node{

	///初期化
	this(BinaryOp _op, Node a, Node b){
    type = NodeType.BinaryOp;
		op = _op;
		super((o){
			switch(o){
        case BinaryOp.Mul:        return "*";
				case BinaryOp.Div:        return "/";
        case BinaryOp.IntDiv:     return "div";
        case BinaryOp.Mod:        return "mod";
        //-------------------------------------
				case BinaryOp.Add:        return "+";
				case BinaryOp.Sub:        return "-";
        //-------------------------------------
        case BinaryOp.LShift:     return "<<";
        case BinaryOp.RShift:     return ">>";
        //-------------------------------------
        case BinaryOp.Eq:         return "==";
        case BinaryOp.NotEq:      return "!=";
        case BinaryOp.Less:       return "<";
        case BinaryOp.Greater:    return ">";
        case BinaryOp.LessEq:     return "<=";
        case BinaryOp.GreaterEq:  return ">=";
        //-------------------------------------
        case BinaryOp.And:        return "and";
        case BinaryOp.Or:         return "or";
        case BinaryOp.Xor:        return "xor";
        //-------------------------------------
        case BinaryOp.LogicalAnd: return "&&";
        case BinaryOp.LogicalOr:  return "||";

				default: assert(0);
			}
		}(op), [a, b]);
	}

	///演算子の種別
	BinaryOp op;

	override Operation operation(){
		return new BinaryOpCommand(op);
	}
}


///単項演算子
class UnaryOpNode : Node{

	///初期化
  this(UnaryOp _op, Node a){
    type = NodeType.UnaryOp;
    op = _op;

    super((o){
        switch(o){
          case UnaryOp.Neg:         return "-";
          case UnaryOp.Not:         return "not";
          case UnaryOp.LogicalNot:  return "!";
          default: assert(0);
        }
    }(op), [a]);
  }

	///演算子の種別
  UnaryOp op;

	override Operation operation(){
		return new UnaryOpCommand(op);
	}
}


///リテラルを格納する
class ValueNode : Node{

	///初期化
	this(T)(T a){
		type = NodeType.Value;

		value.data = a;
		super(value.toString);
	}

	///値
	public Value value;

	override Operation operation(){
		switch(value.type){
			case ValueType.Integer:
				auto k = value.get!int;
				if(short.min <= k && k <= short.max){
					return new PushImm16(k.to!short);
				}else{
					return new PushImm32(k);
				}
			case ValueType.Floater:
				return new PushImm64f(value.get!double);
			case ValueType.String:
				return new PushString(value.get!wstring);

			default: assert(0);
		}
	}
}

import tosuke.smilebasic.operator;
import tosuke.smilebasic.value;

///Nodeどうしを演算した結果を返す
Value unaryOp(UnaryOp op, Node a){
  return tosuke.smilebasic.operator.unaryOp(op, (cast(ValueNode)a).value);
}


///ditto
Value binaryOp(BinaryOp op, Node a, Node b){
  return tosuke.smilebasic.operator.binaryOp(op, (cast(ValueNode)a).value, (cast(ValueNode)b).value);
}