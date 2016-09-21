import std.stdio;
import pegged.grammar;
import std.array;
import std.conv;

import tosuke.smilebasic.parser;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.error;
import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.ast.optimize;
import tosuke.smilebasic.ast.genList;
import tosuke.smilebasic.code.gencode;
import tosuke.smilebasic.vm;

void main(){
	tosuke.smilebasic.operator.initialize;

	auto parser = new Parser();

	try{
		auto tree = parser.parse(`print "hhh"`~"\n");
		tree.writeln;
		//tree = constantFolding(tree);
		//tree.writeln;

		auto list = genList(tree);
		list[].writeln;
		auto byteCode = genCode(list);
		byteCode.writeln;

		auto vm = new VM();
		vm.set(0, byteCode);
		vm.run(0);
	}catch(SmileBasicError e){
		writeln(e.msg);
	}
}
