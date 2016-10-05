module tosuke.smilebasic.value;

import tosuke.smilebasic.error;
import std.conv : to;
import std.format;


///値の種別
enum ValueType{
	Undefined,
	Integer,
	Floater,
	String
}


///値の種別を文字列化する
string toString(ValueType t){
	switch(t){
		case ValueType.Undefined: return "Undefined";
		case ValueType.Integer: return "Integer";
		case ValueType.Floater: return "Floater";
		case ValueType.String: return "String";
		default: assert(0);
	}
}


///tosukeSmileBasic内の値
struct Value{
	import std.variant : Algebraic;

	alias data this;

	///初期化
	this(T)(T a) if(!is(T == ValueType)){
		data = a;
	}

	this(ValueType t){
		final switch(t){
			case ValueType.Undefined:
				break;
			case ValueType.Integer:
				data = 0;
				break;
			case ValueType.Floater:
				data = 0.0;
				break;
			case ValueType.String:
				data = ""w;
				break;
		}

		type = t;
	}

	///値の実体
	private Algebraic!(int, double, wstring) data_;
	@property{
		///ditto
		public auto data(){return data_;}
		///ditto
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


	/// =演算子
	void opAssign(T)(T a){data = a;}

	/// 値の種別
	private ValueType type_;
	@property{
		///ditto
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
	/// 単項-演算子
	Value opUnary(string op : "-")(){
		switch(type){
	    case ValueType.Integer: return Value(-(data.get!int));
	    case ValueType.Floater: return Value(-(data.get!double));
	    default: throw imcompatibleTypeError("-", this);
	  }
	}

	/// ~演算子
	Value opUnary(string op : "~")(){
		if(this.isArithmeticValue){
			return Value(~(this.toInteger));
		}else{
			throw imcompatibleTypeError("not", this);
		}
	}

	/// *演算子
	Value opBinary(string op : "*")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    if(this.type == ValueType.Integer && b.type == ValueType.Integer){
	      return Value(this.get!int * b.get!int);
	    }else{
	      return Value(this.toFloater * b.toFloater);
	    }
	  }else if(this.type == ValueType.String && b.isArithmeticValue){
	    import std.array : replicate;
	    return Value(this.get!wstring.replicate(b.toInteger));
	  }else{
	    throw imcompatibleTypeError("*", this, b);
	  }
	}

	/// /演算子
	Value opBinary(string op : "/")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(this.toFloater / b.toFloater);
	  }else{
	    throw imcompatibleTypeError("/", this, b);
	  }
	}

	/// mod演算子
	Value opBinary(string op : "%")(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(this.toInteger % b.toInteger);
	  }else{
	    throw imcompatibleTypeError("%", this, b);
	  }
	}

	/// +演算子
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

	/// -演算子
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

	/// <<,>>演算子
	Value opBinary(string op)(Value b) if(op == "<<" || op == ">>"){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(mixin(`this.toInteger`~op~`b.toInteger`));
	  }else{
	    throw imcompatibleTypeError(op, this, b);
	  }
	}

	/// &,|,^演算子
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

	/// ==演算子
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

	/// <,>,<=.>=演算子
	int opCmp(Value b){
		if(this.isArithmeticValue && b.isArithmeticValue){
			if(this.type == ValueType.Integer && b.type == ValueType.Integer){
				immutable m = this.get!int; immutable n = b.get!int;
				if(m <  n){
					return -1;
				}else if(m == n){
					return  0;
				}else if(m >  n){
					return +1;
				}
			}else{
				immutable m = this.toFloater; immutable n = b.toFloater;
				if(m <  n){
					return -1;
				}else if(m == n){
					return  0;
				}else if(m >  n){
					return +1;
				}
			}
		}else if(this.type == ValueType.String && b.type == ValueType.String){
			immutable m = this.get!wstring; immutable n = b.get!wstring;
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


///数値型であるか？
bool isArithmeticValue(Value v){
	return v.type == ValueType.Integer || v.type == ValueType.Floater;
}


///配列型であるか？
bool isArrayValue(Value v){
	return false;
}


///実数型に変換する
double toFloater(Value v){
	if(!isArithmeticValue(v)) throw new TypeMismatchError();
	if(v.type == ValueType.Integer){
		return v.get!int.to!double;
	}else{
		return v.get!double;
	}
}


///整数型に変換する
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


///真であれば0以外、偽であれば0を返す
int toBoolean(Value v){
	switch(v.type){
		case ValueType.Integer: return cast(int)(v.get!int != 0);
		case ValueType.Floater: return cast(int)(v.get!double != 0);
		case ValueType.String: return 3;
		default: assert(0);
	}
}
