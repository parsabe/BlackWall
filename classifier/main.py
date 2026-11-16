"""
BlackWall Safety Classifier Barrier Service (/analyze)
Evaluates prompt and response safety:
  class_id 0: Safe
  class_id 1: Violence / General Risk
  class_id 2: Critical Risk (Injections, Jailbreaks, Exploits)
"""

import time
import re
from typing import List, Optional, Dict, Any
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import uvicorn

app = FastAPI(
    title="BlackWall AI Safety Classifier",
    version="1.0.0",
    description="Dual-Barrier Ingress/Egress Inspection Service"
)

# Pattern banks for safety classification
CRITICAL_RISK_PATTERNS = [
    r"(?i)\bignore\s+(?:all\s+)?previous\s+instructions\b",
    r"(?i)\byou\s+are\s+now\s+(?:dan|developer\s+mode|unrestricted|jailbreak)\b",
    r"(?i)\bbypass\s+(?:safety|filter|guardrail|firewall|blackwall)\b",
    r"(?i)\bdisregard\s+(?:your\s+)?(?:rules|instructions|directives|safety)\b",
    r"(?i)\breveal\s+(?:your\s+)?(?:system\s+prompt|hidden\s+prompt|instructions)\b",
    r"(?i)\bwrite\s+(?:a\s+)?(?:malware|ransomware|keylogger|rootkit|exploit\s+script)\b",
    r"(?i)\b(?:sql\s+injection|xss\s+payload|remote\s+code\s+execution|zero-day)\b",
]

GENERAL_RISK_PATTERNS = [
    r"(?i)\bhow\s+to\s+(?:build|make|manufacture)\s+(?:a\s+)?(?:bomb|explosive|weapon)\b",
    r"(?i)\bhow\s+to\s+(?:synthesize|cook)\s+(?:methamphetamine|heroin|fentanyl)\b",
    r"(?i)\bhow\s+to\s+(?:kill|harm|torture|assassinate)\b",
    r"(?i)\bhow\s+to\s+commit\s+(?:suicide|self-harm)\b",
    r"(?i)\bhate\s+speech\b",
    r"(?i)\bviolent\s+extremism\b",
]

class AnalyzeRequest(BaseModel):
    prompt: Optional[str] = Field(default=None, description="Input prompt text")
    text: Optional[str] = Field(default=None, description="Alternative text payload")

    def get_content(self) -> str:
        return (self.prompt or self.text or "").strip()

class AnalyzeResponse(BaseModel):
    class_id: int = Field(..., description="0=Safe, 1=General Risk, 2=Critical Risk")
    risk_label: str = Field(..., description="Human readable risk level")
    confidence: float = Field(..., description="Confidence score between 0.0 and 1.0")
    categories: List[str] = Field(default_factory=list, description="Flagged risk categories")
    latency_ms: float = Field(..., description="Analysis duration in milliseconds")
    passed: bool = Field(..., description="True if class_id == 0")
    details: Optional[Dict[str, Any]] = None

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "blackwall-classifier",
        "port": 8000,
        "classes": {
            0: "Safe",
            1: "Violence / General Risk",
            2: "Critical Risk"
        }
    }

@app.post("/analyze", response_model=AnalyzeResponse)
def analyze(payload: AnalyzeRequest):
    start_time = time.perf_counter()
    content = payload.get_content()

    if not content:
        duration_ms = (time.perf_counter() - start_time) * 1000
        return AnalyzeResponse(
            class_id=0,
            risk_label="Safe",
            confidence=1.0,
            categories=[],
            latency_ms=round(duration_ms, 2),
            passed=True,
            details={"reason": "Empty payload treated as inert"}
        )

    # 1. Critical Risk Check (Jailbreaks, Injections, Exploits)
    critical_matches = []
    for pattern in CRITICAL_RISK_PATTERNS:
        if re.search(pattern, content):
            critical_matches.append(pattern)

    if critical_matches:
        duration_ms = (time.perf_counter() - start_time) * 1000
        return AnalyzeResponse(
            class_id=2,
            risk_label="Critical Risk",
            confidence=0.98,
            categories=["injection_jailbreak", "security_evasion"],
            latency_ms=round(duration_ms, 2),
            passed=False,
            details={"matched_rules": len(critical_matches)}
        )

    # 2. General Risk Check (Violence, Harm, Controlled Items)
    general_matches = []
    for pattern in GENERAL_RISK_PATTERNS:
        if re.search(pattern, content):
            general_matches.append(pattern)

    if general_matches:
        duration_ms = (time.perf_counter() - start_time) * 1000
        return AnalyzeResponse(
            class_id=1,
            risk_label="Violence / General Risk",
            confidence=0.92,
            categories=["violence_or_harm", "policy_violation"],
            latency_ms=round(duration_ms, 2),
            passed=False,
            details={"matched_rules": len(general_matches)}
        )

    # 3. Passed Safe (Class ID 0)
    duration_ms = (time.perf_counter() - start_time) * 1000
    return AnalyzeResponse(
        class_id=0,
        risk_label="Safe",
        confidence=0.99,
        categories=[],
        latency_ms=round(duration_ms, 2),
        passed=True,
        details={"status": "Clean compliance check"}
    )

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
