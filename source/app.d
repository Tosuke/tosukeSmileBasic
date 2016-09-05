import std.stdio;
import pegged.grammar;
import std.array;
import std.conv : to;

import tosuke.smilebasic.parser;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.node;

void main(){
	//Parser_ parser;
	//parser.initialize();
	//parser.parse("1+1").writeln;
	initUnaryOpTable();

	auto parser = new Parser();
	auto tree = parser.parse(`!2`);
	tree.writeln;
	eval(tree).writeln;
}

Node eval(Node node){
	import std.algorithm, std.array;
	node.children = node.children.map!(a => eval(a)).array;

	switch(node.type){
		case NodeType.UnaryOp:
			return eval(cast(UnaryOpNode)node);
		default:
			return node;
	}
}

Node eval(UnaryOpNode node){
	if(node.children[0].type == NodeType.Value){
		return new ValueNode(unaryOp(node.op, node.children[0]));
	}else{
		return node;
	}
}
