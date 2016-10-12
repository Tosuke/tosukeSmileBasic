module tosuke.smilebasic.compiler.genlist;

import tosuke.smilebasic.compiler;
import std.conv : to;

///ASTから中間表現コードを生成する
OperationList genList(Node node){
  OperationList temp;

  final switch(node.type){
    case NodeType.Forward:
      temp ~= (a){
        a.line = node.line;
        return a;
      }(node.operation);
      
      foreach(a; node.children){
        temp ~= genList(a)[];
      }
      break;
      
    case NodeType.Reverse:
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
