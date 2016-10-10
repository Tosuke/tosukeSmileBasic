module tosuke.smilebasic.compiler.node.variable;

import tosuke.smilebasic.compiler.node;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.value;
import tosuke.smilebasic.error;

import std.algorithm, std.array;
import std.conv : to;


///変数
abstract class VariableNode : ExpressionNode{
	
	///初期化
	this(string name, Node[] children = []){
		type = NodeType.Variable;
		super(name, children);
	}

	override abstract Operation operation() const;

	///popされるときのoperation
	abstract Operation popOperation() const;

	///定義されるときのoperation
	abstract Operation defineOperation() const;

	///代入可能か?(popOperationを呼べるか？)
	abstract override bool isAssignable() const;
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

	override Operation operation() const {
		//変数だけのときは式なのでPushと判断する
		return new PushScalarVariable(name);
	}

	override Operation popOperation() const {
		return new PopScalarVariable(name);
	}

	override Operation defineOperation() const {
		return new DefineScalarVariable(name);
	}

	override bool isAssignable() const {
		return true;
	}
}


///配列変数(定義)
class ArrayVariableNode : VariableNode{

	///初期化
	this(wstring _name, ExpressionNode[] index){
		name = _name;
		super("ArrayVariable("~name.to!string~"[])", index.to!(Node[]));
	}

	///変数名
	private wstring name;
	private size_t indexNum() @property const {
		return children.length;
	}

	override Operation operation() const {
		//定義のみなので実装されない
		throw new InternalError("Push is not implemented");
	}

	override Operation popOperation() const {
		//定義のみなので実装されない
		throw new InternalError("Pop is not implemented");
	}

	override Operation defineOperation() const {
		return new DefineArrayVariable(name, indexNum.to!ushort);
	}

	override bool isAssignable() const {
		return false; //定義のみなので
	}
}
