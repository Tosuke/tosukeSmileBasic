module tosuke.smilebasic.compiler.node.variable;

import tosuke.smilebasic.compiler.node;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.value;

import std.algorithm, std.array;
import std.conv : to;


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