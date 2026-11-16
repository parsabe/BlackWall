# BlackWall Kernel: Core Safety Barrier & Backend Engines

[![Branch: Kernel](https://img.shields.io/badge/branch-kernel-crimson.svg)](https://github.com/parsabe/BlackWall/tree/kernel)
[![Master Branch](https://img.shields.io/badge/branch-master-blue.svg)](https://github.com/parsabe/BlackWall/tree/master)
[![App Branch](https://img.shields.io/badge/branch-app-teal.svg)](https://github.com/parsabe/BlackWall/tree/app)
[![Fail-Closed Security](https://img.shields.io/badge/security-Fail--Closed-red.svg)](#fail-closed-mechanisms)

The **Kernel branch** hosts the core AI safety barrier, classifier service, Ollama Gemma 3 1B model configuration, container orchestration, and the fail-closed gateway pipeline.

---

## Navigation & Cross-Branch Links

- 🌐 [Master Branch (Architecture & Global Entry Point)](https://github.com/parsabe/BlackWall/tree/master)
- 📱 [App Branch (Flutter Client Application)](https://github.com/parsabe/BlackWall/tree/app)

---

## Architecture Overview

```
User Request
    │
    ▼
┌────────────────────────────────────────────────────────┐
│ BlackWall Gateway (:8080 or parsabe.com/projects/blackwall/sandbox) │
│                                                        │
│  1. Ingress Check ──> Classifier (:8000 /analyze)      │
│     ├─ class_id != 0 ──> Return "blocked_ingress"      │
│     │                    (Gemma is NEVER contacted)    │
│     └─ class_id == 0 ──> Proceed                       │
│                                                        │
│  2. Brain Inference ─> Ollama (:11434 /api/chat)       │
│     └─ Gemma 3 1B (num_ctx: 2048, keep_alive: -1)     │
│                                                        │
│  3. Egress Check ───> Classifier (:8000 /analyze)      │
│     ├─ class_id != 0 ──> Return "blocked_egress"       │
│     │                    (Model output WITHHELD)       │
│     └─ class_id == 0 ──> Return "released" + telemetry │
│                                                        │
│  * If ANY service is unreachable ──> Return "offline"  │
│                                      (FAILS CLOSED)    │
└────────────────────────────────────────────────────────┘
```

---

## 1. Safety Classifier Service (`/analyze`)

- **Port**: `8000` (FastAPI / Uvicorn)
- **Endpoint**: `POST /analyze`
- **Request Schema**:
  ```json
  {
    "prompt": "Explain quantum mechanics"
  }
  ```
- **Response Schema**:
  ```json
  {
    "class_id": 0,
    "risk_label": "Safe",
    "confidence": 0.99,
    "categories": [],
    "latency_ms": 1.25,
    "passed": true,
    "details": { "status": "Clean compliance check" }
  }
  ```

### Safety Classification Hierarchy

| `class_id` | Risk Label | Trigger Criteria | Action |
| :---: | :--- | :--- | :--- |
| **`0`** | **Safe** | Benign queries, technical prompts, safe text. | **Passed** |
| **`1`** | **Violence / General Risk** | Harm instructions, hate, violence, weapons. | **Blocked** |
| **`2`** | **Critical Risk** | Jailbreak attempts, prompt injection, evasion. | **Blocked & Audited** |

---

## 2. Ollama Gemma 3 1B Brain (`/api/chat`)

- **Port**: `11434`
- **Model**: `gemma3:1b` (configured via `ollama/Modelfile`)
- **Key Parameters**:
  - `num_ctx`: `2048` tokens
  - `keep_alive`: `-1` (retains weights in memory for fast turnaround)
  - `temperature`: `0.7`
- **Hardware Profile**: Worst-case CPU host inference latency can reach **60s to 100s**. The gateway sets a default client timeout of 120s to prevent early disconnection.

---

## 3. Fail-Closed Gateway Service (`/sandbox`)

- **Port**: `8080` (or reverse proxied via NGINX/Ingress at `https://parsabe.com/projects/blackwall/sandbox`)
- **Payload**: `{"prompt": "<user text>"}`
- **Statuses Returned**:
  - `released`: Output cleared by both Ingress and Egress barriers.
  - `blocked_ingress`: Prompt blocked before reaching LLM.
  - `blocked_egress`: LLM output blocked; response withheld from user.
  - `offline`: Any internal dependency is down or timed out.

---

## 4. Deployment Instructions

### Option A: Docker Compose
```bash
cd infra
docker compose up -d --build
```
Verify services:
```bash
curl http://localhost:8000/health
curl http://localhost:11434/api/tags
curl http://localhost:8080/health
```

### Option B: Kubernetes
```bash
kubectl apply -f infra/k8s/00-namespace.yaml
kubectl apply -f infra/k8s/01-configmap.yaml
kubectl apply -f infra/k8s/02-classifier.yaml
kubectl apply -f infra/k8s/03-ollama.yaml
kubectl apply -f infra/k8s/04-gateway.yaml
kubectl apply -f infra/k8s/05-ingress.yaml
```

---

## 5. Running Tests

```bash
pip install -r classifier/requirements.txt -r gateway/requirements.txt pytest
pytest tests/
```
