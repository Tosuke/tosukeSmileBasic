module tosuke.smilebasic.compiler.node.statement;

import tosuke.smilebasic.compiler.node;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.value;

import std.algorithm, std.array;
import std.conv : to;


///Print文
class PrintStatementNode : Node{
	
	///初期化
	this(Node[] _children){
		super("Print", _children);
	}

	override Operation operation() const {
		return new PrintCommand(this.children.length.to!ushort);
	}

	override NodeType type() const {
		return NodeType.Reverse;
	}
}


///代入文
class AssignStatementNode : Node{

	///初期化
	this(VariableNode var, ExpressionNode expr){

		Node temp = 
			new class() Node{
				this(){
					super("Variable", var.children);
				}

				override Operation operation() const {
					return var.popOperation;
				}

				override NodeType type() const {
					return NodeType.Reverse;
				}

			};

		super("Assign", [temp, expr.to!Node]);
	}


	override Operation operation() const {
		return new EmptyOperation;
	}

	override NodeType type() const {
		return NodeType.Reverse;
	}
}


///変数定義文
class VariableDefineStatementNode : Node{

	///初期化
	this(VariableNode[] defines, Node[] _children){
		
		Node[] temp =
			defines[].map!(
				(a){
					return new class() Node{
						
						this(){
							super(a.name, a.children);
						}

						override Operation operation() const {
							return a.defineOperation;
						}

						override NodeType type() const {
							return NodeType.Reverse;
						}

					}.to!Node;
				}
			).array;

			super("Define", temp ~ _children);
	}

	override Operation operation() const {
		return new EmptyOperation();
	}

	override NodeType type() const {
		return NodeType.Forward;
	}
}


///ラベルを宣言する
class LabelStatement : Node{

	///初期化
	this(wstring _name){
		name = _name;

		super("Label "~name.to!string);
	}

	///ラベルの名前
	private wstring name;

	override Operation operation() const {
		return new DefineLabel(name);
	}

	override NodeType type() const {
		return NodeType.Forward;
	}
}


///ラベルでgoto
class GotoStatementWithLabelNode : Node{

	///初期化
	this(wstring _name){
		name = _name;

		super("Goto "~name.to!string);
	}

	///ラベルの名前
	private wstring name;

	override Operation operation() const {
		return new GotoWithLabelCommand(name);
	}

	override NodeType type() const {
		return NodeType.Forward;
	}
}


///文字列でgoto
class GotoStatementWithStringNode : Node{

	///初期化
	this(ExpressionNode name){
		super("Goto", [name.to!Node]);
	}

	override Operation operation() const {
		return new GotoWithStringCommand();
	}

	override NodeType type() const {
		return NodeType.Reverse;
	}
}


///if~then文
class IfThenStatementNode : Node{

	///初期化
	this(ExpressionNode cond){
		super("IfThen", [cond.to!Node]);
	}

	override Operation operation() const {
		return new IfThenCommand();
	}

	override NodeType type() const {
		return NodeType.Reverse;
	}
}


///else文
class ElseStatementNode : Node{

	///初期化
	this(){
		super("Else",[
			new class() Node{
				this(){super("Goto Endif");}
				override Operation operation() const {
					return new GotoEndifCommand();
				}
				override NodeType type() const {return NodeType.Forward;}
			},

			new class() Node{
				this(){super("Else");}
				override Operation operation() const {
					return new ElseCommand();
				}
				override NodeType type() const {return NodeType.Forward;}
			}
			
		]);
	}

	override Operation operation() const {
		return new EmptyOperation();
	}

	override NodeType type() const {
		return NodeType.Forward;
	}
}

///endif文
class EndifStatementNode : Node{

	///初期化
	this(){
		super("Endif");
	}

	override Operation operation() const {
		return new EndifCommand();
	}

	override NodeType type() const {
		return NodeType.Forward;
	}
}