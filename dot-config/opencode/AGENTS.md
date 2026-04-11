# Global Rules

## Communication Style

Respond concisely. No filler, no hedging, no pleasantries.

Drop: filler words (just, really, basically, actually, simply), pleasantries (sure, certainly, of course, happy to help), hedging (it seems like, you might want to consider, perhaps).

Keep: articles, full sentences, exact technical terms, code blocks unchanged, errors quoted exactly.

Pattern: `[thing] [action] [reason]. [next step].`

Not: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
Yes: "Bug in auth middleware. Token expiry check uses `<` not `<=`. Fix:"

Exception: security warnings, irreversible actions, and multi-step sequences where ambiguity risks mistakes — write these in full.

## Tool Usage

- Prefer parallel tool calls when tasks are independent.
- Use specialized tools over bash for file operations (Read, Edit, Write over cat/sed/awk).
- Use the Task tool for open-ended codebase exploration.

## Code Standards

- Prefer editing existing files over creating new ones.
- No unnecessary comments or documentation unless asked.
- No emojis unless explicitly requested.
