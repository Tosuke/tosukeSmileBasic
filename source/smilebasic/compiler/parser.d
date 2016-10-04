module tosuke.smilebasic.compiler.parser;

import tosuke.smilebasic.compiler;

import tosuke.smilebasic.value;
import tosuke.smilebasic.operator;
import tosuke.smilebasic.error;

import pegged.grammar;
import std.experimental.logger;
import std.algorithm, std.array;
import std.string;
import std.conv : to;

///パーサ
class Parser{
	
	///初期化
	this(){
		initialize();
	}

	private{
		//Document
		Node line(ParseTree tree){
			return new DocumentNode(tree.children.map!(a => node(a)).array);
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
			auto k = tree.matches.front.to!double;
			Value v;
			if(k > int.max){
				v = k;
			}else{
				v = k.to!int;
			}
			return new ValueNode(v);
		}
		Node decimalFloater(ParseTree tree){
			auto k = tree.matches.front.to!double;
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
			return new ValueNode(tree.matches.front.to!wstring[1..$]);
		}

		Node commandStatement(ParseTree tree){
			immutable name = tree.children[0].matches.front.to!wstring.toLower;
			switch(name){
				case "print"w, "?"w:
					return print(tree.children[1..$]);
				default:
					throw new SyntaxError("Unrecognized syntax");
			}
		}

		Node print(ParseTree[] trees){
			Node[] temp =  trees
										.filter!(a => !(a.name == "Parser.commandDelimiter" && a.matches.front == ";"))
										.map!(a => a.name != "Parser.commandDelimiter" ? node(a) : new ValueNode("\t"w))
										.array;
			if(trees.length == 0 || trees[$-1].name != "Parser.commandDelimiter"){
				temp ~= new ValueNode("\n"w);
			}
			return new PrintStatementNode(temp);
		}
	}
	
	mixin ParserMixin!("Parser");
	mixin(import("grammar.d"));
}

import pegged.grammar;

///パーサのユーティリテイの実装
private mixin template ParserMixin(string parserName){

	///パースしてASTを返す
	Node parse(string source){
		auto tree = mixin(parserName~"(source)");
		version(none) std.stdio.writeln(tree);
		Node n;
		try{
			n = node(tree);
		}catch(SmileBasicError e){
			e.slot = 0;
			throw e;
		}
		return n;
	}

	///ParseTreeからNodeを得る
	Node node(ParseTree tree){
    if(!tree.successful){
			immutable t = position(tree);
			int line = t.line.to!int + 1;
			int col = t.col.to!int + 1;
			auto e = new SyntaxError("Unrecognized syntax");
			e.line = line; e.col = col;
			throw e;
		}
		return converters.get(tree.name, &skip)(tree);
	}

	///ParseTreeを処理する関数が見つからなかったときに処理をスキップする
	Node skip(ParseTree tree){
		//("skip "~tree.name).log;
		return node(tree.children.front);
	}

	///ParseTreeをNodeに変換する関数群
	alias Converter = Node delegate(ParseTree);
	Converter[string] converters;

	import std.meta, std.traits;
	void initialize(){
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
			import std.format : format;
			s ~= format(q{converters["%s.%s"] = &%s;}, parserName, a, a);
		}
		return s;
	}
}
