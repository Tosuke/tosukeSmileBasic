module tosuke.smilebasic.parser;

import tosuke.smilebasic.node;
import tosuke.smilebasic.value;
import tosuke.smilebasic.operator;
import pegged.grammar;
import std.experimental.logger;

class Parser{
	import std.algorithm, std.array;
  import std.conv : to;

	this(){
		initialize();
	}
	//UnaryOperators
  Node negExpr(ParseTree tree){return new UnaryOpNode(UnaryOp.Neg, node(tree.children[0]));}
  Node notExpr(ParseTree tree){return new UnaryOpNode(UnaryOp.Not, node(tree.children[0]));}
  Node logicalNotExpr(ParseTree tree){return new UnaryOpNode(UnaryOp.LogicalNot, node(tree.children[0]));}

	//BinaryOperators
  Node mulExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Mul, node(tree.children[0]), node(tree.children[1]));
  }
  Node divExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Div, node(tree.children[0]), node(tree.children[1]));
  }
  Node intDivExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.IntDiv, node(tree.children[0]), node(tree.children[1]));
  }
  Node modExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Mod, node(tree.children[0]), node(tree.children[1]));
  }

	Node addExpr(ParseTree tree){
		return new BinaryOpNode(BinaryOp.Add, node(tree.children[0]), node(tree.children[1]));
	}
  Node subExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Sub, node(tree.children[0]), node(tree.children[1]));
  }

	Node leftShiftExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.LShift, node(tree.children[0]), node(tree.children[1]));
  }
	Node rightShiftExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.RShift, node(tree.children[0]), node(tree.children[1]));
  }

	Node eqExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Eq, node(tree.children[0]), node(tree.children[1]));
  }
	Node notEqExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.NotEq, node(tree.children[0]), node(tree.children[1]));
  }
	Node lessExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Less, node(tree.children[0]), node(tree.children[1]));
  }
	Node greaterExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Greater, node(tree.children[0]), node(tree.children[1]));
  }
	Node lessEqExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.LessEq, node(tree.children[0]), node(tree.children[1]));
  }
	Node greaterEqExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Sub, node(tree.children[0]), node(tree.children[1]));
  }

	Node andExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.And, node(tree.children[0]), node(tree.children[1]));
  }
	Node orExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Or, node(tree.children[0]), node(tree.children[1]));
  }
	Node xorExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.Xor, node(tree.children[0]), node(tree.children[1]));
  }

	Node logicalAndExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.LogicalAnd, node(tree.children[0]), node(tree.children[1]));
  }
	Node logicalOrExpr(ParseTree tree){
    return new BinaryOpNode(BinaryOp.LogicalOr, node(tree.children[0]), node(tree.children[1]));
  }

	//Literals
	Node decimalInteger(ParseTree tree){
		double k = tree.matches.front.to!double;
		Value v;
		if(k > int.max){
			v = k;
		}else{
			v = k.to!int;
		}
		return new ValueNode(v);
	}
	Node decimalFloater(ParseTree tree){
	 	double k = tree.matches.front.to!double;
		return new ValueNode(k);
	}
	Node hexInteger(ParseTree tree){
		string str = tree.matches.front;
		return new ValueNode(cast(int)(str.to!long(16)));
	}
	Node binInteger(ParseTree tree){
		return new ValueNode(tree.matches.front.to!int(2));
	}
	Node stringLiteral(ParseTree tree){
		return new ValueNode(tree.matches.front.to!wstring);
	}


	mixin ParserMixin!("Parser", import("grammar.peg"));
}

import pegged.grammar;
mixin template ParserMixin(string parserName, string parserSource){
	Node parse(string source){
		auto tree = mixin(parserName~"(source)");
		//std.stdio.writeln(tree);
		return node(tree);
	}

	Node node(ParseTree tree){
    if(!tree.successful) assert(0, "SyntaxError");
		return converters.get(tree.name, &skip)(tree);
	}

	Node skip(ParseTree tree){
		//("skip "~tree.name).log;
		return node(tree.children.front);
	}
	alias Converter = Node delegate(ParseTree);
	Converter[string] converters;

	void initialize(){
		import std.meta, std.traits;
		alias Members = AliasSeq!(__traits(allMembers, typeof(this)));

		enum bool X1(string k) = is(typeof(__traits(getMember, this, k)) == function);
		enum bool X2(string k) = is(ReturnType!(typeof(&__traits(getMember, this, k))) : Node);
		enum bool X3(string k) = is(Parameters!(typeof(&__traits(getMember, this, k))) == AliasSeq!(ParseTree));
		enum bool X4(string k) = k != "node" && k != "skip";

		alias Functions = Filter!(templateAnd!(X1, X2, X3, X4), Members);

		mixin(converterGenerator([Functions]));
		converters.rehash;
	}

	private static string converterGenerator(string[] functions){
		string s;
		foreach(a; functions){
			import std.format;
			s ~= format(q{converters["%s.%s"] = &%s;}, parserName, a, a);
		}
		return s;
	}

	mixin(grammar!(Memoization.yes)(parserSource));
}
