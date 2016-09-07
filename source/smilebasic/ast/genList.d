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
  temp ~= node.operation;

  return temp;
}
