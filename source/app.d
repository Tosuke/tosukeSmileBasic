import std.stdio;
import pegged.grammar;
import std.array;
import std.conv : to;

import tosuke.smilebasic.parser;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.ast.optimize;

void main(){

	tosuke.smilebasic.operator.initialize;

	auto parser = new Parser();
	auto tree = parser.parse("?2*3");
	tree.writeln;
	tree = constantFolding(tree);
	tree.writeln;
}
