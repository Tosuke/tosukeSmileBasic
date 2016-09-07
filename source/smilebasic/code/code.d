module tosuke.smilebasic.code.code;

/*
#バイトコード表
0xnnnx
x<-命令種別
0b0000|Command
0b0001|Push

##Command
0bnxx0
xx<-種別
0x00|UnaryOperator
0x01|BinaryOparator
0x02|IndexOperator(1)
0x03|IndexOperator(2)
0x04|IndexOperator(3)
0x05|IndexOperator(4)
0x06|Call Function(Common)
0x07|Call Function(Local)
0x08|Call command statement
0x09|def start(ローカル変数の確保)
0x0A|def end(ローカル変数の開放)
0x0B|return
0x10|goto
0x11|gosub
0x12|if goto
0x13|if gosub
0x14|on goto
0x15|on gosub
0x16|string goto
0x17|string gosub

###Call command statement
0xm080 CallCmd imm16(argument num)
m<-種別
0x0|Print

## Push
0x00x1
x<-種別
0x0|imm16
0x1|imm32
0x2|imm64f
0x3|string

### Push string
0x0031 PushStr length(imm16) wchar...
*/
alias VMCode = ushort;
