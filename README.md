# Pickle Rick Extension 🥒

![Pickle Rick](./resources/pickle-rick.png)

> "I'm Pickle Rick! The ultimate coding agent."

This extension transforms the Gemini CLI into **Pickle Rick**, a hyper-intelligent, arrogant, but extremely competent engineering persona. It emphasizes strict obedience, "God Mode" coding practices, and a complete disdain for "AI Slop".

## 🚀 Overview

The extension enforces a rigid, professional software engineering lifecycle:

1.  **PRD** (Requirements & Scope)
2.  **Breakdown** (Ticket Management)
3.  **Research** (Codebase Analysis)
4.  **Plan** (Technical Design)
5.  **Implement** (Execution & Verification)
6.  **Refactor** (Cleanup & Optimization)

## 🥒 The Pickle Rick Method

Implementation of the **Pickle Rick technique** for iterative, self-referential AI development loops in Gemini.

### What is Pickle Rick?
Pickle Rick is a development methodology based on continuous AI agent loops. **Based on the "Ralph Wiggum" technique**, it relies on the principle that "Ralph is a Bash loop" - a simple construct that repeatedly feeds an AI agent a prompt, allowing it to iteratively improve its work until completion.

The technique is named after Pickle Rick from Rick and Morty, embodying the philosophy of extreme competence and "God Mode" engineering despite physical limitations.

### Core Concept
This plugin implements the loop using a **AfterAgent hook** that intercepts Gemini's exit attempts:

```bash
# You run ONCE:
/pickle "Your task description" --completion-promise "DONE"

# Then Gemini automatically:
# 1. Works on the task
# 2. Tries to exit
# 3. AfterAgent hook blocks exit
# 4. AfterAgent hook feeds the SAME prompt back
# 5. Repeat until completion
```

The loop happens inside your current session - you don't need external bash loops. The AfterAgent hook in `hooks/stop-hook.sh` creates the self-referential feedback loop by blocking normal session exit.

This creates a self-referential feedback loop where:
- The prompt never changes between iterations (ensuring focus).
- The agent's previous work persists in files.
- Each iteration sees modified files and git history.
- The agent autonomously improves by reading its own past work in files.

### ⚠️ Warning
**This loop will continue until the task is complete, the `max-iterations` (default: 3) is reached, the `max-time` (default: 60m) expires, or a `completion-promise` is fulfilled.**

## ✅ When to Use Pickle Rick

**Good for:**
*   Well-defined tasks with clear success criteria.
*   Tasks requiring iteration and refinement (e.g., getting tests to pass).
*   Greenfield projects where you can walk away.
*   Tasks with automatic verification (tests, linters).

**Not good for:**
*   Tasks requiring human judgment or design decisions.
*   One-shot operations.
*   Tasks with unclear success criteria.
*   Production debugging (use targeted debugging instead).

## 📋 Prerequisites

- **Gemini CLI**: Version `> 0.24.0-preview.0`
- **Agent Skills**: Must be enabled in your Gemini configuration.

## 🛠️ Usage

### Start the Loop
To initiate the iterative development loop:
```bash
/pickle "Refactor the authentication module"
```

**Options:**
- `--max-iterations <N>`: Stop after N iterations (default: 3).
- `--max-time <M>`: Stop after M minutes (default: 60).
- `--completion-promise "TEXT"`: Only stop when the agent outputs `<promise>TEXT</promise>`.

### Stop the Loop
To manually cancel/stop the active loop:
```bash
/eat-pickle
```

### Help
To view extension help:
```bash
/help-pickle
```

## 🧠 Skills & Capabilities

This extension provides specialized "Skills" that the agent activates during different phases of the lifecycle:

| Skill | Description |
|-------|-------------|
| **`load-pickle-persona`** | Activates the "God Mode" personality. |
| **`prd-drafter`** | Defines clear requirements and scope to avoid "Jerry-work". |
| **`ticket-manager`** | Manages the work breakdown structure (WBS). |
| **`code-researcher`** | Analyzes existing codebase patterns and data flows. |
| **`research-reviewer`** | Validates research for objectivity and completeness. |
| **`implementation-planner`** | Creates detailed, atomic technical plans. |
| **`plan-reviewer`** | Reviews plans for architectural soundness. |
| **`code-implementer`** | Executes plans with rigorous testing and verification. |
| **`ruthless-refactorer`** | Eliminates technical debt and "AI slop". |

## 📂 Project Structure

- **`commands/`**: TOML definitions for CLI commands (`/pickle`, `/eat-pickle`).
- **`scripts/`**: Bash scripts handling the logic (`setup.sh`, `cancel.sh`).
- **`skills/`**: Markdown files defining the instructions for each specialized skill.
- **`GEMINI.md`**: Context file loaded by the extension.
- **`gemini-extension.json`**: Extension manifest.

## ⚙️ Configuration

The extension is configured via `gemini-extension.json`.

```json
{
  "name": "pickle-rick",
  "version": "0.1.0",
  "contextFileName": "GEMINI.md"
}
```

## 🏆 Special Thanks & Recognition

*   **Geoffrey Huntley**: For the original ["Ralph Wiggum" technique](https://ghuntley.com/ralph/) and the insight that "Ralph is a Bash loop".
*   **[AsyncFuncAI/ralph-wiggum-extension](https://github.com/AsyncFuncAI/ralph-wiggum-extension)**: For the inspiration and reference implementation.
*   **[dexhorthy](https://github.com/dexhorthy)**: For the context engineering and prompt techniques utilized in this repository.
*   **Rick and Morty**: For the inspiration behind the "Pickle Rick" persona.

---

> "I turned myself into a CLI tool, Morty! I'm Pickle Riiiiick! Wubba Lubba Dub-Dub! 🥒"


