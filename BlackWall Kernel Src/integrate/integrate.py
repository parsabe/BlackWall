import torch
import torch.nn as nn
from transformers import AutoTokenizer, AutoModel
import re

# --- CONFIG ---
MODEL_PATH = "./production_model_cv_3class" # Where we saved the best model
MAX_LEN = 512
RISK_LABELS = {0: "SAFE", 1: "GENERAL_RISK", 2: "CRITICAL"}

# --- 1. RE-DEFINE THE MODEL CLASS ---
# We must define the class exactly as it was during training so PyTorch can load the weights
class DATLongformer(nn.Module):
    def __init__(self, model_name, num_labels):
        super().__init__()
        self.longformer = AutoModel.from_pretrained(model_name)
        self.config = self.longformer.config
        hidden_size = self.config.hidden_size

        self.risk_classifier = nn.Sequential(
            nn.Dropout(0.1),
            nn.Linear(hidden_size, hidden_size),
            nn.Tanh(),
            nn.Linear(hidden_size, num_labels)
        )
        # Domain classifier exists in weights but we don't use it for inference
        self.domain_classifier = nn.Sequential(
            nn.Dropout(0.1),
            nn.Linear(hidden_size, hidden_size),
            nn.ReLU(),
            nn.Linear(hidden_size, 2)
        )

    def forward(self, input_ids, attention_mask):
        outputs = self.longformer(input_ids=input_ids, attention_mask=attention_mask)
        sequence_output = outputs.last_hidden_state[:, 0, :]
        risk_logits = self.risk_classifier(sequence_output)
        return risk_logits

# --- 2. THE GUARDRAIL CLASS ---
class SafetyGuard:
    def __init__(self):
        print("🛡️ Initializing Safety Guardrail...")
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        
        # Load Tokenizer
        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
        
        # Load Model Structure & Weights
        # Note: We pass 'allenai/longformer-base-4096' just to initialize the config, 
        # but we overwrite weights immediately
        self.model = DATLongformer('allenai/longformer-base-4096', num_labels=3)
        
        # Load the saved state dictionary (the trained brain)
        # We need to handle the case where it was saved by Trainer (might be inside a subfolder or directly)
        try:
            state_dict = torch.load(f"{MODEL_PATH}/pytorch_model.bin", map_location=self.device)
            self.model.load_state_dict(state_dict)
        except:
            # If using safetensors (newer format)
            from safetensors.torch import load_file
            state_dict = load_file(f"{MODEL_PATH}/model.safetensors")
            self.model.load_state_dict(state_dict)

        self.model.to(self.device)
        self.model.eval() # Set to evaluation mode (freezes dropout)
        print("✅ Safety Guard is Active on", self.device)

    def scan_message(self, text):
        """
        Returns: (is_safe: bool, label_name: str, probability: float)
        """
        # 1. Clean & Tokenize
        clean_text = text.lower().strip()
        inputs = self.tokenizer(
            clean_text, 
            truncation=True, 
            padding='max_length', 
            max_length=MAX_LEN, 
            return_tensors="pt"
        ).to(self.device)

        # 2. Predict
        with torch.no_grad():
            logits = self.model(inputs['input_ids'], inputs['attention_mask'])
            probs = torch.nn.functional.softmax(logits, dim=1)
            prediction = torch.argmax(probs, dim=1).item()
            confidence = probs[0][prediction].item()

        # 3. Verdict
        label_name = RISK_LABELS[prediction]
        is_safe = (prediction == 0) # Only 0 is safe
        
        return is_safe, label_name, confidence

# --- 3. SIMULATED CHATBOT APPLICATION ---
# This simulates your real chat app
def run_chat_simulation():
    guard = SafetyGuard()
    
    # Mock Chatbot Response Function
    def get_ai_response(user_input):
        # Let's pretend the AI sometimes says bad things for testing
        if "hate" in user_input:
            return "I hate you too! You should hurt yourself." # Simulated Unsafe AI Response
        else:
            return "I am a helpful AI. How can I support you today?"

    print("\n" + "="*50)
    print(" 💬 SECURE CHAT SESSION STARTED")
    print("="*50)
    print("(Type 'exit' to quit)\n")

    while True:
        # A. USER INPUT
        user_msg = input("You: ")
        if user_msg.lower() == 'exit': break

        # --- STEP 1: SCAN USER MESSAGE ---
        print(f"   [Scanning User Input...]", end="\r")
        safe, label, conf = guard.scan_message(user_msg)

        if not safe:
            print(f"❌ [BLOCKED] User message flagged as {label} ({conf:.1%})")
            print("   SYSTEM ALERT: Incoming message contained harmful content. Message dropped.")
            continue # Skip sending to bot
        
        # If safe, proceed
        print(f"✅ [CLEAN] User Input ({conf:.1%} confidence)")
        
        # --- STEP 2: SEND TO AI ---
        ai_reply = get_ai_response(user_msg)

        # --- STEP 3: SCAN AI RESPONSE ---
        print(f"   [Scanning AI Output...]", end="\r")
        safe_ai, label_ai, conf_ai = guard.scan_message(ai_reply)

        if not safe_ai:
            print(f"❌ [BLOCKED] AI Response flagged as {label_ai} ({conf_ai:.1%})")
            print(f"   SYSTEM ERROR: The AI attempted to generate harmful content: '{ai_reply}'")
            print("   RESPONSE REPLACED: [Content Redacted by Safety System]")
        else:
            print(f"✅ [CLEAN] AI Output ({conf_ai:.1%} confidence)")
            print(f"Bot: {ai_reply}")
        
        print("-" * 30)

if __name__ == "__main__":
    run_chat_simulation()