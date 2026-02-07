#!/usr/bin/env python3
"""
GitHub Scanner for Docker cagent Tools
========================================
Scans GitHub to find new tools, projects, repositories, and blog posts that use Docker cagent.
Outputs results in a format ready to be added to the awesome-docker-cagent README.

Usage:
    export GITHUB_TOKEN=your_github_token
    python3 scan_github_tools.py

Requirements:
    pip install requests PyGithub
"""

import os
import sys
import re
from datetime import datetime, timedelta
from typing import List, Dict, Set
import json

try:
    from github import Github
    from github.GithubException import GithubException
except ImportError:
    print("Error: PyGithub not installed. Install it with: pip install PyGithub")
    sys.exit(1)


class CagentToolScanner:
    """Scanner for finding new cagent tools on GitHub"""
    
    # Configuration constants
    MAX_REPOS_PER_QUERY = 30  # Maximum repositories to process per search query
    MAX_BLOGS_PER_QUERY = 15  # Maximum blog repositories to collect per query
    
    def __init__(self, github_token: str = None):
        """Initialize the scanner with GitHub API token"""
        self.token = github_token or os.environ.get('GITHUB_TOKEN')
        if not self.token:
            print("Warning: GITHUB_TOKEN not set. API rate limits will be very restrictive.")
            print("Set it with: export GITHUB_TOKEN=your_token")
        
        self.github = Github(self.token)
        self.existing_urls = set()
        self.results = {
            'repositories': [],
            'mcp_servers': [],
            'sample_projects': [],
            'tutorials': [],
            'blogs': []
        }
    
    def load_existing_urls(self, readme_path: str = 'README.md'):
        """Load existing URLs from README to avoid duplicates"""
        try:
            with open(readme_path, 'r', encoding='utf-8') as f:
                content = f.read()
                # Extract all URLs from markdown links [text](url)
                urls = re.findall(r'\[.*?\]\((https?://[^\)]+)\)', content)
                self.existing_urls = set(url.rstrip('/') for url in urls)
                print(f"Loaded {len(self.existing_urls)} existing URLs for deduplication")
        except FileNotFoundError:
            print(f"Warning: {readme_path} not found. Deduplication disabled.")
    
    def is_duplicate(self, url: str) -> bool:
        """Check if URL already exists in the awesome list"""
        return url.rstrip('/') in self.existing_urls
    
    def search_repositories(self, query: str, min_stars: int = 1, days_back: int = 90):
        """Search GitHub repositories with given query"""
        print(f"\nSearching repositories: {query}")
        
        # Calculate date for recent activity filter
        since_date = datetime.now() - timedelta(days=days_back)
        date_str = since_date.strftime('%Y-%m-%d')
        
        # Add date filter to query
        full_query = f"{query} pushed:>{date_str} stars:>={min_stars}"
        
        try:
            repos = self.github.search_repositories(
                query=full_query,
                sort='stars',
                order='desc'
            )
            
            found_count = 0
            for repo in repos[:50]:  # Limit to top 50 results
                if self.is_duplicate(repo.html_url):
                    continue
                
                # Skip archived repos
                if repo.archived:
                    continue
                
                # Check if repo has meaningful content
                if not repo.description:
                    continue
                
                # Categorize the repository
                self.categorize_repository(repo)
                found_count += 1
                
                # Rate limiting
                if found_count >= 20:
                    break
            
            print(f"Found {found_count} new repositories")
            
        except GithubException as e:
            print(f"Error searching repositories: HTTP {e.status}")
            if e.status == 403:
                print("  → This is likely due to GitHub API rate limiting.")
                print("  → Set GITHUB_TOKEN environment variable for higher limits.")
            elif e.status == 401:
                print("  → Authentication failed. Check your GITHUB_TOKEN.")
        except Exception as e:
            print(f"Unexpected error: {type(e).__name__}: {str(e)}")
    
    def categorize_repository(self, repo):
        """Categorize repository into appropriate section"""
        description = (repo.description or "").lower()
        readme = self.get_readme_content(repo)
        
        # Determine category based on content
        is_mcp_server = self.is_mcp_server(repo, readme)
        is_sample_project = self.is_sample_project(repo, readme)
        
        if is_mcp_server:
            self.results['mcp_servers'].append({
                'name': repo.name,
                'url': repo.html_url,
                'description': repo.description or 'No description',
                'stars': repo.stargazers_count,
                'author': repo.owner.login,
                'updated': repo.updated_at.strftime('%Y-%m-%d')
            })
        elif is_sample_project:
            self.results['sample_projects'].append({
                'name': repo.name,
                'url': repo.html_url,
                'description': repo.description or 'No description',
                'stars': repo.stargazers_count,
                'author': repo.owner.login,
                'updated': repo.updated_at.strftime('%Y-%m-%d')
            })
        else:
            self.results['repositories'].append({
                'name': repo.name,
                'url': repo.html_url,
                'description': repo.description or 'No description',
                'stars': repo.stargazers_count,
                'author': repo.owner.login,
                'updated': repo.updated_at.strftime('%Y-%m-%d')
            })
    
    def get_readme_content(self, repo) -> str:
        """Get README content from repository"""
        try:
            readme = repo.get_readme()
            return readme.decoded_content.decode('utf-8').lower()
        except GithubException:
            return ""
        except Exception:
            return ""
    
    def is_mcp_server(self, repo, readme: str) -> bool:
        """Check if repository is an MCP server"""
        indicators = [
            'mcp server',
            'mcp-server',
            'model context protocol',
            'mcp_server',
        ]
        
        name = repo.name.lower()
        description = (repo.description or "").lower()
        
        # Check name, description, and README
        for indicator in indicators:
            if indicator in name or indicator in description or indicator in readme:
                return True
        
        return False
    
    def is_sample_project(self, repo, readme: str) -> bool:
        """Check if repository is a sample/example project"""
        indicators = [
            'example',
            'sample',
            'demo',
            'tutorial',
            'getting started',
            'starter',
            'template'
        ]
        
        name = repo.name.lower()
        description = (repo.description or "").lower()
        
        for indicator in indicators:
            if indicator in name or indicator in description:
                return True
        
        # Check if it has cagent configuration files
        config_patterns = [
            'cagent.yaml',
            'cagent-config.yaml',
            'agents:\n',  # YAML agent definition
            'version: "3"',  # cagent v3
        ]
        
        for pattern in config_patterns:
            if pattern in readme:
                return True
        
        return False
    
    def search_code_files(self, filename: str):
        """Search for specific files (e.g., cagent.yaml)"""
        print(f"\nSearching for files: {filename}")
        
        try:
            code_results = self.github.search_code(
                query=f"filename:{filename}",
                sort='indexed',
                order='desc'
            )
            
            found_count = 0
            for code in code_results[:30]:  # Limit results
                repo = code.repository
                
                if self.is_duplicate(repo.html_url):
                    continue
                
                if repo.archived:
                    continue
                
                # Add to sample projects
                if not any(p['url'] == repo.html_url for p in self.results['sample_projects']):
                    self.results['sample_projects'].append({
                        'name': repo.name,
                        'url': repo.html_url,
                        'description': repo.description or f'Contains {filename}',
                        'stars': repo.stargazers_count,
                        'author': repo.owner.login,
                        'updated': repo.updated_at.strftime('%Y-%m-%d')
                    })
                    found_count += 1
                
                if found_count >= 10:
                    break
            
            print(f"Found {found_count} repositories with {filename}")
            
        except GithubException as e:
            print(f"Error searching code: HTTP {e.status}")
            if e.status == 403:
                print("  → Rate limit exceeded. Try again later or set GITHUB_TOKEN.")
        except Exception as e:
            print(f"Unexpected error: {type(e).__name__}")
    
    def search_blogs(self, query: str, days_back: int = 90):
        """Search GitHub for blog posts and articles about cagent
        
        Args:
            query: Search query string to find blog repositories
            days_back: Number of days to look back for recent activity (default: 90)
            
        Side effects:
            Updates self.results['blogs'] with found blog repositories
        """
        print(f"\nSearching for blog posts: {query}")
        
        # Calculate date for recent activity filter
        since_date = datetime.now() - timedelta(days=days_back)
        date_str = since_date.strftime('%Y-%m-%d')
        
        # Add date filter to query
        full_query = f"{query} pushed:>{date_str}"
        
        try:
            repos = self.github.search_repositories(
                query=full_query,
                sort='updated',
                order='desc'
            )
            
            found_count = 0
            # Note: Slicing repos[:N] still fetches all results from API first
            # This is acceptable for our use case since we need to filter/check each repo
            # before deciding if it's a blog. API-level limiting via per_page would skip
            # potentially valid blogs that come later in results.
            for repo in repos[:self.MAX_REPOS_PER_QUERY]:  # Limit results
                if self.is_duplicate(repo.html_url):
                    continue
                
                # Skip archived repos
                if repo.archived:
                    continue
                
                # Check if this looks like a blog/article repository
                if self.is_blog_repository(repo):
                    self.results['blogs'].append({
                        'name': repo.name,
                        'url': repo.html_url,
                        'description': repo.description or 'Blog/article about cagent',
                        'stars': repo.stargazers_count,
                        'author': repo.owner.login,
                        'updated': repo.updated_at.strftime('%Y-%m-%d')
                    })
                    found_count += 1
                
                # Rate limiting
                if found_count >= self.MAX_BLOGS_PER_QUERY:
                    break
            
            print(f"Found {found_count} blog/article repositories")
            
        except GithubException as e:
            print(f"Error searching blogs: HTTP {e.status}")
            if e.status == 403:
                print("  → Rate limit exceeded. Try again later or set GITHUB_TOKEN.")
        except Exception as e:
            print(f"Unexpected error: {type(e).__name__}")
    
    def is_blog_repository(self, repo) -> bool:
        """Check if repository appears to be a blog or article
        
        Args:
            repo: GitHub repository object with name, description, and get_topics() method
            
        Returns:
            bool: True if repository appears to be a blog/article, False otherwise
            
        Checks repository name, description, and topics against known blog indicators:
        - Names/descriptions: blog, article, tutorial, guide, post, writing, content
        - Topics: blog, article, tutorial, documentation, guide
        """
        blog_indicators = [
            'blog',
            'article',
            'tutorial',
            'guide',
            'post',
            'writing',
            'content'
        ]
        
        name = repo.name.lower()
        description = (repo.description or "").lower()
        
        # Check if name or description contains blog indicators
        for indicator in blog_indicators:
            if indicator in name or indicator in description:
                return True
        
        # Check for common blog/documentation sites
        topics = [topic.lower() for topic in repo.get_topics()]
        blog_topics = ['blog', 'article', 'tutorial', 'documentation', 'guide']
        
        for topic in blog_topics:
            if topic in topics:
                return True
        
        return False
    
    def run_scan(self):
        """Execute the full scan"""
        print("=" * 70)
        print("Docker cagent GitHub Tool Scanner")
        print("=" * 70)
        
        # Load existing URLs for deduplication
        self.load_existing_urls()
        
        # Search queries for repositories
        queries = [
            'cagent docker',
            'docker cagent',
            'cagent yaml',
            'cagent agent',
            'cagent multi-agent',
            'docker model runner cagent',
            'cagent MCP',
        ]
        
        for query in queries:
            self.search_repositories(query, min_stars=1, days_back=90)
        
        # Search for specific configuration files
        self.search_code_files('cagent.yaml')
        
        # Search for blog posts and articles
        blog_queries = [
            'cagent docker blog',
            'cagent tutorial',
            'cagent guide',
            'docker cagent article',
            'cagent introduction',
        ]
        
        for query in blog_queries:
            self.search_blogs(query, days_back=90)
        
        print("\n" + "=" * 70)
        print("Scan Complete!")
        print("=" * 70)
    
    def format_output(self) -> str:
        """Format results as markdown for the awesome list"""
        output = []
        
        output.append("\n## 🔍 New Tools Found on GitHub\n")
        output.append(f"*Scan Date: {datetime.now().strftime('%Y-%m-%d')}*\n")
        
        # Blogs & Articles (NEW!)
        if self.results['blogs']:
            output.append("\n### Blogs & Articles\n")
            output.append("| Title | Description | Author | Updated |")
            output.append("|-------|-------------|--------|---------|")
            for item in sorted(self.results['blogs'], key=lambda x: x['updated'], reverse=True):
                output.append(f"| [{item['name']}]({item['url']}) | {item['description']} | {item['author']} | {item['updated']} |")
        
        # MCP Servers
        if self.results['mcp_servers']:
            output.append("\n### MCP Servers\n")
            output.append("| Name | Description | Stars |")
            output.append("|------|-------------|-------|")
            for item in sorted(self.results['mcp_servers'], key=lambda x: x['stars'], reverse=True):
                stars = f"{item['stars']}⭐"
                output.append(f"| [{item['name']}]({item['url']}) | {item['description']} | {stars} |")
        
        # Sample Projects
        if self.results['sample_projects']:
            output.append("\n### Sample Projects\n")
            output.append("| Project | Description | Author |")
            output.append("|---------|-------------|--------|")
            for item in sorted(self.results['sample_projects'], key=lambda x: x['stars'], reverse=True):
                output.append(f"| [{item['name']}]({item['url']}) | {item['description']} | {item['author']} |")
        
        # Other Repositories
        if self.results['repositories']:
            output.append("\n### Other Repositories\n")
            output.append("| Repository | Description | Author | Stars |")
            output.append("|------------|-------------|--------|-------|")
            for item in sorted(self.results['repositories'], key=lambda x: x['stars'], reverse=True):
                output.append(f"| [{item['name']}]({item['url']}) | {item['description']} | {item['author']} | {item['stars']}⭐ |")
        
        return "\n".join(output)
    
    def save_results(self, filename: str = 'new_tools_found.md'):
        """Save results to a file"""
        output = self.format_output()
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(output)
        
        print(f"\nResults saved to: {filename}")
        return output
    
    def print_summary(self):
        """Print summary of findings"""
        total = (len(self.results['mcp_servers']) + 
                len(self.results['sample_projects']) + 
                len(self.results['repositories']) +
                len(self.results['blogs']))
        
        print(f"\n📊 Summary:")
        print(f"  - Blogs & Articles: {len(self.results['blogs'])}")
        print(f"  - MCP Servers: {len(self.results['mcp_servers'])}")
        print(f"  - Sample Projects: {len(self.results['sample_projects'])}")
        print(f"  - Other Repositories: {len(self.results['repositories'])}")
        print(f"  - Total New Tools: {total}")


def main():
    """Main entry point"""
    scanner = CagentToolScanner()
    scanner.run_scan()
    scanner.print_summary()
    
    # Save results
    output = scanner.save_results()
    
    # Print preview
    print("\n" + "=" * 70)
    print("Preview of Results:")
    print("=" * 70)
    print(output)
    
    print("\n✅ Scan complete! Review 'new_tools_found.md' and add entries to README.md")


if __name__ == '__main__':
    main()
