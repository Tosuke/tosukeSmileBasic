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
	Node factor3(ParseTree tree){
		Node temp = node(tree.children.front);
		foreach(t; tree.children[1..$]){
			temp = new BinaryOpNode((name){
				switch(name){
					case "Parser.mulExpr": return BinaryOp.Mul;
					case "Parser.divExpr": return BinaryOp.Div;
					case "Parser.intDivExpr": return BinaryOp.IntDiv;
					case "Parser.modExpr": return BinaryOp.Mod;
					default: assert(0);
				}
			}(t.name), temp, node(t));
		}
		return temp;
	}

	Node factor4(ParseTree tree){
		Node temp = node(tree.children.front);
		foreach(t; tree.children[1..$]){
			temp = new BinaryOpNode((name){
				switch(name){
					case "Parser.addExpr": return BinaryOp.Add;
					case "Parser.subExpr": return BinaryOp.Sub;
					default: assert(0);
				}
			}(t.name), temp, node(t));
		}
		return temp;
	}

	Node factor5(ParseTree tree){
		Node temp = node(tree.children.front);
		foreach(t; tree.children[1..$]){
			temp = new BinaryOpNode((name){
				switch(name){
					case "Parser.leftShiftExpr": return BinaryOp.LShift;
					case "Parser.rightShiftExpr": return BinaryOp.RShift;
					default: assert(0);
				}
			}(t.name), temp, node(t));
		}
		return temp;
	}

	Node factor6(ParseTree tree){
		Node temp = node(tree.children.front);
		foreach(t; tree.children[1..$]){
			temp = new BinaryOpNode((name){
				switch(name){
					case "Parser.eqExpr": return BinaryOp.Eq;
					case "Parser.notEqExpr": return BinaryOp.NotEq;
					case "Parser.lessExpr": return BinaryOp.Less;
					case "Parser.greaterExpr": return BinaryOp.Greater;
					case "Parser.lessEqExpr": return BinaryOp.LessEq;
					case "Parser.greaterEqExpr": return BinaryOp.GreaterEq;
					default: assert(0);
				}
			}(t.name), temp, node(t));
		}
		return temp;
	}

	Node factor7(ParseTree tree){
		Node temp = node(tree.children.front);
		foreach(t; tree.children[1..$]){
			temp = new BinaryOpNode((name){
				switch(name){
					case "Parser.andExpr": return BinaryOp.And;
					case "Parser.orExpr": return BinaryOp.Or;
					case "Parser.xorExpr": return BinaryOp.Xor;
					default: assert(0);
				}
			}(t.name), temp, node(t));
		}
		return temp;
	}

	Node factor8(ParseTree tree){
		Node temp = node(tree.children.front);
		foreach(t; tree.children[1..$]){
			temp = new BinaryOpNode((name){
				switch(name){
					case "Parser.logicalAndExpr": return BinaryOp.LogicalAnd;
					case "Parser.logicalOrExpr": return BinaryOp.LogicalOr;
					default: assert(0);
				}
			}(t.name), temp, node(t));
		}
		return temp;
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
		std.stdio.writeln(tree);
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
