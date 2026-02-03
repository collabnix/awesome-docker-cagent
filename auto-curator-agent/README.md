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
