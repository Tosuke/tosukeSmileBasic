module tosuke.smilebasic.utils;

import std.experimental.logger;


///スタックの実装
struct Stack(T){
  private T[] data;
  private int ptr;


  ///Pushする
  void push(T a){
    if(ptr + 1 >= data.length){
      data.length = (data.length + 1) * 2;
    }
    data[++ptr] = a;
  }

  ///スタックの最上をPushする
  void dup(){
    push(this.front);
  }

  ///Popする
  T pop(){
    if(ptr == 0) assert(0);
    return data[ptr--];
  }

  ///スタックの最上
  @property T front(){
    return data[ptr];
  }
}
