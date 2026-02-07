# GitHub Scanner for Docker cagent Tools

This scanner automatically searches GitHub to find new tools, projects, and repositories that use Docker cagent. It helps maintain the awesome-docker-cagent list by discovering new resources.

## Features

- 🔍 **Smart Search**: Searches GitHub using multiple query strategies
- 📝 **Blog Discovery**: Searches for blog posts and articles about cagent
- 🔄 **Deduplication**: Automatically skips tools already in the awesome list
- 🏷️ **Auto-Categorization**: Categorizes findings into Blogs, MCP Servers, Sample Projects, or General Repositories
- ⭐ **Quality Filtering**: Filters by star count, recent activity, and meaningful content
- 📝 **Formatted Output**: Generates markdown ready to paste into README.md
- 🚫 **Excludes Archived**: Skips archived or inactive repositories

## Prerequisites

1. **Python 3.7+**
2. **GitHub Personal Access Token** (recommended for higher API rate limits)
   - Create one at: https://github.com/settings/tokens
   - Required scopes: `public_repo` (for public repositories)

## Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Or install manually
pip install PyGithub requests
```

## Usage

### Basic Usage

```bash
# Set your GitHub token (recommended)
export GITHUB_TOKEN=your_github_personal_access_token

# Run the scanner
python3 scan_github_tools.py
```

### Without a Token

You can run the scanner without a token, but you'll be limited to 60 API requests per hour:

```bash
python3 scan_github_tools.py
```

## How It Works

### 1. Search Queries

The scanner uses multiple search strategies:

**Repository Searches:**
- `cagent docker` - General cagent + Docker projects
- `docker cagent` - Projects mentioning Docker cagent
- `cagent yaml` - Projects with cagent YAML configurations
- `cagent multi-agent` - Multi-agent systems using cagent
- `docker model runner cagent` - Projects using Docker Model Runner
- `cagent MCP` - MCP integration projects

**Blog & Article Searches:**
- `cagent docker blog` - Blog posts about cagent
- `cagent tutorial` - Tutorial articles
- `cagent guide` - How-to guides
- `docker cagent article` - Articles about Docker cagent
- `cagent introduction` - Introduction/getting started posts

### 2. File Search

Searches for repositories containing:
- `cagent.yaml` - Main cagent configuration files
- Other cagent-related configuration patterns

### 3. Filtering Criteria

The scanner filters repositories based on:
- **Recent Activity**: Only repositories updated in the last 90 days
- **Minimum Stars**: At least 1 star (configurable)
- **Not Archived**: Active repositories only
- **Has Description**: Must have a meaningful description
- **Not Duplicate**: Not already in the awesome list

### 4. Auto-Categorization

Repositories are automatically categorized:

**Blogs & Articles** - Identified by:
- Name or description contains: `blog`, `article`, `tutorial`, `guide`, `post`, `writing`, `content`
- Topics include: `blog`, `article`, `tutorial`, `documentation`, `guide`

**MCP Servers** - Identified by:
- Name contains: `mcp-server`, `mcp_server`
- Description mentions: "MCP server", "Model Context Protocol"

**Sample Projects** - Identified by:
- Name contains: `example`, `sample`, `demo`, `tutorial`, `starter`, `template`
- Contains `cagent.yaml` or cagent configuration files

**General Repositories** - Everything else

## Output

The scanner generates two outputs:

### 1. Console Output
Real-time progress and summary statistics

### 2. Markdown File (`new_tools_found.md`)
Formatted tables ready to paste into README.md:

```markdown
## 🔍 New Tools Found on GitHub
*Scan Date: 2026-02-05*

### Blogs & Articles
| Title | Description | Author | Updated |
|-------|-------------|--------|---------|
| [cagent-intro](https://github.com/...) | Introduction to Docker cagent | johndoe | 2026-02-01 |

### MCP Servers
| Name | Description | Stars |
|------|-------------|-------|
| [awesome-mcp-server](https://github.com/...) | MCP server for awesome lists | 42⭐ |

### Sample Projects
| Project | Description | Author |
|---------|-------------|--------|
| [cagent-example](https://github.com/...) | Example cagent setup | johndoe |

### Other Repositories
| Repository | Description | Author | Stars |
|------------|-------------|--------|-------|
| [ai-toolkit](https://github.com/...) | AI toolkit with cagent | janedoe | 150⭐ |
```

## Configuration

You can modify the scanner behavior by editing `scan_github_tools.py`:

```python
# Change time range (default: 90 days)
self.search_repositories(query, min_stars=1, days_back=180)

# Change minimum stars (default: 1)
self.search_repositories(query, min_stars=5, days_back=90)

# Limit results per query (default: 50)
for repo in repos[:100]:  # Increase to 100
```

## API Rate Limits

### Without Token
- 60 requests per hour
- Sufficient for occasional scans

### With Token
- 5,000 requests per hour
- Recommended for frequent scans or comprehensive searches

Check your rate limit:
```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit
```

## Example Workflow

1. **Run the scanner**:
   ```bash
   export GITHUB_TOKEN=ghp_your_token_here
   python3 scan_github_tools.py
   ```

2. **Review the results**:
   ```bash
   cat new_tools_found.md
   ```

3. **Manually curate**:
   - Review each tool for quality and relevance
   - Check if descriptions are accurate
   - Verify the tool actually uses cagent

4. **Add to README.md**:
   - Copy relevant entries from `new_tools_found.md`
   - Paste into the appropriate section of `README.md`
   - Ensure formatting matches existing entries

5. **Commit changes**:
   ```bash
   git add README.md
   git commit -m "Add new cagent tools from GitHub scan"
   git push
   ```

## Automation

### GitHub Actions

Create `.github/workflows/scan-tools.yml`:

```yaml
name: Scan for New cagent Tools

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:  # Manual trigger

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: pip install -r requirements.txt
      
      - name: Run scanner
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: python3 scan_github_tools.py
      
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: new-tools
          path: new_tools_found.md
```

### Cron Job

Add to your crontab:
```bash
# Run scanner weekly on Sunday at midnight
0 0 * * 0 cd /path/to/awesome-docker-cagent && python3 scan_github_tools.py
```

## Troubleshooting

### Rate Limit Exceeded
```
Error: API rate limit exceeded
```
**Solution**: Set GITHUB_TOKEN or wait for rate limit reset

### No Results Found
```
Found 0 new repositories
```
**Solutions**:
- All tools may already be in the awesome list (good!)
- Try increasing `days_back` parameter
- Lower `min_stars` requirement
- Check if GitHub API is accessible

### Import Error
```
Error: PyGithub not installed
```
**Solution**: Install dependencies with `pip install -r requirements.txt`

## Contributing

To improve the scanner:

1. **Add More Search Queries**: Edit the `queries` list in `run_scan()`
2. **Improve Categorization**: Enhance `categorize_repository()` logic
3. **Add Quality Checks**: Implement additional filtering in `is_sample_project()`, etc.
4. **Better README Parsing**: Improve `get_readme_content()` to extract more information

## Related Tools

- **Auto-Curator Agent** (`auto-curator-agent/`): Full multi-agent system using cagent itself
- **Manual Curation**: Always review automated findings for quality

## License

This scanner is part of the awesome-docker-cagent project and follows the same license.
