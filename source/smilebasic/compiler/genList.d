module tosuke.smilebasic.compiler.genlist;

//ASTを中間表現コードに置きかえる

import tosuke.smilebasic.compiler;
import std.conv : to;

OperationList genList(Node node){
  OperationList temp;

  switch(node.type){
    case NodeType.Document, NodeType.Line:
      temp ~= (a){
        a.line = node.line;
        return a;
      }(node.operation);
      
      foreach(a; node.children){
        temp ~= genList(a)[];
      }
      break;
    default:
      foreach_reverse(a; node.children){
        temp ~= genList(a)[];
      }

      temp ~= (a){
        a.line = node.line;
        return a;
      }(node.operation);
      break;
  }


  return temp;
}
