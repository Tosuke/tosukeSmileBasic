import std.stdio;
import std.array;
import std.conv;

import tosuke.smilebasic.parser;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.error;
import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.ast.optimize;
import tosuke.smilebasic.ast.genList;
import tosuke.smilebasic.code.gencode;
import tosuke.smilebasic.code.sourcemap;
import tosuke.smilebasic.vm;

void main(){
	tosuke.smilebasic.operator.initialize;

	auto parser = new Parser();

	try{
		Node tree;
		Node[] nodeList;
		int line = 1;
		try{
			nodeList = parser.parse(`print ""+44`).children;
		}catch(SyntaxError e){
			e.line = line;
			throw e;
		}
		Appender!(Node[]) temp;
		foreach(a; nodeList){
			a.line = line;
			temp ~= a;
		}
		tree = new DocumentNode(temp.data);
		tree.writeln;
		//tree = constantFolding(tree);
		//tree.writeln;

		auto list = genList(tree);
		list[].writeln;

		auto codeMap = list.codeMap;
		codeMap.data.writeln;

		auto byteCode = genCode(list);
		byteCode.writeln;

		auto vm = new VM();
		vm.set(0, byteCode);
		vm.run(0);
	}catch(SmileBasicError e){
		writeln(e.msg);
	}
}
