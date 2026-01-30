[![stars](https://img.shields.io/github/stars/docker/cagent)](https://github.com/docker/cagent)
[![Discord](https://img.shields.io/discord/1020180904129335379)](https://discord.gg/QEkCXAXYSe)
[![Twitter](https://img.shields.io/twitter/follow/collabnix?style=social)](https://twitter.com/collabnix)

# Awesome Docker cagent [![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

A curated list of Docker cagent resources - blogs, tutorials, videos, and sample projects, organized by integration category. This is a community effort to help people discover the best resources for Docker cagent in 2026 and beyond.

## What's cagent?

Docker cagent is an open-source, multi-agent runtime designed to simplify the development and deployment of autonomous AI systems. 

Unlike traditional chatbots, this tool allows developers to orchestrate specialized teams of agents that can plan, reason, and execute complex tasks through a declarative YAML configuration. 

The curated list of links and resources in this page highlight its integration with the Model Context Protocol (MCP), which grants agents secure access to external tools, databases like Couchbase, and local filesystems. Users can run models from various providers, including OpenAI and Anthropic, or utilize the Docker Model Runner for local-first execution. The framework also supports agent distribution, allowing configurations to be shared and versioned as OCI artifacts via Docker Hub. Ultimately, cagent aims to provide a standardized, "container-like" experience for the burgeoning era of agentic AI.

## Table of Contents

1. [Join our Community](#-join-our-community)
2. [Official Resources](#-official-resources)
3. [cagent + MCP](#-cagent--mcp)
4. [cagent + Docker Model Runner](#-cagent--docker-model-runner)
5. [cagent + IDE (ACP)](#-cagent--ide-acp)
6. [cagent + RAG](#-cagent--rag)
7. [General Resources](#-general-resources)
8. [GitHub Sample Projects](#-github-sample-projects)
9. [MCP Servers for cagent](#-mcp-servers-for-cagent)
10. [Featured Videos](#-featured-videos)

---

## 📝 Join our Community

- Join 17K+ DevOps Engineers via [Community Slack](https://launchpass.com/collabnix)
- Join our [Discord Server](https://discord.gg/QEkCXAXYSe)
- Fork, Contribute & Share via [cagent GitHub Repository](https://github.com/collabnix/awesome-docker-cagent)
- Follow us on Twitter [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40collabnix)](https://twitter.com/collabnix)

---

## 📚 Official Resources

| Resource | Description |
|----------|-------------|
| [Docker cagent Docs](https://docs.docker.com/ai/cagent/) | Official Docker documentation for cagent |
| [cagent GitHub Repository](https://github.com/docker/cagent) | Source code, examples, and issue tracking |
| [Docker MCP Catalog](https://docs.docker.com/ai/mcp-catalog-and-toolkit/) | Containerized MCP servers for cagent |
| [cagent Configuration Reference](https://docs.docker.com/ai/cagent/reference/configuration/) | YAML configuration options |
| [cagent Tools Reference](https://docs.docker.com/ai/cagent/reference/tools/) | Built-in and MCP tool integration |
| [Building a Coding Agent Tutorial](https://docs.docker.com/ai/cagent/tutorial/) | Official step-by-step tutorial |

---

## 🔌 cagent + MCP

*Model Context Protocol (MCP) integration enables agents to use external tools and services via containerized MCP servers.*

### Blogs & Articles

| Title | Source | Description |
|-------|--------|-------------|
| [Using MCP Servers with Docker: Tools to Multi-Agent](https://www.docker.com/blog/mcp-servers-docker-toolkit-cagent-gateway/) | Docker Blog | Comprehensive guide on MCP Toolkit, Catalog, Gateway with cagent |
| [Docker cagent Integration with MCP](https://collabnix.com/docs/docker-cagent/docker-cagent-integration-with-mcp/) | Collabnix | Detailed MCP integration patterns and examples |
| [Build and Distribute AI Agents with cagent](https://www.docker.com/blog/cagent-build-and-distribute-ai-agents-and-workflows/) | Docker Blog | Using MCP for GitHub issues, Advocu integration |
| [Orchestrate AI agents with cagent for BC/AL](https://tobiasfenster.io/orchestrate-multiple-ai-agents-with-cagent-by-docker) | tobiasfenster.io | Custom AL MCP Server integration |

### Documentation

| Resource | Description |
|----------|-------------|
| [MCP Toolsets Reference](https://docs.docker.com/ai/cagent/reference/tools/#mcp-toolsets) | Official MCP configuration docs |
| [Docker MCP Gateway](https://github.com/docker/mcp-gateway) | Centralized frontend for MCP servers |

### Example Configurations

```yaml
# Basic MCP Integration with DuckDuckGo
agents:
  root:
    model: openai/gpt-5-mini
    description: A helpful AI assistant
    instruction: |
      You are a knowledgeable assistant with web search.
    toolsets:
      - type: mcp
        ref: docker:duckduckgo
```

### Projects

| Project | Description |
|---------|-------------|
| [mcp-advocu](https://github.com/shelajev/mcp-advocu) | Custom MCP server for Docker Captains tracking |
| [GitHub Todo Agent](https://hub.docker.com/r/olegselajev241/github-todo) | Task tracking agent using GitHub MCP |

---

## 🖥️ cagent + Docker Model Runner

*Run AI models locally without API keys using Docker Model Runner (DMR) for privacy-first, cost-effective inference.*

### Blogs & Articles

| Title | Source | Description |
|-------|--------|-------------|
| [Docker Model Runner: Now Generally Available](https://www.docker.com/blog/announcing-docker-model-runner-ga/) | Docker Blog | DMR GA announcement with cagent integration |
| [Run LLMs Locally with Docker Model Runner](https://www.docker.com/blog/run-llms-locally/) | Docker Blog | Quickstart guide for local LLM inference |
| [From Zero to Local LLM: A Developer's Guide](https://dev.to/docker/from-zero-to-local-llm-a-developers-guide-to-docker-model-runner-4oi2) | Dev.to | Comprehensive DMR tutorial |
| [Docker Model Runner makes local LLMs easy](https://www.xda-developers.com/docker-model-runner-running-local-llms-easy/) | XDA Developers | Beginner-friendly DMR guide |
| [How to change context size for DMR](https://jgcarmona.com/change-dmr-context-size/) | jgcarmona.com | Advanced DMR configuration with cagent |

### Documentation

| Resource | Description |
|----------|-------------|
| [Local Models with cagent](https://docs.docker.com/ai/cagent/local-models/) | Official DMR + cagent integration docs |
| [Docker Model Runner Docs](https://docs.docker.com/ai/model-runner/) | Complete DMR documentation |
| [DigitalOcean cagent + DMR](https://docs.digitalocean.com/products/marketplace/catalog/cagent/) | Deploy cagent with DMR on DigitalOcean |

### Example Configurations

```yaml
# Local Model with Docker Model Runner
agents:
  root:
    model: dmr/ai/qwen3
    instruction: You are a helpful assistant
    toolsets:
      - type: filesystem

# With custom model configuration
models:
  local-qwen:
    provider: dmr
    model: ai/qwen3:14B
    temperature: 0.7
    max_tokens: 8192

agents:
  root:
    model: local-qwen
    instruction: You are a helpful coding assistant
```

### Key Features

- **No API keys required** - Run models completely locally
- **OpenAI-compatible API** - Easy integration with existing tools
- **Automatic model pulling** - cagent prompts to download models on first use
- **Privacy-first** - Your data never leaves your machine
- **Multiple engines** - llama.cpp, vLLM, Diffusers support

---

## 💻 cagent + IDE (ACP)

*Agent Client Protocol (ACP) enables cagent agents to run directly in your IDE with file operations through the editor.*

### Blogs & Articles

| Title | Source | Description |
|-------|--------|-------------|
| [Cagent Comes to Docker Desktop with IDE Support through ACP](https://www.docker.com/blog/cagent-comes-to-docker-desktop-with-built-in-ide-support-through-acp/) | Docker Blog | ACP launch announcement for cagent |
| [Docker, JetBrains, and Zed: Building a Common Language](https://www.docker.com/blog/docker-jetbrains-and-zed-building-a-common-language-for-agents-and-ides/) | Docker Blog | ACP ecosystem expansion |
| [Zed ACP Progress Report](https://zed.dev/blog/acp-progress-report) | Zed Blog | Community-driven ACP adoption |
| [Intro to ACP: The Standard for AI Agent-Editor Integration](https://block.github.io/goose/blog/2025/10/24/intro-to-agent-client-protocol-acp/) | Goose Blog | ACP overview and setup |
| [Zed debuts ACP to connect AI coding agents](https://tessl.io/blog/zed-debuts-agent-client-protocol-to-connect-ai-coding-agents-to-any-editor/) | Tessl.io | ACP ecosystem analysis |

### Documentation

| Resource | Description |
|----------|-------------|
| [cagent ACP Integration](https://docs.docker.com/ai/cagent/integrations/acp/) | Official ACP setup for Zed, Neovim |
| [Zed ACP Documentation](https://zed.dev/docs/ai/external-agents) | External agents in Zed |
| [Agent Client Protocol](https://zed.dev/acp) | ACP specification and supported agents |

### Supported IDEs

| IDE | Status | Configuration |
|-----|--------|---------------|
| **Zed** | ✅ Native support | Built-in agent servers |
| **Neovim** | ✅ Via CodeCompanion | Plugin configuration |
| **JetBrains** | 🔜 Coming soon | Full IDE ecosystem |
| **VS Code** | 🔜 Community adapters | In development |

### Example Configuration (Zed)

```json
// ~/.config/zed/settings.json
{
  "agent_servers": {
    "my-cagent-agent": {
      "command": "cagent",
      "args": ["acp", "./agent.yaml"]
    }
  }
}
```

### Example Configuration (Neovim with CodeCompanion)

```lua
require("codecompanion").setup({
  adapters = {
    acp = {
      cagent = function()
        return require("codecompanion.adapters").extend("cagent", {
          commands = {
            default = { "cagent", "acp", "agent.yml" },
          },
        })
      end,
    },
  },
})
```

### Key Benefits

- **Synchronized view** - Agent sees what you see in your editor
- **Direct file operations** - Edit code right in your editor
- **No context switching** - Stay in your IDE workflow
- **Protocol standard** - Same agents work across editors

---

## 🔍 cagent + RAG

*Retrieval-Augmented Generation (RAG) enables agents to access your documents with multiple retrieval strategies.*

### Documentation

| Resource | Description |
|----------|-------------|
| [cagent RAG Configuration](https://github.com/docker/cagent#rag-retrieval-augmented-generation) | Official RAG setup in USAGE.md |
| [Local Models with RAG](https://docs.docker.com/ai/cagent/local-models/) | Using DMR for embeddings and reranking |

### Supported Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| **BM25** | Keyword-based retrieval | Fast, no embeddings needed |
| **chunked-embeddings** | Semantic search with chunking | Best for large documents |
| **semantic-embeddings** | Full document embeddings | Small knowledge bases |
| **Hybrid** | Combine multiple strategies | Production use |

### Example Configurations

```yaml
# Basic RAG with OpenAI embeddings
models:
  embedder:
    provider: openai
    model: text-embedding-3-small

rag:
  my_knowledge_base:
    docs: [./documents, ./pdfs]
    strategies:
      - type: chunked-embeddings
        model: embedder
        threshold: 0.5
        chunking:
          size: 1000
          overlap: 100
    results:
      limit: 5

agents:
  root:
    model: openai/gpt-4o
    instruction: |
      You are an assistant with access to an internal knowledge base.
```

```yaml
# RAG with Local DMR Embeddings (No API keys!)
rag:
  codebase:
    docs: [./src]
    strategies:
      - type: chunked-embeddings
        embedding_model: dmr/ai/embeddinggemma
    database: ./code.db
```

```yaml
# Advanced RAG with Reranking
rag:
  knowledge_base:
    docs: [./documents]
    strategies:
      - type: chunked-embeddings
        model: openai/text-embedding-3-small
        limit: 20  # Retrieve more candidates
    results:
      reranking:
        model: openai/gpt-4.1-mini
        threshold: 0.3
        criteria: |
          Prioritize recent documentation and practical examples.
      limit: 5  # Final results after reranking
```

### Key Features

- **Pluggable strategies** - BM25, chunked-embeddings, semantic-embeddings
- **Hybrid retrieval** - Combine multiple strategies with result fusion
- **Reranking support** - DMR native /rerank or LLM-based
- **Local embeddings** - Use DMR for privacy-first RAG

---

## 📖 General Resources

### Getting Started

| Title | Source | Description |
|-------|--------|-------------|
| [What is Docker cagent and what problem does it solve?](https://collabnix.com/what-is-docker-cagent-and-what-problem-does-it-solve/) | Collabnix | Comprehensive introduction |
| [Introduction to Docker Cagent](https://collabnix.com/docs/docker-cagent/introduction-to-docker-cagent/) | Collabnix | Architecture overview |
| [Getting Started with Cagent](https://collabnix.com/docs/docker-cagent/getting-started-with-cagent/) | Collabnix | Installation and first agent |
| [How to Build a Multi-Agent AI System Fast](https://www.docker.com/blog/how-to-build-a-multi-agent-system/) | Docker Blog | Multi-agent fundamentals |

### Advanced Topics

| Title | Source | Description |
|-------|--------|-------------|
| [Break Free From AI Lock-In: GitHub Models + cagent](https://www.docker.com/blog/configure-cagent-github-models/) | Docker Blog | Vendor independence with GitHub Models |
| [Deterministic AI Testing with Session Recording](https://www.docker.com/blog/deterministic-ai-testing-with-session-recording-in-cagent/) | Docker Blog | VCR-style testing for agents |
| [Building AI Agents Using cagent and GitHub Models](https://dzone.com/articles/building-ai-agents-using-docker-cagent-and-github) | DZone | Podcast generator tutorial |
| [Building AI Agents Using Open-Source Docker cagent](https://cloudnativenow.com/contributed-content/building-ai-agents-using-open-source-docker-cagent-and-github-models/) | Cloud Native Now | Production deployment |

### Community Blogs

| Title | Source | Author |
|-------|--------|--------|
| [Why You Should Care About Docker's cagent](https://medium.com/@reddyfull/why-you-should-care-about-dockers-cagent-and-how-to-build-a-multi-agent-ai-toolchain-with-it-cd0f0a2e92d9) | Medium | Srinivasa Tadipatri |
| [Orchestrate AI agents with cagent for BC/AL](https://tobiasfenster.io/orchestrate-multiple-ai-agents-with-cagent-by-docker) | tobiasfenster.io | Tobias Fenster |

---

## 💻 GitHub Sample Projects

### Official Examples

| Project | Description |
|---------|-------------|
| [cagent Examples Directory](https://github.com/docker/cagent/tree/main/examples) | Official example agents from Docker |
| [Podcast Generator (GitHub Models)](https://github.com/docker/cagent/blob/main/examples/podcastgenerator_githubmodel.yaml) | Multi-agent podcast generation |
| [Golang Developer Agent](https://github.com/docker/cagent/blob/main/examples/golang_developer.yaml) | The agent Docker uses to develop cagent |
| [DMR Example](https://github.com/docker/cagent/blob/main/examples/dmr.yaml) | Local model with Docker Model Runner |
| [Pirate Agent](https://github.com/docker/cagent/blob/main/examples/pirate.yaml) | Fun personality agent |
| [cagent GitHub Action](https://github.com/docker/cagent-action) | Run cagent AI agents in GitHub workflows |

### Community Projects

| Project | Description | Author |
|---------|-------------|--------|
| [mcp-advocu](https://github.com/shelajev/mcp-advocu) | MCP server for Docker Captains tracking | Oleg Šelajev |
| [GitHub Todo Agent](https://hub.docker.com/r/olegselajev241/github-todo) | Task tracking with GitHub Issues | Oleg Šelajev |
| [Research Agent](https://hub.docker.com/r/ajeetraina777/researchagent) | Web research with DuckDuckGo | Ajeet Raina |
| [Docktor](https://github.com/hwclass/docktor) | AI-native autoscaler for Docker Compose built with cagent + MCP + Model Runner | hwclass |
| [Narwhal](https://github.com/jalonsogo/Narwhal) | Visual flow editor for creating and orchestrating multi-agent AI workflows | jalonsogo |
| [cagent-blogposter](https://github.com/mfranzon/cagent-blogposter) | AI agents for ghostwriting using Docker cagent | mfranzon |
| [cagent-compose](https://github.com/bjornhovd/cagent-compose) | Multi-agent AI system for meal planning, recipes, and wine pairing with MCP | bjornhovd |
| [cagent-comedy-central](https://github.com/artofthepossible/cagent-comedy-central) | Launchpad for experimenting with multi-agent AI workflows | artofthepossible |
| [nerdy-night-live](https://github.com/artofthepossible/nerdy-night-live) | Multi-agent AI playground where agents collaborate and delegate | artofthepossible |
| [hackernews-sentiment-analysis](https://github.com/ajeetraina/hackernews-sentiment-analysis) | Sentiment analysis of Docker discussions from Hacker News using MCP | Ajeet Raina |
| [bioCurator](https://github.com/sunitj/bioCurator) | Memory-augmented multi-agent system for scientific literature curation | sunitj |
| [simple-alfresco-agent-mesh](https://github.com/aborroy/simple-alfresco-agent-mesh) | Alfresco MCP Server that routes prompts to specialized MCP servers | aborroy |
| [cagent-demos](https://github.com/0GiS0/cagent-demos) | Demos and experiments with cagent | 0GiS0 |
| [jueves-de-quack-cagent-demos](https://github.com/0GiS0/jueves-de-quack-cagent-demos) | Demos from Jueves de Quack event with cagent | 0GiS0 |
| [cagent-ai-agent-docker](https://github.com/0GiS0/cagent-ai-agent-docker) | Minimal example of running cagent with GitHub Models | 0GiS0 |

---

## 🔧 MCP Servers for cagent

*Useful MCP servers that extend cagent capabilities with external tools and services.*

### Infrastructure & DevOps

| MCP Server | Description | Stars |
|-----------|-------------|-------|
| [mcp-server-docker](https://github.com/ckreiling/mcp-server-docker) | MCP server for Docker container management | 670⭐ |
| [docker-mcp](https://github.com/QuantGeekDev/docker-mcp) | Docker MCP Server for Model Context Protocol | 447⭐ |
| [hub-mcp](https://github.com/docker/hub-mcp) | Official Docker Hub MCP Server | 115⭐ |
| [k8s-mcp-server](https://github.com/alexei-led/k8s-mcp-server) | Kubernetes CLI tools (kubectl, helm, istioctl, argocd) | 180⭐ |
| [aws-mcp-server](https://github.com/alexei-led/aws-mcp-server) | Execute AWS CLI commands in safe containerized environment | 172⭐ |
| [podman-mcp-server](https://github.com/manusa/podman-mcp-server) | MCP server for Podman and Docker container runtimes | 54⭐ |

### Development Tools

| MCP Server | Description | Stars |
|-----------|-------------|-------|
| [docker-mcp-tutorial](https://github.com/theNetworkChuck/docker-mcp-tutorial) | Complete tutorial for building MCP servers with Docker | 1310⭐ |
| [code-sandbox-mcp](https://github.com/Automata-Labs-team/code-sandbox-mcp) | Secure code sandbox environment in Docker containers | 309⭐ |
| [sandbox-mcp](https://github.com/pottekkat/sandbox-mcp) | Run ANY code safely in isolated Docker containers | 96⭐ |
| [node-code-sandbox-mcp](https://github.com/alfonsograziano/node-code-sandbox-mcp) | Node.js-based MCP server for JavaScript execution | 141⭐ |

### Gateways & Orchestration

| MCP Server | Description | Stars |
|-----------|-------------|-------|
| [mcp-gateway](https://github.com/microsoft/mcp-gateway) | Microsoft's MCP Gateway for Kubernetes environments | 440⭐ |
| [mcp-context-forge](https://github.com/IBM/mcp-context-forge) | IBM's MCP Gateway & Registry with REST API conversion | 3201⭐ |
| [Unla](https://github.com/AmoyLab/Unla) | Lightweight gateway transforming APIs into MCP servers | 2020⭐ |
| [sandbox](https://github.com/agent-infra/sandbox) | All-in-One Sandbox: Browser, Shell, File, MCP and VSCode | 2307⭐ |

### Security & Testing

| MCP Server | Description | Stars |
|-----------|-------------|-------|
| [mcp-security-hub](https://github.com/FuzzingLabs/mcp-security-hub) | MCP servers for offensive security tools (Nmap, Ghidra, Nuclei) | 209⭐ |
| [MCP-Kali-Server](https://github.com/TriV3/MCP-Kali-Server) | Automates Kali Linux pentesting with MCP | 25⭐ |

### Utilities

| MCP Server | Description | Stars |
|-----------|-------------|-------|
| [yutu](https://github.com/eat-pray-ai/yutu) | Fully functional MCP server and CLI for YouTube | 372⭐ |
| [1Panel](https://github.com/1Panel-dev/1Panel) | Web interface and MCP Server to manage Linux servers | 33065⭐ |
| [openapi-mcp](https://github.com/ckanthony/openapi-mcp) | Dockerized MCP Server for accessing any API with OpenAPI docs | 169⭐ |

---

## 🎬 Featured Videos

*Coming soon - contributions welcome!*

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-resource`)
3. Commit your changes (`git commit -m 'Add amazing resource'`)
4. Push to the branch (`git push origin feature/amazing-resource`)
5. Open a Pull Request

### Contribution Ideas

- Add new blogs, tutorials, or videos
- Share your cagent agent configurations
- Create tutorials for specific use cases
- Translate resources to other languages

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

⭐ **Star this repo** if you find it helpful!

📢 **Share** with your network to help others discover cagent resources!
