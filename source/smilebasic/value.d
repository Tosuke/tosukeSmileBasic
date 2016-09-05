module tosuke.smilebasic.value;

enum ValueType{
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
			}else static if(is(T : int)){
				type = ValueType.Integer;
				data_ = a;
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
}
