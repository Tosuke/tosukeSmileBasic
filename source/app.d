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
	initBinaryOpTable();

	auto parser = new Parser();
	auto tree = parser.parse(`2*3*3-3*3+3*4`);
	tree.writeln;
	eval(tree).writeln;
}

Node eval(Node node){
	import std.algorithm, std.array;
	node.children = node.children.map!(a => eval(a)).array;

	switch(node.type){
		case NodeType.UnaryOp:
			return eval(cast(UnaryOpNode)node);
		case NodeType.BinaryOp:
			return eval(cast(BinaryOpNode)node);
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

Node eval(BinaryOpNode node){
	if(node.children[0].type == NodeType.Value && node.children[1].type == NodeType.Value){
		return new ValueNode(binaryOp(node.op, node.children[0], node.children[1]));
	}else{
		return node;
	}
}
