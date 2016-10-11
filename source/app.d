import std.stdio;
import std.array;
import std.conv;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm;
import tosuke.smilebasic.error;

void main(){
	try{
		auto slot = slot(
			`
				a$=" "
				a$[0]="aabb"
				?a$
				
				dim c$[10]
				c$[0]="c"
				d$=c$[0]
				c$[0][0]="d"
				?c$[0]
				?d$

				d$[0]="f"
				?c$[0]
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
