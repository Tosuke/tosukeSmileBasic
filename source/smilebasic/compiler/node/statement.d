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


