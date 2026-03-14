<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Black Wall AI Chat</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Tailwind Configuration & Theme Script -->
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        gemini: {
                            dark: '#131314',
                            darkSidebar: '#1e1f20',
                            darkInput: '#2b2c2f',
                            light: '#ffffff',
                            lightSidebar: '#f0f4f9',
                            lightInput: '#f0f4f9'
                        }
                    }
                }
            }
        }

        // Prevent Flash of Unstyled Content (FOUC) for Dark Mode
        if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
        }
    </script>

    <!-- Custom Styles -->
    <style>
        /* Modern Scrollbar */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
        .dark ::-webkit-scrollbar-thumb { background: #475569; }
        
        /* Hide scrollbar for sidebar history but keep functionality */
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        /* Smooth fade-in animation */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .fade-in { animation: fadeIn 0.4s ease-out forwards; }
    </style>
</head>
<body class="h-screen w-screen overflow-hidden bg-gemini-light dark:bg-gemini-dark text-gray-800 dark:text-gray-200 transition-colors duration-300 flex">

    <!-- Mobile Sidebar Overlay -->
    <div id="sidebar-overlay" class="fixed inset-0 bg-black/50 z-20 hidden lg:hidden backdrop-blur-sm transition-opacity"></div>

    <!-- Sidebar -->
    <aside id="sidebar" class="fixed top-0 left-0 h-full w-72 bg-gemini-lightSidebar dark:bg-gemini-darkSidebar z-30 transform -translate-x-full lg:relative lg:translate-x-0 transition-transform duration-300 flex flex-col shadow-xl lg:shadow-none">
        
        <!-- New Chat Button -->
        <div class="p-4 mt-2">
            <button id="new-chat-btn" class="w-full flex items-center gap-3 px-5 py-3 bg-white dark:bg-[#131314] hover:bg-gray-50 dark:hover:bg-[#2b2c2f] rounded-full text-sm font-medium transition-colors border border-gray-200 dark:border-gray-700 shadow-sm">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-500">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                New Chat
            </button>
        </div>

        <!-- Chat History -->
        <div class="px-4 pb-2 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mt-4">
            Recent
        </div>
        <div class="flex-1 overflow-y-auto px-3 space-y-1 no-scrollbar" id="chat-history-list">
            <!-- Javascript injects buttons here -->
        </div>

        <!-- Bottom Tools (Theme Toggle) -->
        <div class="p-4 mt-auto border-t border-gray-200 dark:border-gray-800">
            <button id="theme-toggle-btn" class="w-full flex items-center justify-between px-4 py-3 hover:bg-gray-200 dark:hover:bg-[#2b2c2f] rounded-xl transition-colors text-sm font-medium">
                <span class="flex items-center gap-3 text-gray-700 dark:text-gray-300">
                    <svg id="theme-icon-dark" class="hidden w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                    <svg id="theme-icon-light" class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                    <span id="theme-text">Light Mode</span>
                </span>
            </button>
        </div>
    </aside>

    <!-- Main Chat Area -->
    <main class="flex-1 flex flex-col h-full relative min-w-0">
        
        <!-- Header -->
        <header class="flex items-center px-4 lg:px-6 py-4 h-16 shrink-0">
            <button id="hamburger-btn" class="p-2 mr-3 -ml-2 rounded-full hover:bg-gray-100 dark:hover:bg-[#2b2c2f] transition-colors lg:hidden text-gray-600 dark:text-gray-300">
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
            </button>
            <h1 class="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-purple-600 dark:from-blue-400 dark:to-purple-400 tracking-tight">
                Black Wall
            </h1>
        </header>

        <!-- Chat Content Container -->
        <div id="chat-container" class="flex-1 overflow-y-auto flex flex-col items-center px-4 pb-4 w-full scroll-smooth">
            
            <!-- Welcome Screen (Empty State) -->
            <div id="welcome-screen" class="flex-1 flex flex-col items-center justify-center w-full max-w-4xl text-center fade-in px-4">
                <h2 class="text-4xl md:text-6xl font-extrabold mb-8 tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 leading-tight">
                    Welcome to Black Wall<br/><span class="text-3xl md:text-5xl">Barrier for Safety</span>
                </h2>
                <a href="https://github.com/your-username/your-repo" target="_blank" class="inline-flex items-center gap-3 px-8 py-4 bg-gray-900 dark:bg-white text-white dark:text-gray-900 rounded-full font-semibold transition-all hover:scale-105 hover:shadow-xl hover:shadow-gray-900/20 dark:hover:shadow-white/20">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
                    View Documentation
                </a>
            </div>

            <!-- Messages Wrapper -->
            <div id="messages-container" class="w-full max-w-4xl flex flex-col space-y-8 hidden mt-4 pb-12">
                <!-- Javascript injects chat bubbles here -->
            </div>
            
        </div>

        <!-- Input Area (Fixed Bottom) -->
        <div class="px-4 pb-6 pt-2 w-full max-w-5xl mx-auto shrink-0 bg-gemini-light dark:bg-gemini-dark">
            <div class="relative flex items-end w-full bg-gemini-lightInput dark:bg-gemini-darkInput rounded-[2rem] p-2 pr-3 shadow-sm border border-gray-200 dark:border-gray-800 focus-within:ring-2 focus-within:ring-blue-500/50 transition-all duration-300">
                <textarea id="chat-input" rows="1" placeholder="Ask Black Wall anything..." class="flex-1 max-h-40 bg-transparent border-none focus:ring-0 resize-none px-5 py-3.5 outline-none text-gray-900 dark:text-gray-100 placeholder-gray-500 text-md"></textarea>
                <button id="send-btn" class="p-3 mb-1 ml-2 rounded-full text-blue-500 hover:bg-blue-100 dark:hover:bg-blue-900/40 disabled:opacity-50 transition-colors flex shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="22" y1="2" x2="11" y2="13"></line>
                        <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
                    </svg>
                </button>
            </div>
            <p class="text-[11px] text-center text-gray-500 mt-3 font-medium">
                Black Wall Barrier may occasionally reject unsafe inputs or make mistakes. Verify critical information.
            </p>
        </div>
    </main>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // DOM Elements
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebar-overlay');
            const hamburgerBtn = document.getElementById('hamburger-btn');
            const newChatBtn = document.getElementById('new-chat-btn');
            const chatHistoryList = document.getElementById('chat-history-list');
            
            const themeToggleBtn = document.getElementById('theme-toggle-btn');
            const themeText = document.getElementById('theme-text');
            const themeIconDark = document.getElementById('theme-icon-dark');
            const themeIconLight = document.getElementById('theme-icon-light');
            
            const welcomeScreen = document.getElementById('welcome-screen');
            const messagesContainer = document.getElementById('messages-container');
            const chatContainer = document.getElementById('chat-container');
            
            const chatInput = document.getElementById('chat-input');
            const sendBtn = document.getElementById('send-btn');
            
            // State
            let chats = JSON.parse(localStorage.getItem('blackwall_chats') || '[]');
            let currentChatId = null;

            // --- Initialization ---
            function updateThemeUI() {
                if (document.documentElement.classList.contains('dark')) {
                    themeText.innerText = 'Light Mode';
                    themeIconDark.classList.add('hidden');
                    themeIconLight.classList.remove('hidden');
                } else {
                    themeText.innerText = 'Dark Mode';
                    themeIconLight.classList.add('hidden');
                    themeIconDark.classList.remove('hidden');
                }
            }
            updateThemeUI();

            // --- Sidebar & Theme Logic ---
            function toggleSidebar() {
                sidebar.classList.toggle('-translate-x-full');
                overlay.classList.toggle('hidden');
            }
            hamburgerBtn.addEventListener('click', toggleSidebar);
            overlay.addEventListener('click', toggleSidebar);

            function toggleTheme() {
                if (document.documentElement.classList.contains('dark')) {
                    document.documentElement.classList.remove('dark');
                    localStorage.theme = 'light';
                } else {
                    document.documentElement.classList.add('dark');
                    localStorage.theme = 'dark';
                }
                updateThemeUI();
            }
            themeToggleBtn.addEventListener('click', toggleTheme);

            // --- Input Field Auto-Resize ---
            function autoResizeTextarea() {
                chatInput.style.height = 'auto';
                chatInput.style.height = Math.min(chatInput.scrollHeight, 160) + 'px';
                sendBtn.disabled = chatInput.value.trim().length === 0;
            }
            chatInput.addEventListener('input', autoResizeTextarea);
            sendBtn.disabled = true; // Initial state

            // --- Chat Session Management ---
            function renderSidebar() {
                chatHistoryList.innerHTML = '';
                chats.forEach(chat => {
                    const btn = document.createElement('button');
                    btn.className = `w-full text-left truncate px-3 py-2.5 rounded-lg text-[13px] font-medium transition-colors mb-1 ${
                        chat.id === currentChatId 
                        ? 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300' 
                        : 'text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-[#2b2c2f]'
                    }`;
                    btn.innerHTML = `<span class="flex items-center gap-2"><svg class="w-4 h-4 opacity-70" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" /></svg> ${chat.title || 'New Conversation'}</span>`;
                    btn.onclick = () => loadChat(chat.id);
                    chatHistoryList.appendChild(btn);
                });
            }

            function createNewChat() {
                currentChatId = null;
                welcomeScreen.classList.remove('hidden');
                messagesContainer.classList.add('hidden');
                messagesContainer.innerHTML = '';
                renderSidebar();
                chatInput.focus();
                if(window.innerWidth < 1024 && !sidebar.classList.contains('-translate-x-full')) toggleSidebar();
            }
            newChatBtn.addEventListener('click', createNewChat);

            function loadChat(id) {
                currentChatId = id;
                const chat = chats.find(c => c.id === id);
                
                welcomeScreen.classList.add('hidden');
                messagesContainer.classList.remove('hidden');
                messagesContainer.innerHTML = '';
                
                if (chat) {
                    chat.messages.forEach(msg => appendMessageUI(msg.role, msg.content, msg.status, false));
                }
                
                renderSidebar();
                scrollToBottom();
                if(window.innerWidth < 1024 && !sidebar.classList.contains('-translate-x-full')) toggleSidebar();
            }

            // --- Chat Rendering Logic ---
            function appendMessageUI(role, content, status = 'success', animate = true) {
                const wrapper = document.createElement('div');
                wrapper.className = `flex w-full ${role === 'user' ? 'justify-end' : 'justify-start'} ${animate ? 'fade-in' : ''}`;

                const bubble = document.createElement('div');
                
                if (role === 'user') {
                    // User Message Styling
                    bubble.className = 'bg-gray-100 dark:bg-[#2b2c2f] text-gray-900 dark:text-gray-100 rounded-[1.5rem] rounded-tr-sm px-6 py-3.5 max-w-[85%] sm:max-w-[75%] whitespace-pre-wrap leading-relaxed shadow-sm text-[15px]';
                    bubble.innerText = content;
                } else {
                    // AI Message Styling
                    if (status === 'rejected') {
                        bubble.className = 'bg-red-50 dark:bg-red-900/10 text-red-900 dark:text-red-200 border border-red-200 dark:border-red-900/50 rounded-[1.5rem] rounded-tl-sm px-6 py-4 max-w-[90%] sm:max-w-[80%] whitespace-pre-wrap leading-relaxed shadow-sm flex flex-col gap-3 text-[15px]';
                        bubble.innerHTML = `
                            <div class="flex items-center gap-2 font-bold text-red-600 dark:text-red-400">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path></svg>
                                Security Rejection: Black Wall
                            </div>
                            <div>${content}</div>
                        `;
                    } else {
                        // Normal AI response (No bubble background, transparent like Gemini)
                        bubble.className = 'text-gray-900 dark:text-gray-100 px-2 py-2 max-w-[95%] sm:max-w-[85%] whitespace-pre-wrap leading-relaxed flex flex-col gap-3 text-[15px]';
                        bubble.innerHTML = `
                            <div class="flex items-center gap-2 font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-500 to-purple-500 pb-1">
                                <svg class="w-5 h-5 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"/></svg>
                                Black Wall
                            </div>
                            <div class="prose dark:prose-invert max-w-none">${content}</div>
                        `;
                    }
                }
                
                wrapper.appendChild(bubble);
                messagesContainer.appendChild(wrapper);
                scrollToBottom();
            }

            function scrollToBottom() {
                setTimeout(() => {
                    chatContainer.scrollTo({
                        top: chatContainer.scrollHeight,
                        behavior: 'smooth'
                    });
                }, 50);
            }

            // --- Sending & API Logic ---
            async function sendMessage() {
                const text = chatInput.value.trim();
                if (!text) return;

                // Reset UI input
                chatInput.value = '';
                autoResizeTextarea();

                // Initialize Chat if New
                if (!currentChatId) {
                    currentChatId = Date.now().toString();
                    chats.unshift({
                        id: currentChatId,
                        title: text.length > 30 ? text.substring(0, 30) + '...' : text,
                        messages: []
                    });
                    welcomeScreen.classList.add('hidden');
                    messagesContainer.classList.remove('hidden');
                }

                const currentChat = chats.find(c => c.id === currentChatId);

                // Append User Message locally
                currentChat.messages.push({ role: 'user', content: text, status: 'success' });
                appendMessageUI('user', text, 'success');
                renderSidebar();
                saveChats();

                // Loading indicator
                const loadingId = 'loading-' + Date.now();
                const loadingWrapper = document.createElement('div');
                loadingWrapper.id = loadingId;
                loadingWrapper.className = `flex w-full justify-start fade-in`;
                loadingWrapper.innerHTML = `
                    <div class="text-gray-500 dark:text-gray-400 px-2 py-4 flex items-center gap-3 text-sm font-medium">
                        <svg class="animate-spin h-5 w-5 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                        Black Wall is analyzing...
                    </div>
                `;
                messagesContainer.appendChild(loadingWrapper);
                scrollToBottom();

                // Perform POST fetch
                try {
                    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
                    
                    const response = await fetch('/api/chat/send', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'X-CSRF-TOKEN': csrfToken
                        },
                        body: JSON.stringify({ message: text })
                    });

                    const data = await response.json();
                    
                    // Remove loading UI
                    document.getElementById(loadingId)?.remove();

                    // Evaluate API response
                    const isRejected = data.status === 'rejected';
                    const aiResponseContent = isRejected ? (data.reason || 'Message rejected by security policies.') : (data.response || 'No valid response returned.');
                    const msgStatus = isRejected ? 'rejected' : 'success';

                    // Append AI Message
                    currentChat.messages.push({ role: 'ai', content: aiResponseContent, status: msgStatus });
                    appendMessageUI('ai', aiResponseContent, msgStatus);
                    saveChats();

                } catch (error) {
                    document.getElementById(loadingId)?.remove();
                    
                    const errorMsgContent = 'Network error or server is unreachable.';
                    currentChat.messages.push({ role: 'ai', content: errorMsgContent, status: 'rejected' });
                    appendMessageUI('ai', errorMsgContent, 'rejected');
                    saveChats();
                    console.error("Black Wall Chat Error:", error);
                }
            }

            function saveChats() {
                localStorage.setItem('blackwall_chats', JSON.stringify(chats));
            }

            // --- Event Listeners ---
            sendBtn.addEventListener('click', sendMessage);
            
            chatInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    sendMessage();
                }
            });

            // Finalize load state
            renderSidebar();
        });
    </script>
</body>
</html>