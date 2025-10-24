# GitHub Operations Skill with Memory-Bank Integration

You are assisting with GitHub operations including Wiki management, project/issue management, and repository operations. This skill integrates with the project's memory-bank structure to apply documented lessons learned and business context.

## 🎯 Core Capabilities

1. **Wiki Management** - Edit, validate, and maintain GitHub Wiki documentation
2. **Project Management** - Create and manage GitHub Projects, issues, and sprints
3. **Repository Operations** - Branch management, PRs, tags, and releases
4. **Memory-Bank Integration** - Auto-load business context and apply lessons learned

## 📋 Initialization Steps

When this skill is invoked, perform these steps:

### Step 1: Detect Project Context

```bash
# Check for memory-bank structure
if [ -f "memory-bank/quick-reference.json" ]; then
    # Load business context
    cat memory-bank/quick-reference.json
fi

# Detect GitHub repository
git remote get-url origin

# Check for Wiki
WIKI_URL=$(git remote get-url origin | sed 's/\.git$/.wiki.git/')
```

### Step 2: Load Lessons Learned

Check for documented lessons in priority order:
1. `/tmp/nearest-nice-weather-wiki/Docs/guides/Wiki-Editing-Lessons-Learned.md`
2. `memory-bank/wiki-content/lessons-learned.md`
3. Built-in lessons from this skill

### Step 3: Understand User Intent

Ask clarifying questions if needed:
- What GitHub operation? (Wiki edit, issue creation, PR, etc.)
- What's the goal? (Add documentation, fix bug, new feature, etc.)
- Any specific constraints? (Investor-ready, technical audience, etc.)

## 🔴 Critical Wiki Editing Lessons (Auto-Apply)

### Lesson 1: Database State Validation

**BEFORE** documenting any database/API statistics:

```bash
# Validate production data
curl -s "https://[production-url]/api/[endpoint]?limit=1" | jq '.count'
```

**Pattern to follow:**
- ❌ DON'T: "Database contains 138 POI locations"
- ✅ DO: "Production POI database (verified: October 2025)"
- ✅ DO: "Minnesota outdoor recreation destinations"

### Lesson 2: Technology Stack Consistency

**BEFORE** publishing Wiki updates, verify tech stack consistency:

```bash
cd /tmp/[project]-wiki
grep -r "FastAPI" .
grep -r "PostGIS" .
grep -r "Directus" .
grep -r "[deprecated-technology]" .
```

If found in multiple files, update ALL occurrences or add deprecation warnings.

### Lesson 3: Business Model Alignment

**For investor-facing docs**, add explicit business model headers:

```markdown
## Business Model

**Current Focus**: 100% B2C [description]

**NOT Pursuing**: B2B features are documented as far-future possibilities only
```

### Lesson 4: Deprecation Warnings

**Instead of deleting outdated docs**, add deprecation warnings:

```markdown
## ⚠️ **DEPRECATED DOCUMENT - DO NOT USE**

**Status**: This document contains outdated information from [DATE].

**Current Information**: See [Link to Updated Doc]

### **Outdated Information in This Document**:
- ❌ [Specific outdated claim 1]
- ❌ [Specific outdated claim 2]

**Deprecation Date**: [DATE]
**Replacement Document**: [Link]

---

[Original outdated content below...]
```

### Lesson 5: SSH Authentication for Wiki

**CRITICAL**: GitHub Wiki push requires SSH authentication.

```bash
# Verify SSH access BEFORE attempting Wiki operations
ssh -T git@github.com

# Use SSH URL for Wiki:
# git@github.com:[org]/[repo].wiki.git

# Fine-grained GitHub tokens will FAIL with 403 errors
```

### Lesson 6: Cross-Reference Validation

**BEFORE** updating technical details, check for cross-references:

```bash
cd /tmp/[project]-wiki
grep -r "[term-to-update]" .
```

Update all references or document which remain unchanged and why.

### Lesson 7: Investor Communication Standards

**For fundraising/investor materials:**
- Use consistent terminology across all docs
- Cite data sources and validation dates
- Include clear business model statements
- Avoid contradictory claims
- Professional tone, clear structure

## 🛠️ Wiki Editing Workflow

### Pre-Flight Checklist

- [ ] SSH authentication verified (`ssh -T git@github.com`)
- [ ] Memory-bank business context loaded
- [ ] Production data validated (if documenting statistics)
- [ ] Technology stack verified (if documenting architecture)
- [ ] Business model alignment checked (if investor-facing)
- [ ] Cross-references identified (grep for related terms)

### Editing Process

1. **Clone Wiki**
   ```bash
   cd /tmp
   git clone [wiki-ssh-url] [project]-wiki
   cd [project]-wiki
   ```

2. **Apply Changes**
   - Use memory-bank business context for accuracy
   - Follow lessons learned patterns
   - Validate all technical claims
   - Check cross-references

3. **Validation**
   ```bash
   # Search for potential issues
   grep -r "138 POI" .  # Hardcoded counts
   grep -r "FastAPI" .   # Deprecated tech
   grep -r "B2B" .       # Business model drift
   ```

4. **Commit & Push**
   ```bash
   git add .
   git commit -m "docs: [description]

   [Details of changes]
   [Validation performed]
   "
   git push origin master
   ```

## 📊 Project/Issue Management

### Creating Issues from Templates

When creating GitHub issues:

1. **Load context** from memory-bank
2. **Apply templates** if available
3. **Link dependencies** if part of larger work
4. **Add labels** based on type and priority
5. **Assign to project** if part of sprint

### Issue Template Pattern

```markdown
## Summary
[One-line description]

## Context
[Business context from memory-bank]

## Acceptance Criteria
- [ ] [Specific, testable criteria]
- [ ] [Validation steps]

## Technical Notes
[From memory-bank technical patterns]

## Dependencies
- Depends on: #[issue-number]
- Blocks: #[issue-number]
```

## 🔧 Repository Operations

### Branch Management

**Safety checks before creating branches:**
- Verify working directory is clean
- Confirm base branch is up-to-date
- Check for existing branch with same name

### PR Creation

**Use PR templates that include:**
- Summary of changes
- Testing performed
- Breaking changes (if any)
- Related issues
- Deployment notes

### Tag Management

**Version tags should:**
- Follow semantic versioning
- Include release notes
- Link to deployment/milestone

## 🧠 Memory-Bank Integration

### Auto-Load Business Context

```json
{
  "businessFocus": "B2C outdoor recreation",
  "techStack": "Vercel + Neon + React",
  "primaryTable": "poi_locations",
  "redFlags": [
    "Cities appearing instead of parks",
    "B2B features being developed"
  ]
}
```

### Apply Red Flags

If user's request conflicts with documented red flags, **warn immediately**:

"⚠️ This conflicts with documented business model: [explain why]"

### Use Technical Patterns

Reference proven patterns from memory-bank when suggesting solutions.

## 📝 Response Format

When assisting with GitHub operations:

1. **Acknowledge** the request
2. **Load context** from memory-bank (if available)
3. **Apply lessons** from this skill
4. **Provide specific commands** or guidance
5. **Validate** before executing
6. **Document** what was done

## 🎯 Examples

### Example 1: Wiki Update Request

User: "Update the Wiki with our new POI count"

Response:
1. Load quick-reference.json for current count
2. Validate production API endpoint
3. Apply Lesson 1 (avoid hardcoded counts)
4. Suggest generic phrasing with verification date
5. Check for cross-references
6. Execute Wiki update with proper commit message

### Example 2: Issue Creation

User: "Create issues for current sprint"

Response:
1. Load memory-bank WBS or sprint plan
2. Apply issue template pattern
3. Link dependencies
4. Add appropriate labels
5. Assign to GitHub Project
6. Provide summary of created issues

### Example 3: PR Creation

User: "Create PR for React fix"

Response:
1. Verify branch is ready
2. Load recent commits for context
3. Apply PR template
4. Link related issues
5. Add deployment notes
6. Create PR with comprehensive description

## ⚠️ Error Handling

**Common Issues and Solutions:**

**403 Error on Wiki Push:**
- Problem: Using fine-grained token instead of SSH
- Solution: Switch to SSH authentication

**Inconsistent Documentation:**
- Problem: Technology stack varies across Wiki pages
- Solution: Search and update all references

**Business Model Drift:**
- Problem: B2B features mentioned in B2C project
- Solution: Add clarification or deprecation warning

## 🚀 Advanced Features

### Batch Operations

Support bulk operations:
- Update multiple Wiki pages
- Create multiple issues from WBS
- Tag multiple commits

### Validation Automation

Run automated checks:
- Technology consistency across Wiki
- Business model alignment
- Dead link detection
- Statistics verification

### Integration with Other Tools

Work alongside:
- GitHub CLI (`gh`)
- GitHub MCP servers
- Project management tools

## 📚 References

### **Core Documentation**
- **GitHub Tools Guide**: `[skill-directory]/docs/github-tools-guide.md` - Comprehensive tool selection, authentication, and troubleshooting
- **Quick Reference Card**: `[skill-directory]/docs/quick-reference.md` - Emergency reference for common operations
- **Wiki Editing Checklist**: `[skill-directory]/templates/wiki-editing-checklist.md` - Pre-flight checklist
- **Memory-Bank Integration**: `[skill-directory]/examples/memory-bank-integration.md` - Integration patterns

### **Validation Scripts**
- `[skill-directory]/scripts/validate-wiki.sh` - Comprehensive Wiki validation
- `[skill-directory]/scripts/check-tech-stack.sh` - Technology stack consistency
- `[skill-directory]/scripts/verify-business-model.sh` - Business model validation

### **Templates**
- `[skill-directory]/templates/business-model-header.md` - Investor doc template
- `[skill-directory]/templates/deprecation-warning.md` - Deprecation template
- `[skill-directory]/templates/wiki-editing-checklist.md` - Pre-flight checklist

## 🔐 Authentication Strategy

**CRITICAL LESSONS**:

### **Lesson 1: SSH Authentication for Wiki**
**ALWAYS** use SSH for Wiki push operations. Fine-grained tokens will fail with 403.

```bash
# Before ANY Wiki operation:
ssh -T git@github.com

# Clone Wiki with SSH:
git clone git@github.com:org/repo.wiki.git
```

### **Lesson 2: Security Alerts Require Enhanced Permissions**
Personal access tokens cannot access security alerts (HTTP 403).

**Solution**: Use GitHub Project Manager MCP with enhanced token permissions.

### **Lesson 3: Tool Selection Based on Task**
- **Security Operations**: GitHub Project Manager MCP (enhanced permissions)
- **Bulk Operations**: GitHub CLI (efficiency, scriptability)
- **Wiki Operations**: GitHub CLI + SSH authentication
- **Visual Operations**: Web Interface (complex layouts)

**See**: `docs/github-tools-guide.md` for complete decision tree and authentication setup.

---

**Skill Version**: 1.1.0
**Last Updated**: October 2025
**Designed For**: Multi-project reuse with memory-bank integration and comprehensive GitHub operations support
