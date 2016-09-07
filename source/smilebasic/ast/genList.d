module tosuke.smilebasic.ast.genList;

//ASTを中間表現コードに置きかえる

import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.code.operation;
import std.conv : to;

OperationList genList(Node node){
  OperationList temp;

  foreach_reverse(a; node.children){
    temp ~= genList(a)[];
  }
  temp.insertBack((type){
    switch(type){
      case NodeType.PrintStatement: return genOperation(cast(PrintStatementNode)node);
      case NodeType.Value: return genOperation(cast(ValueNode)node);
      case NodeType.UnaryOp: return genOperation(cast(UnaryOpNode)node);
      case NodeType.BinaryOp: return genOperation(cast(BinaryOpNode)node);
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
      auto k = v.get!int;
      if(short.min <= k && k <= short.max){
        return new PushImm16(k.to!short);
      }else{
        return new PushImm32(k);
      }
    case ValueType.Floater:
      return new PushImm64f(v.get!double);
    case ValueType.String:
      return new PushString(v.get!wstring);
    default: assert(0);
  }
}

Operation genOperation(UnaryOpNode node){
  return new UnaryOpCommand(node.op);
}

Operation genOperation(BinaryOpNode node){
  return new BinaryOpCommand(node.op);
}
