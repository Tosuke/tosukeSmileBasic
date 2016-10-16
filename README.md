# tosukeSmileBasic
SmileBASIC v3.x Compatible BASIC

## How to install
```sh
git clone git@github.com:Tosuke/tosukeSmileBasic.git / git clone https://github.com/Tosuke/tosukeSmileBasic.git
cd tosukeSmileBasic
dub build -c update
```

## How to build
```sh
dub build
```
When source/grammar/grammar.peg is updated, use instead of this,
```sh
dub build -c update
```

## How to run
```sh
dub run
```
or
```sh
cd bin
./tosukeSmileBasic
```

## Dependency : build
+ D compiler(Recommended : dmd or ldc)
+ dub
