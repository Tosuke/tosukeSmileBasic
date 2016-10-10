module tosuke.smilebasic.value;

import tosuke.smilebasic.error;
import std.conv : to;
import std.format;
import std.algorithm, std.range, std.array;


///値の種別
enum ValueType{
	Undefined,
	Integer,
	Floater,
	String,
	Array,
}


///値の種別を文字列化する
string toString(ValueType t){
	switch(t){
		case ValueType.Undefined:	return "Undefined";
		case ValueType.Integer: 	return "Integer";
		case ValueType.Floater: 	return "Floater";
		case ValueType.String: 		return "String";
		case ValueType.Array: 		return "Array";
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

	///ditto
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
			case ValueType.Array:
				break;
		}

		type = t;
	}

	///値の実体
	alias Type = Algebraic!(int, double, StringValue, ArrayValue);
	private Type data_;
	@property{
		///ditto
		public Type data() const {return data_;}
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
				data_ = new StringValue(a);
			}else static if(is(T == StringValue)){
				type = ValueType.String;
				data_ = a;
			}else static if(is(T == ArrayValue)){
				type = ValueType.Array;
				data_ = a;
			}else{
				static assert(0);
			}
		}
	}


	///取得
	T get(T)() const{
		static if(is(T : wstring)){
			return data.get!StringValue.data.to!T;
		}else{
			return data.get!T;
		}
	}


	///次元
	int dimension() @property const{
		final switch(this.type){
			case ValueType.Undefined:	return 0;
			case ValueType.Integer: 	return 0;
			case ValueType.Floater: 	return 0;
			case ValueType.String:		return this.get!StringValue.dimension;
			case ValueType.Array:			return this.get!ArrayValue.dimension;
		}
	}


	///長さ
	size_t length() @property const {
		switch(this.type){
			case ValueType.String:	return this.get!StringValue.length;
			case ValueType.Array:		return this.get!ArrayValue.length;
			default:
				throw cannotUseAsArrayError(this);
		}
	}

	///配列アクセス
	Value index(int[] ind) const {
		if(ind.length != this.dimension){
			throw illegalIndexError(this.dimension);
		}
		if(!this.isArrayValue){
			throw cannotUseAsArrayError(this);
		}

		if(this.type == ValueType.String){
			return this.get!StringValue.index(ind);
		}else if(this.type == ValueType.Array){
			return this.get!ArrayValue.index(ind);
		}
		assert(0);
	}

	///ditto
	Value opIndex(int[] ind...) const {
		return index(ind);
	}

	///配列アクセス
	void indexAssign(Value a, int[] ind){
		if(ind.length != this.dimension){
			throw illegalIndexError(this.dimension);
		}
		if(!this.isArrayValue){
			throw cannotUseAsArrayError(this);
		}

		if(this.type == ValueType.String){
			this.get!StringValue.indexAssign(a, ind);
		}else if(this.type == ValueType.Array){
			this.get!ArrayValue.indexAssign(a, ind);
		}
	}

	///ditto
	void opIndexAssign(Value a, int[] ind...){
		indexAssign(a, ind);
	}


	/// =演算子
	void opAssign(T)(T a) if(!is(T == Value)){
		data = a;
	}

	///ditto
	void opAssign(Value a){
		if(this.isArithmeticValue && a.isArithmeticValue){
			if(this.type == ValueType.Integer){
				this.data = a.toInteger;
			}else{
				this.data = a.toFloater;
			}
		}else if(this.type == a.type || this.type == ValueType.Undefined){
			this.data = a;
		}else{
			throw failedToConvertTypeError(this, a);
		}
	}

	/// 値の種別
	private ValueType type_;
	@property{
		///ditto
		public ValueType type() const {return type_;}
		private void type(ValueType a){type_ = a;}
	}

	///初期化
	public void clear(){
		this.type = ValueType.Undefined;
	}

	string toString() const{
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

	///怒られるので
	auto toHash() const{
		return data.toHash;
	}
}


///数値型であるか？
bool isArithmeticValue(Value v){
	return v.type == ValueType.Integer || v.type == ValueType.Floater;
}


///配列型であるか？
bool isArrayValue(Value v){
	return v.type == ValueType.String || v.type == ValueType.Array;
}


///実数型に変換する
double toFloater(Value v){
	if(!isArithmeticValue(v))
		throw failedToConvertTypeError(v, Value(ValueType.Floater));
		
	if(v.type == ValueType.Integer){
		return v.get!int.to!double;
	}else{
		return v.get!double;
	}
}


///整数型に変換する
int toInteger(Value v){
	if(!isArithmeticValue(v))
		throw failedToConvertTypeError(v, Value(ValueType.Integer));
	
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

///配列アクセスを提供する
abstract class IArray{
	
	///次元
	abstract int dimension() @property const;

	///長さ
	abstract size_t length() @property const;

	///配列アクセスで返却される値の型
	abstract ValueType type() @property const;

	///配列アクセス
	abstract Value index(int[] ind);

	///配列アクセス
	abstract void indexAssign(Value a, int[] ind);
}

///内部文字列
class StringValue : IArray{
	
	///初期化
	this(wstring str){
		data = str;
	}

	///文字列の実体
	public wstring data;

	///次元
	override int dimension() @property const {return 1;}

	///長さ
	override size_t length() @property const {
		return data.length;
	}

	///配列アクセスで返却される値の型
	override ValueType type() @property const {
		return ValueType.String;
	}

	///配列アクセス
	override Value index(int[] ind) const
	in{
		assert(ind.length == 1);
	}body{
		immutable i = ind[0];
		return Value(data[i..i+1].dup.to!wstring);
	}

	///配列アクセス
	override void indexAssign(Value a, int[] ind)
	in{
		assert(ind.length == 1);
	}body{
		if(a.type != ValueType.String)
			throw failedToConvertTypeError(Value(ValueType.String), a);
		
		immutable i = ind[0];
		data = data[0..i] ~ a.get!wstring ~ data[i+1..$];
	}
}

unittest{
	auto a = Value("aaa"w);
	assert(a[1] == Value("a"w));
	Value b = a;

	a[1] = Value("bbb"w);
	assert(a == Value("abbba"w));

	assert(b == Value("abbba"w));
}


///内部配列
abstract class ArrayValue : IArray{

	///次元
	override abstract int dimension() @property const;

	///長さ
	override abstract size_t length() @property const;

	///内部の型
	override abstract ValueType type() @property const;

	///配列アクセス
	override abstract Value index(int[] ind);

	///配列アクセス
	override abstract void indexAssign(Value a, int[] ind);
}

import std.experimental.ndslice;

///内部配列の実装
class TypedArrayValue(T) : ArrayValue
	if(is(T == int) || is(T == double) || is(T ==  StringValue)){

	///配列の生データ
	private T[] data_;
	@property{
		///ditto
		public T[] data(){return data_;}
		///ditto
		public void data(T[] a){
			data_ = a;
			slice = a.sliced(slice.shape);
		}
	}

	///スライスされた配列
	private Slice!(4, T*) slice;

	///次元
	private int dimension_;
	@property{
		///ditto
		public override int dimension() const {return dimension_;}
		private void dimension(int a){dimension_ = a;}
	}

	///長さ
	public override size_t length() @property const {
		return data_.length; //悪手
	}

	///配列アクセスで返却される型
	public override ValueType type() @property const {
		static if(is(T == int)){
			return ValueType.Integer;
		}else static if(is(T == double)){
			return ValueType.Floater;
		}else static if(is(T == StringValue)){
			return ValueType.String;
		}else{
			static assert(0);
		}
	}

	///初期化
	this(int[] ind){
		if(!(1 <= ind.length && ind.length <= 4)){
			throw new OutOfRangeError("only 1~4 index allowed");
		}

		size_t length = ind.reduce!"a*b";
		data_ = new T[length];
		static if(is(T == StringValue)){
			foreach(ref a; data_){
				a = new StringValue(""w);
			}
		}

		if(length){
			size_t[4] l = [1, 1, 1, 1];
			l[0..ind.length] = ind.to!(size_t[])[];

			slice = data.sliced(l);
		}
	}

	///配列アクセス
	public override Value index(int[] ind)
	in{
		assert(ind.length == dimension);
	}body{
		size_t[4] l = [0, 0, 0, 0];
		l[0..ind.length] = ind.to!(size_t[])[];
		
		try{
			const v = Value(slice.opIndex!(size_t[4])(l)); 
			return v;
		}catch(Error e){
			throw invalidIndexError;
		}
			
	}

	///配列アクセス
	public override void indexAssign(Value a, int[] ind)
	in{
		assert(ind.length == dimension);
	}body{
		int[4] l = [0, 0, 0, 0];
		l[0..ind.length] = ind[];

		try{
			slice[l] = a.get!T;			
		}catch(Error e){
			throw invalidIndexError;
		}
	}
}

unittest{
	auto a = new TypedArrayValue!int([2, 2]);
	a.indexAssign(Value(1), [0, 0]);
	assert(a.index([0, 0]) == Value(1));
}