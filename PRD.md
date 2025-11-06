# Product Requirements Document: Claude GitHub Skill v2.0

## Executive Summary

This PRD outlines the enhancement of the claude-github-skill from v1.1.0 to v2.0.0, transforming it from a functional but project-specific tool into a production-grade, multi-project skill following Anthropic's official skill architecture patterns and community best practices.

**Goals:**
1. Achieve 100% compatibility with official Anthropic skill standards
2. Enable true multi-project portability with zero hardcoded paths
3. Implement safety-first design patterns from best-in-class community skills
4. Add innovative features for parallel workflows and CI/CD integration
5. Maintain backward compatibility with existing projects

**Timeline:** 4.5 hours total development time across 7 phases

**Success Metrics:**
- ✅ Skill loads successfully in Claude Code with frontmatter recognition
- ✅ Zero hardcoded paths remaining
- ✅ Works identically across portfolio-factory, nearest-nice-weather, and new projects
- ✅ Validation scripts catch 95%+ of common errors before human review
- ✅ CI/CD integration reduces manual validation time by 70%

---

## Background & Research

### Current State Assessment

**Strengths:**
- Comprehensive documentation (7 files, 2,760 lines)
- Real-world lessons learned from October 2025 audit
- Template-based approach with reusable patterns
- Graceful memory-bank integration

**Critical Issues:**
- Missing YAML frontmatter (incompatible with official skill loading)
- Hardcoded project path: `/tmp/nearest-nice-weather-wiki/Docs/guides/Wiki-Editing-Lessons-Learned.md`
- No tool permission scoping (security surface too broad)
- Validation patterns embedded in scripts (not configurable per project)
- No announcement pattern (user unaware of skill usage)

**Research Sources:**
- Official Anthropic skills repository (anthropics/skills)
- Community best practices (obra/superpowers, travisvn/awesome-claude-skills)
- Technical deep dive (leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- Production examples (incident.io git worktrees workflow)

---

## Phase A: Quick Wins (Critical Priority)

**Goal:** Achieve official Anthropic skill compatibility and remove critical blockers

**Timeline:** 30 minutes

**Dependencies:** None

### A1. Rename skill.md → SKILL.md

**Requirement:**
Rename the main skill file to match official standard.

**Implementation:**
```bash
mv skill.md SKILL.md
```

**Acceptance Criteria:**
- [ ] File named `SKILL.md` exists in repo root
- [ ] No `skill.md` file remains
- [ ] Git history preserved
- [ ] README.md references updated if needed

**Technical Notes:**
- Official Anthropic convention uses `SKILL.md` (all caps)
- Improves discoverability in Claude's skill scanning
- All official skills use this naming

---

### A2. Add YAML Frontmatter to SKILL.md

**Requirement:**
Add required YAML frontmatter with metadata and tool permissions.

**Implementation:**
Add to beginning of SKILL.md:
```yaml
---
name: github-operations
description: Manage GitHub Wiki, issues, and repository operations with memory-bank integration, business model validation, and SSH authentication
allowed-tools: "Bash(git:*),Bash(gh:*),Bash(ssh:*),Bash(jq:*),Read,Write,Edit,Grep,Glob"
model: inherit
license: MIT
version: 2.0.0
---
```

**Field Specifications:**

| Field | Value | Rationale |
|-------|-------|-----------|
| `name` | `github-operations` | Lowercase, hyphenated, descriptive (≤64 chars) |
| `description` | Multi-line summary | What skill does + when to use (≤1024 chars) |
| `allowed-tools` | Scoped permissions | Minimal necessary access with wildcards |
| `model` | `inherit` | Use session model (don't override) |
| `license` | `MIT` | Match existing LICENSE file |
| `version` | `2.0.0` | Major version bump for breaking changes |

**Tool Permission Breakdown:**
- `Bash(git:*)` - All git commands (clone, push, pull, status, diff)
- `Bash(gh:*)` - GitHub CLI commands (issue, pr, repo)
- `Bash(ssh:*)` - SSH authentication verification
- `Bash(jq:*)` - JSON parsing for memory-bank
- `Read,Write,Edit` - File operations
- `Grep,Glob` - Search operations

**Acceptance Criteria:**
- [ ] Frontmatter uses valid YAML syntax
- [ ] All required fields present (name, description)
- [ ] Tool permissions minimal but sufficient
- [ ] Description accurately summarizes skill purpose
- [ ] Name follows lowercase-hyphenated convention
- [ ] Skill loads successfully in Claude Code

**Testing:**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1])"

# Test skill loading
claude -p "Load the github-operations skill and describe what it does"
```

---

### A3. Replace Hardcoded Paths with {baseDir} Placeholder

**Requirement:**
Remove all hardcoded absolute paths and replace with `{baseDir}` placeholder for portability.

**Current State (SKILL.md line 35):**
```markdown
Check for documented lessons in priority order:
1. `/tmp/nearest-nice-weather-wiki/Docs/guides/Wiki-Editing-Lessons-Learned.md`
2. `memory-bank/wiki-content/lessons-learned.md`
3. Built-in lessons from this skill
```

**New Implementation:**
```markdown
Check for documented lessons in priority order:
1. `{baseDir}/memory-bank/wiki-content/lessons-learned.md`
2. Built-in lessons from this skill (see References section)
```

**Additional Changes:**
- Line 29: Replace `WIKI_URL=$(git remote get-url origin | sed 's/\.git$/.wiki.git/')`
  - No change needed (dynamic detection)
- skill.md line 366-375: Update all `[skill-directory]` references to use `{baseDir}`

**Before:**
```markdown
- **GitHub Tools Guide**: `[skill-directory]/docs/github-tools-guide.md`
- **Quick Reference Card**: `[skill-directory]/docs/quick-reference.md`
```

**After:**
```markdown
- **GitHub Tools Guide**: `{baseDir}/.claude/skills/github/docs/github-tools-guide.md`
- **Quick Reference Card**: `{baseDir}/.claude/skills/github/docs/quick-reference.md`
```

**Acceptance Criteria:**
- [ ] No absolute paths remain in SKILL.md
- [ ] All file references use `{baseDir}` placeholder
- [ ] Skill works identically in any project directory
- [ ] Cross-references resolve correctly
- [ ] Test in 3 different projects (portfolio-factory, nearest-nice-weather, test-project)

**Validation:**
```bash
# Check for hardcoded paths
grep -n "^/\|/tmp/\|/home/" SKILL.md
# Should return 0 results

# Check for proper {baseDir} usage
grep -n "{baseDir}" SKILL.md
# Should show all file references
```

---

### A4. Add Red Flags Section at Top of Instructions

**Requirement:**
Create prominent "Red Flags" section immediately after frontmatter to prevent the 4 most common errors.

**Implementation:**
Insert after line 14 (after "## 🎯 Core Capabilities"):

```markdown
## ⚠️ Critical Red Flags

### NEVER Do These Things:
- ❌ **Use fine-grained tokens for Wiki push** → Will get 403 error. Wiki requires SSH authentication.
- ❌ **Hardcode database counts** → Numbers go stale. Use "Production database (verified: DATE)" instead.
- ❌ **Mix B2B/B2C messaging** → Creates investor confusion. Add explicit business model headers.
- ❌ **Update tech stack without grep** → Creates inconsistency. Always `grep -r "TechName" .` for cross-references.
- ❌ **Skip validation scripts** → Catches errors before publish. Always run validate-wiki.sh, check-tech-stack.sh, verify-business-model.sh.

### ALWAYS Do These Things:
- ✅ **Verify SSH auth first** → Run `ssh -T git@github.com` before any Wiki operation
- ✅ **Load memory-bank context** → Read `{baseDir}/memory-bank/quick-reference.json` for business context
- ✅ **Run validation before push** → Execute all 3 validation scripts on Wiki checkout
- ✅ **Check cross-references** → `grep -r "term-to-update" {baseDir}/tmp/[project]-wiki`
- ✅ **Use verification dates** → "Minnesota outdoor recreation destinations (verified: October 2025)"
- ✅ **Announce skill usage** → Tell user: "I'm using the GitHub Operations skill to [action]"

### Quick Error Prevention Checklist:
```bash
# Before Wiki operations:
[ ] SSH verified: ssh -T git@github.com
[ ] Memory-bank loaded: cat memory-bank/quick-reference.json
[ ] Wiki cloned: git clone git@github.com:org/repo.wiki.git
[ ] Cross-refs checked: grep -r "term" /tmp/project-wiki
[ ] Validation passed: ./scripts/validate-wiki.sh /tmp/project-wiki
```

**Impact:** Prevents 90% of documented errors from October 2025 audit.
```

**Acceptance Criteria:**
- [ ] Red Flags section appears before "📋 Initialization Steps"
- [ ] Uses emoji indicators (❌/✅) for visual scanning
- [ ] Lists all 5 NEVER items
- [ ] Lists all 6 ALWAYS items
- [ ] Includes quick checklist
- [ ] References resolve to correct paths

**Design Rationale:**
- Based on obra/superpowers pattern (git worktrees skill)
- Prevents errors **before** they occur
- Visual hierarchy with emoji and bold text
- Checklist format enables quick verification

---

### A5. Add Announcement Pattern

**Requirement:**
Implement transparency pattern where skill announces its usage to the user.

**Implementation:**
Modify "## 📋 Initialization Steps" section (currently line 14):

**Before:**
```markdown
## 📋 Initialization Steps

When this skill is invoked, perform these steps:

### Step 1: Detect Project Context
```

**After:**
```markdown
## 📋 Initialization Steps

When this skill is invoked, follow this sequence:

### Step 0: Announce Skill Usage (REQUIRED)

Immediately tell the user:

"I'm using the **GitHub Operations** skill to [specific action]. This skill will:
- Load business context from memory-bank (if available)
- Apply documented lessons learned from October 2025 audit
- Validate [relevant validations based on action]
- Use [specific tools: SSH/CLI/MCP] for the operation"

**Examples:**
- "I'm using the GitHub Operations skill to **update the Wiki**. I'll verify SSH auth, load business context, check cross-references, and run validation before pushing."
- "I'm using the GitHub Operations skill to **create sprint issues**. I'll load memory-bank WBS, apply issue templates, and link dependencies."
- "I'm using the GitHub Operations skill to **create a PR**. I'll analyze commits, apply PR template, and include deployment notes."

### Step 1: Detect Project Context
```

**Acceptance Criteria:**
- [ ] Announcement appears as Step 0 in initialization
- [ ] Marked as REQUIRED
- [ ] Includes 3 example announcements
- [ ] Claude actually announces in test runs
- [ ] User receives transparency about skill usage

**Testing:**
```bash
# Test announcement in real session
claude -p "Update the Wiki with new features using the github-operations skill"
# Verify first output includes: "I'm using the GitHub Operations skill to..."
```

---

## Phase B: Enhanced UX (High Priority)

**Goal:** Improve usability with decision tables, integration mapping, and better error messages

**Timeline:** 60 minutes

**Dependencies:** Phase A complete

### B1. Create Tool Selection Decision Table

**Requirement:**
Add quick-reference table for choosing between Git/CLI/MCP/Web based on task type.

**Implementation:**
Insert after "## ⚠️ Critical Red Flags" section:

```markdown
## 🛠️ Tool Selection Decision Table

Choose the right tool for your GitHub operation:

| Task Category | Primary Tool | Authentication | Command Example | When NOT to Use |
|---------------|--------------|----------------|-----------------|-----------------|
| **Wiki Operations** | Git + SSH | SSH keys | `git clone git@github.com:org/repo.wiki.git` | ❌ Never use tokens (403 error) |
| **Security Alerts** | GitHub Project Manager MCP | PAT (enhanced) | Via MCP interface | ❌ Standard PAT lacks permissions |
| **Issue Creation** | GitHub CLI (`gh`) | PAT or SSH | `gh issue create --title "..." --body "..."` | ✅ MCP works too (slower) |
| **PR Creation** | GitHub CLI (`gh`) | PAT or SSH | `gh pr create --title "..." --body "..."` | ✅ Web interface for complex |
| **PR Review** | GitHub CLI (`gh`) | PAT or SSH | `gh pr view 123 --comments` | Use Web for visual diffs |
| **Bulk Operations** | GitHub CLI (`gh`) | PAT or SSH | `gh issue list --label bug` | ❌ MCP not optimized for bulk |
| **Project Boards** | GitHub Project Manager MCP | PAT | Via MCP interface | Use Web for drag-drop |
| **Releases** | GitHub CLI (`gh`) | PAT or SSH | `gh release create v1.0.0` | ✅ Either tool works |
| **Repository Settings** | Web Interface | Browser session | Manual navigation | ❌ No CLI/API for some settings |

### Quick Selection Rules:

**🔴 Wiki Operations = SSH ONLY**
```bash
# ALWAYS use SSH URL for Wiki
git clone git@github.com:org/repo.wiki.git
# Fine-grained tokens WILL FAIL with 403
```

**🟡 Security Operations = MCP Required**
```bash
# Security alerts require enhanced PAT permissions
# Use GitHub Project Manager MCP, not CLI
```

**🟢 Everything Else = GitHub CLI Preferred**
```bash
# Fast, scriptable, works in CI/CD
gh issue create | gh pr create | gh repo view
```

### Authentication Quick Reference:

| Method | Use Case | Setup Command | Scope |
|--------|----------|---------------|-------|
| SSH Key | Wiki, Git operations | `ssh-keygen && gh ssh-key add` | Full repo access |
| PAT (Classic) | CLI automation | `gh auth login` | User-defined scopes |
| Fine-Grained Token | Project-specific | GitHub Settings → Tokens | Repo-specific |
| OAuth (Browser) | Web operations | Login via browser | Full account access |

**Performance Note:** GitHub CLI saves 4+ hours/week per developer vs manual Web UI operations.
```

**Acceptance Criteria:**
- [ ] Table includes all 9 major operation types
- [ ] Each row has primary tool, auth method, example, and warning
- [ ] Quick selection rules use color coding (🔴🟡🟢)
- [ ] Authentication reference table included
- [ ] Performance benefit noted

**Design Rationale:**
- Based on obra/superpowers decision table pattern
- Reduces cognitive load ("What tool should I use?")
- Prevents auth errors before they occur
- Cross-references docs/github-tools-guide.md

---

### B2. Add Integration Mapping Section

**Requirement:**
Show how this skill connects with other skills, tools, and workflows.

**Implementation:**
Insert before "## 📚 References" section (currently line 363):

```markdown
## 🔗 Integration Points

This skill is designed to work seamlessly with other tools and workflows.

### Works Directly With:

**Memory-Bank Structure:**
- `memory-bank/quick-reference.json` → Business context, tech stack, red flags
- `memory-bank/skill-config.json` → Project-specific validation rules
- `memory-bank/wiki-content/lessons-learned.md` → Additional lessons beyond built-in

**Project Configuration:**
- `CLAUDE.md` → Project-specific GitHub operation standards
- `.github/workflows/` → CI/CD integration for validation automation
- `.claude/skills/` → Other skills (composition patterns)

**External Tools:**
- `git` + SSH → Wiki operations (required)
- `gh` (GitHub CLI) → API operations, bulk tasks, scripting
- GitHub Project Manager MCP → Security alerts, sprint planning
- `jq` → JSON parsing for memory-bank files

### Typical Multi-Skill Workflows:

**Workflow 1: Wiki Documentation Update**
```
1. /memory-bank-loader → Load business context
2. /documentation-writer → Generate content
3. /github-operations → Validate and publish to Wiki
```

**Workflow 2: Sprint Planning**
```
1. /memory-bank-loader → Load WBS and technical patterns
2. /github-operations → Create issues with templates and dependencies
3. /project-tracker → Monitor progress and update statuses
```

**Workflow 3: Feature PR Creation**
```
1. Developer writes code → Commits to branch
2. /github-operations → Create PR with template and analysis
3. /code-reviewer → Review PR for quality issues
4. /github-operations → Address feedback, merge
```

**Workflow 4: Investor Documentation**
```
1. /memory-bank-loader → Load business model and red flags
2. /documentation-writer → Generate investor-facing content
3. /github-operations → Validate business model consistency
4. /github-operations → Publish to Wiki with proper headers
```

### Invocation Patterns:

**Explicit Invocation:**
```
/github-operations
```

**Implicit Invocation (Auto-Triggered):**
- User says: "Update the Wiki with..."
- User says: "Create issues for..."
- User says: "Make a PR for..."
- User says: "Check business model consistency"

**Composition with Other Skills:**
```
# Load memory-bank first, then use GitHub operations
/memory-bank && /github-operations

# Generate docs, then validate with GitHub operations
/docs-generator && /github-operations validate
```

### Environment Variables:

Set these to customize skill behavior per project:

```bash
# Override default paths
export SKILL_CONFIG_PATH="./custom-config/github-skill.json"
export WIKI_LESSONS_PATH="./docs/wiki-lessons.md"
export MEMORY_BANK_PATH="./project-context"
export GITHUB_WIKI_URL="https://github.com/org/repo/wiki"

# CI/CD mode
export CLAUDE_HEADLESS=true
export GITHUB_TOKEN="ghp_..."
```

### Related Skills:

- **memory-bank-loader** - Loads business context before GitHub operations
- **documentation-writer** - Generates content that this skill validates
- **code-reviewer** - Reviews PRs created by this skill
- **project-tracker** - Monitors issues created by this skill
- **git-worktrees** - Enables parallel GitHub operations (see Innovative Ideas)

### Documentation Cross-References:

- Full tool guide: `{baseDir}/.claude/skills/github/docs/github-tools-guide.md`
- Quick reference: `{baseDir}/.claude/skills/github/docs/quick-reference.md`
- Memory-bank integration: `{baseDir}/.claude/skills/github/examples/memory-bank-integration.md`
- CLAUDE.md setup: `{baseDir}/.claude/skills/github/docs/claude-md-integration.md` (Phase B3)
```

**Acceptance Criteria:**
- [ ] Lists all memory-bank integration points
- [ ] Shows 4 typical multi-skill workflows
- [ ] Documents environment variables
- [ ] Lists related skills
- [ ] Includes invocation patterns (explicit & implicit)
- [ ] Cross-references other documentation

---

### B3. Create docs/claude-md-integration.md

**Requirement:**
Provide template and guidance for integrating this skill with project CLAUDE.md files.

**Implementation:**
Create new file: `docs/claude-md-integration.md`

```markdown
# CLAUDE.md Integration Guide

## Overview

This guide shows how to configure your project's `CLAUDE.md` file to work optimally with the GitHub Operations skill.

## What is CLAUDE.md?

`CLAUDE.md` is your project's instruction manual for Claude Code. At session start, Claude reads it to understand:
- Code style and conventions
- Project-specific standards
- Common commands and workflows
- Architecture and patterns

**Location:** `{baseDir}/CLAUDE.md` (project root)

## Recommended CLAUDE.md Section

Add this section to your project's `CLAUDE.md`:

```markdown
## GitHub Operations Standards

This project uses the `claude-github-skill` for all GitHub operations.

### Authentication Configuration

**Wiki Operations (REQUIRED):**
```bash
# Verify SSH authentication before Wiki operations
ssh -T git@github.com
# Expected: "Hi username! You've successfully authenticated..."
```

**API Operations:**
```bash
# Configure GitHub CLI with PAT or SSH
gh auth login
# Choose: GitHub.com → SSH or Token
```

**Security Operations:**
- Use GitHub Project Manager MCP (enhanced PAT required)
- Standard PAT will get 403 on security alerts

### Pre-Push Validation (REQUIRED)

Before publishing any Wiki updates, run all validation scripts:

```bash
# 1. Content validation
./claude/skills/github/scripts/validate-wiki.sh /tmp/[project]-wiki

# 2. Technology stack consistency
./claude/skills/github/scripts/check-tech-stack.sh /tmp/[project]-wiki

# 3. Business model alignment (investor docs only)
./claude/skills/github/scripts/verify-business-model.sh /tmp/[project]-wiki
```

All scripts must pass (exit code 0) before pushing to Wiki.

### Memory-Bank Integration

**Required Files:**
- `memory-bank/quick-reference.json` → Business context, tech stack, red flags
- `memory-bank/skill-config.json` → Validation rules (optional, uses defaults if missing)

**Load Context Before:**
- Documenting features or statistics (verify production data)
- Creating investor-facing documentation (check business model)
- Making technical architecture claims (validate tech stack)
- Updating Wiki with cross-references (grep for consistency)

**Example:**
```bash
# Load business context
cat memory-bank/quick-reference.json

# Check current business focus
jq -r '.businessFocus' memory-bank/quick-reference.json
# Output: "B2C outdoor recreation"
```

### Business Model Standards

**Current Focus:** [Load from memory-bank/quick-reference.json]
- Business Focus: {businessFocus}
- Tech Stack: {techStack}
- Revenue Model: {revenueModel}
- NOT Pursuing: {notPursuing[]}

**Red Flags to Avoid:**
{redFlags[]}

**Validation Requirements:**
- Investor docs MUST have "## Business Model" header
- B2B/B2C mentions must have clear context
- Technical claims must be verified against production
- Statistics must include verification dates

### Common GitHub Workflows

**Update Wiki Documentation:**
```bash
# 1. Clone Wiki via SSH
cd /tmp && git clone git@github.com:[org]/[repo].wiki.git [project]-wiki

# 2. Make changes (load memory-bank context first)
cat memory-bank/quick-reference.json

# 3. Validate before committing
./claude/skills/github/scripts/validate-wiki.sh /tmp/[project]-wiki

# 4. Commit and push
cd /tmp/[project]-wiki
git add .
git commit -m "docs: [description]"
git push origin master
```

**Create Sprint Issues:**
```bash
# 1. Load work breakdown structure
cat memory-bank/sprint-plan.json

# 2. Create issues with templates
gh issue create --title "Feature: X" \
  --body "$(cat .claude/skills/github/templates/issue-template.md)" \
  --label "sprint-1" \
  --project "Q1 2025"
```

**Create Pull Request:**
```bash
# 1. Ensure branch is ready
git status
git log origin/main..HEAD

# 2. Create PR with template
gh pr create --title "fix: React rendering issue" \
  --body "$(cat .github/pull_request_template.md)" \
  --base main
```

### Tool Selection Rules

| Task | Tool | Command |
|------|------|---------|
| Wiki push/pull | Git + SSH | `git clone git@github.com:org/repo.wiki.git` |
| Security alerts | GitHub MCP | Via MCP interface |
| Issue/PR operations | GitHub CLI | `gh issue create` / `gh pr create` |
| Bulk operations | GitHub CLI | `gh issue list --json` |

### Validation Rules Configuration

**Location:** `memory-bank/skill-config.json`

**Example Configuration:**
```json
{
  "validation": {
    "deprecatedTech": [
      "FastAPI",
      "Directus",
      "PostGIS",
      "Docker Compose"
    ],
    "hardcodedPatterns": [
      "138 POI",
      "169 locations",
      "[0-9]+ POI locations"
    ],
    "investorDocTypes": [
      "Investment",
      "Executive",
      "Financial",
      "Business",
      "Strategy",
      "Pitch"
    ]
  },
  "projectSpecific": {
    "name": "your-project-name",
    "primaryFocus": "B2C [description]",
    "techStack": "Vercel + Neon + React"
  }
}
```

### Error Prevention Checklist

Copy to your CLAUDE.md for quick reference:

**Before Wiki Operations:**
- [ ] SSH authentication verified: `ssh -T git@github.com`
- [ ] Memory-bank loaded: `cat memory-bank/quick-reference.json`
- [ ] Wiki cloned via SSH: `git clone git@github.com:org/repo.wiki.git`
- [ ] Cross-references checked: `grep -r "term" /tmp/project-wiki`
- [ ] Validation scripts passed: All 3 scripts exit 0

**Before Investor Documentation:**
- [ ] Business model header added to doc
- [ ] Business focus verified from quick-reference.json
- [ ] No contradictory B2B/B2C claims
- [ ] Revenue model clearly stated
- [ ] Red flags checked against content

**Before Technical Documentation:**
- [ ] Production data verified (not hardcoded)
- [ ] Technology stack consistent across docs
- [ ] Deprecated tech has warnings or removed
- [ ] Cross-references updated (grep results)
- [ ] Verification dates included

---

## Project-Specific Examples

### Example 1: Nearest Nice Weather

```markdown
## GitHub Operations Standards

This project uses the `claude-github-skill` for all GitHub operations.

### Business Context
- **Focus:** 100% B2C outdoor recreation discovery
- **Tech Stack:** Vercel + Neon + React (Vite)
- **Primary Table:** poi_locations (Minnesota outdoor destinations)
- **NOT Pursuing:** B2B features, city-based search

### Red Flags
- ❌ Cities appearing instead of parks in search results
- ❌ Hardcoded POI counts (138, 169) - use verification dates
- ❌ B2B features being mentioned without "far-future" context
- ❌ Database statistics without production API validation

### Validation Rules
```json
{
  "validation": {
    "deprecatedTech": ["FastAPI", "Directus", "PostGIS", "Docker Compose"],
    "hardcodedPatterns": ["138 POI", "169 locations", "[0-9]+ POI locations"],
    "investorDocTypes": ["Investment", "Executive", "Business"]
  }
}
```

### Wiki Operations
```bash
# Clone Wiki
cd /tmp && git clone git@github.com:PrairieAster-Ai/nearest-nice-weather.wiki.git nearest-nice-weather-wiki

# Validate
./.claude/skills/github/scripts/validate-wiki.sh /tmp/nearest-nice-weather-wiki
```
```

### Example 2: Portfolio Factory

```markdown
## GitHub Operations Standards

This project uses the `claude-github-skill` for all GitHub operations.

### Business Context
- **Focus:** B2C portfolio showcase and project management
- **Tech Stack:** Vite + React + Vercel
- **Primary Goal:** Display development work and skills

### Red Flags
- ❌ Hardcoded project counts - use dynamic loading
- ❌ Outdated technology stack in README
- ❌ Missing project metadata in portfolio items

### Validation Rules
```json
{
  "validation": {
    "deprecatedTech": ["Webpack", "CRA", "Create React App"],
    "hardcodedPatterns": ["42 projects", "[0-9]+ portfolio items"],
    "investorDocTypes": ["Pitch", "Investor"]
  }
}
```

### Wiki Operations
```bash
# Clone Wiki
cd /tmp && git clone git@github.com:user/portfolio-factory.wiki.git portfolio-factory-wiki

# Validate
./.claude/skills/github/scripts/validate-wiki.sh /tmp/portfolio-factory-wiki
```
```

---

## Testing Your Configuration

### 1. Verify CLAUDE.md is Loaded

Start a Claude Code session and check if Claude mentions your standards:

```
User: "What are the GitHub operation standards for this project?"
Claude: "According to CLAUDE.md, this project uses claude-github-skill with..."
```

### 2. Test Memory-Bank Loading

```bash
# Start Claude session
claude

# Ask Claude to load context
"Load the memory-bank context and tell me the business focus"

# Expected: Claude reads quick-reference.json and reports businessFocus
```

### 3. Test Validation Scripts

```bash
# Create test Wiki checkout
cd /tmp
git clone git@github.com:org/repo.wiki.git test-wiki

# Run validations
./.claude/skills/github/scripts/validate-wiki.sh /tmp/test-wiki
./.claude/skills/github/scripts/check-tech-stack.sh /tmp/test-wiki
./.claude/skills/github/scripts/verify-business-model.sh /tmp/test-wiki

# All should exit 0 if valid, exit 1 if issues found
echo $?
```

### 4. Test Skill Invocation

```
User: "Update the Wiki with new feature docs"
Claude: "I'm using the GitHub Operations skill to update the Wiki..."
# Claude should announce skill usage
```

---

## Troubleshooting

### Issue: Claude Doesn't Load CLAUDE.md

**Solution:**
- Ensure file is named exactly `CLAUDE.md` (case-sensitive)
- Place in project root directory
- Restart Claude session

### Issue: Validation Scripts Not Found

**Solution:**
```bash
# Check skill installation
ls -la .claude/skills/github/scripts/

# Ensure scripts are executable
chmod +x .claude/skills/github/scripts/*.sh
```

### Issue: Memory-Bank Not Loading

**Solution:**
```bash
# Verify file exists and is valid JSON
cat memory-bank/quick-reference.json | jq .

# Check file permissions
ls -la memory-bank/quick-reference.json
```

### Issue: SSH Authentication Fails

**Solution:**
```bash
# Test SSH connection
ssh -T git@github.com

# If fails, add SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"
gh ssh-key add ~/.ssh/id_ed25519.pub
```

---

## Best Practices

1. **Keep CLAUDE.md Updated:** Review quarterly or when standards change
2. **Version Control Configuration:** Commit CLAUDE.md and memory-bank/ to git
3. **Document Deviations:** If project needs custom rules, document in CLAUDE.md
4. **Test After Changes:** Run validation scripts after updating CLAUDE.md
5. **Share with Team:** Ensure all developers have consistent CLAUDE.md
6. **Integrate with CI/CD:** Run validation scripts in GitHub Actions

---

## Additional Resources

- [GitHub Tools Guide](./github-tools-guide.md) - Comprehensive tool selection
- [Quick Reference Card](./quick-reference.md) - Print-friendly emergency reference
- [Memory-Bank Integration](../examples/memory-bank-integration.md) - Integration patterns
- [Validation Scripts](../scripts/) - Script documentation

---

**Version:** 2.0.0
**Last Updated:** November 2025
**Maintained By:** PrairieAster-Ai
```

**Acceptance Criteria:**
- [ ] File created at `docs/claude-md-integration.md`
- [ ] Includes template CLAUDE.md section
- [ ] Shows 2 project-specific examples (nearest-nice-weather, portfolio-factory)
- [ ] Documents testing procedures
- [ ] Includes troubleshooting guide
- [ ] Lists best practices
- [ ] Cross-references other documentation

---

### B4. Improve Error Messages in validate-wiki.sh

**Requirement:**
Enhance error messages with specific available alternatives to help Claude fix issues without guessing.

**Current Implementation (validate-wiki.sh:22-25):**
```bash
if grep -rn "138 POI\|169 locations\|[0-9]\+ POI locations" "$WIKI_DIR" --include="*.md" 2>/dev/null; then
    echo -e "${RED}❌ Found hardcoded database counts${NC}"
    echo "   Use generic terms like 'Minnesota POI database (verified: DATE)'"
    ((ERRORS++))
```

**Enhanced Implementation:**
```bash
if MATCHES=$(grep -rn "138 POI\|169 locations\|[0-9]\+ POI locations" "$WIKI_DIR" --include="*.md" 2>/dev/null); then
    echo -e "${RED}❌ Found hardcoded database counts${NC}"
    echo ""
    echo "   Found patterns:"
    echo "$MATCHES" | sed 's/^/     /'
    echo ""
    echo "   ✓ Available alternatives (choose one):"
    echo "     1. 'Minnesota outdoor recreation destinations (verified: $(date +%B\ %Y))'"
    echo "     2. 'Production POI database (verified: $(date +%B\ %Y))'"
    echo "     3. 'POI location database (updated regularly)'"
    echo "     4. 'Outdoor recreation destinations across Minnesota'"
    echo ""
    echo "   💡 Tip: Use verification dates instead of counts. Verify production data:"
    echo "      curl -s 'https://[production-url]/api/poi?limit=1' | jq '.count'"
    ((ERRORS++))
```

**Apply Similar Pattern to All Checks:**

**Check 2: Deprecated Technology (lines 31-40)**
```bash
for tech in "${DEPRECATED_TECH[@]}"; do
    if MATCHES=$(grep -rn "$tech" "$WIKI_DIR" --include="*.md" 2>/dev/null); then
        echo -e "${YELLOW}⚠️  Found references to potentially deprecated: $tech${NC}"
        echo ""
        echo "   Found in:"
        echo "$MATCHES" | head -5 | sed 's/^/     /'
        echo ""
        echo "   ✓ Actions to consider:"
        echo "     1. Replace with current technology (see memory-bank/quick-reference.json)"
        echo "     2. Add deprecation warning (use templates/deprecation-warning.md)"
        echo "     3. Remove if no longer relevant"
        echo "     4. Keep if historically accurate with context"
        echo ""
        echo "   💡 Check current tech stack:"
        echo "      jq -r '.techStack' memory-bank/quick-reference.json"
        ((ERRORS++))
    fi
done
```

**Check 3: Business Model (lines 46-57)**
```bash
if [ $B2B_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found B2B references - verify these are clearly marked as not current focus${NC}"
    echo ""
    echo "   B2B mentions found:"
    grep -rn "B2B" "$WIKI_DIR" --include="*.md" 2>/dev/null | head -5 | sed 's/^/     /'
    echo ""
    echo "   ✓ Required actions:"
    echo "     1. Add business model header (see templates/business-model-header.md)"
    echo "     2. Use 'NOT Pursuing: B2B' language if not current focus"
    echo "     3. Add 'far-future possibility' context if mentioned"
    echo "     4. Check for contradictions with 'grep -r \"developing.*B2B\"'"
    echo ""
    echo "   💡 Verify current business focus:"
    echo "      jq -r '.businessFocus' memory-bank/quick-reference.json"
fi
```

**Check 4: Broken Links (lines 60-67)**
```bash
if MATCHES=$(grep -rn "\[.*\](\s*)" "$WIKI_DIR" --include="*.md" 2>/dev/null); then
    echo -e "${RED}❌ Found empty links${NC}"
    echo ""
    echo "   Empty links found:"
    echo "$MATCHES" | sed 's/^/     /'
    echo ""
    echo "   ✓ Fix by:"
    echo "     1. Add target URL: [Text](https://github.com/...)"
    echo "     2. Remove link formatting: Text (no brackets)"
    echo "     3. Link to Wiki page: [Text](PageName)"
    ((ERRORS++))
```

**Acceptance Criteria:**
- [ ] All 6 validation checks have enhanced error messages
- [ ] Each message shows found patterns (with line numbers)
- [ ] Each message lists 3-4 specific alternatives
- [ ] Each message includes "💡 Tip" with verification command
- [ ] Output uses indentation for readability
- [ ] Test with intentionally bad Wiki content

**Testing:**
```bash
# Create test Wiki with intentional errors
mkdir /tmp/test-wiki
echo "We have 138 POI locations" > /tmp/test-wiki/test.md
echo "FastAPI backend" >> /tmp/test-wiki/test.md
echo "B2B features coming" >> /tmp/test-wiki/test.md

# Run validation
./scripts/validate-wiki.sh /tmp/test-wiki

# Verify enhanced messages appear
```

---

## Phase C: Advanced Features (Medium Priority)

**Goal:** Add configuration validation, plan-validate-execute pattern, and testing infrastructure

**Timeline:** 90 minutes

**Dependencies:** Phases A & B complete

### C1. Create scripts/validate-config.sh

**Requirement:**
Validate `memory-bank/skill-config.json` syntax and structure before running other validation scripts.

**Implementation:**
Create new file: `scripts/validate-config.sh`

```bash
#!/bin/bash

# Configuration Validation Script
# Validates memory-bank/skill-config.json before running other validations

set -e

CONFIG_FILE="${SKILL_CONFIG_PATH:-memory-bank/skill-config.json}"
ERRORS=0
WARNINGS=0

echo "🔍 Validating skill configuration: $CONFIG_FILE"
echo ""

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check 1: File exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}⚠️  No config file found at: $CONFIG_FILE${NC}"
    echo "   Using built-in defaults"
    echo ""
    echo "   ✓ To customize validation rules, create:"
    echo "     memory-bank/skill-config.json"
    echo ""
    echo "   💡 Template:"
    cat <<'EOF'
{
  "validation": {
    "deprecatedTech": ["Technology1", "Technology2"],
    "hardcodedPatterns": ["pattern1", "pattern2"],
    "investorDocTypes": ["Investment", "Executive"]
  },
  "projectSpecific": {
    "name": "your-project",
    "primaryFocus": "B2C description",
    "techStack": "Tech + Stack + Here"
  }
}
EOF
    exit 0
fi

# Check 2: Valid JSON syntax
echo "📄 Checking JSON syntax..."
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${RED}❌ Invalid JSON syntax in: $CONFIG_FILE${NC}"
    echo ""
    echo "   Error details:"
    jq empty "$CONFIG_FILE" 2>&1 | sed 's/^/     /'
    echo ""
    echo "   ✓ Common JSON errors:"
    echo "     1. Missing comma between elements"
    echo "     2. Trailing comma after last element"
    echo "     3. Unquoted strings"
    echo "     4. Single quotes instead of double quotes"
    echo ""
    echo "   💡 Validate JSON online:"
    echo "      https://jsonlint.com/"
    ((ERRORS++))
    exit 1
fi
echo -e "${GREEN}✅ JSON syntax valid${NC}"
echo ""

# Check 3: Required top-level structure
echo "📋 Checking structure..."
REQUIRED_SECTIONS=("validation")
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! jq -e ".$section" "$CONFIG_FILE" >/dev/null 2>&1; then
        echo -e "${RED}❌ Missing required section: $section${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✅ Section found: $section${NC}"
    fi
done
echo ""

# Check 4: Validation section fields
echo "🔍 Checking validation fields..."
VALIDATION_FIELDS=("deprecatedTech" "hardcodedPatterns" "investorDocTypes")
for field in "${VALIDATION_FIELDS[@]}"; do
    if ! jq -e ".validation.$field" "$CONFIG_FILE" >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Missing recommended field: validation.$field${NC}"
        echo "   Will use built-in defaults"
        ((WARNINGS++))
    else
        # Check if array
        if ! jq -e ".validation.$field | type == \"array\"" "$CONFIG_FILE" >/dev/null 2>&1; then
            echo -e "${RED}❌ Field validation.$field must be an array${NC}"
            ((ERRORS++))
        else
            COUNT=$(jq -r ".validation.$field | length" "$CONFIG_FILE")
            echo -e "${GREEN}✅ validation.$field: $COUNT items${NC}"
        fi
    fi
done
echo ""

# Check 5: Project-specific section (optional but recommended)
echo "📦 Checking project-specific fields..."
if jq -e ".projectSpecific" "$CONFIG_FILE" >/dev/null 2>&1; then
    PROJECT_FIELDS=("name" "primaryFocus" "techStack")
    for field in "${PROJECT_FIELDS[@]}"; do
        if ! jq -e ".projectSpecific.$field" "$CONFIG_FILE" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠️  Missing recommended field: projectSpecific.$field${NC}"
            ((WARNINGS++))
        else
            VALUE=$(jq -r ".projectSpecific.$field" "$CONFIG_FILE")
            echo -e "${GREEN}✅ projectSpecific.$field: $VALUE${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  No projectSpecific section found${NC}"
    echo "   This section helps document project context"
    ((WARNINGS++))
fi
echo ""

# Check 6: Validate array contents
echo "🔍 Validating array contents..."

# Check deprecatedTech
if jq -e ".validation.deprecatedTech" "$CONFIG_FILE" >/dev/null 2>&1; then
    EMPTY_COUNT=$(jq -r '.validation.deprecatedTech[] | select(. == "")' "$CONFIG_FILE" 2>/dev/null | wc -l)
    if [ "$EMPTY_COUNT" -gt 0 ]; then
        echo -e "${RED}❌ Found $EMPTY_COUNT empty strings in validation.deprecatedTech${NC}"
        ((ERRORS++))
    fi
fi

# Check hardcodedPatterns for valid regex
if jq -e ".validation.hardcodedPatterns" "$CONFIG_FILE" >/dev/null 2>&1; then
    while IFS= read -r pattern; do
        # Basic regex validation (check if grep accepts it)
        if ! echo "test" | grep -q "$pattern" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Potentially invalid regex pattern: $pattern${NC}"
            ((WARNINGS++))
        fi
    done < <(jq -r '.validation.hardcodedPatterns[]' "$CONFIG_FILE" 2>/dev/null)
fi
echo ""

# Check 7: Display configuration summary
echo "📊 Configuration Summary:"
echo ""
jq -r '
  "Deprecated Technologies: " + (.validation.deprecatedTech | length | tostring),
  "Hardcoded Patterns: " + (.validation.hardcodedPatterns | length | tostring),
  "Investor Doc Types: " + (.validation.investorDocTypes | length | tostring),
  "",
  "Project: " + (.projectSpecific.name // "not specified"),
  "Focus: " + (.projectSpecific.primaryFocus // "not specified"),
  "Tech Stack: " + (.projectSpecific.techStack // "not specified")
' "$CONFIG_FILE" | sed 's/^/   /'
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Configuration validation passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Configuration valid with $WARNINGS warnings${NC}"
    echo "Review warnings above (non-blocking)"
    exit 0
else
    echo -e "${RED}❌ Configuration validation failed with $ERRORS errors${NC}"
    echo "Fix errors above before running other validation scripts"
    exit 1
fi
```

**Acceptance Criteria:**
- [ ] File created at `scripts/validate-config.sh`
- [ ] Executable: `chmod +x scripts/validate-config.sh`
- [ ] Validates JSON syntax with jq
- [ ] Checks all required sections
- [ ] Validates array types
- [ ] Checks for empty strings
- [ ] Tests regex patterns
- [ ] Displays configuration summary
- [ ] Separates ERRORS from WARNINGS
- [ ] Exit code: 0 (valid), 1 (errors)
- [ ] Provides helpful error messages with alternatives

**Testing:**
```bash
# Test with valid config
./scripts/validate-config.sh
# Should exit 0

# Test with invalid JSON
echo "{invalid json}" > memory-bank/skill-config.json
./scripts/validate-config.sh
# Should exit 1 with error details

# Test with missing file
rm memory-bank/skill-config.json
./scripts/validate-config.sh
# Should exit 0 with warning (uses defaults)
```

---

### C2. Create scripts/config.sh (Shared Configuration Loader)

**Requirement:**
Create shared bash library for loading configuration that all validation scripts can source.

**Implementation:**
Create new file: `scripts/config.sh`

```bash
#!/bin/bash

# Shared Configuration Loader
# Source this file from other validation scripts
# Usage: source "$(dirname "$0")/config.sh"

# Configuration file location (can be overridden via environment)
CONFIG_FILE="${SKILL_CONFIG_PATH:-memory-bank/skill-config.json}"

# Project configuration (loaded on demand)
PROJECT_CONFIG=""

# Color codes for output
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Load project configuration from JSON file
# Sets PROJECT_CONFIG variable
load_project_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${BLUE}📚 Loading project config from: $CONFIG_FILE${NC}"

        # Validate JSON before loading
        if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
            echo -e "${RED}❌ Invalid JSON in config file${NC}"
            echo "   Run: ./scripts/validate-config.sh"
            exit 1
        fi

        PROJECT_CONFIG=$(cat "$CONFIG_FILE")
        echo -e "${GREEN}✅ Configuration loaded${NC}"
    else
        echo -e "${YELLOW}ℹ️  No project config found, using defaults${NC}"
        echo "   Expected: $CONFIG_FILE"
        PROJECT_CONFIG='{}'
    fi
    echo ""
}

# Get deprecated technology list
# Returns: Array of technology names (one per line)
get_deprecated_tech() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "$PROJECT_CONFIG" | jq -r '.validation.deprecatedTech[]? // empty' 2>/dev/null
}

# Get hardcoded pattern list
# Returns: Array of regex patterns (one per line)
get_hardcoded_patterns() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "$PROJECT_CONFIG" | jq -r '.validation.hardcodedPatterns[]? // empty' 2>/dev/null
}

# Get investor document types
# Returns: Array of document type keywords (one per line)
get_investor_doc_types() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "$PROJECT_CONFIG" | jq -r '.validation.investorDocTypes[]? // empty' 2>/dev/null
}

# Get project name
# Returns: Project name string
get_project_name() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "$PROJECT_CONFIG" | jq -r '.projectSpecific.name // "unknown"' 2>/dev/null
}

# Get primary business focus
# Returns: Business focus string
get_business_focus() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "$PROJECT_CONFIG" | jq -r '.projectSpecific.primaryFocus // ""' 2>/dev/null
}

# Get tech stack
# Returns: Tech stack string
get_tech_stack() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "$PROJECT_CONFIG" | jq -r '.projectSpecific.techStack // ""' 2>/dev/null
}

# Get default deprecated tech list (fallback)
# Returns: Array of default technologies
get_default_deprecated_tech() {
    cat <<EOF
FastAPI
Directus
PostGIS
Docker Compose
Flask
Django
EOF
}

# Get default hardcoded patterns (fallback)
# Returns: Array of default patterns
get_default_hardcoded_patterns() {
    cat <<EOF
138 POI
169 locations
[0-9]\+ POI locations
[0-9]\+ items
[0-9]\+ projects
EOF
}

# Get default investor doc types (fallback)
# Returns: Array of default document types
get_default_investor_doc_types() {
    cat <<EOF
Investment
Executive
Financial
Business
Strategy
Pitch
Deck
EOF
}

# Check if configuration file exists
# Returns: 0 if exists, 1 if not
has_config_file() {
    [ -f "$CONFIG_FILE" ]
}

# Display configuration summary
show_config_summary() {
    if [ -z "$PROJECT_CONFIG" ]; then
        load_project_config
    fi

    echo "📊 Configuration Summary:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Config file: $CONFIG_FILE"
    echo "Project: $(get_project_name)"
    echo "Focus: $(get_business_focus)"
    echo "Tech Stack: $(get_tech_stack)"
    echo ""
    echo "Deprecated Tech: $(get_deprecated_tech | wc -l) items"
    echo "Hardcoded Patterns: $(get_hardcoded_patterns | wc -l) items"
    echo "Investor Doc Types: $(get_investor_doc_types | wc -l) items"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Export functions for use in other scripts
export -f load_project_config
export -f get_deprecated_tech
export -f get_hardcoded_patterns
export -f get_investor_doc_types
export -f get_project_name
export -f get_business_focus
export -f get_tech_stack
export -f get_default_deprecated_tech
export -f get_default_hardcoded_patterns
export -f get_default_investor_doc_types
export -f has_config_file
export -f show_config_summary
```

**Acceptance Criteria:**
- [ ] File created at `scripts/config.sh`
- [ ] All functions documented with comments
- [ ] Functions exported for sourcing
- [ ] Handles missing config file gracefully
- [ ] Provides default values
- [ ] Validates JSON before loading
- [ ] Color codes exported
- [ ] Configuration summary function included

**Testing:**
```bash
# Test sourcing
source scripts/config.sh

# Test functions
load_project_config
get_deprecated_tech
get_project_name
show_config_summary
```

---

### C3. Refactor validate-wiki.sh to Use config.sh

**Requirement:**
Modify `validate-wiki.sh` to source `config.sh` and use configuration functions instead of hardcoded values.

**Implementation:**

**At the top of validate-wiki.sh (after line 6):**
```bash
#!/bin/bash

# Wiki Validation Script
# Validates Wiki content for common issues before publishing

set -e

# Source shared configuration loader
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/config.sh"

WIKI_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "🔍 Validating Wiki content in: $WIKI_DIR"
echo ""

# Load and display configuration
load_project_config
```

**Replace hardcoded patterns check (lines 20-28):**
```bash
# Check 1: Hardcoded database counts
echo "📊 Checking for hardcoded database counts..."

# Load patterns from config or use defaults
mapfile -t PATTERNS < <(get_hardcoded_patterns)
if [ ${#PATTERNS[@]} -eq 0 ]; then
    mapfile -t PATTERNS < <(get_default_hardcoded_patterns)
fi

# Build grep pattern
PATTERN_STRING=$(IFS='|'; echo "${PATTERNS[*]}")

if [ -n "$PATTERN_STRING" ] && MATCHES=$(grep -rn "$PATTERN_STRING" "$WIKI_DIR" --include="*.md" 2>/dev/null); then
    echo -e "${RED}❌ Found hardcoded database counts${NC}"
    echo ""
    echo "   Found patterns:"
    echo "$MATCHES" | sed 's/^/     /'
    echo ""
    echo "   ✓ Available alternatives (choose one):"
    echo "     1. 'Production database (verified: $(date +%B\ %Y))'"
    echo "     2. 'Database (updated regularly)'"
    echo "     3. 'Data verified: $(date +%B\ %Y)'"
    echo ""
    echo "   💡 Tip: Use verification dates instead of counts"
    ((ERRORS++))
else
    echo -e "${GREEN}✅ No hardcoded counts found${NC}"
fi
echo ""
```

**Replace deprecated tech check (lines 31-43):**
```bash
# Check 2: Deprecated technology references
echo "🔧 Checking for deprecated technology references..."

# Load tech from config or use defaults
mapfile -t DEPRECATED_TECH < <(get_deprecated_tech)
if [ ${#DEPRECATED_TECH[@]} -eq 0 ]; then
    mapfile -t DEPRECATED_TECH < <(get_default_deprecated_tech)
fi

FOUND_DEPRECATED=0
for tech in "${DEPRECATED_TECH[@]}"; do
    if MATCHES=$(grep -rn "$tech" "$WIKI_DIR" --include="*.md" 2>/dev/null); then
        echo -e "${YELLOW}⚠️  Found references to potentially deprecated: $tech${NC}"
        echo ""
        echo "   Found in:"
        echo "$MATCHES" | head -5 | sed 's/^/     /'
        echo ""

        # Check if current tech stack is available
        CURRENT_STACK=$(get_tech_stack)
        if [ -n "$CURRENT_STACK" ]; then
            echo "   ✓ Current tech stack: $CURRENT_STACK"
        fi

        echo "   ✓ Actions to consider:"
        echo "     1. Replace with current technology"
        echo "     2. Add deprecation warning (use templates/deprecation-warning.md)"
        echo "     3. Remove if no longer relevant"
        echo "     4. Keep if historically accurate with context"
        echo ""
        ((WARNINGS++))
        FOUND_DEPRECATED=1
    fi
done

if [ $FOUND_DEPRECATED -eq 0 ]; then
    echo -e "${GREEN}✅ No deprecated technology references found${NC}"
fi
echo ""
```

**Update investor docs check (lines 78-87):**
```bash
# Check 6: Inconsistent headers
echo "📋 Checking for business model headers in investor docs..."

# Load investor doc types from config
mapfile -t INVESTOR_DOCS < <(get_investor_doc_types)
if [ ${#INVESTOR_DOCS[@]} -eq 0 ]; then
    mapfile -t INVESTOR_DOCS < <(get_default_investor_doc_types)
fi

MISSING_HEADERS=0
for doc_type in "${INVESTOR_DOCS[@]}"; do
    if find "$WIKI_DIR" -name "*$doc_type*.md" -type f 2>/dev/null | grep -q .; then
        echo "   Found investor docs matching: $doc_type"
        for file in $(find "$WIKI_DIR" -name "*$doc_type*.md" -type f 2>/dev/null); do
            if ! grep -q "## Business Model" "$file" 2>/dev/null; then
                echo -e "${YELLOW}⚠️  Missing 'Business Model' header: $(basename "$file")${NC}"
                ((MISSING_HEADERS++))
            fi
        done
    fi
done

if [ $MISSING_HEADERS -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  $MISSING_HEADERS investor documents missing business model headers${NC}"
    echo "   Add business model section using templates/business-model-header.md"
    ((WARNINGS++))
else
    echo -e "${GREEN}✅ All investor documents have business model headers${NC}"
fi
echo ""
```

**Update summary (lines 90-99):**
```bash
# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All validation checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Validation passed with $WARNINGS warnings${NC}"
    echo "Review warnings above (non-blocking)"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS critical errors and $WARNINGS warnings${NC}"
    echo "Fix critical errors before publishing"
    exit 1
fi
```

**Acceptance Criteria:**
- [ ] Script sources config.sh successfully
- [ ] Uses get_hardcoded_patterns() instead of hardcoded array
- [ ] Uses get_deprecated_tech() instead of hardcoded array
- [ ] Uses get_investor_doc_types() instead of hardcoded array
- [ ] Falls back to defaults if config missing
- [ ] Separates ERRORS (critical) from WARNINGS (review)
- [ ] Exit codes: 0 (pass), 0 (warnings), 1 (errors)
- [ ] All tests pass with and without config file

---

### C4. Refactor check-tech-stack.sh to Use config.sh

**Requirement:**
Modify `check-tech-stack.sh` to source `config.sh` for consistency.

**Implementation:**

**Update header (lines 1-28):**
```bash
#!/bin/bash

# Technology Stack Validation Script
# Checks Wiki content for outdated or deprecated technology references

set -e

# Source shared configuration loader
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/config.sh"

WIKI_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "🔧 Checking technology stack references in: $WIKI_DIR"
echo ""

# Load and display configuration
load_project_config

# Display current tech stack if available
CURRENT_STACK=$(get_tech_stack)
if [ -n "$CURRENT_STACK" ]; then
    echo "📚 Current tech stack: $CURRENT_STACK"
    echo ""
fi
```

**Replace deprecated tech array (lines 30-39):**
```bash
# Common deprecated technologies to check
mapfile -t DEPRECATED_TECH < <(get_deprecated_tech)
if [ ${#DEPRECATED_TECH[@]} -eq 0 ]; then
    echo "ℹ️  No project-specific deprecated tech, using defaults"
    mapfile -t DEPRECATED_TECH < <(get_default_deprecated_tech)
fi

echo "🔍 Scanning for technology references..."
echo "   Checking for: ${DEPRECATED_TECH[*]}"
echo ""
```

**Rest of script remains same, update summary:**
```bash
# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Technology stack validation passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Validation passed with $WARNINGS warnings${NC}"
    echo "Review technology mentions for consistency"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS technology issues${NC}"
    echo "Check if these technologies are still in use or need deprecation warnings"
    exit 1
fi
```

**Acceptance Criteria:**
- [ ] Script sources config.sh
- [ ] Uses get_deprecated_tech() function
- [ ] Uses get_tech_stack() for display
- [ ] Falls back to defaults
- [ ] Separates ERRORS from WARNINGS
- [ ] All tests pass

---

### C5. Refactor verify-business-model.sh to Use config.sh

**Requirement:**
Modify `verify-business-model.sh` to source `config.sh` for consistency.

**Implementation:**

**Update header (lines 1-29):**
```bash
#!/bin/bash

# Business Model Validation Script
# Ensures consistent business model messaging across investor-facing documentation

set -e

# Source shared configuration loader
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/config.sh"

WIKI_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "💼 Validating business model consistency in: $WIKI_DIR"
echo ""

# Load and display configuration
load_project_config

# Display business context if available
BUSINESS_FOCUS=$(get_business_focus)
if [ -n "$BUSINESS_FOCUS" ]; then
    echo "📚 Current business focus: $BUSINESS_FOCUS"
    echo ""
fi
```

**Replace investor doc types (lines 51-59):**
```bash
# Check 2: Investor-facing documents have business model headers
echo "📋 Checking for business model headers in investor docs..."

mapfile -t INVESTOR_DOCS < <(get_investor_doc_types)
if [ ${#INVESTOR_DOCS[@]} -eq 0 ]; then
    mapfile -t INVESTOR_DOCS < <(get_default_investor_doc_types)
fi

MISSING_HEADERS=0
# ... rest of check remains same
```

**Update summary:**
```bash
# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Business model validation passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Validation passed with $WARNINGS warnings${NC}"
    echo "Review business model consistency warnings"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS business model issues${NC}"
    echo "Fix critical business model inconsistencies before publishing"
    exit 1
fi
```

**Acceptance Criteria:**
- [ ] Script sources config.sh
- [ ] Uses get_investor_doc_types() function
- [ ] Uses get_business_focus() for display
- [ ] Falls back to defaults
- [ ] Separates ERRORS from WARNINGS
- [ ] All tests pass

---

### C6. Create Test Suite for Validation Scripts

**Requirement:**
Create automated test suite to verify all validation scripts work correctly.

**Implementation:**
Create new file: `scripts/test-validation.sh`

```bash
#!/bin/bash

# Test Suite for Validation Scripts
# Runs automated tests on all validation scripts

set -e

SCRIPT_DIR="$(dirname "$0")"
TEST_DIR="/tmp/github-skill-test-$$"
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🧪 GitHub Skill Validation Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Setup test environment
setup_test_env() {
    echo "📦 Setting up test environment..."
    mkdir -p "$TEST_DIR/memory-bank"
    mkdir -p "$TEST_DIR/wiki"

    # Create valid config
    cat > "$TEST_DIR/memory-bank/skill-config.json" <<'EOF'
{
  "validation": {
    "deprecatedTech": ["OldTech", "DeprecatedLib"],
    "hardcodedPatterns": ["123 items", "[0-9]+ widgets"],
    "investorDocTypes": ["Investment", "Pitch"]
  },
  "projectSpecific": {
    "name": "test-project",
    "primaryFocus": "B2C testing",
    "techStack": "Test Stack"
  }
}
EOF

    echo -e "${GREEN}✅ Test environment ready: $TEST_DIR${NC}"
    echo ""
}

# Cleanup test environment
cleanup_test_env() {
    echo ""
    echo "🧹 Cleaning up test environment..."
    rm -rf "$TEST_DIR"
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit="$3"

    echo "Running: $test_name"

    if eval "$test_command" >/dev/null 2>&1; then
        actual_exit=0
    else
        actual_exit=$?
    fi

    if [ "$actual_exit" -eq "$expected_exit" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name (expected exit $expected_exit, got $actual_exit)"
        ((TESTS_FAILED++))
    fi
}

# Test 1: validate-config.sh with valid config
test_valid_config() {
    cd "$TEST_DIR"
    run_test "validate-config.sh: valid config" \
        "$SCRIPT_DIR/validate-config.sh" \
        0
}

# Test 2: validate-config.sh with missing config (should succeed with warning)
test_missing_config() {
    rm -f "$TEST_DIR/memory-bank/skill-config.json"
    cd "$TEST_DIR"
    run_test "validate-config.sh: missing config" \
        "$SCRIPT_DIR/validate-config.sh" \
        0

    # Restore config
    setup_test_env >/dev/null 2>&1
}

# Test 3: validate-config.sh with invalid JSON
test_invalid_json() {
    echo "{invalid json}" > "$TEST_DIR/memory-bank/skill-config.json"
    cd "$TEST_DIR"
    run_test "validate-config.sh: invalid JSON" \
        "$SCRIPT_DIR/validate-config.sh" \
        1

    # Restore config
    setup_test_env >/dev/null 2>&1
}

# Test 4: validate-wiki.sh with clean Wiki
test_clean_wiki() {
    echo "# Clean Wiki Page" > "$TEST_DIR/wiki/Home.md"
    echo "This is a clean page with no issues." >> "$TEST_DIR/wiki/Home.md"

    cd "$TEST_DIR"
    run_test "validate-wiki.sh: clean Wiki" \
        "$SCRIPT_DIR/validate-wiki.sh $TEST_DIR/wiki" \
        0
}

# Test 5: validate-wiki.sh with hardcoded counts
test_hardcoded_counts() {
    echo "# Wiki with Issues" > "$TEST_DIR/wiki/Bad.md"
    echo "We have 123 items in the database." >> "$TEST_DIR/wiki/Bad.md"

    cd "$TEST_DIR"
    run_test "validate-wiki.sh: hardcoded counts" \
        "$SCRIPT_DIR/validate-wiki.sh $TEST_DIR/wiki" \
        1

    # Clean up
    rm "$TEST_DIR/wiki/Bad.md"
}

# Test 6: validate-wiki.sh with deprecated tech
test_deprecated_tech() {
    echo "# Wiki with Deprecated Tech" > "$TEST_DIR/wiki/Tech.md"
    echo "We use OldTech for backend processing." >> "$TEST_DIR/wiki/Tech.md"

    cd "$TEST_DIR"
    run_test "validate-wiki.sh: deprecated technology" \
        "$SCRIPT_DIR/validate-wiki.sh $TEST_DIR/wiki" \
        0  # Should pass with warnings

    # Clean up
    rm "$TEST_DIR/wiki/Tech.md"
}

# Test 7: check-tech-stack.sh
test_tech_stack() {
    echo "# Technology Documentation" > "$TEST_DIR/wiki/Tech.md"
    echo "Built with Test Stack" >> "$TEST_DIR/wiki/Tech.md"

    cd "$TEST_DIR"
    run_test "check-tech-stack.sh: tech stack check" \
        "$SCRIPT_DIR/check-tech-stack.sh $TEST_DIR/wiki" \
        0

    # Clean up
    rm "$TEST_DIR/wiki/Tech.md"
}

# Test 8: verify-business-model.sh with proper headers
test_business_model() {
    echo "# Investment Deck" > "$TEST_DIR/wiki/Investment.md"
    echo "" >> "$TEST_DIR/wiki/Investment.md"
    echo "## Business Model" >> "$TEST_DIR/wiki/Investment.md"
    echo "B2C focus" >> "$TEST_DIR/wiki/Investment.md"

    cd "$TEST_DIR"
    run_test "verify-business-model.sh: proper headers" \
        "$SCRIPT_DIR/verify-business-model.sh $TEST_DIR/wiki" \
        0

    # Clean up
    rm "$TEST_DIR/wiki/Investment.md"
}

# Test 9: verify-business-model.sh missing headers
test_missing_headers() {
    echo "# Investment Deck" > "$TEST_DIR/wiki/Investment.md"
    echo "Content without business model header" >> "$TEST_DIR/wiki/Investment.md"

    cd "$TEST_DIR"
    run_test "verify-business-model.sh: missing headers" \
        "$SCRIPT_DIR/verify-business-model.sh $TEST_DIR/wiki" \
        0  # Should pass with warnings

    # Clean up
    rm "$TEST_DIR/wiki/Investment.md"
}

# Test 10: config.sh source test
test_config_sourcing() {
    cd "$TEST_DIR"
    run_test "config.sh: source and load functions" \
        "bash -c 'source $SCRIPT_DIR/config.sh && load_project_config && get_project_name'" \
        0
}

# Main test execution
main() {
    setup_test_env

    echo "Running tests..."
    echo ""

    test_valid_config
    test_missing_config
    test_invalid_json
    test_clean_wiki
    test_hardcoded_counts
    test_deprecated_tech
    test_tech_stack
    test_business_model
    test_missing_headers
    test_config_sourcing

    cleanup_test_env

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Test Results:"
    echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        exit 0
    fi
}

# Run tests
main
```

**Acceptance Criteria:**
- [ ] File created at `scripts/test-validation.sh`
- [ ] Executable: `chmod +x scripts/test-validation.sh`
- [ ] Tests all 4 validation scripts
- [ ] Tests valid, invalid, and missing configs
- [ ] Tests error and warning conditions
- [ ] Creates isolated test environment
- [ ] Cleans up after tests
- [ ] Reports pass/fail for each test
- [ ] Exit code: 0 (all pass), 1 (any fail)

**Testing:**
```bash
# Run test suite
./scripts/test-validation.sh

# Should output:
# 🧪 GitHub Skill Validation Test Suite
# ...
# 🎉 All tests passed!
```

---

## Phase D: Innovative Ideas (Experimental)

**Goal:** Implement cutting-edge patterns from community and production use cases

**Timeline:** 120 minutes

**Dependencies:** Phases A, B, C complete

### D1. Git Worktrees Integration

**Requirement:**
Add support for parallel Wiki editing using git worktrees pattern.

**Research Source:** obra/superpowers, incident.io blog

**Implementation:**
Add to SKILL.md after "## 🔧 Repository Operations" section:

```markdown
## 🌳 Advanced: Git Worktrees for Parallel Wiki Editing

### What Are Git Worktrees?

Git worktrees allow multiple working directories from the same repository, enabling parallel Wiki editing tasks without interference.

**Use Cases:**
- Multiple Claude instances editing different Wiki sections simultaneously
- Testing Wiki changes in isolation before merging
- Maintaining stable Wiki while developing major updates

### When to Use Worktrees

**✅ Use Worktrees When:**
- Large Wiki updates requiring parallel edits to 5+ pages
- Multiple developers/AI instances working on Wiki simultaneously
- Testing breaking changes without affecting main Wiki
- Long-running Wiki feature branches (multi-day updates)

**❌ Don't Use Worktrees For:**
- Simple single-page edits (overhead not worth it)
- Quick typo fixes or minor updates
- Projects where you're the only editor

### Worktree Setup Workflow

**Step 1: Create Main Wiki Checkout**
```bash
# Create primary Wiki directory
cd /tmp
git clone git@github.com:[org]/[repo].wiki.git [project]-wiki-main
cd [project]-wiki-main
```

**Step 2: Create Worktrees for Parallel Tasks**
```bash
# Create worktree for feature A
git worktree add ../[project]-wiki-feature-a feature-a

# Create worktree for feature B
git worktree add ../[project]-wiki-feature-b feature-b

# List all worktrees
git worktree list
```

**Step 3: Edit in Parallel**
```bash
# Claude Instance 1: Edit in feature-a worktree
cd /tmp/[project]-wiki-feature-a
# Make changes to section A pages...
git add . && git commit -m "docs: update section A"

# Claude Instance 2: Edit in feature-b worktree (simultaneously)
cd /tmp/[project]-wiki-feature-b
# Make changes to section B pages...
git add . && git commit -m "docs: update section B"
```

**Step 4: Merge and Cleanup**
```bash
# Switch to main worktree
cd /tmp/[project]-wiki-main

# Merge feature-a
git merge feature-a
git push origin master

# Merge feature-b
git merge feature-b
git push origin master

# Remove worktrees
git worktree remove ../[project]-wiki-feature-a
git worktree remove ../[project]-wiki-feature-b
```

### Safety Checks for Worktrees

**Before Creating Worktree:**
- [ ] Verify main Wiki checkout is clean: `git status`
- [ ] Check CLAUDE.md for worktree preferences
- [ ] Ensure worktree directory doesn't already exist
- [ ] Confirm sufficient disk space (3x Wiki size)

**Project-Local vs Global Worktrees:**

| Type | Location | .gitignore Required? | Use Case |
|------|----------|---------------------|----------|
| **Project-Local** | `/project/.worktrees/` | ✅ Yes (critical) | Team collaboration |
| **Global** | `/tmp/[project]-worktrees/` | ❌ No | Solo development |

**Critical:** If using project-local worktrees, add to `.gitignore`:
```gitignore
.worktrees/
```

### Example: Parallel Wiki Sections Update

**Scenario:** Update Wiki with 3 independent sections (architecture, API docs, deployment guide)

**Setup:**
```bash
cd /tmp
git clone git@github.com:org/repo.wiki.git wiki-main
cd wiki-main

# Create 3 worktrees
git worktree add ../wiki-architecture architecture
git worktree add ../wiki-api api-docs
git worktree add ../wiki-deployment deployment
```

**Parallel Editing (3 Claude instances):**
```bash
# Terminal 1: Architecture updates
cd /tmp/wiki-architecture
claude -p "Update architecture diagrams in Wiki using github-operations skill"

# Terminal 2: API documentation
cd /tmp/wiki-api
claude -p "Document new API endpoints in Wiki using github-operations skill"

# Terminal 3: Deployment guide
cd /tmp/wiki-deployment
claude -p "Update deployment instructions in Wiki using github-operations skill"
```

**Validation (each worktree independently):**
```bash
# Run validation in each worktree before merging
./claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-architecture
./claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-api
./claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-deployment
```

**Merge:**
```bash
cd /tmp/wiki-main

git merge architecture
git merge api-docs
git merge deployment

# Resolve conflicts if any
git push origin master

# Cleanup
git worktree remove ../wiki-architecture
git worktree remove ../wiki-api
git worktree remove ../wiki-deployment
```

### Worktree-Aware Skill Announcement

When using worktrees, announce differently:

```
"I'm using the GitHub Operations skill with git worktrees to [action].
This allows parallel editing of [section] without affecting other Wiki work.
I'll validate this worktree independently before merging."
```

### Performance Benefits

**Time Savings:**
- Traditional serial editing: 3 sections × 20 min = 60 minutes
- Parallel worktree editing: max(20 min) = 20 minutes
- **Savings: 40 minutes (67% faster)**

**Resource Requirements:**
- Disk space: ~3x Wiki size (e.g., 30MB Wiki = 90MB total)
- Memory: Minimal (worktrees share .git directory)
- Network: No additional bandwidth (local operations)

### Troubleshooting Worktrees

**Issue: "fatal: '[path]' is already a registered worktree"**
```bash
# List worktrees
git worktree list

# Remove stale worktree
git worktree remove [path] --force
```

**Issue: Worktree merge conflicts**
```bash
# Check which files conflict
git status

# Resolve manually or accept one side
git checkout --ours [file]   # Keep current branch
git checkout --theirs [file]  # Use merging branch
```

**Issue: Forgetting to cleanup worktrees**
```bash
# List all worktrees
git worktree list

# Prune removed worktrees
git worktree prune
```

### Integration with CLAUDE.md

Add to your project's CLAUDE.md:

```markdown
## Git Worktrees Preferences

**Default Worktree Location:** `/tmp/[project]-worktrees/`
**Use Worktrees For:** Wiki updates affecting 5+ pages
**Worktree Naming:** `[project]-wiki-[feature-name]`
**Cleanup Policy:** Remove worktrees within 24 hours of merge
```

### Related Tools

**Worktree Manager Script:** (Coming in Phase D1.5)
- Auto-creates worktrees with proper naming
- Validates before merge
- Auto-cleanup after successful merge
```

**Acceptance Criteria:**
- [ ] Worktrees section added to SKILL.md
- [ ] Explains what/when/why for worktrees
- [ ] Provides step-by-step workflow
- [ ] Includes safety checks
- [ ] Shows parallel editing example
- [ ] Documents troubleshooting
- [ ] Integration with CLAUDE.md

**Future Enhancement (Phase D1.5):**
Create `scripts/worktree-manager.sh` for automated worktree operations

---

### D2. CI/CD Integration (Headless Mode)

**Requirement:**
Enable GitHub Actions integration for automated Wiki validation in CI/CD pipelines.

**Research Source:** Official Claude Code docs, Anthropic engineering blog

**Implementation:**

**Create `.github/workflows/wiki-validation.yml`:**
```yaml
name: Wiki Validation

on:
  push:
    paths:
      - 'wiki/**'
      - '.github/workflows/wiki-validation.yml'
  pull_request:
    paths:
      - 'wiki/**'
  workflow_dispatch:

jobs:
  validate-wiki:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      issues: write
      pull-requests: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Checkout Wiki
        run: |
          cd /tmp
          git clone git@github.com:${{ github.repository }}.wiki.git wiki-checkout
        env:
          GIT_SSH_COMMAND: 'ssh -i ${{ secrets.WIKI_SSH_KEY }} -o StrictHostKeyChecking=no'

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y jq

      - name: Validate configuration
        run: |
          chmod +x .claude/skills/github/scripts/*.sh
          ./.claude/skills/github/scripts/validate-config.sh

      - name: Validate Wiki content
        id: validate-content
        run: |
          ./.claude/skills/github/scripts/validate-wiki.sh /tmp/wiki-checkout
        continue-on-error: true

      - name: Check tech stack
        id: validate-tech
        run: |
          ./.claude/skills/github/scripts/check-tech-stack.sh /tmp/wiki-checkout
        continue-on-error: true

      - name: Verify business model
        id: validate-business
        run: |
          ./.claude/skills/github/scripts/verify-business-model.sh /tmp/wiki-checkout
        continue-on-error: true

      - name: Generate validation report
        if: always()
        run: |
          cat << EOF > validation-report.md
          # Wiki Validation Report

          **Workflow Run:** ${{ github.run_number }}
          **Triggered By:** ${{ github.actor }}
          **Branch:** ${{ github.ref_name }}
          **Commit:** ${{ github.sha }}

          ## Validation Results

          | Check | Status |
          |-------|--------|
          | Content Validation | ${{ steps.validate-content.outcome == 'success' && '✅ Passed' || '❌ Failed' }} |
          | Tech Stack | ${{ steps.validate-tech.outcome == 'success' && '✅ Passed' || '⚠️ Warnings' }} |
          | Business Model | ${{ steps.validate-business.outcome == 'success' && '✅ Passed' || '⚠️ Review' }} |

          ## Next Steps

          ${{ steps.validate-content.outcome == 'success' && '✅ All validations passed! Safe to merge.' || '❌ Fix validation errors before merging.' }}

          ---
          *Automated by claude-github-skill v2.0*
          EOF

          cat validation-report.md

      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('validation-report.md', 'utf8');

            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: report
            });

      - name: Fail if critical errors
        if: steps.validate-content.outcome == 'failure'
        run: |
          echo "::error::Wiki validation failed with critical errors"
          exit 1

      - name: Upload validation report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: wiki-validation-report
          path: validation-report.md
          retention-days: 30

  validate-with-claude-headless:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Claude Code CLI
        run: |
          curl -fsSL https://claude.com/install.sh | sh

      - name: Run Claude validation in headless mode
        run: |
          claude -p "Load github-operations skill and validate Wiki changes in this PR" \
            --output-format stream-json \
            > claude-validation.jsonl
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}

      - name: Parse Claude results
        run: |
          cat claude-validation.jsonl | jq -r '.content' > claude-report.md

      - name: Comment Claude analysis
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const analysis = fs.readFileSync('claude-report.md', 'utf8');

            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## Claude AI Analysis\n\n${analysis}`
            });
```

**Add documentation to SKILL.md:**
```markdown
## 🤖 CI/CD Integration

### GitHub Actions Integration

This skill includes GitHub Actions workflows for automated Wiki validation.

**Setup Instructions:**

1. **Add SSH Key Secret:**
```bash
# Generate SSH key for Wiki access
ssh-keygen -t ed25519 -C "github-actions@your-project" -f wiki_deploy_key

# Add public key to GitHub Wiki deploy keys
# Settings → Wiki → Deploy keys → Add key

# Add private key to repository secrets
# Settings → Secrets → Actions → New secret
# Name: WIKI_SSH_KEY
# Value: (paste private key content)
```

2. **Add Claude API Key (Optional - for headless validation):**
```bash
# Get API key from Claude console
# https://console.anthropic.com/

# Add to repository secrets
# Name: CLAUDE_API_KEY
# Value: (your API key)
```

3. **Copy Workflow File:**
```bash
cp .claude/skills/github/.github/workflows/wiki-validation.yml \
   .github/workflows/wiki-validation.yml
```

4. **Enable Workflow:**
```bash
git add .github/workflows/wiki-validation.yml
git commit -m "ci: add Wiki validation workflow"
git push
```

**Workflow Triggers:**
- ✅ Push to Wiki directory
- ✅ Pull request affecting Wiki
- ✅ Manual trigger (workflow_dispatch)

**Workflow Steps:**
1. Checkout repository and Wiki
2. Install dependencies (jq, bash)
3. Run configuration validation
4. Run all 3 validation scripts
5. Generate validation report
6. Comment on PR (if applicable)
7. Upload artifacts for review
8. (Optional) Run Claude headless analysis

**Validation Report Example:**
```markdown
# Wiki Validation Report

**Workflow Run:** 42
**Triggered By:** robert
**Branch:** feature/update-docs

## Validation Results

| Check | Status |
|-------|--------|
| Content Validation | ✅ Passed |
| Tech Stack | ⚠️ Warnings |
| Business Model | ✅ Passed |

## Warnings

- Found 2 references to deprecated technology: FastAPI
- Consider adding deprecation warnings

## Next Steps

⚠️ Review warnings before merging (non-blocking)
```

**Performance Metrics:**
- Validation time: ~30-60 seconds
- Feedback on PR: Immediate (within 2 minutes)
- Cost: Free (GitHub Actions minutes)
- Time saved: 5-10 minutes per Wiki update

### Pre-Commit Hooks

**Setup Local Pre-Commit Validation:**

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash

# Pre-commit hook for Wiki validation
# Runs validation scripts before allowing commit

echo "🔍 Running pre-commit Wiki validation..."

# Check if Wiki files are being committed
WIKI_FILES=$(git diff --cached --name-only | grep "^wiki/" || true)

if [ -n "$WIKI_FILES" ]; then
    echo "Found Wiki changes, running validation..."

    # Run quick validation
    if ! ./.claude/skills/github/scripts/validate-wiki.sh wiki/; then
        echo ""
        echo "❌ Wiki validation failed!"
        echo "Fix errors or use 'git commit --no-verify' to skip"
        exit 1
    fi

    echo "✅ Wiki validation passed"
fi

exit 0
```

**Make executable:**
```bash
chmod +x .git/hooks/pre-commit
```

### Headless Mode Usage

**Run Claude validation from command line:**
```bash
# Basic validation
claude -p "Validate Wiki using github-operations skill"

# With JSON output for parsing
claude -p "Validate Wiki using github-operations skill" \
  --output-format stream-json

# With specific task
claude -p "Check Wiki for business model consistency using github-operations skill" \
  --output-format stream-json \
  | jq -r '.content'
```

**Environment Variables:**
```bash
# Headless mode configuration
export CLAUDE_HEADLESS=true
export SKILL_CONFIG_PATH="./memory-bank/skill-config.json"
export GITHUB_TOKEN="ghp_..."  # For gh CLI

# Run validation
claude -p "Validate Wiki"
```

### Integration Testing

**Test CI/CD Workflow Locally:**
```bash
# Install act (GitHub Actions local runner)
brew install act  # macOS
# or
sudo apt-get install act  # Linux

# Run workflow locally
act push -W .github/workflows/wiki-validation.yml

# Run with secrets
act push -s WIKI_SSH_KEY="$(cat ~/.ssh/id_ed25519)" \
         -W .github/workflows/wiki-validation.yml
```

### Best Practices

1. **Always run validation locally before pushing**
   ```bash
   ./claude/skills/github/scripts/validate-wiki.sh wiki/
   ```

2. **Review CI/CD reports before merging PRs**
   - Check validation artifacts
   - Read Claude's headless analysis
   - Fix warnings even if non-blocking

3. **Update secrets when rotating keys**
   - SSH keys every 90 days
   - API tokens every 6 months

4. **Monitor workflow failures**
   - Set up GitHub notifications
   - Review failed runs weekly
   - Update scripts if patterns change

### Troubleshooting CI/CD

**Issue: SSH authentication fails in Actions**
```yaml
# Solution: Verify SSH key secret
- name: Test SSH
  run: |
    ssh -T git@github.com
  env:
    GIT_SSH_COMMAND: 'ssh -i ${{ secrets.WIKI_SSH_KEY }} -o StrictHostKeyChecking=no'
```

**Issue: jq not found**
```yaml
# Solution: Add installation step
- name: Install dependencies
  run: sudo apt-get update && sudo apt-get install -y jq
```

**Issue: Validation scripts not executable**
```yaml
# Solution: Add chmod step
- name: Make scripts executable
  run: chmod +x .claude/skills/github/scripts/*.sh
```
```

**Acceptance Criteria:**
- [ ] GitHub Actions workflow file created
- [ ] Documentation added to SKILL.md
- [ ] Pre-commit hook example provided
- [ ] Headless mode usage documented
- [ ] Local testing instructions included
- [ ] Troubleshooting guide added
- [ ] Test workflow with act locally
- [ ] Verify PR commenting works

---

### D3. Skill Composition Patterns

**Requirement:**
Document how this skill composes with other skills for complex workflows.

**Research Source:** ClaudeKit patterns, Anthropic engineering blog

**Implementation:**
Add to SKILL.md after "## 🔗 Integration Points" section:

```markdown
## 🎭 Skill Composition Patterns

### What is Skill Composition?

Skill composition allows multiple skills to work together in a single workflow, with each skill providing specialized capabilities.

**Benefits:**
- ✅ Divide complex tasks into specialized steps
- ✅ Reuse skills across different workflows
- ✅ Claude automatically loads relevant skills
- ✅ Token-efficient (only active skills loaded)

### Composition Pattern 1: Sequential Workflow

**Use Case:** Load context → Generate content → Validate → Publish

**Example Workflow:**
```
User: "Create investor documentation and publish to Wiki"

Claude (automatic skill loading):
1. Loads memory-bank-loader skill → Reads quick-reference.json
2. Loads documentation-writer skill → Generates investor docs
3. Loads github-operations skill → Validates and publishes
```

**Manual Invocation:**
```bash
# Explicit skill chain
claude -p "/memory-bank && /docs-writer && /github-operations publish"
```

**SKILL.md Implementation:**
```markdown
When user requests documentation updates:
1. First check if memory-bank context is loaded
2. If not, suggest: "Let me load business context first with /memory-bank"
3. Then proceed with GitHub operations
```

### Composition Pattern 2: Parallel Workflow

**Use Case:** Multiple independent validations running simultaneously

**Example Workflow:**
```
User: "Comprehensive Wiki validation"

Claude (parallel skill loading):
1. github-operations skill → Content validation
2. tech-stack-validator skill → Technology consistency
3. business-model-checker skill → Business alignment
```

**Benefits:**
- ⚡ 3x faster than sequential
- 🎯 Specialized validation per domain
- 📊 Consolidated reporting

### Composition Pattern 3: Nested Workflow

**Use Case:** Skill calls another skill internally

**Example Workflow:**
```
User: "Update Wiki with API documentation"

github-operations skill:
1. Loads memory-bank context (composition)
2. Calls api-doc-generator skill (composition)
3. Validates generated docs
4. Publishes to Wiki
```

**SKILL.md Implementation:**
```markdown
### Step 2: Load Business Context (Automatic Composition)

Check if memory-bank context is available:
- If `/memory-bank` skill exists, invoke it
- Otherwise, directly read memory-bank/quick-reference.json
- Apply business context to all operations
```

### Composition Pattern 4: Conditional Workflow

**Use Case:** Different skills based on task type

**Example Workflow:**
```
User: "Prepare for investor meeting"

Claude (conditional loading):
1. Detects "investor" keyword
2. Loads business-model-validator skill
3. Loads github-operations skill
4. Loads presentation-builder skill

If investor docs incomplete:
  → Load documentation-writer skill
  → Generate missing sections
  → Validate with github-operations
```

**Decision Logic:**
```markdown
## Task Type Detection

| Keywords | Skills Loaded | Priority |
|----------|---------------|----------|
| "Wiki", "documentation" | github-operations, docs-writer | High |
| "investor", "pitch", "funding" | business-model-validator, github-operations | Critical |
| "sprint", "issues", "tasks" | project-tracker, github-operations | High |
| "PR", "pull request", "code review" | code-reviewer, github-operations | Medium |
```

### Practical Composition Examples

#### Example 1: Full Documentation Workflow

**User Request:**
```
"Document our new authentication feature with security considerations
and publish to Wiki"
```

**Skill Composition:**
```
1. /memory-bank
   → Load: techStack, securityPatterns, redFlags

2. /security-analyzer
   → Analyze: authentication implementation
   → Generate: security considerations

3. /documentation-writer
   → Input: code analysis + security findings
   → Output: comprehensive docs

4. /github-operations
   → Validate: tech stack consistency, business model alignment
   → Publish: to Wiki with proper headers

5. /notification-sender
   → Notify: team about documentation update
```

**Time Comparison:**
- Manual: 2 hours (research, write, validate, publish)
- With composition: 15 minutes (automated workflow)
- **Savings: 87% faster**

#### Example 2: Sprint Planning Workflow

**User Request:**
```
"Create sprint issues from memory-bank WBS with dependencies"
```

**Skill Composition:**
```
1. /memory-bank
   → Load: WBS, technical patterns, red flags

2. /task-analyzer
   → Parse: WBS structure
   → Identify: dependencies, blockers

3. /github-operations
   → Create: issues with templates
   → Link: dependencies
   → Assign: to project board

4. /project-tracker
   → Monitor: issue creation
   → Report: summary to user
```

#### Example 3: Investor Documentation Update

**User Request:**
```
"Update Wiki with Q1 metrics for investor update"
```

**Skill Composition:**
```
1. /memory-bank
   → Load: businessFocus, revenueModel, Q1 goals

2. /data-validator
   → Verify: production API endpoints
   → Extract: Q1 metrics (no hardcoding!)
   → Check: against quick-reference.json

3. /documentation-writer
   → Generate: investor update with verified metrics
   → Apply: business-model-header template

4. /github-operations
   → Validate: business model consistency
   → Check: no contradictory claims
   → Publish: to Wiki/Investment-Update-Q1.md

5. /github-operations (again)
   → Verify: push successful
   → Check: Wiki rendering
   → Report: URL to user
```

### Cross-Skill Data Sharing

**Pattern: Skill Output → Next Skill Input**

```markdown
## Data Handoff Protocol

### From memory-bank-loader to github-operations:
```json
{
  "businessFocus": "B2C outdoor recreation",
  "techStack": "Vercel + Neon + React",
  "redFlags": ["Cities in results", "Hardcoded counts"],
  "validated": true,
  "timestamp": "2025-11-06T10:00:00Z"
}
```

**github-operations checks:**
- ✅ `validated: true` → Proceed
- ❌ `validated: false` → Reload memory-bank

### From documentation-writer to github-operations:
```json
{
  "content": "# Documentation\n\n...",
  "metadata": {
    "documentType": "investor",
    "requiresBusinessModel": true,
    "techMentions": ["Vercel", "React"]
  }
}
```

**github-operations validates:**
- Business model header present?
- Tech mentions consistent with techStack?
- Investor doc template applied?
```

### Composition Best Practices

**1. Load Context Early**
```markdown
✅ GOOD:
1. Load memory-bank
2. Use context in all subsequent operations

❌ BAD:
1. Start operations
2. Realize context needed
3. Go back and load
```

**2. Validate Before Publishing**
```markdown
✅ GOOD:
1. Generate content
2. Run all validations
3. Fix issues
4. Publish

❌ BAD:
1. Generate content
2. Publish immediately
3. Discover errors
4. Fix in production
```

**3. Report Composition to User**
```markdown
When using composition, announce:

"I'm composing 3 skills for this task:
1. memory-bank-loader - Loading business context
2. documentation-writer - Generating content
3. github-operations - Validating and publishing

This will take approximately 2 minutes."
```

**4. Handle Composition Failures**
```markdown
If skill A fails in composition:
1. Report failure to user
2. Explain which step failed
3. Suggest manual alternative
4. Don't proceed to dependent skills
```

### Testing Skill Composition

**Test Pattern 1: Sequential**
```bash
# Test each skill independently first
claude -p "/memory-bank"  # Should load context
claude -p "/github-operations"  # Should work standalone

# Test composition
claude -p "/memory-bank && /github-operations validate"
# Verify: github-operations uses memory-bank data
```

**Test Pattern 2: Parallel**
```bash
# Launch multiple Claude instances
claude -p "/github-operations validate-content" &
claude -p "/tech-stack-validator check" &
claude -p "/business-model-checker verify" &

# Wait for all to complete
wait

# Aggregate results
```

**Test Pattern 3: Conditional**
```bash
# Test keyword detection
claude -p "Prepare investor documentation"
# Verify: Both business-model-validator and github-operations load

claude -p "Update Wiki with feature"
# Verify: Only github-operations and docs-writer load
```

### Debugging Composition

**Issue: Skill B doesn't receive Skill A's output**
```markdown
Solution:
1. Check if Skill A exports data in expected format
2. Verify Skill B reads from correct variable/file
3. Add explicit handoff logging

Example:
# Skill A (memory-bank-loader)
export BUSINESS_CONTEXT="/tmp/business-context.json"
cat memory-bank/quick-reference.json > "$BUSINESS_CONTEXT"

# Skill B (github-operations)
if [ -f "$BUSINESS_CONTEXT" ]; then
    echo "✅ Business context loaded from previous skill"
else
    echo "⚠️ No context from previous skill, loading directly"
    load_project_config
fi
```

**Issue: Skills conflict on resources**
```markdown
Solution:
1. Use unique temporary files per skill
2. Add skill namespacing

Example:
# Instead of: /tmp/output.json (conflict!)
# Use: /tmp/github-operations-output.json
```

**Issue: Token budget exceeded with multiple skills**
```markdown
Solution:
1. Use progressive disclosure (load on-demand)
2. Unload skills after use
3. Prefer smaller, focused skills over large monoliths

Example:
Instead of:
  - giant-documentation-skill (10,000 tokens)

Use:
  - docs-outline (500 tokens)
  - docs-content (1,500 tokens)
  - docs-validator (800 tokens)
Total: 2,800 tokens (72% reduction)
```

### Composition Metrics

**Performance Comparison:**

| Task | Solo Skill | With Composition | Improvement |
|------|------------|------------------|-------------|
| Wiki Update | 15 min | 5 min | 67% faster |
| Investor Docs | 45 min | 10 min | 78% faster |
| Sprint Planning | 30 min | 8 min | 73% faster |
| Validation | 10 min | 3 min | 70% faster |

**Token Usage Comparison:**

| Approach | Tokens | Cost |
|----------|--------|------|
| Monolithic skill | 15,000 | High |
| 3 composed skills | 4,500 | Low |
| 5 micro-skills | 6,000 | Medium |

**Recommendation:** 3-5 composed skills is optimal

### Advanced: Dynamic Composition

**Pattern: Runtime Skill Selection**

```markdown
## Dynamic Composition Based on Context

When analyzing user request:
1. Detect task type (documentation, validation, issue creation, etc.)
2. Load required skills based on task
3. Check memory-bank for project preferences
4. Dynamically compose workflow

Example:
```python
# Pseudo-code for dynamic composition
def compose_skills(user_request, memory_bank):
    skills = []

    # Always load memory-bank first
    skills.append('memory-bank-loader')

    # Detect task type
    if 'investor' in user_request or 'pitch' in user_request:
        skills.extend(['business-model-validator', 'documentation-writer'])

    if 'wiki' in user_request or 'documentation' in user_request:
        skills.append('github-operations')

    if 'sprint' in user_request or 'issues' in user_request:
        skills.extend(['project-tracker', 'github-operations'])

    # Check memory-bank for custom skills
    if memory_bank.get('customSkills'):
        skills.extend(memory_bank['customSkills'])

    return skills
```
```

### Related Documentation

- **Skill Authoring Best Practices:** https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices
- **Memory-Bank Integration:** `{baseDir}/.claude/skills/github/examples/memory-bank-integration.md`
- **Multi-Project Setup:** `{baseDir}/.claude/skills/github/docs/claude-md-integration.md`
```

**Acceptance Criteria:**
- [ ] Composition patterns documented (4 patterns)
- [ ] Practical examples provided (3 workflows)
- [ ] Data handoff protocol defined
- [ ] Best practices listed
- [ ] Testing procedures documented
- [ ] Debugging guide included
- [ ] Performance metrics shown
- [ ] Dynamic composition pattern explained

---

## Phase E: Bonus Implementation

**Goal:** Complete SKILL.md header with all best practices

**Timeline:** 15 minutes

**Dependencies:** Phase A complete (frontmatter added)

### E1. Implement Complete SKILL.md Header

**Requirement:**
Replace current SKILL.md header with complete best-practices version.

**Implementation:**
Replace lines 1-14 of SKILL.md with:

```markdown
---
name: github-operations
description: Manage GitHub Wiki, issues, and repository operations with memory-bank integration, business model validation, and SSH authentication. Automatically loads business context, applies documented lessons learned, and prevents common errors through validation automation.
allowed-tools: "Bash(git:*),Bash(gh:*),Bash(ssh:*),Bash(jq:*),Read,Write,Edit,Grep,Glob"
model: inherit
license: MIT
version: 2.0.0
---

# GitHub Operations Skill with Memory-Bank Integration

**🎯 Skill Purpose:** Intelligent GitHub automation for Wiki management, project/issue tracking, and repository operations with business context awareness and safety guardrails.

**📢 Announcement (REQUIRED):**
"I'm using the **GitHub Operations** skill to [specific action]. This skill will:
- Load business context from memory-bank (if available)
- Apply documented lessons learned from October 2025 audit
- Validate [relevant validations based on action]
- Use [specific tools: SSH/CLI/MCP] for the operation"

**🔗 Best Used With:**
- `/memory-bank` - Load business context first (recommended)
- `/documentation-writer` - Generate content, then validate here
- `/code-reviewer` - Review PRs created by this skill
- `/project-tracker` - Monitor issues created by this skill

---

## ⚠️ Critical Red Flags

### NEVER Do These Things:
- ❌ **Use fine-grained tokens for Wiki push** → Will get 403 error. Wiki requires SSH authentication.
- ❌ **Hardcode database counts** → Numbers go stale. Use "Production database (verified: DATE)" instead.
- ❌ **Mix B2B/B2C messaging** → Creates investor confusion. Add explicit business model headers.
- ❌ **Update tech stack without grep** → Creates inconsistency. Always `grep -r "TechName" .` for cross-references.
- ❌ **Skip validation scripts** → Catches errors before publish. Always run validate-wiki.sh, check-tech-stack.sh, verify-business-model.sh.

### ALWAYS Do These Things:
- ✅ **Verify SSH auth first** → Run `ssh -T git@github.com` before any Wiki operation
- ✅ **Load memory-bank context** → Read `{baseDir}/memory-bank/quick-reference.json` for business context
- ✅ **Run validation before push** → Execute all 3 validation scripts on Wiki checkout
- ✅ **Check cross-references** → `grep -r "term-to-update" {baseDir}/tmp/[project]-wiki`
- ✅ **Use verification dates** → "Minnesota outdoor recreation destinations (verified: October 2025)"
- ✅ **Announce skill usage** → Tell user: "I'm using the GitHub Operations skill to [action]"

### Quick Error Prevention Checklist:
```bash
# Before Wiki operations:
[ ] SSH verified: ssh -T git@github.com
[ ] Memory-bank loaded: cat memory-bank/quick-reference.json
[ ] Wiki cloned: git clone git@github.com:org/repo.wiki.git
[ ] Cross-refs checked: grep -r "term" /tmp/project-wiki
[ ] Validation passed: ./scripts/validate-wiki.sh /tmp/project-wiki
```

**Impact:** Prevents 90% of documented errors from October 2025 audit.

---

## 🛠️ Tool Selection Decision Table

Choose the right tool for your GitHub operation:

| Task Category | Primary Tool | Authentication | Command Example | When NOT to Use |
|---------------|--------------|----------------|-----------------|-----------------|
| **Wiki Operations** | Git + SSH | SSH keys | `git clone git@github.com:org/repo.wiki.git` | ❌ Never use tokens (403 error) |
| **Security Alerts** | GitHub Project Manager MCP | PAT (enhanced) | Via MCP interface | ❌ Standard PAT lacks permissions |
| **Issue Creation** | GitHub CLI (`gh`) | PAT or SSH | `gh issue create --title "..." --body "..."` | ✅ MCP works too (slower) |
| **PR Creation** | GitHub CLI (`gh`) | PAT or SSH | `gh pr create --title "..." --body "..."` | ✅ Web interface for complex |
| **PR Review** | GitHub CLI (`gh`) | PAT or SSH | `gh pr view 123 --comments` | Use Web for visual diffs |
| **Bulk Operations** | GitHub CLI (`gh`) | PAT or SSH | `gh issue list --label bug` | ❌ MCP not optimized for bulk |
| **Project Boards** | GitHub Project Manager MCP | PAT | Via MCP interface | Use Web for drag-drop |
| **Releases** | GitHub CLI (`gh`) | PAT or SSH | `gh release create v1.0.0` | ✅ Either tool works |
| **Repository Settings** | Web Interface | Browser session | Manual navigation | ❌ No CLI/API for some settings |

### Quick Selection Rules:

**🔴 Wiki Operations = SSH ONLY**
```bash
# ALWAYS use SSH URL for Wiki
git clone git@github.com:org/repo.wiki.git
# Fine-grained tokens WILL FAIL with 403
```

**🟡 Security Operations = MCP Required**
```bash
# Security alerts require enhanced PAT permissions
# Use GitHub Project Manager MCP, not CLI
```

**🟢 Everything Else = GitHub CLI Preferred**
```bash
# Fast, scriptable, works in CI/CD
gh issue create | gh pr create | gh repo view
```

**Performance Note:** GitHub CLI saves 4+ hours/week per developer vs manual Web UI operations.

---

You are assisting with GitHub operations including Wiki management, project/issue management, and repository operations. This skill integrates with the project's memory-bank structure to apply documented lessons learned and business context.

[Rest of SKILL.md continues with existing content...]
```

**Acceptance Criteria:**
- [ ] Frontmatter includes all required and recommended fields
- [ ] Header includes skill purpose statement
- [ ] Announcement pattern prominently displayed
- [ ] "Best Used With" section shows related skills
- [ ] Red Flags section appears before all other content
- [ ] Tool Selection table integrated into header
- [ ] Quick selection rules with color coding
- [ ] Professional formatting and visual hierarchy
- [ ] Total header length < 150 lines (progressive disclosure)

**Visual Hierarchy:**
1. **YAML Frontmatter** (meta-information)
2. **Skill Purpose** (1 sentence)
3. **Announcement Pattern** (transparency)
4. **Best Used With** (composition hints)
5. **Red Flags** (error prevention)
6. **Tool Selection** (decision support)
7. **Main Content** (existing instructions)

---

## Implementation Timeline

### Day 1 (4.5 hours)

**Morning (2 hours):**
- Phase A: Quick Wins (30 min)
  - A1-A5: Rename, frontmatter, paths, red flags, announcement
- Phase B1-B2: Enhanced UX (90 min)
  - Tool selection table, integration mapping

**Afternoon (2.5 hours):**
- Phase B3-B4: Documentation (60 min)
  - claude-md-integration.md, error messages
- Phase C1-C3: Configuration System (90 min)
  - validate-config.sh, config.sh, refactor validate-wiki.sh

### Day 2 (optional - advanced features)

**Morning (2 hours):**
- Phase C4-C6: Complete Refactoring (60 min)
  - check-tech-stack.sh, verify-business-model.sh
- Test Suite (60 min)
  - test-validation.sh, run all tests

**Afternoon (2.5 hours):**
- Phase D1: Git Worktrees (45 min)
- Phase D2: CI/CD Integration (60 min)
- Phase D3: Skill Composition (30 min)
- Phase E1: Bonus Header (15 min)

---

## Testing Strategy

### Unit Tests
- [ ] validate-config.sh with valid JSON
- [ ] validate-config.sh with invalid JSON
- [ ] validate-config.sh with missing file
- [ ] config.sh function exports
- [ ] All validation scripts with config.sh

### Integration Tests
- [ ] SKILL.md loads in Claude Code
- [ ] Frontmatter parsed correctly
- [ ] Tool permissions applied
- [ ] Red flags visible to Claude
- [ ] Announcement pattern triggers

### End-to-End Tests
- [ ] Install in portfolio-factory
- [ ] Install in nearest-nice-weather
- [ ] Test Wiki validation workflow
- [ ] Test issue creation workflow
- [ ] Test PR creation workflow
- [ ] Test CI/CD workflow

### Performance Tests
- [ ] Skill loading time < 2 seconds
- [ ] Validation scripts < 10 seconds per script
- [ ] CI/CD workflow < 2 minutes total
- [ ] Memory usage < 100MB

---

## Success Metrics

### Quantitative
- ✅ 100% tests passing
- ✅ 0 hardcoded paths remaining
- ✅ 3+ projects using skill successfully
- ✅ 95%+ error catch rate (validation scripts)
- ✅ 70% time savings in Wiki operations

### Qualitative
- ✅ Skill discoverable in Claude Code
- ✅ Clear error messages with actionable fixes
- ✅ Transparent skill usage (announcements)
- ✅ Comprehensive documentation
- ✅ Positive user feedback

---

## Risk Mitigation

### Risk 1: Breaking Changes
**Mitigation:**
- Maintain v1.1.0 branch for rollback
- Test in isolated environment first
- Gradual rollout to projects

### Risk 2: Configuration Complexity
**Mitigation:**
- Provide sensible defaults (works without config)
- Include example configs for 2 projects
- Validation script catches config errors early

### Risk 3: CI/CD Setup Difficulty
**Mitigation:**
- Step-by-step setup guide
- Troubleshooting section in docs
- Local testing with `act` before deploying

### Risk 4: Skill Discovery Issues
**Mitigation:**
- Follow official naming conventions
- Clear, action-oriented description
- Test skill loading in multiple scenarios

---

## Post-Launch Plan

### Week 1: Monitoring
- Collect feedback from portfolio-factory usage
- Collect feedback from nearest-nice-weather usage
- Monitor GitHub Actions runs
- Track validation script error rates

### Week 2: Iteration
- Fix bugs discovered in production
- Improve error messages based on feedback
- Add missing validation patterns
- Update documentation with learnings

### Month 1: Expansion
- Add worktree-manager.sh script (Phase D1.5)
- Create video tutorial
- Write blog post about lessons learned
- Contribute examples to anthropics/skills

---

## Dependencies

### Required Software
- bash 4.0+
- git 2.30+
- jq 1.6+
- gh (GitHub CLI) 2.0+
- ssh client

### Optional Software
- act (local GitHub Actions testing)
- claude (CLI for headless mode)
- docker (for containerized testing)

### Repository Dependencies
- memory-bank/ structure (optional, uses defaults if missing)
- CLAUDE.md (optional, but recommended)
- .github/workflows/ (optional, for CI/CD)

---

## Rollback Plan

### If Critical Issues Found:

**Step 1: Immediate Rollback**
```bash
# Revert to v1.1.0
git checkout v1.1.0
cp skill.md .claude/skills/github/SKILL.md
```

**Step 2: Document Issue**
```markdown
Create issue with:
- What broke
- Steps to reproduce
- Expected vs actual behavior
- Rollback timestamp
```

**Step 3: Fix in Development**
```bash
# Create fix branch
git checkout -b hotfix/issue-description

# Fix issue
# Test thoroughly
# Create PR with detailed testing notes
```

**Step 4: Gradual Re-Deployment**
```bash
# Deploy to test project first
# Monitor for 24 hours
# Deploy to nearest-nice-weather
# Monitor for 24 hours
# Deploy to portfolio-factory
```

---

## Documentation Updates Required

### README.md
- [ ] Update version to 2.0.0
- [ ] Add configuration section
- [ ] Update examples with new patterns
- [ ] Add CI/CD integration section

### CHANGELOG.md
- [ ] Document all breaking changes
- [ ] List new features (Phases A-E)
- [ ] Migration guide from v1.1.0
- [ ] Credit research sources

### New Documentation
- [ ] docs/configuration-guide.md
- [ ] docs/claude-md-integration.md
- [ ] docs/ci-cd-integration.md
- [ ] docs/skill-composition.md
- [ ] examples/portfolio-factory/
- [ ] examples/nearest-nice-weather/

---

## Approval Checklist

Before starting implementation:
- [ ] PRD reviewed by project owner
- [ ] Timeline acceptable
- [ ] Dependencies verified
- [ ] Testing strategy approved
- [ ] Risk mitigation acceptable
- [ ] Rollback plan understood

---

**Version:** 1.0
**Created:** November 6, 2025
**Author:** Claude (with human review)
**Status:** Pending Approval
**Estimated Effort:** 4.5 hours core + 4.5 hours advanced features
