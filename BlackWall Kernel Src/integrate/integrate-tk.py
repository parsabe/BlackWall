import torch
import torch.nn as nn
from transformers import AutoTokenizer, AutoModel
from safetensors.torch import load_file
import os
import sys
import threading
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox

# --- CONFIG ---
MODEL_PATH = "./blackwall_models/production_ready"
MAX_LEN = 256
RISK_LABELS = {0: "SAFE", 1: "VIOLENCE/ILLEGAL", 2: "SUICIDE/CRITICAL"}

# --- THEME COLORS ---
COLOR_BG = "#121212"        # Dark Background
COLOR_FG = "#E0E0E0"        # Light Text
COLOR_ACCENT = "#00FF41"    # Matrix Green
COLOR_SAFE = "#2E7D32"      # Green for Safe
COLOR_DANGER = "#C62828"    # Red for Danger
COLOR_INPUT = "#1E1E1E"     # Slightly lighter BG for input

# --- 1. MODEL DEFINITION (Unchanged Logic) ---
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

# --- 2. THE GUARDRAIL LOGIC (Refactored for GUI) ---
class SafetyGuard:
    def __init__(self, status_callback=None):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.tokenizer = None
        self.model = None
        self.status_callback = status_callback  # Function to update GUI text

    def log(self, message):
        if self.status_callback:
            self.status_callback(message)
        print(message)

    def load_model(self):
        self.log("🛡️ Initializing Guardrail...")
        
        # A. Load Tokenizer
        try:
            self.tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
        except:
            self.log("⚠️ Using default tokenizer.")
            self.tokenizer = AutoTokenizer.from_pretrained('allenai/longformer-base-4096')
        
        # B. Initialize Structure
        self.log(f"⚙️ Building Model on {self.device}...")
        self.model = DATLongformer('allenai/longformer-base-4096', num_labels=3, num_domains=3)
        
        # C. Load Weights
        safetensors_path = os.path.join(MODEL_PATH, "model.safetensors")
        bin_path = os.path.join(MODEL_PATH, "pytorch_model.bin")
        
        try:
            if os.path.exists(safetensors_path):
                self.log(f"📂 Loading SAFETENSORS...")
                state_dict = load_file(safetensors_path)
                self.model.load_state_dict(state_dict)
            elif os.path.exists(bin_path):
                self.log(f"📂 Loading BIN...")
                state_dict = torch.load(bin_path, map_location=self.device)
                self.model.load_state_dict(state_dict)
            else:
                self.log(f"❌ No model found in {MODEL_PATH}")
                return False
                
        except Exception as e:
            self.log(f"❌ Error: {e}")
            return False

        self.model.to(self.device)
        self.model.eval()
        self.log("✅ SYSTEM ONLINE")
        return True

    def scan_message(self, text):
        if not self.model:
            return False, "MODEL_NOT_LOADED", 0.0

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

# --- 3. TKINTER GUI ---
class BlackwallApp:
    def __init__(self, root):
        self.root = root
        self.root.title("BLACKWALL // SECURE CHAT TERMINAL")
        self.root.geometry("700x600")
        self.root.configure(bg=COLOR_BG)

        self.guard = SafetyGuard(status_callback=self.update_status_threadsafe)
        self.is_loading = True

        self._setup_ui()
        
        # Load model in a separate thread to prevent GUI freezing
        threading.Thread(target=self._init_model, daemon=True).start()

    def _setup_ui(self):
        # 1. Header
        header_frame = tk.Frame(self.root, bg=COLOR_BG)
        header_frame.pack(fill="x", padx=10, pady=10)
        
        lbl_title = tk.Label(header_frame, text="BLACKWALL PROTOCOL", 
                             font=("Consolas", 16, "bold"), fg=COLOR_ACCENT, bg=COLOR_BG)
        lbl_title.pack(side="left")

        self.lbl_status = tk.Label(header_frame, text="INITIALIZING...", 
                                   font=("Consolas", 10), fg="yellow", bg=COLOR_BG)
        self.lbl_status.pack(side="right")

        # 2. Chat History (ScrolledText)
        self.chat_display = scrolledtext.ScrolledText(self.root, state='disabled', 
                                                      bg=COLOR_INPUT, fg=COLOR_FG,
                                                      font=("Helvetica", 11), insertbackground="white")
        self.chat_display.pack(expand=True, fill="both", padx=10, pady=5)

        # Configure tags for coloring text
        self.chat_display.tag_config("user", foreground="#64B5F6", font=("Helvetica", 11, "bold"))
        self.chat_display.tag_config("bot", foreground="#81C784")
        self.chat_display.tag_config("blocked", foreground="#EF5350", font=("Helvetica", 11, "italic"))
        self.chat_display.tag_config("system", foreground="#9E9E9E", font=("Consolas", 9))

        # 3. Input Area
        input_frame = tk.Frame(self.root, bg=COLOR_BG)
        input_frame.pack(fill="x", padx=10, pady=10)

        self.txt_input = tk.Entry(input_frame, bg=COLOR_INPUT, fg="white", 
                                  font=("Helvetica", 12), insertbackground="white",
                                  relief="flat")
        self.txt_input.pack(side="left", fill="x", expand=True, ipady=8, padx=(0, 10))
        self.txt_input.bind("<Return>", self.send_message)

        self.btn_send = tk.Button(input_frame, text="SECURE SEND", command=self.send_message,
                                  bg=COLOR_ACCENT, fg="black", font=("Consolas", 10, "bold"),
                                  activebackground="#00CC33", relief="flat")
        self.btn_send.pack(side="right", ipadx=10)

    def update_status_threadsafe(self, msg):
        # Tkinter is not thread-safe, so we use after()
        self.root.after(0, lambda: self.lbl_status.config(text=msg))

    def _init_model(self):
        success = self.guard.load_model()
        self.is_loading = False
        if success:
            self.update_status_threadsafe("● ONLINE")
            self.root.after(0, lambda: self.lbl_status.config(fg=COLOR_ACCENT))
        else:
            self.update_status_threadsafe("⚠ LOAD FAILED")
            self.root.after(0, lambda: self.lbl_status.config(fg=COLOR_DANGER))

    def append_chat(self, sender, message, tag):
        self.chat_display.config(state='normal')
        self.chat_display.insert(tk.END, f"{sender}: ", tag)
        self.chat_display.insert(tk.END, f"{message}\n\n")
        self.chat_display.see(tk.END)
        self.chat_display.config(state='disabled')

    def send_message(self, event=None):
        if self.is_loading:
            messagebox.showinfo("Wait", "System is still initializing...")
            return

        msg = self.txt_input.get().strip()
        if not msg: return

        # Clear input
        self.txt_input.delete(0, tk.END)
        
        # Display User Message
        self.append_chat("You", msg, "user")

        # 1. Run Classification
        safe, label, confidence = self.guard.scan_message(msg)
        
        # 2. Visual Feedback Logic
        if safe:
            self.lbl_status.config(text=f"✓ SAFE ({confidence:.1%})", fg=COLOR_SAFE)
            # Simulate Bot Response
            self.root.after(500, lambda: self.append_chat("Blackwall AI", "Message received. How can I assist?", "bot"))
        else:
            self.lbl_status.config(text=f"🚫 {label} ({confidence:.1%})", fg=COLOR_DANGER)
            self.append_chat("SYSTEM", f"Message blocked by protocol. Reason: {label}", "blocked")
            # Flash the screen red briefly (optional visual flare)
            self.flash_warning()

    def flash_warning(self):
        original_bg = self.chat_display.cget("bg")
        self.chat_display.config(bg="#3b1e1e") # Dark red tint
        self.root.after(200, lambda: self.chat_display.config(bg=original_bg))

if __name__ == "__main__":
    root = tk.Tk()
    app = BlackwallApp(root)
    root.mainloop()