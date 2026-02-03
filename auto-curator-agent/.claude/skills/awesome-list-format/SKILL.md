---
name: awesome-list-format
description: Formatting rules for the awesome-docker-cagent README.md including markdown table syntax, section structure, category placement, badge formatting, and YAML code block examples
---

# Awesome List Formatting Skill

## README.md Section Structure

The awesome-docker-cagent README.md has these sections in order:

1. `## 📝 Join our Community` — Static, don't modify
2. `## 📚 Official Resources` — Docker official docs only
3. `## 🔌 cagent + MCP` — MCP integration resources
4. `## 🖥️ cagent + Docker Model Runner` — DMR resources
5. `## 💻 cagent + IDE (ACP)` — IDE/ACP integration resources
6. `## 🔍 cagent + RAG` — RAG configuration resources
7. `## 📖 General Resources` — Getting started, advanced, community blogs
8. `## 💻 GitHub Sample Projects` — Official and community projects
9. `## 🔧 MCP Servers for cagent` — MCP server catalog
10. `## 🎬 Featured Videos` — Video content
11. `## 🤝 Contributing` — Static, don't modify

## Table Formats by Section

### Blogs & Articles (used in MCP, DMR, IDE, RAG, General sections)
```markdown
| [Article Title](https://example.com/article) | Source Name | Brief one-line description |
```

### Documentation Tables
```markdown
| [Resource Name](https://docs.example.com) | Brief description |
```

### GitHub Sample Projects - Official
```markdown
| [Project Name](https://github.com/org/repo) | Brief description |
```

### GitHub Sample Projects - Community
```markdown
| [project-name](https://github.com/user/repo) | Brief description | Author Name |
```

### MCP Servers
```markdown
| [server-name](https://github.com/org/repo) | Brief description | XXX⭐ |
```
Note: Include approximate star count. Check the repo for current count.

## Categorization Rules

### Goes in "cagent + MCP" section:
- Articles about MCP server integration with cagent
- MCP configuration examples
- MCP gateway/catalog content

### Goes in "cagent + Docker Model Runner" section:
- Local model execution with DMR
- DMR configuration guides
- Privacy-first / offline agent content

### Goes in "cagent + IDE (ACP)" section:
- Agent Client Protocol content
- IDE integration (Zed, Neovim, VS Code, JetBrains)
- Editor plugin documentation

### Goes in "cagent + RAG" section:
- RAG configuration and strategies
- Embedding model setup
- Knowledge base integration

### Goes in "General Resources" section:
- Getting started guides
- Architecture overviews
- Advanced topics not fitting other categories
- Community blog posts

### Goes in "GitHub Sample Projects" section:
- Repos containing cagent YAML configs
- Example agent implementations
- Tools built on top of cagent

### Goes in "MCP Servers for cagent" section:
- MCP server repos that work with Docker/cagent
- Must be actual server implementations, not articles

## Code Block Examples
When adding YAML examples, use this format:
````markdown
```yaml
# Comment explaining the example
agents:
  root:
    model: openai/gpt-4o
    # ... config
```
````

## Important Rules
1. Always add new entries at the END of the relevant table
2. Never reorder existing entries
3. Keep descriptions to one concise line (under 100 chars ideally)
4. Use consistent link formatting — no trailing slashes on URLs
5. For GitHub repos, link to the repo root, not a specific file
6. Verify the table header row matches when adding entries
7. Maintain blank lines between sections
