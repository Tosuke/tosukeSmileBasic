import std.stdio;
import std.array;
import std.conv;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.vm;
import tosuke.smilebasic.error;

void main(){
	try{
		auto slot = slot(`
				a% = 1
				if a%==1 then
					?"hage"
				else
					?"not hage"
				endif

				if a%==1 goto @a
				
				?@a
				@a
				
				?@b
				@b
			`);
		slot.compile;

		auto vm = new VM();
		vm.set(0, slot);
		vm.run(0);
	}catch(SmileBasicError e){
		writeln(e.msg);
		//throw e;
	}
}
