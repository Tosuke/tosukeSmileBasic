module tosuke.smilebasic.value.operator;

import tosuke.smilebasic.value;
import tosuke.smilebasic.error;
import std.conv : to;
import std.format;
import std.algorithm, std.range, std.array;

///Valueの演算子の実装
mixin template OperatorMixin(){
  //Operator Overloadings
	/// 単項-演算子
	Value opUnary(string op : "-")() const{
		switch(type){
	    case ValueType.Integer: return Value(-(data.get!int));
	    case ValueType.Floater: return Value(-(data.get!double));
	    default: throw imcompatibleTypeError("-", this);
	  }
	}

	/// ~演算子
	Value opUnary(string op : "~")() const {
		if(this.isArithmeticValue){
			return Value(~(this.toInteger));
		}else{
			throw imcompatibleTypeError("not", this);
		}
	}

	/// *演算子
	Value opBinary(string op : "*")(Value b) const {
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
	Value opBinary(string op : "/")(Value b) const {
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(this.toFloater / b.toFloater);
	  }else{
	    throw imcompatibleTypeError("/", this, b);
	  }
	}

	/// mod演算子
	Value opBinary(string op : "%")(Value b) const {
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(this.toInteger % b.toInteger);
	  }else{
	    throw imcompatibleTypeError("%", this, b);
	  }
	}

	/// +演算子
	Value opBinary(string op : "+")(Value b) const {
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
	Value opBinary(string op : "-")(Value b) const {
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
	Value opBinary(string op)(Value b) const if(op == "<<" || op == ">>"){
		if(this.isArithmeticValue && b.isArithmeticValue){
	    return Value(mixin(`this.toInteger`~op~`b.toInteger`));
	  }else{
	    throw imcompatibleTypeError(op, this, b);
	  }
	}

	/// &,|,^演算子
	Value opBinary(string op)(Value b) const if(op == "&" || op == "|" || op == "^"){
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
	bool opEquals(Value b) const{
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
	int opCmp(Value b) const{
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