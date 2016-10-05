import std.stdio;
import std.array;
import std.conv;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm;
import tosuke.smilebasic.error;

void main(){
	tosuke.smilebasic.operator.initialize;

	try{
		auto slot = slot(
			`
				a$="ゆうアシ"
				print a$+"はハゲ"
			`
		);
		slot.source.writeln;
		slot.compile;

		auto vm = new VM();
		vm.set(0, slot);
		vm.run(0);
	}catch(SmileBasicError e){
		writeln(e.msg);
	}
}
