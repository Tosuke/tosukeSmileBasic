module tosuke.smilebasic.value;

import std.conv : to;

enum ValueType{
	Undefined,
	Integer,
	Floater,
	String
}
struct Value{
	alias data this;

	this(T)(T a){
		data = a;
	}

	import std.variant;
	private Algebraic!(int, double, wstring) data_;
	@property{
		public auto data(){return data_;}
		public void data(T)(T a){
			static if(is(T == Value)){
				type = a.type;
				data_ = a.data;
			}else static if(is(T : int) || is(T : bool)){
				type = ValueType.Integer;
				data_ = cast(int)a;
			}else static if(is(T : double)){
				type = ValueType.Floater;
				data_ = a;
			}else static if(is(T : wstring)){
				type = ValueType.String;
				data_ = a;
			}else{
				static assert(0);
			}
		}
	}
	void opAssign(T)(T a){data = a;}

	private ValueType type_;
	@property{
		public ValueType type(){return type_;}
		private void type(ValueType a){type_ = a;}
	}

	string toString(){
		switch(this.type){
			case ValueType.Undefined: return "undefined";
			case ValueType.Integer: return this.get!int.to!string;
			case ValueType.Floater: return this.get!double.to!string;
			case ValueType.String: return `"`~this.get!wstring.to!string~`"`;
			default: assert(0);
		}
	}
}

bool isArithmeticValue(Value v){
	return v.type == ValueType.Integer || v.type == ValueType.Floater;
}
bool isArrayValue(Value v){
	return false;
}

double toFloater(Value v){
	if(!isArithmeticValue(v)) assert(0, "Type Mismatch");
	if(v.type == ValueType.Integer){
		return v.get!int.to!double;
	}else{
		return v.get!double;
	}
}

int toInteger(Value v){
	if(!isArithmeticValue(v)) assert(0, "Type Mismatch");
	if(v.type == ValueType.Floater){
		auto k = v.get!double;
		if(k > int.max){
			return int.max;
		}else if(k < int.min){
			return int.min;
		}else{
			return k.to!int;
		}
	}else{
		return v.get!int;
	}
}

int toBoolean(Value v){
	switch(v.type){
		case ValueType.Integer: return cast(int)(v.get!int != 0);
		case ValueType.Floater: return cast(int)(v.get!double != 0);
		case ValueType.String: return 3;
		default: assert(0);
	}
}
