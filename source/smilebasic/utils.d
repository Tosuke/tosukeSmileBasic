module tosuke.smilebasic.utils;

import std.experimental.logger;

struct Stack(T){
  private T[] data;
  private int ptr;

  void push(T a){
    if(ptr + 1 >= data.length){
      data.length = (data.length + 1) * 2;
    }
    data[++ptr] = a;
  }
  T pop(){
    if(ptr == 0) assert(0);
    return data[ptr--];
  }
}
