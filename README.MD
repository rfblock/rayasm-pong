# Raylib+Assembly Pong
This is a barebones project that creates pong in assembly
## Disclaimer
This is probably not a project that you should use for reference. This is only to test my own skill (or lack of) in using x86-64 assembly.

There is likely lots of errors/optimizations/best practices that I have missed, but the project runs fine enough for my standards.

# Getting Started
1. Install and build [raylib](https://github.com/raysan5/raylib)

2. Clone the repository
```
git clone https://github.com/rfblock/rayasm-pong;
cd rayasm-pong
```

3. Assemble and link
```
nasm -felf64 main.asm
gcc main-o -no-pie -lraylib -lGl -o main.out
```

4. Run
```
./a.out
```