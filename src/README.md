### Building

The following steps can be used to **build** and **run** the individual modules.

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