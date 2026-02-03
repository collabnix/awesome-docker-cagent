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
