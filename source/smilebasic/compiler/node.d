module tosuke.smilebasic.compiler.node;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.value;

import std.algorithm, std.array;
import std.conv : to;


///ノードの種別
enum NodeType{
	///プログラム全体
	Document,
	///Print文
	PrintStatement,
	///代入文
	AssignStatement,
	///変数定義文
	VariableDefineStatement,

	///二項演算子
	BinaryOp,
	///単項演算子
  UnaryOp,
	///リテラル
	Value,
	///変数
	Variable
}


///ASTのノード
abstract class Node{
	
	///ノードの種類
	private NodeType type_;
	@property{
		///ditto
		public NodeType type(){return type_;}
		protected void type(NodeType a){type_ = a;}
	}

	///ノードの位置の行番号
	private int line_;
	@property{
		///ditto
		public int line(){return line_;}
		///ditto
		public void line(int a){
			line_ = a;
			foreach(ref c; children){
				c.line = a;
			}
		}
	}

	///ノードの名前
	public string name;

	///子ノード
	Node[] children;


	///ノードを生成する
	this(string _name, Node[] _children = []){
		name = _name;
		children = _children;
	}


	///ASTを人間が読める形で出力する
	override string toString(){
		import std.algorithm : map;
		import std.string : join;
		return name~":["~children.map!"a.toString".join(", ")~"]";
	}


	///中間コード
	abstract Operation operation();
}


///プログラムの最上位に位置する。特に意味はない
class DocumentNode : Node{

	///初期化
	this(Node[] _children){
		type = NodeType.Document;
		super("Doc", _children);
	}

	override Operation operation(){
		return new EmptyOperation();
	}
}


///Print文
class PrintStatementNode : Node{
	
	///初期化
	this(Node[] _children){
		type = NodeType.PrintStatement;
		super("Print", _children);
	}

	override Operation operation(){
		return new PrintCommand(this.children.length.to!ushort);
	}
}


///代入文
class AssignStatementNode : Node{

	///初期化
	this(VariableNode var, Node expr){
		type = NodeType.AssignStatement;
		super("Assign", [expr]);
		variable = var;
	}

	private VariableNode variable;

	override Operation operation(){
		return variable.popOperation;
	}
}


///変数定義文
class VariableDefineStatementNode : Node{

	///初期化
	this(VariableNode[] defines, Node[] _children){
		type = NodeType.VariableDefineStatement;
		
		Node[] temp =
			defines[].map!(
				(a){
					return new class() Node{
						
						this(){
							type = NodeType.VariableDefineStatement;
							super(a.name);
						}

						override Operation operation(){
							return a.defineOperation;
						}

					}.to!Node;
				}
			).array;

			super("Define", temp ~ _children);
	}

	override Operation operation(){
		return new EmptyOperation();
	}

}


///二項演算子
class BinaryOpNode : Node{

	///初期化
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


///変数
abstract class VariableNode : Node{
	
	///初期化
	this(string name, Node[] children = []){
		type = NodeType.Variable;
		super(name, children);
	}

	override abstract Operation operation();

	///popされるときのoperation
	abstract Operation popOperation();

	///定義されるときのoperation
	abstract Operation defineOperation();
}

///単純変数
class ScalarVariableNode : VariableNode{
	
	///初期化
	this(wstring name_){
		name = name_;
		super("ScalarVariable("~name.to!string~")");
	}

	///変数名
	private wstring name;

	override Operation operation(){
		//変数だけのときは式なのでPushと判断する
		return new PushScalarVariable(name);
	}

	override Operation popOperation(){
		return new PopScalarVariable(name);
	}

	override Operation defineOperation(){
		return new DefineScalarVariable(name);
	}
}
