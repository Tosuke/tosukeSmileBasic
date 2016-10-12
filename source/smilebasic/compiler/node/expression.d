module tosuke.smilebasic.compiler.node.expression;

import tosuke.smilebasic.compiler.node;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.value;

import std.algorithm, std.array;
import std.conv : to;

///式の構成要素
abstract class ExpressionNode : Node{

	///初期化
	this(string name, Node[] children = []){
		super(name, children);
	}

	///中間コード
	override abstract Operation operation() const;

	///処理方向
	override abstract NodeType type() const;

	///代入可能か
	abstract bool isAssignable() const {
		return false;
	}
}

//式の構成要素
///二項演算子
class BinaryOpNode : ExpressionNode{

	///初期化
	this(BinaryOp _op, Node a, Node b){
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

	override Operation operation() const {
		return new BinaryOpCommand(op);
	}

	override NodeType type() const {
		return NodeType.Reverse;
	}

	override bool isAssignable() const {return false;}
}


///単項演算子
class UnaryOpNode : ExpressionNode{

	///初期化
  this(UnaryOp _op, Node a){
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

	override Operation operation() const {
		return new UnaryOpCommand(op);
	}

	override NodeType type() const {
		return NodeType.Reverse;
	}

	override bool isAssignable() const {return false;}
}


///リテラルを格納する
class ValueNode : ExpressionNode{

	///初期化
	this(T)(T a){
		value.data = a;
		super(value.toString);
	}

	///値
	public Value value;

	override Operation operation() const {
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

	override NodeType type() const {
		return NodeType.Reverse;
	}

	override bool isAssignable() const {return false;}
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