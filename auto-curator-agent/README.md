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

Skills Layer (.claude/skills/) — full version only:
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

## Quick Start

```bash
export GITHUB_TOKEN=your_github_pat

# Use the LITE version (recommended for GitHub Models free tier)
cagent run ./cagent-curator-lite.yaml "Find new cagent blog posts"
```

## Two Configs: Full vs Lite

| | `cagent-curator.yaml` (Full) | `cagent-curator-lite.yaml` (Lite) |
|---|---|---|
| **Skills** | ✅ 3 skill files loaded | ❌ Disabled (saves ~2,500 tokens) |
| **Instructions** | Detailed with examples | Condensed essentials |
| **Sub-agent model** | gpt-4o (smart) | gpt-4o-mini (fast) |
| **Token budget** | ~4,500+ tokens overhead | ~1,500 tokens overhead |
| **Best for** | Paid GitHub Models / other providers | GitHub Models **free tier** |

> **⚠️ GitHub Models free tier limits gpt-4o to 8,000 input tokens per request.**
> Skills + detailed instructions + fetched content can easily exceed this.
> Use the **lite** version unless you have paid GitHub Models or another provider.

## Usage

### 🔍 Discover New Resources

```bash
# Basic discovery
cagent run ./cagent-curator-lite.yaml "Find new Docker cagent blog posts published this week"

# Specific and targeted (recommended — see Prompting Tips below)
cagent run ./cagent-curator-lite.yaml "Search for blog posts that specifically mention 'cagent' the Docker multi-agent runtime tool. Only include posts that discuss cagent YAML configs, cagent run commands, or multi-agent orchestration with cagent. Exclude generic Docker or Docker Model Runner posts."

# Search GitHub repos
cagent run ./cagent-curator-lite.yaml "Search GitHub for new cagent projects with at least 5 stars"

# Full sweep with dedup check
cagent run ./cagent-curator-lite.yaml "Read the current README from collabnix/awesome-docker-cagent, then search for new blog posts about Docker cagent that are NOT already in the list. Only include posts that specifically discuss cagent."
```

### ✅ Validate Existing Links

```bash
# Check all links in the awesome list
cagent run ./cagent-curator-lite.yaml "Read the awesome-docker-cagent README and check all URLs for broken links"

# Check a specific section
cagent run ./cagent-curator-lite.yaml "Validate all GitHub repo links in the Sample Projects section"
```

### 📝 Submit Updates via PR

```bash
# Find and submit new resources
cagent run ./cagent-curator-lite.yaml "Find new cagent resources, validate them, and create a PR adding them to the awesome list"

# Weekly maintenance
cagent run ./cagent-curator-lite.yaml "Perform weekly maintenance: discover new resources, validate all links, and submit a PR with all changes"
```

## 💡 Prompting Tips

The **lite config** trades detailed skill instructions for token headroom. This means your **prompt quality matters more** — be specific to get better results.

### ❌ Too Vague (may return generic Docker content)
```bash
cagent run ./cagent-curator-lite.yaml "Find new cagent blog posts"
```
This can return posts about Docker Model Runner, Docker MCP, or other Docker AI features that aren't specifically about cagent.

### ✅ Specific & Targeted (better results)
```bash
cagent run ./cagent-curator-lite.yaml "Search for blog posts that specifically mention 'cagent' the Docker multi-agent runtime tool. Only include posts that discuss cagent YAML configs, cagent run commands, or multi-agent orchestration with cagent. Exclude generic Docker or Docker Model Runner posts."
```

### ✅ With Deduplication
```bash
cagent run ./cagent-curator-lite.yaml "Read the current README from collabnix/awesome-docker-cagent first, then search for new blog posts about Docker cagent that are NOT already listed. Only include posts that specifically discuss cagent."
```

### Key Tips
- **Say "cagent" explicitly** — helps the model distinguish from generic Docker content
- **Mention what to exclude** — "Exclude generic Docker, Docker Model Runner, or Claude Code posts"
- **Ask it to read the README first** — enables deduplication against existing entries
- **One task per prompt** — "Find blogs" OR "Validate links", not both at once (saves tokens)

## Skills (Full Version Only)

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
    model: openai/gpt-4o     # vendor prefix required!
    max_tokens: 4096
  fast:
    provider: github
    model: openai/gpt-4o-mini
    max_tokens: 2048
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

## GitHub Models Free Tier Limits

| Limit | gpt-4o | gpt-4o-mini |
|-------|--------|-------------|
| Input tokens/request | 8,000 | 8,000 |
| Output tokens/request | 4,096 | 4,096 |
| Requests/minute | 10 | 15 |
| Requests/day | 50 | 150 |

These limits are why the **lite version** exists — skills + verbose instructions consume too many input tokens.

## How It Works

1. **Discovery**: The `discoverer` agent searches DuckDuckGo and GitHub for new cagent content
2. **Validation**: The `validator` agent checks each URL, verifies content relevance, and scores quality
3. **Formatting**: The root agent formats new entries into the correct markdown table syntax
4. **Publishing**: The `publisher` agent reads the current README, creates a branch, adds new entries in the correct sections, and opens a PR

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `403 no_access to model: /gpt-4o` | Missing vendor prefix | Use `openai/gpt-4o` not `gpt-4o` |
| `403 no_access to model: openai/gpt-4o` | Token missing models permission | Add `models:read` to your PAT |
| `413 Request Entity Too Large` | Input exceeds 8K tokens | Switch to `cagent-curator-lite.yaml` |
| `429 Too Many Requests` | Rate limit hit | Wait and retry (10 req/min for gpt-4o) |
| Results include generic Docker posts | Prompt too vague | Be specific — see Prompting Tips above |

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
          config: auto-curator-agent/cagent-curator-lite.yaml
          prompt: "Search for blog posts that specifically mention cagent the Docker multi-agent runtime. Read the current README first to avoid duplicates. Only include cagent-specific content. Create a PR with any new findings."
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Push to Docker Hub
```bash
docker login
cagent push ./cagent-curator-lite.yaml docker.io/ajeetraina/awesome-cagent-curator:latest
```
