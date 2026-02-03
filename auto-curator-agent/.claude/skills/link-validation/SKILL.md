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
