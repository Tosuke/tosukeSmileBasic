module tosuke.smilebasic.compiler.astoptimize;

import tosuke.smilebasic.compiler;
import tosuke.smilebasic.error;
import tosuke.smilebasic.value;

import std.conv : to;

///定数畳み込みをする
public Node constantFolding(Node node){
  import std.algorithm, std.array;
  node.children = node.children.map!(a => constantFolding(a)).array;

  try{
    switch(node.type){
      case NodeType.UnaryOp:
        return folding(cast(UnaryOpNode)node);
      case NodeType.BinaryOp:
        return folding(cast(BinaryOpNode)node);
      default:
        return node;
    }
  }catch(SmileBasicError e){
    e.line = node.line;
    throw e;
  }
}

private Node folding(UnaryOpNode node){
  if( node.children[0].type == NodeType.Value &&
      node.children[0].to!ValueNode.value.isArithmeticValue){
    
    return new ValueNode(unaryOp(node.op, node.children[0]));
	}else{
		return node;
	}
}
private Node folding(BinaryOpNode node){
  if((node.children[0].type == NodeType.Value && node.children[1].type == NodeType.Value) &&
     (node.children[0].to!ValueNode.value.isArithmeticValue && node.children[1].to!ValueNode.value.isArithmeticValue)){
		return new ValueNode(binaryOp(node.op, node.children[0], node.children[1]));
	}else{
		return node;
	}
}
