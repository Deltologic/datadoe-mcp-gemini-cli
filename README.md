# DataDoe MCP + Gemini CLI Template

This repository is a starter template for integrating DataDoe MCP with Gemini CLI in a secure, team-friendly way.

## Table of Contents

- [What This Repo Includes](#what-this-repo-includes)
- [Prerequisites](#prerequisites)
- [Get DataDoe Subscription and MCP Key](#get-datadoe-subscription-and-mcp-key)
- [Configure DataDoe MCP in Gemini CLI](#configure-datadoe-mcp-in-gemini-cli)
- [Run Gemini CLI from Dedicated Launcher](#run-gemini-cli-from-dedicated-launcher)
- [Gemini Settings (Official Model)](#gemini-settings-official-model)
- [DataDoe MCP Configuration Options](#datadoe-mcp-configuration-options)
- [Validation Checklist](#validation-checklist)
- [How to get help](#how-to-get-help)
- [Recommended repository cleanup](#recommended-repository-cleanup)
- [Tags](#tags)

## What This Repo Includes

- Gemini CLI MCP setup guidance for a project-scoped `datadoe` server
- secure secret handling with `.env` and `.env.example`
- repository-specific assistant rules in `GEMINI.md`
- validation checks to confirm integration is working

## Prerequisites

- Gemini CLI installed and working (`gemini --version`)
- A valid DataDoe subscription
- A generated DataDoe MCP key

If `gemini --version` shows nothing or `gemini` is not found, install and verify Gemini CLI:

```bash
npm install -g @google/gemini-cli
hash -r
gemini --version
```

If the command is still not found, add npm global binaries to your shell `PATH` (for `zsh`):

```bash
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
which gemini
gemini --version
```

If your organization uses Google Workspace subscription access for Gemini CLI, authenticate with your Workspace account:

1. Run `gemini`
2. Choose **Sign in with Google**
3. Complete browser sign-in with your Workspace account
4. If needed later, run `/auth` inside Gemini CLI to switch authentication method

## Get DataDoe Subscription and MCP Key

1. Go to [app.datadoe.com](https://app.datadoe.com)
2. Create account
3. Purchase subscription
4. Accept Terms and Conditions and Privacy Policy
5. Go to `Integrations`
6. Click `MCP` tile (`/integrations/mcp`)
7. Click `MCP Key`, add name + expiration, click `Create`
8. Copy key and store in a secure secret manager

## Configure DataDoe MCP in Gemini CLI

> [!WARNING]
> Direct `gemini mcp add ...` connection for DataDoe is currently unreliable in our setup.
> Use the launcher + `mcp-remote` workaround from this repository.

Direct command shown below is kept for reference only:

```bash
gemini mcp add --transport http --scope project --header "datadoe-mcp-key: YOUR_API_KEY" datadoe "https://api.datadoe.com/mcp/v1"
```

What this does (reference behavior):

- adds a project-scoped MCP server named `datadoe`
- creates/updates `.gemini/settings.json` for shared project configuration
- keeps setup consistent for all collaborators

Reference: [Gemini CLI MCP docs](https://geminicli.com/docs/tools/mcp-server/)
and [`mcp-remote` usage docs](https://www.npmjs.com/package/mcp-remote#Usage)

## Run Gemini CLI from Dedicated Launcher

This repository includes a dedicated launcher script:

> [!WARNING]
> `scripts/start-gemini.sh` is the protected launcher for this repository.
> Do not edit, replace, or "quick fix" it unless you are intentionally changing launcher behavior.

```bash
./scripts/start-gemini.sh
```

The launcher loads `.env`, exports `DATADOE_MCP_KEY` into the current process, syncs `.gemini/settings.json` to the repository `mcp-remote` configuration, and then starts Gemini CLI from the repository root.

Short manual:

```bash
# Interactive menu (recommended)
./scripts/start-gemini.sh

# Direct launch Gemini CLI
./scripts/start-gemini.sh --cli

# Validate env loading + Gemini CLI availability only
./scripts/start-gemini.sh --check

# Help
./scripts/start-gemini.sh --help
```

If needed, make it executable once:

```bash
chmod +x ./scripts/start-gemini.sh
```

## Gemini Settings (Official Model)

Gemini CLI supports user and project settings scopes:

- **User scope**: `~/.gemini/settings.json` (personal defaults across repositories)
- **Project scope**: `.gemini/settings.json` (shared with this repository team)
- **Project memory/instructions**: `GEMINI.md` (team-shared assistant guidance)

Recommended workflow:

1. Use `/settings` inside Gemini CLI to create or edit settings safely.
2. Keep team-wide MCP setup in `.gemini/settings.json`.
3. Use `/model` to inspect or set the active model for your session.
4. Use `/mcp` to verify MCP server status and discovered tools.

## DataDoe MCP Configuration Options

You can configure DataDoe MCP in either of these ways.

Option A: repository-managed `mcp-remote` proxy config (recommended and currently supported):

```json
{
  "mcpServers": {
    "datadoe": {
      "command": "bash",
      "args": [
        "-lc",
        "npx -y mcp-remote@latest https://api.datadoe.com/mcp/v1 --transport http-only --header \"datadoe-mcp-key:${DATADOE_MCP_KEY}\""
      ],
      "env": {
        "DATADOE_MCP_KEY": "$DATADOE_MCP_KEY"
      }
    }
  }
}
```

Option B: direct Gemini MCP HTTP setup (currently unstable in this environment; fallback only):

```bash
gemini mcp add --transport http --scope project --header "datadoe-mcp-key: YOUR_API_KEY" datadoe "https://api.datadoe.com/mcp/v1"
```

The recommended path is to always start with `./scripts/start-gemini.sh`, which loads `.env` and re-syncs `mcp-remote` configuration automatically.

> [!CAUTION]
> Treat `DATADOE_MCP_KEY` like a password. Do not publish repositories, screenshots, or logs that contain this key.
> Never commit real keys to git.
> If a key is exposed, rotate it immediately.

## Validation Checklist

- `.env` is ignored by Git.
- `.env.example` is tracked by Git.
- `GEMINI.md` exists.
- `gemini mcp list` shows `datadoe`.
- `/mcp` inside Gemini CLI shows the server as available.

## How to get help

- Email: [contact@datadoe.com](mailto:contact@datadoe.com)
- Gemini CLI docs: [geminicli.com/docs](https://geminicli.com/docs/)
- Gemini CLI commands: [geminicli.com/docs/reference/commands](https://geminicli.com/docs/reference/commands/)

## Recommended repository cleanup

For each repository using this template, keep settings lean:

- Disable GitHub Wiki if not used.
- Disable GitHub Projects if not used.
- Disable Discussions if not used.
- Keep branch protection minimal but enabled for your main branch.
- Do not commit `.env` or real API keys.

## Tags

`DataDoe` `MCP` `Google` `Gemini CLI` `Amazon` `Amazon Seller` `AI Assistant` `LLM` `Prompting` `E-Commerce` `Online Marketplaces`
