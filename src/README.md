### Getting Started

The following steps can be used to **build** and **evaluate** llvm source files.

#### Run LLVM IR source using the Interpreter (lli)
```bash
lli <input>.ll
```

#### Compile LLVM IR to Object Code

```bash
llc -filetype=obj <input>.ll -o <output>.o
```

#### Link Object Code and Geneate Executable
```bash
gcc <output>.o -o <output> -no-pie
```

### Compiling and Linking the source files

* `basic_web_server.ll`

```bash
llc -filetype=obj ./src/basic_web_server.ll -o server.obj
```

```bash
gcc server.obj -o server.exe -lws2_32
```

