import torch
import torch.nn as nn
from transformers import AutoTokenizer, AutoModel
from safetensors.torch import load_file # <--- REQUIRED FOR NEW MODELS
import os
import sys

# --- CONFIG ---
MODEL_PATH = "./blackwall_models/production_ready"
MAX_LEN = 256
RISK_LABELS = {0: "SAFE", 1: "VIOLENCE/ILLEGAL", 2: "SUICIDE/CRITICAL"}

# --- 1. RE-DEFINE THE MODEL CLASS ---
class DATLongformer(nn.Module):
    def __init__(self, model_name, num_labels, num_domains=3):
        super().__init__()
        self.longformer = AutoModel.from_pretrained(model_name, weights_only=False)
        self.config = self.longformer.config
        hidden_size = self.config.hidden_size

        self.risk_classifier = nn.Sequential(
            nn.Dropout(0.1),
            nn.Linear(hidden_size, hidden_size),
            nn.Tanh(),
            nn.Linear(hidden_size, num_labels)
        )

        self.domain_classifier = nn.Sequential(
            nn.Dropout(0.1),
            nn.Linear(hidden_size, hidden_size),
            nn.ReLU(),
            nn.Linear(hidden_size, num_domains)
        )

    def forward(self, input_ids, attention_mask):
        outputs = self.longformer(input_ids=input_ids, attention_mask=attention_mask)
        sequence_output = outputs.last_hidden_state[:, 0, :]
        risk_logits = self.risk_classifier(sequence_output)
        return risk_logits

# --- 2. THE GUARDRAIL CLASS ---
class SafetyGuard:
    def __init__(self):
        print("🛡️  Initializing Safety Guardrail...")
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"✅  Hardware: {self.device}")
        
        # A. Load Tokenizer
        try:
            self.tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
        except:
            print("⚠️  Using default tokenizer.")
            self.tokenizer = AutoTokenizer.from_pretrained('allenai/longformer-base-4096')
        
        # B. Initialize Structure
        print("⚙️  Building Model Architecture...")
        self.model = DATLongformer('allenai/longformer-base-4096', num_labels=3, num_domains=3)
        
        # C. Load Weights (SMART LOADER)
        # Check which file exists
        safetensors_path = os.path.join(MODEL_PATH, "model.safetensors")
        bin_path = os.path.join(MODEL_PATH, "pytorch_model.bin")
        
        try:
            if os.path.exists(safetensors_path):
                print(f"📂 Loading SAFETENSORS from: {safetensors_path}")
                # USE SPECIAL LOADER FOR SAFETENSORS
                state_dict = load_file(safetensors_path)
                self.model.load_state_dict(state_dict)
                print("✅  Weights Loaded Successfully.")
                
            elif os.path.exists(bin_path):
                print(f"📂 Loading BIN from: {bin_path}")
                # USE STANDARD LOADER FOR BIN
                state_dict = torch.load(bin_path, map_location=self.device)
                self.model.load_state_dict(state_dict)
                print("✅  Weights Loaded Successfully.")
            else:
                print(f"❌  No model file found in {MODEL_PATH}")
                sys.exit(1)
                
        except Exception as e:
            print(f"❌  CRITICAL ERROR Loading Weights: {e}")
            sys.exit(1)

        self.model.to(self.device)
        self.model.eval()
        print("✅  Safety Guard is ACTIVE.\n")

    def scan_message(self, text):
        clean_text = str(text).lower().strip()
        inputs = self.tokenizer(
            clean_text, 
            truncation=True, 
            padding='max_length', 
            max_length=MAX_LEN, 
            return_tensors="pt"
        ).to(self.device)

        with torch.no_grad():
            logits = self.model(inputs['input_ids'], inputs['attention_mask'])
            probs = torch.nn.functional.softmax(logits, dim=1)
            prediction_idx = torch.argmax(probs, dim=1).item()
            confidence = probs[0][prediction_idx].item()

        label_name = RISK_LABELS[prediction_idx]
        is_safe = (prediction_idx == 0)
        return is_safe, label_name, confidence

# --- 3. CHAT SIMULATION ---
def run_chat():
    guard = SafetyGuard()
    
    print("="*60)
    print(" 💬  BLACKWALL SECURE CHAT")
    print("="*60)
    print("Type 'exit' to quit.\n")

    while True:
        try:
            user_msg = input("You: ")
            if user_msg.lower() in ['exit', 'quit']: break
            if not user_msg.strip(): continue

            safe, label, conf = guard.scan_message(user_msg)

            if not safe:
                print(f"🚫 [BLOCKED] Flagged as {label} ({conf:.1%})")
            else:
                print(f"✅ [SAFE] Sent to AI ({conf:.1%})")
                print("Bot: I am a helpful AI assistant.")
                
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    run_chat()