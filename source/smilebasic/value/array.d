module tosuke.smilebasic.value.array;

import tosuke.smilebasic.value;
import tosuke.smilebasic.error;
import std.conv : to;
import std.format;
import std.algorithm, std.range, std.array;


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


unittest{
	auto a = new TypedArrayValue!int([2, 2]);
	a.indexAssign(Value(1), [0, 0]);
	assert(a.index([0, 0]) == Value(1));
}


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

		dimension = ind.length.to!int;

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
