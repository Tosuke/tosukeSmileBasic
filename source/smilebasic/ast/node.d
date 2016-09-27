module tosuke.smilebasic.ast.node;

import tosuke.smilebasic.value;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.code.operation;

import std.conv : to;

enum NodeType{
	Document,
	Line,

	PrintStatement,

	BinaryOp,
  UnaryOp,
	Value,
}

abstract class Node{
	private NodeType type_;
	@property{
		public NodeType type(){return type_;}
		protected void type(NodeType a){type_ = a;}
	}
	private int line_; //自分の位置の行番号
	@property{
		public int line(){return line_;}
		public void line(int a){
			line_ = a;
			foreach(ref c; children){
				c.line = a;
			}
		}
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

	abstract Operation operation();
}

class DocumentNode : Node{
	this(Node[] _children){
		type = NodeType.Document;
		super("Doc", _children);
	}

	override Operation operation(){
		return new EmptyOperation();
	}
}

class LineNode : Node{
	this(int _line, Node[] _children){
		line = _line;
		this(_children);
	}
	this(Node[] _children){
		type = NodeType.Line;
		super("Line", _children);
	}

	override Operation operation(){
		return new EmptyOperation();
	}
}


class PrintStatementNode : Node{
	this(Node[] _children){
		type = NodeType.PrintStatement;
		super("Print", _children);
	}

	override Operation operation(){
		return new PrintCommand(this.children.length.to!ushort);
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

	override Operation operation(){
		return new BinaryOpCommand(op);
	}
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

	override Operation operation(){
		return new UnaryOpCommand(op);
	}
}

class ValueNode : Node{
	this(T)(T a){
		type = NodeType.Value;

		value.data = a;
		super(value.toString);
	}
	Value value;

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

Value unaryOp(UnaryOp op, Node a){
  return tosuke.smilebasic.operator.unaryOp(op, (cast(ValueNode)a).value);
}
Value binaryOp(BinaryOp op, Node a, Node b){
  return tosuke.smilebasic.operator.binaryOp(op, (cast(ValueNode)a).value, (cast(ValueNode)b).value);
}
