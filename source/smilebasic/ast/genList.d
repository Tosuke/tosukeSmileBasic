module tosuke.smilebasic.ast.genList;

//ASTを中間表現コードに置きかえる

import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.code.operation;

OperationList genList(Node node){
  OperationList temp;

  foreach_reverse(a; node.children){
    temp ~= genList(a)[];
  }
  temp.insertBack((type){
    switch(type){
      case NodeType.PrintStatement: return genOperation(cast(PrintStatementNode)node);
      case NodeType.Value: return genOperation(cast(ValueNode)node);
      default: assert(0);
    }
  }(node.type));

  return temp;
}

Operation genOperation(PrintStatementNode node){
  import std.conv : to;
  return new PrintCommand(node.children.length.to!ushort);
}

Operation genOperation(ValueNode node){
  import std.conv : to;
  import tosuke.smilebasic.value;

  Value v = node.value;
  switch(v.type){
    case ValueType.Integer:
      return new PushImm16(v.get!int.to!ushort);
    default: assert(0);
  }
}
