# Changelog

All notable changes to the Claude GitHub Skill will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-24

### Added

#### Core Skill
- `skill.md` - Comprehensive GitHub operations skill prompt with memory-bank integration
- Auto-load business context from memory-bank/quick-reference.json
- Apply documented lessons learned automatically
- Red flag enforcement for business model drift detection

#### Templates
- `templates/wiki-editing-checklist.md` - Pre-flight checklist for Wiki editing operations
- `templates/deprecation-warning.md` - Template for properly deprecating outdated documentation
- `templates/business-model-header.md` - Template for investor-facing document consistency

#### Validation Scripts
- `scripts/validate-wiki.sh` - Comprehensive Wiki content validation
  - Checks for hardcoded database counts
  - Detects deprecated technology references
  - Validates business model consistency
  - Finds broken internal links
  - Identifies TODO/FIXME markers
  - Checks for business model headers in investor docs

- `scripts/check-tech-stack.sh` - Technology stack consistency validation
  - Scans for deprecated technology references
  - Checks for consistency across Wiki pages
  - Validates technology mention counts

- `scripts/verify-business-model.sh` - Business model consistency validation
  - Checks B2C vs B2B consistency
  - Validates investor documents have business model headers
  - Detects contradictory claims
  - Checks revenue model consistency

#### Documentation
- `README.md` - Comprehensive installation and usage guide
- `examples/memory-bank-integration.md` - Detailed examples showing memory-bank integration patterns
- `LICENSE` - MIT License
- `.gitignore` - Standard ignore patterns

#### Features
- Multi-project reuse design (nearest-nice-weather, portfolio-factory, future projects)
- Clean separation from project codebases
- Memory-bank integration for business context awareness
- Automated validation preventing common documentation issues
- Templates ensuring consistency across projects

### Lessons Learned Integrated

This initial release incorporates 7 critical lessons from the nearest-nice-weather Wiki audit (October 2025):

1. **Database State Validation** - Always validate production data before documenting statistics
2. **Technology Stack Consistency** - Synchronize all technology references across Wiki
3. **Business Model Alignment** - Explicit business model headers in investor documents
4. **Deprecation Warnings** - Preserve history instead of deleting outdated docs
5. **SSH Authentication** - Wiki push requires SSH, fine-grained tokens fail with 403
6. **Cross-Reference Validation** - Update all references when changing technical details
7. **Investor Communication Standards** - Consistent terminology and professional tone

### Design Principles

- **Reusable**: Designed for use across multiple projects via git clone or submodule
- **Memory-Bank First**: Automatically loads business context and technical patterns
- **Lessons Applied**: Prevents recurring issues through automated checks
- **Template-Driven**: Consistent documentation structure across projects
- **Validation-First**: Catch issues before they reach production

### Installation

```bash
# Option 1: Git Clone (Recommended)
cd /path/to/your-project/.claude/skills
git clone git@github.com:PrairieAster-Ai/claude-github-skill.git github

# Option 2: Git Submodule
cd /path/to/your-project/.claude/skills
git submodule add git@github.com:PrairieAster-Ai/claude-github-skill.git github
```

### Usage

```bash
# Invoke the skill in Claude Code
/github

# Or call specific validation scripts directly
./github/scripts/validate-wiki.sh /tmp/project-wiki
./github/scripts/check-tech-stack.sh /tmp/project-wiki
./github/scripts/verify-business-model.sh /tmp/project-wiki
```

---

**Repository**: https://github.com/PrairieAster-Ai/claude-github-skill
**Initial Commit**: 1046b3d
**Created**: October 24, 2025
