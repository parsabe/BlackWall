// --- Tailwind Configuration ---


// Prevent Flash of Unstyled Content (FOUC) for Dark Mode
if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.documentElement.classList.add('dark');
}

// --- App Logic ---
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
    window.currentChatId = null;

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
        window.currentChatId = null;
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
        window.currentChatId = id;
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
                // Normal AI response with Markdown & Code highlighting
                let formattedContent = content;
                if (typeof marked !== 'undefined') {
                    try {
                        formattedContent = marked.parse(content);
                    } catch (e) {
                        console.error('Markdown parse error:', e);
                    }
                }

                bubble.className = 'text-gray-900 dark:text-gray-100 px-2 py-2 max-w-[95%] sm:max-w-[85%] leading-relaxed flex flex-col gap-3 text-[15px]';
                bubble.innerHTML = `
                    <div class="flex items-center gap-2 font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-500 to-purple-500 pb-1">
                        <svg class="w-5 h-5 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"/></svg>
                        Black Wall
                    </div>
                    <div class="markdown-body dark:prose-invert max-w-none">${formattedContent}</div>
                `;

                setTimeout(() => {
                    bubble.querySelectorAll('pre code').forEach((block) => {
                        if (typeof hljs !== 'undefined') {
                            hljs.highlightElement(block);
                        }
                    });
                }, 10);
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
            window.currentChatId = currentChatId;
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
