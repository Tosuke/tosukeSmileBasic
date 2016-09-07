import std.stdio;
import pegged.grammar;
import std.array;
import std.conv;

import tosuke.smilebasic.parser;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.ast.optimize;
import tosuke.smilebasic.ast.genList;
import tosuke.smilebasic.code.gencode;

void main(){

	tosuke.smilebasic.operator.initialize;

	auto parser = new Parser();
	auto tree = parser.parse(`?"hoge"`);
	tree.writeln;
	tree = constantFolding(tree);
	tree.writeln;
	auto list = genList(tree);
	list[].writeln;
	auto byteCode = genCode(list);
	byteCode.writeln;
}
