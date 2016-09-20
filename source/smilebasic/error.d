module tosuke.smilebasic.error;

import tosuke.smilebasic.value;

import std.exception;
import std.string, std.format;
import std.conv : to;

abstract class SmileBasicError : Exception{
  public{
    int slot;
    int line;
    string error;
    string detail;
  }

  @property string msg(){
    return format("Line %d in slot%d %s%s", line, slot, error, detail.length != 0 ? ": "~detail : "");
  }

public:
  this(string _error, string _detail){
    error = _error;
    detail = _detail;
    super(error);
  }

  this(string _error){
    error = _error;
    super(error);
  }
}

class SyntaxError : SmileBasicError{
  public int col;

  this(){
    super("Syntax error");
  }
  this(string detail){
    super("Syntax error", detail);
  }

  @property override string msg(){
    return format("(%d:%d) in slot%d %s%s", line, col, slot, error, detail.length != 0 ? ": "~detail : "");
  }
}

class TypeMismatchError : SmileBasicError{
  this(){
    super("Type mismatch");
  }
  this(string detail){
    super("Type mismatch", detail);
  }
}
auto imcompatibleTypeError(string operator, Value a){
	return new TypeMismatchError(format("imcompatible type for '%s': '%s'", operator, a.type.toString));
}
auto imcompatibleTypeError(string operator, Value a, Value b){
	return new TypeMismatchError(format("imcompatible types for '%s': '%s' and '%s'", operator, a.type.toString, b.type.toString));
}
