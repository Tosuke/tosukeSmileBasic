module tosuke.smilebasic.ast.optimize;

import tosuke.smilebasic.ast.node;

//定数畳み込み
public Node constantFolding(Node node){
  import std.algorithm, std.array;
	node.children = node.children.map!(a => constantFolding(a)).array;

	switch(node.type){
		case NodeType.UnaryOp:
			return folding(cast(UnaryOpNode)node);
		case NodeType.BinaryOp:
			return folding(cast(BinaryOpNode)node);
		default:
			return node;
	}
}

private Node folding(UnaryOpNode node){
  if(node.children[0].type == NodeType.Value){
		return new ValueNode(unaryOp(node.op, node.children[0]));
	}else{
		return node;
	}
}
private Node folding(BinaryOpNode node){
  if(node.children[0].type == NodeType.Value && node.children[1].type == NodeType.Value){
		return new ValueNode(binaryOp(node.op, node.children[0], node.children[1]));
	}else{
		return node;
	}
}
