module tosuke.smilebasic.compiler.astoptimize;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;
import tosuke.smilebasic.value;

import std.conv : to;

///定数畳み込みをする
public Node constantFolding(Node node) {
  import std.algorithm : map;
  import std.array : array;

  node.children = node.children.map!(a => constantFolding(a)).array;

  try {
    if (cast(UnaryOpNode) node) {
      return folding(node.to!UnaryOpNode);
    }
    else if (cast(BinaryOpNode) node) {
      return folding(node.to!BinaryOpNode);
    }
    else {
      return node;
    }
  }
  catch (SmileBasicError e) {
    e.line = node.line;
    throw e;
  }
}

private Node folding(UnaryOpNode node) {
  if (cast(ValueNode)(node.children[0]) && node.children[0].to!ValueNode.value.isArithmeticValue) {

    return new ValueNode(unaryOp(node.op, node.children[0]));
  }
  else {
    return node;
  }
}

private Node folding(BinaryOpNode node) {
  if ((cast(ValueNode)(node.children[0]) && (cast(ValueNode)(node.children[1])))
      && (node.children[0].to!ValueNode.value.isArithmeticValue
        && node.children[1].to!ValueNode.value.isArithmeticValue)) {
    return new ValueNode(binaryOp(node.op, node.children[0], node.children[1]));
  }
  else {
    return node;
  }
}
