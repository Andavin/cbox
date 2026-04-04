# cbox

Containerized Claude Code environments. Run Claude Code inside Docker with pre-configured toolchains, git credentials, and multi-agent orchestration.

## Why

Claude Code runs commands on your machine. cbox isolates it in a Docker container with the right language toolchain, while forwarding your git credentials and GitHub token so it can still commit and push.

## Profiles

Each `Dockerfile.<profile>` builds a container image with Claude Code plus a language-specific toolchain:

| Profile | Base Image | Includes |
|---------|-----------|----------|
| `node` | node:22-slim | Node.js, pnpm, Python, Excel libraries |
| `java` | eclipse-temurin:21 | JDK 21, Maven, Gradle, Node.js, Python 3.13 |

All profiles include: Claude Code, GitHub CLI, [Bazinga](https://github.com/mehdic/bazinga) multi-agent orchestration, git, vim, jq, htop.

## Install

```bash
git clone <this-repo> && cd cbox
./install.sh
```

This installs the `cbox` command to `~/.local/bin` (or `/usr/local/bin` if that's not in your PATH) and optionally builds the Docker images.

Override the install location:

```bash
INSTALL_DIR=/opt/bin ./install.sh
```

## Build images

```bash
./build.sh
```

Builds all profiles. Images are tagged `cbox-<profile>` (e.g. `cbox-node`, `cbox-java`).

## Usage

```bash
cbox <profile> [args...]
```

Opens an interactive Claude Code session inside the container, with the current directory mounted as the workspace.

```bash
# Start a Node.js Claude session
cbox node

# Start with a prompt
cbox node "refactor the auth module"

# List available profiles
cbox profiles
```

## How it works

- Mounts your current directory into the container at `/workspace/$(pwd)`
- Forwards your `~/.gitconfig` and git credentials (works with any credential helper: store, osxkeychain, manager-core)
- Passes your GitHub token as `GH_TOKEN` for the GitHub CLI
- Uses a persistent Docker volume (`claude_config`) for Claude's config across sessions
- Runs Claude Code with `--dangerously-skip-permissions` (it's sandboxed by the container)

## Customization

Claude configuration files live in `context/` and are baked into the images at build time:

- `context/CLAUDE.md` -- instructions Claude follows in every session
- `context/settings.json` -- Claude Code settings
- `context/PR_TEMPLATE_REFERENCE.md` -- PR template reference

Edit these and rebuild with `./build.sh` to apply changes.

## Adding a profile

Create a new `Dockerfile.<name>` (e.g. `Dockerfile.rust`). The build script picks it up automatically and the profile becomes available as `cbox rust`.
