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
				'コメント
				'var a$="ゆうアシ"
				'dim a% = 10
				'b$ = a$+"はハゲ"
				'print b$*a%
				?"hh"[0]
				var b$[10]
				var c[0]
				c=b$
				?c[9]
				?"hh"
			`
		);
		slot.source.writeln;
		slot.compile;

		auto vm = new VM();
		vm.set(0, slot);
		vm.run(0);
	}catch(SmileBasicError e){
		writeln(e.msg);
		//throw e;
	}
}
