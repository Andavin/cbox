FROM eclipse-temurin:21-jdk-jammy

# Install Node.js (required for Claude Code), Python 3.13, git, and dev tools
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs curl git python3.13 python3.13-venv python3-pip vim jq less htop procps tmux bash-completion maven gradle && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1 && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    # Install GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y gh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install uv (for Bazinga multi-agent orchestration)
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# Create a non-root user
RUN useradd -m -s /bin/bash javadev

# Create config directory with proper ownership (before volume mount)
RUN mkdir -p /claude-config && chown -R javadev:javadev /claude-config

# Switch to non-root user for Claude installation
USER javadev
WORKDIR /home/javadev

# Install Claude Code via native installer
RUN curl -fsSL https://claude.ai/install.sh | bash

# Add Claude to PATH
ENV PATH="/home/javadev/.local/bin:${PATH}"

# Copy Claude configuration files (CLAUDE.md, settings.json, etc.)
# Build with: docker build -f Dockerfile.java .
COPY --chown=root:root context/ /root/.claude/
COPY --chown=javadev:javadev context/ /home/javadev/.claude/

# Copy entrypoint script
COPY --chown=root:root entrypoint.sh /usr/local/bin/entrypoint.sh

# Verify installations
RUN java --version && node --version && python --version && claude --version && uv --version

# Set working directory
WORKDIR /app

ENTRYPOINT ["entrypoint.sh"]
