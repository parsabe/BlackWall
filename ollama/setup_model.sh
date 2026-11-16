#!/usr/bin/env bash
# BlackWall Ollama Model Initialization
set -euo pipefail

OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
MODEL_NAME="blackwall-gemma:latest"

echo "==> Checking Ollama connection at $OLLAMA_HOST..."
until curl -s "$OLLAMA_HOST/api/tags" > /dev/null; do
    echo "Waiting for Ollama to become ready..."
    sleep 2
done

echo "==> Pulling base model gemma3:1b..."
curl -s -X POST "$OLLAMA_HOST/api/pull" -d '{"name": "gemma3:1b"}' | grep -o '"status":"[^"]*"' || true

echo "==> Building custom model $MODEL_NAME from Modelfile..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
curl -s -X POST "$OLLAMA_HOST/api/create" -d "{\"name\": \"$MODEL_NAME\", \"path\": \"$SCRIPT_DIR/Modelfile\"}" || true

echo "==> BlackWall Gemma 3 1B model setup completed successfully."
