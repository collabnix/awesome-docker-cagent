#!/bin/bash
# =============================================================================
# Auto-Curator Agent Setup Script
# =============================================================================
# Creates a complete multi-agent system to maintain the awesome-docker-cagent
# list using Docker cagent + GitHub Models (free tier).
#
# Usage:
#   chmod +x setup-auto-curator.sh
#   ./setup-auto-curator.sh
#   cd auto-curator-agent
#   export GITHUB_TOKEN=your_github_pat
#   cagent run ./cagent-curator.yaml "Find new cagent resources"
# =============================================================================

set -e

DIR="auto-curator-agent"

echo "🚀 Setting up Auto-Curator Agent in ./$DIR"
echo "================================================"

# Create directory structure
mkdir -p "$DIR/.claude/skills/awesome-list-format"
mkdir -p "$DIR/.claude/skills/link-validation"
mkdir -p "$DIR/.claude/skills/resource-discovery"

# =============================================================================
# 1. Main cagent YAML
# =============================================================================
echo "📄 Creating cagent-curator.yaml..."
cat > "$DIR/cagent-curator.yaml" << 'YAML_EOF'
#!/usr/bin/env cagent run
version: "3"

# =============================================================================
# Awesome Docker cagent - Auto Curator Agent
# =============================================================================
# A multi-agent system that maintains the awesome-docker-cagent list by:
#   1. Discovering new cagent resources (blogs, repos, videos, MCP servers)
#   2. Validating existing links for freshness and broken URLs
#   3. Categorizing resources into the correct sections
#   4. Submitting PRs to update the awesome list
#
# Uses GitHub Models (free tier) - requires GITHUB_TOKEN
#
# Usage:
#   export GITHUB_TOKEN=your_github_token
#   cagent run ./cagent-curator.yaml "Find new cagent blog posts from the last week"
#   cagent run ./cagent-curator.yaml "Check all links in the awesome list for broken URLs"
#   cagent run ./cagent-curator.yaml "Search for new MCP servers compatible with cagent"
#   cagent run ./cagent-curator.yaml "Create a PR adding the latest resources you found"
# =============================================================================

# GitHub Models as a custom provider - uses OpenAI-compatible API
# There is no built-in "github" provider in cagent, so we define one here
# via the providers section. See: https://github.com/docker/cagent/blob/main/docs/PROVIDERS.md
providers:
  github:
    api_type: openai_chatcompletions
    base_url: https://models.github.ai/inference
    token_key: GITHUB_TOKEN

models:
  smart:
    provider: github
    model: openai/gpt-4o
    max_tokens: 8192

  fast:
    provider: github
    model: openai/gpt-4o-mini
    max_tokens: 4096

agents:
  # ---------------------------------------------------------------------------
  # ROOT AGENT: Curator Coordinator
  # ---------------------------------------------------------------------------
  root:
    model: smart
    skills: true
    description: |
      Coordinates maintenance of the awesome-docker-cagent list at
      github.com/collabnix/awesome-docker-cagent. Discovers new resources,
      validates links, and submits PRs.
    instruction: |
      You are the curator of the awesome-docker-cagent list, a community-maintained
      collection of Docker cagent resources hosted at:
      https://github.com/collabnix/awesome-docker-cagent

      ## Your Responsibilities

      1. **Discover** new cagent resources by delegating to the `discoverer` agent
      2. **Validate** links and content quality via the `validator` agent
      3. **Format** entries correctly using the awesome-list-format skill
      4. **Submit** changes via the `publisher` agent as GitHub PRs

      ## Workflow for Finding New Resources

      1. Delegate to `discoverer` to search for new blogs, repos, videos, MCP servers
      2. Delegate to `validator` to check each URL is live and content is relevant
      3. Format validated resources into the correct markdown table format
      4. Delegate to `publisher` to create a branch and PR with the additions

      ## Workflow for Link Checking

      1. Read the current README.md from the repo
      2. Delegate to `validator` to check all existing URLs
      3. Report broken links with recommendations (remove, update, or replace)
      4. Optionally delegate to `publisher` to create a PR fixing broken links

      ## Quality Standards
      - Only include resources specifically about Docker cagent (not generic Docker)
      - Prefer official sources, well-known tech blogs, and active GitHub repos
      - Exclude paywalled content, spam, or low-quality posts
      - Each entry must have: title, source/author, and brief description
      - Repos should have meaningful content (not just a fork or empty README)

      ## Repository Details
      - Owner: collabnix
      - Repo: awesome-docker-cagent
      - Main file: README.md
      - Default branch: main

    sub_agents: [discoverer, validator, publisher]

    toolsets:
      - type: filesystem
      - type: think
      - type: todo
      - type: mcp
        ref: docker:github

  # ---------------------------------------------------------------------------
  # DISCOVERER AGENT: Finds new cagent resources
  # ---------------------------------------------------------------------------
  discoverer:
    model: smart
    skills: true
    description: |
      Searches the web and GitHub for new Docker cagent resources including
      blog posts, tutorials, sample projects, MCP servers, and videos.
    instruction: |
      You are a research specialist focused on discovering new Docker cagent resources.

      ## Search Strategy

      ### For Blog Posts & Articles
      Search for recent content about:
      - "docker cagent" (exact phrase)
      - "cagent multi-agent"
      - "cagent MCP"
      - "cagent docker model runner"
      - "cagent yaml agent"

      Good sources: docker.com/blog, dev.to, medium.com, dzone.com,
      collabnix.com, hashnode, personal tech blogs

      ### For GitHub Repositories
      Search GitHub for repos with:
      - "cagent" in name or description
      - Topics: docker-cagent, cagent
      - Recent activity (updated within last month)
      - Must have meaningful content (not forks, not empty)

      ### For MCP Servers
      Search for:
      - MCP servers that work with Docker containers
      - New entries in Docker MCP catalog
      - Community MCP servers on GitHub

      ### For Videos
      Search for:
      - YouTube videos about "docker cagent"
      - Conference talks mentioning cagent
      - Tutorial/walkthrough videos

      ## Output Format
      For each resource found, provide:
      1. Title (exact)
      2. URL
      3. Source/Author
      4. Brief description (1 line)
      5. Suggested category from the awesome list
      6. Why it's worth including

      ## Deduplication
      Always check against the current README.md to avoid suggesting
      resources that are already listed.

    toolsets:
      - type: mcp
        ref: docker:duckduckgo
      - type: fetch
      - type: filesystem
      - type: mcp
        ref: docker:github

  # ---------------------------------------------------------------------------
  # VALIDATOR AGENT: Checks links and content quality
  # ---------------------------------------------------------------------------
  validator:
    model: fast
    skills: true
    description: |
      Validates URLs, checks content relevance, and ensures resources
      meet the awesome list quality standards.
    instruction: |
      You are a quality assurance specialist for the awesome-docker-cagent list.

      ## URL Validation
      For each URL provided:
      1. Fetch the URL and check if it returns a valid response
      2. Verify the content is actually about Docker cagent (not just Docker)
      3. Check if the content is still current (not outdated/deprecated)
      4. For GitHub repos: check if the repo is active and not archived

      ## Quality Checks
      - Content must be specifically about Docker cagent
      - Blog posts should have substantive content (not just a link dump)
      - GitHub repos should have: README, meaningful code/configs, recent commits
      - MCP servers should have: working configuration, documentation
      - Videos should be accessible and have reasonable production quality

      ## Output
      For each resource, report:
      - ✅ VALID: URL works, content is relevant and high-quality
      - ⚠️ WARNING: URL works but content may be outdated or borderline
      - ❌ BROKEN: URL returns error (include HTTP status code)
      - 🚫 REJECTED: Content doesn't meet quality standards (explain why)

    toolsets:
      - type: filesystem
      - type: fetch
      - type: think
      - type: mcp
        ref: docker:github

  # ---------------------------------------------------------------------------
  # PUBLISHER AGENT: Creates branches and PRs
  # ---------------------------------------------------------------------------
  publisher:
    model: smart
    skills: true
    description: |
      Creates GitHub branches and pull requests to update the
      awesome-docker-cagent README.md with new resources.
    instruction: |
      You are responsible for publishing changes to the awesome-docker-cagent list
      via GitHub pull requests.

      ## Workflow

      1. **Read current README.md** from collabnix/awesome-docker-cagent
      2. **Create a branch** named: `curator/add-resources-YYYY-MM-DD` or
         `curator/fix-links-YYYY-MM-DD`
      3. **Update README.md** with the new entries, placed in the correct sections
      4. **Create a PR** with:
         - Clear title: "Add X new resources" or "Fix broken links"
         - Body listing all changes with links
         - Label: "curator-bot" if available

      ## Formatting Rules (CRITICAL)
      Follow the awesome-list-format skill exactly. The README uses markdown tables:

      For blogs/articles:
      ```
      | [Title](URL) | Source | Description |
      ```

      For GitHub projects:
      ```
      | [project-name](URL) | Description | Author |
      ```

      For MCP servers:
      ```
      | [server-name](URL) | Description | Stars |
      ```

      ## Important
      - Never overwrite existing entries
      - Add new entries at the END of the relevant table section
      - Preserve all existing formatting
      - Test that the markdown renders correctly
      - Include the SHA of the file being updated to avoid conflicts

      ## Repository Details
      - Owner: collabnix
      - Repo: awesome-docker-cagent
      - File: README.md
      - Branch: main

    toolsets:
      - type: filesystem
      - type: think
      - type: mcp
        ref: docker:github
YAML_EOF

# =============================================================================
# 2. Skill: awesome-list-format
# =============================================================================
echo "📝 Creating awesome-list-format skill..."
cat > "$DIR/.claude/skills/awesome-list-format/SKILL.md" << 'SKILL_EOF'
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
SKILL_EOF

# =============================================================================
# 3. Skill: link-validation
# =============================================================================
echo "🔗 Creating link-validation skill..."
cat > "$DIR/.claude/skills/link-validation/SKILL.md" << 'SKILL_EOF'
---
name: link-validation
description: Link validation patterns for checking URLs, detecting broken links, identifying redirects, verifying GitHub repo activity, and assessing content freshness for the awesome list
---

# Link Validation Skill

## Validation Strategy

### Step 1: Extract All Links
Parse the README.md and extract every URL. Group by section for organized reporting.

### Step 2: Check Each URL
For each URL, determine status:

- **200 OK** → ✅ Link is live
- **301/302 Redirect** → ⚠️ Update URL to final destination
- **403 Forbidden** → ⚠️ May be geo-blocked or rate-limited, retry later
- **404 Not Found** → ❌ Broken link, needs removal or replacement
- **5xx Server Error** → ⚠️ Temporary, recheck before removing
- **Timeout** → ⚠️ Slow server, retry once

### Step 3: GitHub Repo Specific Checks
For GitHub repository links:
1. Check if repo exists (not 404)
2. Check if repo is archived (`archived: true` in API response)
3. Check last commit date — flag if >6 months stale
4. Check star count for MCP server entries (update if changed significantly)

### Step 4: Content Relevance Check
For blog/article links that are live:
1. Fetch the page content
2. Verify it mentions "cagent" or "docker agent" (not just generic Docker)
3. Check if content is outdated (references deprecated APIs or old versions)

## Reporting Format

```
## Link Validation Report — YYYY-MM-DD

### ✅ Valid Links (X/Y)
All links in these sections are working: [list sections]

### ⚠️ Warnings (X)
| URL | Issue | Recommendation |
|-----|-------|----------------|
| ... | 301 redirect | Update to new URL |
| ... | Repo archived | Consider removing |

### ❌ Broken Links (X)
| URL | Section | Status | Action |
|-----|---------|--------|--------|
| ... | MCP     | 404    | Remove entry |

### 📊 GitHub Repo Stats Updates
| Repo | Old Stars | Current Stars |
|------|-----------|---------------|
| ...  | 100⭐     | 250⭐         |
```

## Rate Limiting
- GitHub API: Max 60 requests/hour unauthenticated, 5000 with token
- Space requests 1 second apart for non-GitHub URLs
- Use the GitHub MCP tool for repo checks (uses authenticated token)
SKILL_EOF

# =============================================================================
# 4. Skill: resource-discovery
# =============================================================================
echo "🔍 Creating resource-discovery skill..."
cat > "$DIR/.claude/skills/resource-discovery/SKILL.md" << 'SKILL_EOF'
---
name: resource-discovery
description: Search strategies for finding new Docker cagent resources including blog posts, GitHub repositories, MCP servers, YouTube videos, conference talks, and community content
---

# Resource Discovery Skill

## Search Queries by Category

### Blog Posts & Articles
Run these searches via DuckDuckGo:
1. `"docker cagent" blog` — General blog posts
2. `"cagent" "multi-agent" tutorial` — Tutorials
3. `site:dev.to cagent docker` — Dev.to articles
4. `site:medium.com docker cagent` — Medium posts
5. `site:docker.com/blog cagent` — Official Docker blog
6. `"cagent" site:dzone.com OR site:infoq.com` — Enterprise tech sites
7. `"cagent" yaml agent 2025 OR 2026` — Recent content

### GitHub Repositories
Use GitHub search (via MCP tool):
1. Search repos: `cagent` in name or description
2. Search repos: topic `docker-cagent`
3. Search code: `filename:cagent.yaml` or `filename:cagent-*.yaml`
4. Search repos: `"cagent run"` in README
5. Filter: pushed within last 30 days, has stars

### MCP Servers
1. Search GitHub: `mcp-server docker` with recent activity
2. Search: `"type: mcp" "ref: docker"` in YAML files
3. Check Docker MCP catalog for new additions
4. Search: `"mcp server" "docker container"` on GitHub

### Videos
1. Search: `"docker cagent" site:youtube.com`
2. Search: `cagent "docker" conference talk`
3. Check Docker's official YouTube channel for new uploads

## Deduplication Process

Before suggesting any resource:
1. Read the current README.md from the repo
2. Extract all existing URLs into a set
3. Compare each new finding against the set
4. Only suggest truly new resources

## Quality Scoring

Rate each resource 1-5:
- **5**: Official Docker content, major tech publication, highly starred repo
- **4**: Well-written tutorial from known author, active community project
- **3**: Decent blog post, working example repo with docs
- **2**: Basic content, minimal repo, or borderline relevance
- **1**: Low quality, spam, or not specifically about cagent

Only suggest resources scoring 3 or above.

## Output Template

For each new resource found:
```
### [Title]
- URL: https://...
- Category: [section name from awesome list]
- Quality Score: X/5
- Description: One-line summary
- Why include: Brief justification
- Table entry: | [Title](URL) | Source | Description |
```
SKILL_EOF

# =============================================================================
# 5. README
# =============================================================================
echo "📖 Creating README.md..."
cat > "$DIR/README.md" << 'README_EOF'
# 🤖 Auto-Curator Agent for awesome-docker-cagent

A multi-agent system built with **Docker cagent** that automatically maintains
the [awesome-docker-cagent](https://github.com/collabnix/awesome-docker-cagent) list.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Root: Curator                        │
│              (gpt-4o via GitHub Models)              │
│         Skills: awesome-list-format                  │
│         Tools: GitHub MCP, filesystem, think, todo   │
├──────────────┬──────────────┬───────────────────────┤
│  Discoverer  │  Validator   │      Publisher         │
│  (gpt-4o)    │ (gpt-4o-mini)│      (gpt-4o)         │
│  DuckDuckGo  │  fetch       │      GitHub MCP       │
│  GitHub MCP  │  GitHub MCP  │      filesystem        │
│  fetch       │  think       │      think             │
└──────────────┴──────────────┴───────────────────────┘
```

## Prerequisites

- Docker Desktop 4.49+ with MCP Toolkit enabled
- cagent binary ([download](https://github.com/docker/cagent))
- GitHub Personal Access Token with `repo` scope

## Setup

```bash
# 1. Set your GitHub token
export GITHUB_TOKEN=your_github_pat_here

# 2. Verify cagent is installed
cagent --version
```

## How It Works

Uses **GitHub Models** (free tier) — no OpenAI/Anthropic API key needed.

There's no built-in `github` provider in cagent, so we define one using
the `providers:` section (custom provider alias):

```yaml
providers:
  github:
    api_type: openai_chatcompletions
    base_url: https://models.github.ai/inference
    token_key: GITHUB_TOKEN

models:
  smart:
    provider: github      # References custom provider above
    model: gpt-4o
  fast:
    provider: github
    model: gpt-4o-mini
```

> **Reference:** [PROVIDERS.md](https://github.com/docker/cagent/blob/main/docs/PROVIDERS.md)
> and [this Docker blog post](https://www.docker.com/blog/configure-cagent-github-models/)

## Usage

### Discover new resources
```bash
cagent run ./cagent-curator.yaml "Find new Docker cagent blog posts from the last 2 weeks"
```

### Check for broken links
```bash
cagent run ./cagent-curator.yaml "Read the awesome-docker-cagent README and check all URLs for broken links"
```

### Full maintenance with PR
```bash
cagent run ./cagent-curator.yaml "Find new cagent resources, validate them, and create a PR adding them to the awesome list"
```

### Update star counts
```bash
cagent run ./cagent-curator.yaml "Check and update star counts for all MCP servers in the list"
```

## Skills (v3)

This agent uses cagent **version 3** with skills enabled. Skills auto-load
from `.claude/skills/*/SKILL.md`:

| Skill | Purpose |
|-------|---------|
| `awesome-list-format` | README.md section structure, table formats, categorization rules |
| `link-validation` | URL checking, GitHub repo activity, content freshness |
| `resource-discovery` | Search strategies, quality scoring, deduplication |

## Automate with GitHub Actions

Add this to your awesome-docker-cagent repo as `.github/workflows/curate.yml`:

```yaml
name: Weekly Curation
on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday 9am UTC
  workflow_dispatch:

jobs:
  curate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/cagent-action@v1
        with:
          config: auto-curator-agent/cagent-curator.yaml
          prompt: "Find new cagent resources published this week, validate them, and create a PR"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Push to Docker Hub

```bash
docker login
cagent push ./cagent-curator.yaml docker.io/ajeetraina/awesome-cagent-curator:latest
```

Then anyone can run it:
```bash
cagent run docker.io/ajeetraina/awesome-cagent-curator:latest "Find new cagent resources"
```
README_EOF

# =============================================================================
# Done!
# =============================================================================
echo ""
echo "================================================"
echo "✅ Auto-Curator Agent created successfully!"
echo "================================================"
echo ""
echo "Directory structure:"
find "$DIR" -type f | sort | sed 's/^/  /'
echo ""
echo "Next steps:"
echo "  cd $DIR"
echo "  export GITHUB_TOKEN=your_github_pat"
echo "  cagent run ./cagent-curator.yaml \"Find new cagent blog posts\""
echo ""
