module tosuke.smilebasic.value;

import tosuke.smilebasic.error;
import std.conv : to;
import std.format;

enum ValueType{
	Undefined,
	Integer,
	Floater,
	String
}

string toString(ValueType t){
	switch(t){
		case ValueType.Undefined: return "Undefined";
		case ValueType.Integer: return "Integer";
		case ValueType.Floater: return "Floater";
		case ValueType.String: return "String";
		default: assert(0);
	}
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

	//Operator Overloadings
	//negOp
	Value opUnary(string op : "-")(){
		switch(type){
	    case ValueType.Integer: return Value(-(data.get!int));
	    case ValueType.Floater: return Value(-(data.get!double));
	    default: throw imcompatibleTypeError("-", this);
	  }
	}
	//notOp
	Value opUnary(string op : "~")(){
		if(this.isArithmeticValue){
			return Value(~(this.toInteger));
		}else{
			throw imcompatibleTypeError("not", this);
		}
	}

	//mulOp
	Value opBinary(string op : "*")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    if(this.type == ValueType.Integer && b.type == ValueType.Integer){
	      return Value(this.get!int * b.get!int);
	    }else{
	      return Value(this.toFloater * b.toFloater);
	    }
	  }else if(this.type == ValueType.String && b.isArithmeticValue){
	    import std.array;
	    return Value(this.get!wstring.replicate(b.toInteger));
	  }else{
	    throw imcompatibleTypeError("*", this, b);
	  }
	}

	//divOp
	Value opBinary(string op : "/")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(this.toFloater / b.toFloater);
	  }else{
	    throw imcompatibleTypeError("/", this, b);
	  }
	}

	//modOp
	Value opBinary(string op : "%")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(this.toInteger % b.toInteger);
	  }else{
	    throw imcompatibleTypeError("%", this, b);
	  }
	}

	//addOp
	Value opBinary(string op : "+")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    if(this.type == ValueType.Integer && b.type == ValueType.Integer){
	      return Value(this.get!int + b.get!int);
	    }else{
	      return Value(this.toFloater + b.toFloater);
	    }
	  }else if(this.type == ValueType.String && b.type == ValueType.String){
	    return Value(this.get!wstring ~ b.get!wstring);
	  }else{
	    throw imcompatibleTypeError("+", this, b);
	  }
	}

	//subOp
	Value opBinary(string op : "-")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    if(this.type == ValueType.Integer && b.type == ValueType.Integer){
	      return Value(this.get!int - b.get!int);
	    }else{
	      return Value(this.toFloater - b.toFloater);
	    }
	  }else{
	    throw imcompatibleTypeError("-", this, b);
	  }
	}

	//shiftOp
	Value opBinary(string op)(Value b) if(op == "<<" || op == ">>"){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(mixin(`this.toInteger`~op~`b.toInteger`));
	  }else{
	    throw imcompatibleTypeError(op, this, b);
	  }
	}

	//bitOp
	Value opBinary(string op)(Value b) if(op == "&" || op == "|" || op == "^"){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(mixin(`this.toInteger`~op~`b.toInteger`));
	  }else{
	    throw imcompatibleTypeError((k){
				switch(k){
					case "&": return "and";
					case "|": return "or";
					case "^": return "xor";
					default: assert(0);
				}
			}(op), this, b);
	  }
	}
	//eqOp
	bool opEquals(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
			if(this.type == ValueType.Integer && b.type == ValueType.Integer){
				return this.get!int == b.get!int;
			}else{
				return this.toFloater == b.toFloater;
			}
		}else if(this.type == ValueType.String && b.type == ValueType.String){
			return this.get!wstring == b.get!wstring;
		}else{
			throw new TypeMismatchError();
		}
	}
	//cmpOp
	int opCmp(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
			if(this.type == ValueType.Integer && b.type == ValueType.Integer){
				int m = this.get!int; int n = b.get!int;
				if(m <  n){
					return -1;
				}else if(m == n){
					return  0;
				}else if(m >  n){
					return +1;
				}
			}else{
				double m = this.toFloater; double n = b.toFloater;
				if(m <  n){
					return -1;
				}else if(m == n){
					return  0;
				}else if(m >  n){
					return +1;
				}
			}
		}else if(this.type == ValueType.String && b.type == ValueType.String){
			wstring m = this.get!wstring; wstring n = b.get!wstring;
			if(m <  n){
				return -1;
			}else if(m == n){
				return  0;
			}else if(m >  n){
				return +1;
			}
		}else{
			throw new TypeMismatchError();
		}
		assert(0);
	}
}

bool isArithmeticValue(Value v){
	return v.type == ValueType.Integer || v.type == ValueType.Floater;
}
bool isArrayValue(Value v){
	return false;
}

double toFloater(Value v){
	if(!isArithmeticValue(v)) throw new TypeMismatchError();
	if(v.type == ValueType.Integer){
		return v.get!int.to!double;
	}else{
		return v.get!double;
	}
}

int toInteger(Value v){
	if(!isArithmeticValue(v)) throw new TypeMismatchError();
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
