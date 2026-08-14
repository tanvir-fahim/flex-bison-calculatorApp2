# 🧮 Flex & Bison Web-Based Calculator Compiler

A full-stack, browser-based scientific calculator powered by a custom compiler backend written in **Flex** (Lexical Analyzer) and **Bison** (Parser/Yacc), served via a lightweight **Python** HTTP server.

🌐 **Live Demo:** [https://flex-bison-calculatorapp.onrender.com/](https://flex-bison-calculatorapp.onrender.com/)

---

## ✨ Features

- **Custom Compiler Backend:** Uses Flex for tokenization and Bison for syntax analysis and mathematical expression evaluation.
- **Rich Operator Support:** Supports basic arithmetic, trigonometric functions (`sin`, `cos`, `tan`, `asin`, etc.), logarithmic functions (`log`, `ln`), square roots, exponents (`^`), factorials (`!`), modulo (`%`), and mathematical constants (`pi`, `e`).
- **Modern Web Interface:** Dark-mode code editor with responsive toolbar controls and execution status output logs.
- **Cross-Platform Auto-Build:** Automagically detects OS environment (Windows/macOS/Linux) and compiles Flex/Bison sources automatically on server launch.
- **Zero Heavy Dependencies:** Built using Python's standard library (`http.server`) and vanilla HTML/CSS/JS.

---

## 📁 Project Architecture

```Calculator
├── cal.l          # Flex lexical analyzer rules
├── cal.y          # Bison grammar rules & AST evaluation
├── server.py      # Python HTTP backend (compiles C code & handles API requests)
├── index.html     
├── style.css      
├── script.js      
├── Makefile       # Manual CLI build configuration
├── Dockerfile     
└── .gitignore     
