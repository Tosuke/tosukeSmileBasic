module tosuke.smilebasic.compiler.node.node;

import tosuke.smilebasic.compiler.node;

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
		public NodeType type() const {return type_;}
		protected void type(NodeType a){type_ = a;}
	}

	///ノードの位置の行番号
	private int line_;
	@property{
		///ditto
		public int line() const {return line_;}
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
	override string toString() const{
		import std.algorithm : map;
		import std.string : join;
		return name~":["~children.map!"a.toString".join(", ")~"]";
	}


	///中間コード
	abstract Operation operation() const;
}


///プログラムの最上位に位置する。特に意味はない
class DocumentNode : Node{

	///初期化
	this(Node[] _children){
		type = NodeType.Document;
		super("Doc", _children);
	}

	override Operation operation() const{
		return new EmptyOperation();
	}
}