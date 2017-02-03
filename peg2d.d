/+ dub.json:
{
  "name":"peg2d",
  "dependencies":{
    "pegged":"*"
  }
}
+/

import std.stdio;
import std.file;
import std.getopt;
import pegged.grammar;

void main(string[] args) {
  string source = "";
  string dest = "";

  const info = getopt(args, "source", &source, "dest", &dest);

  if (info.helpWanted || source == "" || dest == "") {
    "HINT:--source (source.peg) --dest (dest.d)".writeln;
    return;
  }

  std.file.write(dest, grammar!(Memoization.yes)(readText(source)));
}
