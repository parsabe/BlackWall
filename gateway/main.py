"""
BlackWall Fail-Closed Gateway Service (/sandbox)
Implements the Dual-Barrier Sandwich:
  User -> Ingress Check -> Gemma 3 1B -> Egress Check -> User

Security Guarantees:
  - If ingress flags unsafe -> blocked_ingress (never contacts Gemma)
  - If egress flags unsafe  -> blocked_egress (output withheld)
  - If any service fails    -> Fails Closed (status: offline)
"""

import os
import time
import httpx
from typing import Optional, Dict, Any
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn

app = FastAPI(
    title="BlackWall Gateway",
    version="1.0.0",
    description="Dual-Barrier AI Guardrail Gateway"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

CLASSIFIER_URL = os.getenv("CLASSIFIER_URL", "http://127.0.0.1:8000")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
MODEL_NAME = os.getenv("OLLAMA_MODEL", "gemma3:1b")
GATEWAY_TIMEOUT_SEC = float(os.getenv("GATEWAY_TIMEOUT_SEC", "120.0"))

class SandboxRequest(BaseModel):
    prompt: str = Field(..., description="User prompt to evaluate and process")

class Telemetry(BaseModel):
    ingress_latency_ms: float = 0.0
    ingress_class_id: int = 0
    llm_latency_ms: float = 0.0
    egress_latency_ms: float = 0.0
    egress_class_id: int = 0
    barrier_overhead_ms: float = 0.0
    total_latency_ms: float = 0.0

class SandboxResponse(BaseModel):
    status: str = Field(..., description="released | blocked_ingress | blocked_egress | offline")
    response: Optional[str] = Field(None, description="Released vetted assistant response or null if blocked")
    message: Optional[str] = Field(None, description="System explanation or security reason")
    telemetry: Telemetry

@app.get("/health")
async def health_check():
    classifier_ok = False
    ollama_ok = False

    async with httpx.AsyncClient(timeout=3.0) as client:
        try:
            r = await client.get(f"{CLASSIFIER_URL}/health")
            classifier_ok = (r.status_code == 200)
        except Exception:
            classifier_ok = False

        try:
            r = await client.get(f"{OLLAMA_URL}/api/tags")
            ollama_ok = (r.status_code == 200)
        except Exception:
            ollama_ok = False

    overall = classifier_ok and ollama_ok
    return JSONResponse(
        status_code=200 if overall else 503,
        content={
            "status": "healthy" if overall else "degraded",
            "classifier_healthy": classifier_ok,
            "ollama_healthy": ollama_ok,
            "fail_closed": True
        }
    )

@app.post("/sandbox", response_model=SandboxResponse)
async def sandbox_pipeline(payload: SandboxRequest):
    req_start = time.perf_counter()
    telemetry = Telemetry()

    # ─────────────────────────────────────────────────────────────
    # STEP 1: Ingress Safety Barrier Check (/analyze)
    # ─────────────────────────────────────────────────────────────
    ingress_start = time.perf_counter()
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            ingress_res = await client.post(
                f"{CLASSIFIER_URL}/analyze",
                json={"prompt": payload.prompt}
            )
            if ingress_res.status_code != 200:
                raise RuntimeError(f"Classifier returned status {ingress_res.status_code}")
            ingress_data = ingress_res.json()
    except Exception as e:
        # FAIL CLOSED: Classifier unreachable
        total_time = (time.perf_counter() - req_start) * 1000
        telemetry.total_latency_ms = round(total_time, 2)
        return SandboxResponse(
            status="offline",
            response=None,
            message=f"Fail-Closed Triggered: Ingress classifier barrier unreachable ({str(e)}).",
            telemetry=telemetry
        )

    telemetry.ingress_latency_ms = round((time.perf_counter() - ingress_start) * 1000, 2)
    telemetry.ingress_class_id = ingress_data.get("class_id", 2)

    # If unsafe, reject immediately at ingress. NEVER contact Gemma!
    if telemetry.ingress_class_id != 0:
        telemetry.barrier_overhead_ms = telemetry.ingress_latency_ms
        telemetry.total_latency_ms = round((time.perf_counter() - req_start) * 1000, 2)
        return SandboxResponse(
            status="blocked_ingress",
            response=None,
            message=f"Prompt rejected by Ingress Safety Barrier (Class ID: {telemetry.ingress_class_id} - {ingress_data.get('risk_label')}).",
            telemetry=telemetry
        )

    # ─────────────────────────────────────────────────────────────
    # STEP 2: LLM Brain Inference (Gemma 3 1B via Ollama)
    # ─────────────────────────────────────────────────────────────
    llm_start = time.perf_counter()
    raw_response_text = ""
    try:
        async with httpx.AsyncClient(timeout=GATEWAY_TIMEOUT_SEC) as client:
            ollama_payload = {
                "model": MODEL_NAME,
                "messages": [
                    {
                        "role": "user",
                        "content": payload.prompt
                    }
                ],
                "options": {
                    "num_ctx": 2048,
                    "temperature": 0.7
                },
                "keep_alive": -1,
                "stream": False
            }
            ollama_res = await client.post(
                f"{OLLAMA_URL}/api/chat",
                json=ollama_payload
            )
            if ollama_res.status_code != 200:
                raise RuntimeError(f"Ollama returned HTTP {ollama_res.status_code}: {ollama_res.text}")
            ollama_data = ollama_res.json()
            raw_response_text = ollama_data.get("message", {}).get("content", "")
    except Exception as e:
        # FAIL CLOSED: LLM engine unreachable or timed out
        total_time = (time.perf_counter() - req_start) * 1000
        telemetry.llm_latency_ms = round((time.perf_counter() - llm_start) * 1000, 2)
        telemetry.total_latency_ms = round(total_time, 2)
        return SandboxResponse(
            status="offline",
            response=None,
            message=f"Fail-Closed Triggered: Gemma LLM engine unreachable or timed out ({str(e)}).",
            telemetry=telemetry
        )

    telemetry.llm_latency_ms = round((time.perf_counter() - llm_start) * 1000, 2)

    # ─────────────────────────────────────────────────────────────
    # STEP 3: Egress Safety Barrier Check (/analyze)
    # ─────────────────────────────────────────────────────────────
    egress_start = time.perf_counter()
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            egress_res = await client.post(
                f"{CLASSIFIER_URL}/analyze",
                json={"text": raw_response_text}
            )
            if egress_res.status_code != 200:
                raise RuntimeError(f"Classifier returned status {egress_res.status_code}")
            egress_data = egress_res.json()
    except Exception as e:
        # FAIL CLOSED: Egress barrier unreachable
        total_time = (time.perf_counter() - req_start) * 1000
        telemetry.total_latency_ms = round(total_time, 2)
        return SandboxResponse(
            status="offline",
            response=None,
            message=f"Fail-Closed Triggered: Egress classifier barrier unreachable ({str(e)}).",
            telemetry=telemetry
        )

    telemetry.egress_latency_ms = round((time.perf_counter() - egress_start) * 1000, 2)
    telemetry.egress_class_id = egress_data.get("class_id", 2)
    telemetry.barrier_overhead_ms = round(telemetry.ingress_latency_ms + telemetry.egress_latency_ms, 2)
    telemetry.total_latency_ms = round((time.perf_counter() - req_start) * 1000, 2)

    # If unsafe, withhold response from user!
    if telemetry.egress_class_id != 0:
        return SandboxResponse(
            status="blocked_egress",
            response=None,
            message=f"Model output suppressed by Egress Safety Barrier (Class ID: {telemetry.egress_class_id} - {egress_data.get('risk_label')}).",
            telemetry=telemetry
        )

    # ─────────────────────────────────────────────────────────────
    # STEP 4: Release Vetted Response
    # ─────────────────────────────────────────────────────────────
    return SandboxResponse(
        status="released",
        response=raw_response_text,
        message="Request vetted and cleared by BlackWall dual-stage security.",
        telemetry=telemetry
    )

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=False)
