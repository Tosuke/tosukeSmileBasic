module tosuke.smilebasic.error;

import tosuke.smilebasic.value;

import std.exception;
import std.string, std.format;
import std.conv : to;

///エラー
abstract class SmileBasicError : Exception{
  public{
    ///エラーの発生したスロット
    int slot;
    ///エラーの発生した行
    int line;
    ///エラーの種別
    string error;
    ///エラーの詳細
    string detail;
  }

  ///エラーメッセージ
  @property string msg(){
    return format("%d : ? in slot%d %s%s", line, slot, error, detail.length != 0 ? ": "~detail : "");
  }

public:
  ///詳細を含んで発生させる
  this(string _error, string _detail){
    error = _error;
    detail = _detail;
    super(error);
  }
  

  ///種別のみで発生させる
  this(string _error){
    error = _error;
    super(error);
  }
}


/**
* 文法に関するエラー
*
* コンパイル時に発生する
**/
class SyntaxError : SmileBasicError{
  ///エラー発生位置
  public int col;

  ///詳細を含まず発生させる
  this(){
    super("Syntax error");
  }


  ///詳細を含んで発生させる
  this(string detail){
    super("Syntax error", detail);
  }


  @property override string msg(){
    return format("%d : %d in slot%d %s%s", line, col, slot, error, detail.length != 0 ? ": "~detail : "");
  }
}


///型が期待するものと異なることにより発生するエラー
class TypeMismatchError : SmileBasicError{
  
  ///詳細を含まず発生させる
  this(){
    super("Type mismatch");
  }


  ///詳細を含んで発生させる
  this(string detail){
    super("Type mismatch", detail);
  }
}


///演算子の型が異なっているときにTypeMismatchErrorを生成する
auto imcompatibleTypeError(string operator, Value a){
	return new TypeMismatchError(format("imcompatible type for '%s': '%s'", operator, a.type.toString));
}


///ditto
auto imcompatibleTypeError(string operator, Value a, Value b){
	return new TypeMismatchError(
    format("imcompatible types for '%s': '%s' and '%s'", operator, a.type.toString, b.type.toString)
  );
}


///代入式の型が異なっているときにTypeMismatchErrorを生成する
auto failedToConvertTypeError(Value a, Value b){
  return new TypeMismatchError(
    format("failed to convert types '%s' to '%s'", b.type.toString, a.type.toString)
  );
}


///指定された型が配列として使えない
auto cannotUseAsArrayError(Value a){
  return new TypeMismatchError(
    format("cannot use a type '%s' as array", a.type.toString)
  );
}

///シンボル衝突エラー
abstract class DuplicateSymbolError : SmileBasicError{
  ///詳細を含まず発生させる
  this(string error){
    super(error);
  }

  ///詳細を含んで発生させる
  this(string error, string detail){
    super(error, detail);
  }
} 


///変数定義の衝突
class DuplicateVariableError : DuplicateSymbolError{

  ///詳細を含まず発生させる
  this(){
    super("Duplicate variable");
  }

  ///詳細を含んで発生させる
  this(string detail){
    super("Duplicate variable", detail);
  }
}


///範囲外の数値が指定された
class OutOfRangeError : SmileBasicError{

  ///詳細を含まず発生させる
  this(){
    super("Out of range");
  }

  ///詳細を含んで発生させる
  this(string detail){
    super("Out of range", detail);
  }
}


///インデックス数が合わない
auto illegalIndexError(int num){
  return new OutOfRangeError(
    format("only %d index allowed", num)
  );
}


///インデックスの大きさが合わない
auto invalidIndexError(){
  return new OutOfRangeError("invalid index");
}


///内部エラー
class InternalError : Exception{

  ///コンストラクタ
  this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null){
    super("Internal Error: "~msg, file, line, next);
  }
}
