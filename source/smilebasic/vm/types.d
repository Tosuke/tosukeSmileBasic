module tosuke.smilebasic.vm.types;

//型定義集

///VM上の位置を記録する型
struct Pointer{
  ///スロット
  int slot;
  ///プログラムカウンタ
  uint count; 
}