# 🤖 Awesome Docker cagent - Auto-Curator Agent

A cagent multi-agent system that **maintains itself** — it discovers new Docker cagent resources, validates links, and submits PRs to keep the [awesome-docker-cagent](https://github.com/collabnix/awesome-docker-cagent) list fresh.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      CURATOR (Root)                             │
│                                                                 │
│  • Coordinates all maintenance tasks                           │
│  • Applies awesome-list-format skill for consistent entries    │
│  • Decides what to add, update, or remove                      │
└─────────────────────┬───────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────────┐ ┌───────────┐ ┌───────────┐
│  DISCOVERER   │ │ VALIDATOR │ │ PUBLISHER  │
│               │ │           │ │            │
│ • Web search  │ │ • Check   │ │ • Create   │
│ • GitHub API  │ │   URLs    │ │   branches │
│ • Find repos  │ │ • Quality │ │ • Update   │
│ • Find blogs  │ │   scoring │ │   README   │
│               │ │ • Freshness│ │ • Open PRs │
└───────────────┘ └───────────┘ └───────────┘
      │                 │             │
      ▼                 ▼             ▼
┌───────────┐    ┌───────────┐  ┌──────────┐
│ DuckDuckGo│    │   Fetch   │  │  GitHub  │
│    MCP    │    │   Tool    │  │   MCP    │
└───────────┘    └───────────┘  └──────────┘

Skills Layer (.claude/skills/):
┌────────────────────┬──────────────────┬────────────────────┐
│ awesome-list-format│ link-validation  │ resource-discovery │
│ Table syntax,      │ URL checking,    │ Search strategies, │
│ section structure, │ GitHub activity, │ quality scoring,   │
│ categorization     │ content checks   │ deduplication      │
└────────────────────┴──────────────────┴────────────────────┘
```

## Prerequisites

- Docker Desktop 4.49+ (includes cagent)
- GitHub Token with `repo` and `models:read` scope: `export GITHUB_TOKEN=your_token`

## Usage

### 🔍 Discover New Resources

```bash
# Find new blog posts from the last week
cagent run ./cagent-curator.yaml "Find new Docker cagent blog posts published this week"

# Search for new GitHub repos
cagent run ./cagent-curator.yaml "Search GitHub for new cagent projects with at least 5 stars"

# Find new MCP servers
cagent run ./cagent-curator.yaml "Find new MCP servers that work with Docker containers"

# Comprehensive discovery
cagent run ./cagent-curator.yaml "Do a full discovery sweep: find new blogs, repos, MCP servers, and videos about Docker cagent"
```

### ✅ Validate Existing Links

```bash
# Check all links in the awesome list
cagent run ./cagent-curator.yaml "Read the awesome-docker-cagent README and check all URLs for broken links"

# Check a specific section
cagent run ./cagent-curator.yaml "Validate all GitHub repo links in the Sample Projects section"

# Update star counts
cagent run ./cagent-curator.yaml "Check and update star counts for all MCP servers in the list"
```

### 📝 Submit Updates via PR

```bash
# Find and submit new resources
cagent run ./cagent-curator.yaml "Find new cagent resources, validate them, and create a PR adding them to the awesome list"

# Fix broken links
cagent run ./cagent-curator.yaml "Check for broken links and create a PR removing or updating them"

# Weekly maintenance
cagent run ./cagent-curator.yaml "Perform weekly maintenance: discover new resources, validate all links, update star counts, and submit a PR with all changes"
```

## Skills

| Skill | Purpose |
|-------|---------|
| `awesome-list-format` | Ensures entries match the README's markdown table format and go in the right section |
| `link-validation` | Systematic URL checking with GitHub API integration for repo health |
| `resource-discovery` | Optimized search queries and quality scoring for finding relevant content |

## Configuration

Uses **GitHub Models** (free tier) — no OpenAI/Anthropic API key needed:

```yaml
# Define GitHub as a custom provider (OpenAI-compatible API)
providers:
  github:
    api_type: openai_chatcompletions
    base_url: https://models.github.ai/inference
    token_key: GITHUB_TOKEN

models:
  smart:
    provider: github
    model: openai/gpt-4o
  fast:
    provider: github
    model: openai/gpt-4o-mini
```

> **Important:** GitHub Models requires the `openai/` vendor prefix in model names.
> Using just `gpt-4o` will result in a `403 Forbidden` error.

> **Note:** There's no built-in `github` provider in cagent. The `providers:` section
> creates a custom alias that maps to GitHub Models' OpenAI-compatible endpoint.
> See [PROVIDERS.md](https://github.com/docker/cagent/blob/main/docs/PROVIDERS.md).

## GitHub Token Setup

Your GitHub PAT needs these permissions:

| Permission | Scope | Why |
|-----------|-------|-----|
| `repo` | Repository | Read/write awesome-list repo, create branches and PRs |
| `models:read` | Account | Access GitHub Models API for LLM inference |

Create a fine-grained PAT at: https://github.com/settings/personal-access-tokens

## How It Works

1. **Discovery**: The `discoverer` agent searches DuckDuckGo and GitHub for new cagent content
2. **Validation**: The `validator` agent checks each URL, verifies content relevance, and scores quality
3. **Formatting**: The root agent applies the `awesome-list-format` skill to create properly formatted table entries
4. **Publishing**: The `publisher` agent reads the current README, creates a branch, adds new entries in the correct sections, and opens a PR

## Automation Ideas

### GitHub Actions (Weekly Curation)
```yaml
# .github/workflows/curate.yml
name: Weekly Curation
on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9am
  workflow_dispatch:

jobs:
  curate:
    runs-on: ubuntu-latest
    steps:
      - uses: docker/cagent-action@v1
        with:
          config: cagent-curator.yaml
          prompt: "Perform weekly maintenance: find new resources and create a PR"
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Push to Docker Hub
```bash
docker login
cagent push ./cagent-curator.yaml docker.io/ajeetraina/awesome-cagent-curator:latest
```
