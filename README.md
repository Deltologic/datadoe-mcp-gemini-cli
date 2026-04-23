# DataDoe MCP + Gemini CLI Template

This repository is a minimal example of using the DataDoe MCP server from Gemini CLI for Amazon-focused workflows.

## Table of Contents

- [What you can do with this repo](#what-you-can-do-with-this-repo)
- [What This Repo Includes](#what-this-repo-includes)
- [Prerequisites](#prerequisites)
- [How to get a DataDoe subscription and get MCP Key](#how-to-get-a-datadoe-subscription-and-get-mcp-key)
- [Configure DataDoe MCP in Gemini CLI](#configure-datadoe-mcp-in-gemini-cli)
- [Example prompt library starter pack](#example-prompt-library-starter-pack)
- [Run Gemini CLI from Dedicated Launcher](#run-gemini-cli-from-dedicated-launcher)
- [Gemini Settings (Official Model)](#gemini-settings-official-model)
- [DataDoe MCP Configuration Options](#datadoe-mcp-configuration-options)
- [How to get help](#how-to-get-help)

## What you can do with this repo

- Connect Gemini CLI to DataDoe MCP in a secure way.
- Ask Amazon seller questions using DataDoe-backed data.
- Reuse this setup as a template for new Amazon-focused assistant projects.

## What This Repo Includes

- Gemini CLI MCP setup guidance for a project-scoped `datadoe` server
- secure secret handling with `.env` and `.env.example`
- repository-specific assistant rules in `GEMINI.md`

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

## How to get a DataDoe subscription and get MCP Key

1. Go to [app.datadoe.com](https://app.datadoe.com).
2. Create an account.
3. Purchase a subscription.
4. Accept the Terms and Conditions and Privacy Policy.
5. Go to the `Integrations` module.
6. Click the `MCP` tile (this navigates to `/integrations/mcp`).
7. Click `MCP Key`, then add a name and expiration date, and click `Create`.
8. Copy the key and store it in a secure secret manager or another safe location.

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

## Example prompt library starter pack

To help you start faster with an AI Agent + DataDoe MCP workflow, this repo includes a small prompt library at:

- `.gemini/prompts/EXAMPLES.md`

Use it as a starter pack:

1. Open `.gemini/prompts/EXAMPLES.md`.
2. Copy a prompt block and adjust placeholders (for example `{{seller_name}}`) to your account context.
3. Run the prompt in Gemini CLI shell chat with DataDoe MCP enabled.
4. Save your own high-performing prompts in the same file to build a reusable internal playbook.

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

## How to get help

- Email: [contact@datadoe.com](mailto:contact@datadoe.com)
- Gemini CLI docs: [geminicli.com/docs](https://geminicli.com/docs/)
- Gemini CLI commands: [geminicli.com/docs/reference/commands](https://geminicli.com/docs/reference/commands/)
