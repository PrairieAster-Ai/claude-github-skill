# Claude GitHub Skill

A comprehensive Claude Code skill for GitHub operations with memory-bank integration, designed for multi-project reuse.

## 🎯 Purpose

This skill provides intelligent GitHub automation for:
- **Wiki Management** with validation and consistency checks
- **Project/Issue Management** with templates and workflows
- **Repository Operations** with safety guardrails
- **Memory-Bank Integration** for business context awareness

## 📦 Installation

### Option 1: Git Clone (Recommended)

```bash
# Navigate to your project's .claude/skills directory
cd /path/to/your-project/.claude/skills

# Clone the skill
git clone git@github.com:PrairieAster-Ai/claude-github-skill.git github
```

### Option 2: Git Submodule

```bash
# Add as submodule to track updates
git submodule add git@github.com:PrairieAster-Ai/claude-github-skill.git .claude/skills/github
git submodule update --init --recursive
```

### Option 3: Manual Copy

Download and copy the `skill.md` file to `.claude/skills/github/skill.md` in your project.

## 🚀 Usage

Once installed, invoke the skill in your Claude Code conversation:

```
/github
```

The skill will automatically:
1. Detect your project's memory-bank structure
2. Load business context and technical patterns
3. Apply documented lessons learned
4. Provide GitHub operation assistance

### Common Use Cases

**Wiki Editing:**
```
/github - I need to update the Wiki with new feature documentation
```

**Project Management:**
```
/github - Create issues for the current sprint from our WBS
```

**Repository Operations:**
```
/github - Create a PR for the React fix with proper templates
```

## 📋 Features

### Wiki Management
- ✅ Validates technical claims against live APIs
- ✅ Checks technology stack consistency
- ✅ Enforces business model alignment
- ✅ Applies deprecation warnings correctly
- ✅ SSH authentication (avoids 403 errors)

### Project/Issue Management
- ✅ Template-based issue creation
- ✅ Sprint board management
- ✅ Dependency tracking
- ✅ Status reporting

### Repository Operations
- ✅ Branch management with safety checks
- ✅ PR creation with templates
- ✅ Tag and release automation
- ✅ Git workflow guidance

### Memory-Bank Integration
- ✅ Auto-loads business context
- ✅ Applies technical patterns
- ✅ Enforces red flags
- ✅ Leverages lessons learned

## 🏗️ Memory-Bank Structure

The skill expects the following optional structure in your project:

```
memory-bank/
├── quick-reference.json          # Business context, tech stack, red flags
├── business-context/             # Core business model
├── technical-patterns/           # Proven patterns and anti-patterns
└── wiki-content/                 # Wiki templates and lessons
```

If memory-bank doesn't exist, the skill will work in standalone mode.

## 📚 Documentation

### Lessons Learned

This skill incorporates documented lessons from:
- Wiki editing sessions (database validation, tech stack consistency)
- GitHub authentication patterns (SSH vs tokens)
- Business model alignment checks
- Deployment and CI/CD workflows

### Templates Included

- `templates/wiki-editing-checklist.md` - Pre-flight checklist
- `templates/deprecation-warning.md` - For outdated docs
- `templates/business-model-header.md` - Investor consistency
- `templates/pr-template.md` - Pull request template

### Scripts Included

- `scripts/validate-wiki.sh` - Wiki validation automation
- `scripts/check-tech-stack.sh` - Technology consistency check
- `scripts/verify-business-model.sh` - Business model validation

## 🔧 Configuration

The skill auto-configures based on your project, but you can customize via environment variables:

```bash
# Optional: Override Wiki URL detection
export GITHUB_WIKI_URL="https://github.com/your-org/your-repo/wiki"

# Optional: Specify memory-bank location
export MEMORY_BANK_PATH="./memory-bank"
```

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add your improvements
4. Submit a pull request

### Adding Lessons Learned

Document your lessons in `examples/` with:
- Problem description
- Impact assessment
- Prevention patterns
- Code examples

## 📖 Examples

See `examples/` directory for:
- `nearest-nice-weather/` - Original use case and patterns
- `portfolio-factory/` - Multi-project usage example

## 🔐 Authentication

**IMPORTANT**: GitHub Wiki requires SSH authentication for push operations.

Fine-grained GitHub tokens will fail with 403 errors. Verify SSH access:

```bash
ssh -T git@github.com
```

## 📄 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

Built from documented lessons learned across multiple projects, designed for reusability and continuous improvement.

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Status**: Active Development
