# GitHub Actions Workflow: Scan for New cagent Tools

This workflow automatically runs the GitHub scanner to discover new Docker cagent tools and creates issues with the findings.

## Workflow File

`.github/workflows/scan-tools.yml`

## Trigger Events

### 1. Scheduled (Automatic)
Runs every **Sunday at 9:00 UTC**

```yaml
schedule:
  - cron: '0 9 * * 0'
```

### 2. Manual (On-Demand)
You can manually trigger the workflow from the GitHub Actions tab:

1. Go to **Actions** → **Scan for New cagent Tools**
2. Click **Run workflow**
3. Optionally specify how many days back to search (default: 90)

## What It Does

1. **Sets up environment**
   - Checks out the repository
   - Installs Python 3.11
   - Installs dependencies from `requirements.txt`

2. **Runs the scanner**
   - Uses `GITHUB_TOKEN` for authenticated API access
   - Searches for new cagent tools on GitHub
   - Generates `new_tools_found.md` with findings

3. **Processes results**
   - Checks if any new tools were found
   - Uploads results as workflow artifacts
   - **Creates a GitHub issue** with the findings

4. **Creates an issue** (if new tools found)
   - Title: "🤖 New cagent Tools Found - YYYY-MM-DD"
   - Body: Contains the formatted list of tools
   - Labels: `automation`, `new-tools`

## Example Issue

When new tools are found, an issue is automatically created:

```markdown
🤖 New cagent Tools Found - 2026-02-05

## 🔍 New Tools Found on GitHub
*Scan Date: 2026-02-05*

### MCP Servers
| Name | Description | Stars |
|------|-------------|-------|
| [mcp-server-docker](https://github.com/...) | ... | 45⭐ |

### Sample Projects
| Project | Description | Author |
|---------|-------------|--------|
| [cagent-starter](https://github.com/...) | ... | johndoe |

---

**Next Steps:**
1. Review each tool for quality and relevance
2. Verify the tools actually use cagent
3. Add appropriate entries to README.md
4. Close this issue once processed
```

## Artifacts

Scan results are also saved as workflow artifacts:
- **Name**: `new-tools-scan-{run_number}`
- **File**: `new_tools_found.md`
- **Retention**: 90 days

You can download artifacts from the workflow run details page.

## Manual Workflow Trigger

To run the scanner on-demand:

1. Navigate to the repository on GitHub
2. Click the **Actions** tab
3. Select **"Scan for New cagent Tools"** workflow
4. Click **"Run workflow"** button
5. (Optional) Adjust the `days_back` parameter
6. Click **"Run workflow"** to start

## Customization

### Change Schedule

Edit the cron expression in `.github/workflows/scan-tools.yml`:

```yaml
schedule:
  - cron: '0 9 * * 0'  # Every Sunday at 9:00 UTC
```

Examples:
- Daily: `'0 9 * * *'`
- Every Monday: `'0 9 * * 1'`
- First day of month: `'0 9 1 * *'`

### Change Search Parameters

Modify the scanner parameters in `scan_github_tools.py`:
- `days_back`: How far back to search (default: 90)
- `min_stars`: Minimum star count (default: 1)
- Maximum results per query (default: 50)

### Add More Labels

In the workflow file, add more labels to the issue:

```yaml
labels: ['automation', 'new-tools', 'needs-review', 'help-wanted']
```

## Permissions

The workflow requires these permissions:

```yaml
permissions:
  contents: read        # Read repository content
  issues: write         # Create issues
  pull-requests: write  # (Future: Create PRs automatically)
```

## Monitoring

### Check Workflow Runs

1. Go to **Actions** tab
2. View run history
3. Check for failures or warnings
4. Download artifacts if needed

### Check for Rate Limiting

If you see rate limit errors:
- The workflow uses `GITHUB_TOKEN` which has 5,000 requests/hour
- This should be sufficient for weekly scans
- Consider reducing search queries if rate limits are hit

## Troubleshooting

### Workflow Fails with "Rate Limit Exceeded"

**Solution**: 
- Reduce the number of search queries in `scan_github_tools.py`
- Increase the schedule interval (e.g., bi-weekly instead of weekly)

### No Issues Created

**Possible reasons**:
- No new tools found (normal if list is up-to-date)
- Check workflow logs for errors
- Verify `new_tools_found.md` was generated

### Scanner Finds Too Many Results

**Solution**:
- Increase `min_stars` filter
- Reduce `days_back` parameter
- Improve filtering logic in the scanner

## Future Enhancements

Potential improvements to this workflow:

1. **Auto-create PRs** instead of issues
2. **Quality scoring** for tools
3. **Duplicate detection** improvements
4. **Notification** to maintainers
5. **Integration** with the cagent auto-curator agent

## Related Files

- **Scanner Script**: `scan_github_tools.py`
- **Documentation**: `SCANNER_USAGE.md`
- **Example Output**: `EXAMPLE_OUTPUT.md`
- **Dependencies**: `requirements.txt`
