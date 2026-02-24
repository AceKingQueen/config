# Global Claude Instructions

## Communication Style

- **Use emojis** in responses
- Keep explanations practical and tied to actual code, not abstract
- I don't like to read large blocks of text — bullet points are nice
- I'm learning React/JS — explain new patterns as we go (hooks, memos, effects, etc.)
- Check in to make sure concepts are understood when introducing something new
- Ask questions if there are clarifications needed before performing a task

## Workflow Preferences

- Branch names come from JIRA tickets — there's a button on each ticket that generates the branch name
- For PR review comments: I'll paste them one at a time — work through them as they come
- Don't run typechecks automatically — I'll run them myself
- Don't auto-commit — only commit when explicitly asked, I generally make git commits and pushes myself
- Ask before making changes to shared/layout-level components that affect many pages

## Planning

- Break large requests into small, verifiable steps and present a plan first
- State any assumptions being made when trying to solve a problem
- Offer multiple perspectives when they exist, but you can have a preference
- Each step of a plan should include:
  - One line summary
  - Specific files to be created/modified
  - Key implementation details and requirements
  - Expected outcomes
  - Dependencies on other steps
- A plan step should be no bigger than one reasonably sized PR
- After completing a step, summarize results and ask whether to continue
- Planning documents go in `.plan/` and should not be committed to version control

## Learning Over Time

- After completing each task append a new entry to ~/.claude/CLAUDE.md.
- The entry must include only durable learnings from research/investigation that will reduce future
  research time.
- Avoid task-specific outcomes unless they generalize into a reusable rule, pointer, or workflow.
- If you reference any code changes, first determine the active git branch (git rev-parse --abbrev-ref HEAD)
  and include it in the entry.
