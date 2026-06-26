# 🧮 x86 Assembly Calculator (8086 / DOSBox)
 
A fully functional multi-operation calculator built in **8086 Assembly Language**, designed to run in **DOSBox** (or any real-mode x86 environment). Performs integer arithmetic using low-level register operations, INT 21h DOS services, and ASCII conversion routines — no high-level language, no libraries, just pure assembly.
 
---
 
## 📸 Preview
 
```
╔══════════════════════════════╗
║   x86 ASSEMBLY CALCULATOR   ║
╠══════════════════════════════╣
║  Enter first number:  45    ║
║  Enter second number: 7     ║
║                              ║
║  1. Addition     (+)         ║
║  2. Subtraction  (-)         ║
║  3. Multiplication (*)       ║
║  4. Division     (/)         ║
║                              ║
║  Select operation: 3         ║
║  Result: 315                 ║
╚══════════════════════════════╝
```
 
---
 
## ✨ Features
 
- **Four arithmetic operations** — Addition, Subtraction, Multiplication, Division
- **Multi-digit input handling** — reads full numbers from stdin using INT 21h, not just single characters
- **ASCII ↔ integer conversion** — manual conversion routines (no C library, no OS help)
- **Division remainder display** — shows both quotient and remainder for division operations
- **Looping menu** — returns to the main menu after each operation; exit option included
- **Register-efficient design** — makes full use of AX, BX, CX, DX with clear conventions
- **Stack discipline** — proper PUSH/POP usage for procedure calls and register preservation
- **String output via INT 21h** — uses DOS Function 09h for all display output
 
---
 
## 🛠️ Tech Stack
 
| Component | Details |
|-----------|---------|
| Architecture | Intel 8086 (16-bit Real Mode) |
| Assembler | MASM / TASM (compatible with both) |
| Runtime | DOSBox 0.74+ |
| Addressing | Segmented memory model (CS, DS, SS) |
| I/O | INT 21h (DOS Services) |
| Number Format | Unsigned integers (2-digit to 5-digit range) |
 
---
 
## 📁 Project Structure
 
```
x86-assembly-calculator/
│
├── calculator.asm        # Main source file — all logic in one file
├── calculator.exe        # Compiled executable (run in DOSBox)
├── README.md             # This file
└── docs/
    └── viva_notes.md     # Explanation of key concepts (optional)
```
 
---
 
## 🚀 Getting Started
 
### Prerequisites
 
- [DOSBox](https://www.dosbox.com/) installed on your machine
- MASM (Microsoft Macro Assembler) **or** TASM (Turbo Assembler)
 
### Step 1 — Mount your project folder in DOSBox
 
```dosbox
mount c C:\path\to\x86-assembly-calculator
c:
```
 
### Step 2 — Assemble the source file
 
**With MASM:**
```dosbox
masm calculator.asm
link calculator.obj
```
 
**With TASM:**
```dosbox
tasm calculator.asm
tlink calculator.obj
```
 
### Step 3 — Run the calculator
 
```dosbox
calculator.exe
```
 
---
 
## ⚙️ How It Works
 
### Memory Model
 
The program uses the **8086 segmented memory model**:
- `CS` (Code Segment) — holds all program instructions
- `DS` (Data Segment) — holds strings, prompts, and result buffers
- `SS` (Stack Segment) — used for procedure calls and register preservation
 
### Input Handling
 
User input is read character-by-character using **INT 21h Function 01h**, then assembled into a 16-bit integer by repeatedly multiplying the running total by 10 and adding the new digit:
 
```asm
; ASCII digit → integer conversion
sub al, '0'       ; strip ASCII offset (e.g. '5' = 53 → 5)
mov bl, 10
mul bl            ; AX = AX * 10
add ax, cx        ; add new digit
```
 
### Arithmetic Operations
 
| Operation | Instruction Used | Notes |
|-----------|-----------------|-------|
| Addition | `ADD AX, BX` | Result in AX |
| Subtraction | `SUB AX, BX` | Result in AX |
| Multiplication | `MUL BX` | Result in DX:AX (high:low) |
| Division | `DIV BX` | Quotient in AX, Remainder in DX |
 
### Output (Integer → ASCII)
 
Converting a result back to printable digits uses repeated division by 10, pushing remainders onto the stack, then popping them in order (reversing the digit sequence):
 
```asm
; integer → ASCII string (result display)
mov cx, 0
divide_loop:
    xor dx, dx
    div bx           ; AX / 10, remainder in DX
    push dx          ; push digit (will pop in reverse = correct order)
    inc cx
    test ax, ax
    jnz divide_loop
print_loop:
    pop dx
    add dl, '0'      ; integer digit → ASCII character
    mov ah, 02h
    int 21h          ; print character
    loop print_loop
```
 
### Program Flow
 
```
START
  │
  ▼
Display Menu
  │
  ▼
Read Number 1 ──→ ASCII-to-int conversion
  │
  ▼
Read Number 2 ──→ ASCII-to-int conversion
  │
  ▼
Read Operation Choice
  │
  ├──→ 1: ADD  ──→ Display Result ──┐
  ├──→ 2: SUB  ──→ Display Result ──┤
  ├──→ 3: MUL  ──→ Display Result ──┤
  ├──→ 4: DIV  ──→ Display Result ──┤
  └──→ 5: EXIT ──→ INT 21h AH=4Ch   │
                                     │
  ◄──────────────────────────────────┘
  (loop back to menu)
```
 
---
 
## 📖 Key Concepts Demonstrated
 
- **INT 21h DOS services** — character I/O (01h, 02h, 09h), program exit (4Ch)
- **Register architecture** — AX/BX/CX/DX as accumulators, base, count, and data registers
- **Stack operations** — PUSH/POP for preserving registers across procedure calls
- **String instructions** — using DX:offset for `INT 21h` string display
- **Conditional jumps** — `JE`, `JNZ`, `JMP` for control flow and loop logic
- **MUL / DIV behavior** — understanding the implicit DX:AX operand for 16-bit operations
- **Segment registers** — CS, DS, SS roles and why `.MODEL SMALL` is used
 
---
 
## ⚠️ Limitations
 
- **Integers only** — no floating point support (8086 FPU requires the 8087 co-processor)
- **Unsigned arithmetic** — negative number handling is not implemented
- **Overflow** — multiplication results exceeding 16 bits (> 65535) are not checked
- **Division by zero** — not guarded; will cause a DOS crash (future improvement)
- **Input range** — designed for numbers up to 4 digits; very large inputs may overflow AX
 
---
 
## 🔮 Possible Improvements
 
- [ ] Add signed integer support (handle negative inputs with `-` prefix)
- [ ] Add division-by-zero guard using `CMP BX, 0` before `DIV`
- [ ] Add overflow detection for multiplication (check DX ≠ 0 after `MUL`)
- [ ] Support multi-digit output for full 32-bit multiplication results (DX:AX)
- [ ] Add modulo as a separate operation
- [ ] Add a basic expression evaluator (e.g. `12 + 45 * 2`)
 
---
 
## 📚 References
 
- Intel. *8086 Family User's Manual*, 1979
- Peter Norton & John Socha. *Peter Norton's Assembly Language Book for the IBM PC*
- [MASM32 SDK Documentation](http://www.masm32.com/)
- [DOSBox Official Site](https://www.dosbox.com/)
- [x86 Instruction Reference — Felixcloutier](https://www.felixcloutier.com/x86/)
 
---
 
## 👤 Author
 
**[Karan Kumar]**
BS Computer Science — AI Specialization
[GitHub](https://github.com/karanahujakumar-a11y/3) · [LinkedIn](https://www.linkedin.com/in/karan-kumardev/)
 
---
 
## 📄 License
 
This project is open source under the [MIT License](LICENSE).
 
---
 
> *"Any sufficiently low-level code is indistinguishable from magic."*  
> Built with 💻 and a lot of DOSBox restarts.
