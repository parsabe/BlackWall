#!/usr/bin/env bash
# BlackWall Branch Setup Helper
# Usage:
#   ./scripts/clone_branches.sh worktree   # sets up git worktrees for kernel and app
#   ./scripts/clone_branches.sh clone      # clones kernel and app into sibling directories

set -euo pipefail

REPO_URL="git@github.com:parsabe/BlackWall.git"
MODE="${1:-worktree}"

if [ "$MODE" = "worktree" ]; then
    echo "==> Setting up Git Worktrees for kernel and app..."
    git worktree add ../BlackWall-kernel kernel 2>/dev/null || echo "Worktree kernel already exists or branch not yet remote."
    git worktree add ../BlackWall-app app 2>/dev/null || echo "Worktree app already exists or branch not yet remote."
    echo "==> Worktrees initialized: ../BlackWall-kernel and ../BlackWall-app"
elif [ "$MODE" = "clone" ]; then
    echo "==> Cloning kernel branch..."
    git clone --branch kernel "$REPO_URL" ../BlackWall-kernel
    echo "==> Cloning app branch..."
    git clone --branch app "$REPO_URL" ../BlackWall-app
    echo "==> Done!"
else
    echo "Unknown mode: $MODE. Choose 'worktree' or 'clone'."
    exit 1
fi
