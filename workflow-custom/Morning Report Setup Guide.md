A weekday-morning Slack DM that pulls your active Jira sprint tickets, your open PRs (with approval counts + reviewer comments), and PRs you've reviewed that have new commits since your last review. Built on macOS launchd + headless Claude Code, so it runs locally with no remote agent, no PATs, and no admin-gated connectors.

> **Heads up:** this guide assumes a macOS workstation. The launchd part is Mac-specific; the rest (prompt + shell script) would work on Linux with `cron` instead.

---

## What you're building

```
┌──────────────────────────────────────────────────────────┐
│ macOS launchd  ← schedule (weekdays 9:30 AM)             │
│        │                                                 │
│        ▼                                                 │
│ run.sh  ← tiny wrapper                                   │
│        │                                                 │
│        ▼                                                 │
│ claude --print  ← headless Claude Code (work profile)    │
│        │                                                 │
│   reads prompt.md, then:                                 │
│        │                                                 │
│        ├──► Atlassian MCP  → fetch sprint tickets        │
│        ├──► gh CLI         → open PRs + reviews          │
│        ├──► gh CLI         → re-review detection         │
│        └──► Slack MCP      → send DM to you              │
└──────────────────────────────────────────────────────────┘
```

Mac asleep at 9:30? launchd fires the job when you wake the Mac. Mac asleep all day? Skipped, no harm.

---

## Prerequisites

Before running setup, you need these three things authenticated **on your local machine**:

### 1. `claude-work` profile (or any Claude Code profile)
If you don't already split work/personal Claude Code profiles, that's fine — you can adapt the script to use your default profile. The point is: you need a Claude Code installation logged in to your work claude.ai account.

### 2. `gh` CLI authed as your work GitHub user
```sh
gh auth status   # verify you're logged in
# if not:
gh auth login    # follow the browser flow
```

### 3. Two MCP connectors at https://claude.ai/customize/connectors
Both connect via OAuth — same flow. You should see a green **Connected** badge on each.

| Connector | Purpose |
|---|---|
| **Slack** (built-in) | Send the DM |
| **Atlassian MCP** (built-in) | Fetch Jira sprint tickets |

> **If `Add custom connector` is grayed out for you (admin-locked at your org)**, that's OK — both Slack and Atlassian are built-in claude.ai connectors and don't require admin approval to enable.

---

## Setup (the easy way: paste this prompt into Claude Code)

Open Claude Code in any directory. Paste the prompt below, **after replacing the four placeholders** at the top with your own values:

```
I want to set up an automated daily morning report that DMs me my Jira sprint tickets,
my open PRs (with approval/reviewer info), and PRs I've reviewed that have new commits.
It runs locally via launchd weekdays at 9:30 AM. Use my pre-existing local gh CLI auth
+ claude.ai Slack MCP + claude.ai Atlassian MCP — no PATs, no remote agents.

MY PERSONAL VALUES (replace these before running):
- Slack user ID (find via /mcp Slack tools or Slack profile → "Copy member ID"):
    SLACK_USER_ID = U0123ABCDEF
- GitHub username:
    GITHUB_USER = my-gh-handle
- GitHub repo (org/repo) to scope the report to:
    GH_REPO = my-org/my-repo
- Atlassian site (the X in X.atlassian.net):
    ATLASSIAN_SITE = my-company.atlassian.net
- Local launchd label (just a unique string, e.g. com.firstname.morning-report):
    LAUNCHD_LABEL = com.alex.morning-report

DO THESE STEPS:

1. Create the directory ~/.claude-work/morning-report/  (or ~/.claude/morning-report/ if
   you don't have a work profile — adjust accordingly).

2. Write the prompt file at <DIR>/prompt.md. The prompt should instruct Claude to:
   - Pull active sprint tickets via Atlassian MCP `searchJiraIssuesUsingJql` with cloudId
     set to ATLASSIAN_SITE and jql:
        assignee = currentUser() AND sprint in openSprints() AND statusCategory != Done
        ORDER BY priority DESC, updated DESC
     Request fields: ["summary", "status", "priority", "issuetype", "updated"], maxResults 50.
   - Pull open PRs via Bash:
        gh pr list --repo GH_REPO --author=GITHUB_USER --state=open
            --json number,title,url,reviewDecision,reviews,headRefName,updatedAt --limit 20
   - Pull PRs I've reviewed via Bash:
        gh search prs --reviewed-by=GITHUB_USER --state=open --repo GH_REPO
            --json number,title,url,author,updatedAt
   - For each reviewed PR, fetch via:
        gh pr view <num> --repo GH_REPO --json title,url,reviews,commits
            --jq '{title, url, my_reviews: [.reviews[] | select(.author.login=="GITHUB_USER")],
                   last_commit_date: (.commits | last | .committedDate)}'
     Flag as "needs re-review" if last_commit_date > most recent of my submittedAt.
   - Compose a Slack-flavored markdown message with three grouped sections:
       ## 🌅 Morning Report — <Day, Mon D>
       ### 📋 Active Sprint Tickets (<count>)
         Markdown table: Key | Status | Priority | Summary
         Status emojis: 🔴 Blocked, 🟡 In Progress / In Review / Review, ⚪ To Do
         Link Jira keys to https://ATLASSIAN_SITE/browse/<KEY>
         Append "→ PR #<num>" if a PR's headRefName references the ticket key.
       ### 🚀 My Open PRs (<count>)
         For each PR: bold link, status line w/ HUMAN approval count
         (exclude bots: copilot-pull-request-reviewer, chatgpt-codex-connector, github-actions),
         and ≤120-char summary of most-recent human reviewer comment
         (or "Only bot reviews so far" if none).
       ### 🔄 Awaiting Your Re-review (<count>)
         Only flagged PRs from re-review detection. For each:
            **[#num](url)** (author) — *title*
            "Approved <date> → new commits <date>"
         If zero, write: "_None — you're all caught up. ✨_"
   - Send the message via Slack MCP `slack_send_message` with channel_id=SLACK_USER_ID.
     The message field IS the markdown — no preamble.

3. Write a shell wrapper at <DIR>/run.sh that:
   - Sets PATH to include /opt/homebrew/bin
   - Sets CLAUDE_CONFIG_DIR (e.g. $HOME/.claude-work — match your profile)
   - Runs:
       /opt/homebrew/bin/claude --print --permission-mode bypassPermissions
           --model claude-sonnet-4-6 --output-format text < <DIR>/prompt.md
   - Appends timestamped output to <DIR>/last-run.log
   chmod +x the script.

4. Write a launchd plist at ~/Library/LaunchAgents/LAUNCHD_LABEL.plist:
   - Label = LAUNCHD_LABEL
   - ProgramArguments = [<DIR>/run.sh]
   - StartCalendarInterval = array of 5 dicts (Weekday=1..5, Hour=9, Minute=30)
   - StandardOutPath / StandardErrorPath = log files in <DIR>
   - RunAtLoad = false

5. Load the launchd job:
       launchctl load -w ~/Library/LaunchAgents/LAUNCHD_LABEL.plist
   Verify with:
       launchctl list | grep <last-segment-of-LAUNCHD_LABEL>

6. Smoke test by running <DIR>/run.sh directly. It should:
   - Take 1–4 minutes
   - Send a Slack DM to me
   - Exit with code 0
   Tail <DIR>/last-run.log to confirm.

After setup, summarize what was created and where, and tell me how to:
- Pause / resume the job
- Edit the prompt to tweak the report
- Rotate to a different time
```

---

## Setup (the manual way: do it yourself)

If you'd rather hand-roll it, the four files you need are documented above. The verbatim contents I used at FlexGen are at the end of this doc — copy them, swap the placeholder values, save, and `launchctl load -w` the plist.

### Find your Slack user ID

Either:
- In claude.ai, ask Claude: *"What's my Slack user ID?"* (it knows when Slack MCP is connected)
- Or in Slack: click your avatar → **View profile** → **⋯ More** → **Copy member ID**

It looks like `U0123ABCDEF`.

### Find your Atlassian cloud ID

It's just your Jira hostname: e.g. `my-company.atlassian.net`. (You can also get the UUID via the Atlassian MCP `getAccessibleAtlassianResources` tool, but the hostname works directly as a `cloudId`.)

---

## Verifying it's running

```sh
launchctl list | grep morning-report   # should show your label
tail -f ~/.claude-work/morning-report/last-run.log
```

The `last-run.log` shows every fire's output. If a fire fails, the error lands here.

## Tweaking after the fact

| What you want | What to do |
|---|---|
| Different time | Edit the plist's Hour/Minute, then `launchctl unload` + `launchctl load -w` |
| Different content | Edit `prompt.md` — no reload needed |
| Pause it | `launchctl unload ~/Library/LaunchAgents/LAUNCHD_LABEL.plist` |
| Run now | `~/.claude-work/morning-report/run.sh` (or `launchctl start LAUNCHD_LABEL`) |
| Different repo / scope | Edit `prompt.md` |

---

## Reference files (verbatim, with placeholders)

### `prompt.md`

```
Generate <YOUR NAME>'s daily morning report and send it to my Slack DM. Be concise and
don't ask questions — execute autonomously and exit cleanly when done.

CONTEXT (everything you need is here — don't search):
- Slack DM channel_id: <SLACK_USER_ID>
- GitHub user: <GITHUB_USER>
- GitHub repo scope: <GH_REPO> only
- Jira cloud ID: <ATLASSIAN_SITE>

[...full prompt body — same as the inline section in the Claude setup prompt above...]
```

### `run.sh`

```bash
#!/bin/bash
set -uo pipefail

DIR="$HOME/.claude-work/morning-report"
LOG="$DIR/last-run.log"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export CLAUDE_CONFIG_DIR="$HOME/.claude-work"

{
  echo "=== Run at $(date '+%Y-%m-%d %H:%M:%S %Z') ==="
  /opt/homebrew/bin/claude \
    --print \
    --permission-mode bypassPermissions \
    --model claude-sonnet-4-6 \
    --output-format text \
    < "$DIR/prompt.md"
  echo "=== Exit: $? ==="
} >>"$LOG" 2>&1
```

### `~/Library/LaunchAgents/<LAUNCHD_LABEL>.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>LAUNCHD_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOU/.claude-work/morning-report/run.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <array>
        <dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>30</integer></dict>
        <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>30</integer></dict>
        <dict><key>Weekday</key><integer>3</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>30</integer></dict>
        <dict><key>Weekday</key><integer>4</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>30</integer></dict>
        <dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>9</integer><key>Minute</key><integer>30</integer></dict>
    </array>
    <key>StandardOutPath</key>
    <string>/Users/YOU/.claude-work/morning-report/launchd.out.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOU/.claude-work/morning-report/launchd.err.log</string>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
```

> launchd `Weekday`: 1=Mon, 2=Tue, …, 5=Fri (0/7=Sun).

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Job loaded but never fires | Mac was asleep during the scheduled window all day |
| `gh: command not found` in last-run.log | PATH not picking up Homebrew — confirm `/opt/homebrew/bin` is in run.sh |
| Slack DM doesn't arrive | Slack MCP may have lapsed — re-auth at claude.ai/customize/connectors |
| Jira section empty | Atlassian MCP same — re-auth or check JQL works in the Jira UI |
| Long tool-use prompts hang the run | Confirm `--permission-mode bypassPermissions` is in run.sh |

That's it. Steal liberally. ☕📬
