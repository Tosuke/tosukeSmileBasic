module tosuke.smilebasic.ast.node;

import tosuke.smilebasic.value;
import tosuke.smilebasic.operator;

import std.conv : to;

enum NodeType{
	BinaryOp,
  UnaryOp,
	Value,

	PrintStatement
}

abstract class Node{
	private NodeType type_;
	@property{
		public NodeType type(){return type_;}
		protected void type(NodeType a){type_ = a;}
	}
	string name;
	Node[] children;

	this(string _name, Node[] _children = []){
		name = _name;
		children = _children;
	}

	override string toString(){
		import std.algorithm, std.string;
		return name~":["~children.map!"a.toString".join(", ")~"]";
	}
}

class BinaryOpNode : Node{
	this(BinaryOp _op, Node a, Node b){
    type = NodeType.BinaryOp;
		op = _op;
		super((o){
			switch(o){
        case BinaryOp.Mul:    return "*";
				case BinaryOp.Div:    return "/";
        case BinaryOp.IntDiv: return "div";
        case BinaryOp.Mod:    return "mod";
        //-----------------------------------
				case BinaryOp.Add: return "+";
				case BinaryOp.Sub: return "-";
        //-----------------------------------
        case BinaryOp.LShift: return "<<";
        case BinaryOp.RShift: return ">>";
        //-----------------------------------
        case BinaryOp.Eq:         return "==";
        case BinaryOp.NotEq:      return "!=";
        case BinaryOp.Less:       return "<";
        case BinaryOp.Greater:    return ">";
        case BinaryOp.LessEq:     return "<=";
        case BinaryOp.GreaterEq:  return ">=";
        //-----------------------------------
        case BinaryOp.And:  return "and";
        case BinaryOp.Or:   return "or";
        case BinaryOp.Xor:  return "xor";
        //-----------------------------------
        case BinaryOp.LogicalAnd: return "&&";
        case BinaryOp.LogicalOr:  return "||";

				default: assert(0);
			}
		}(op), [a, b]);
	}

	BinaryOp op;
}

class UnaryOpNode : Node{
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

  UnaryOp op;
}

class ValueNode : Node{
	this(T)(T a){
		type = NodeType.Value;

		value.data = a;
		super(value.toString);
	}
	Value value;
}

import tosuke.smilebasic.operator;
import tosuke.smilebasic.value;

Value unaryOp(UnaryOp op, Node a){
  return tosuke.smilebasic.operator.unaryOp(op, (cast(ValueNode)a).value);
}
Value binaryOp(BinaryOp op, Node a, Node b){
  return tosuke.smilebasic.operator.binaryOp(op, (cast(ValueNode)a).value, (cast(ValueNode)b).value);
}

class PrintStatementNode : Node{
	this(Node[] _children){
		type = NodeType.PrintStatement;
		super("Print", _children);
	}
}
