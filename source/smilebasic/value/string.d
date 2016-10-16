module tosuke.smilebasic.value.string;

import tosuke.smilebasic.value;
import tosuke.smilebasic.error;
import std.conv : to;
import std.format;
import std.algorithm, std.range, std.array;


unittest{
	auto a = Value("aaa"w);
	assert(a[1] == Value("a"w));
	//Valueにはconstやimmutableな値は代入できない
	Value b = a;

	a[1] = Value("bbb"w);
	assert(a == Value("abbba"w));

	assert(b == Value("abbba"w));
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