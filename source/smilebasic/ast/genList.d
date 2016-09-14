module tosuke.smilebasic.ast.genList;

//ASTを中間表現コードに置きかえる

import tosuke.smilebasic.ast.node;
import tosuke.smilebasic.code.operation;
import std.conv : to;

OperationList genList(Node node){
  OperationList temp;

  switch(node.type){
    case NodeType.Document:
      temp ~= node.operation;
      foreach(a; node.children){
        temp ~= genList(a)[];
      }
      break;
    default:
      foreach_reverse(a; node.children){
        temp ~= genList(a)[];
      }
      temp ~= node.operation;
      break;
  }


  return temp;
}
