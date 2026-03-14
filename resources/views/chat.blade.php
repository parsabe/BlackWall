<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Black Wall AI Chat</title>

    <script src="https://cdn.tailwindcss.com"></script>

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
        };
    </script>

    <link rel="stylesheet" href="{{ asset('assets/css/chat.css') }}">
</head>

<body
    class="h-screen w-screen overflow-hidden bg-gemini-light dark:bg-gemini-dark text-gray-800 dark:text-gray-200 transition-colors duration-300 flex">

    <!-- Mobile Sidebar Overlay -->
    <div id="sidebar-overlay"
        class="fixed inset-0 bg-black/50 z-20 hidden lg:hidden backdrop-blur-sm transition-opacity"></div>

    <!-- Sidebar -->
    <aside id="sidebar"
        class="fixed top-0 left-0 h-full w-72 bg-gemini-lightSidebar dark:bg-gemini-darkSidebar z-30 transform -translate-x-full lg:relative lg:translate-x-0 transition-transform duration-300 flex flex-col shadow-xl lg:shadow-none">

        <!-- New Chat Button -->
        <div class="p-4 mt-2">
            <button id="new-chat-btn"
                class="w-full flex items-center gap-3 px-5 py-3 bg-white dark:bg-[#131314] hover:bg-gray-50 dark:hover:bg-[#2b2c2f] rounded-full text-sm font-medium transition-colors border border-gray-200 dark:border-gray-700 shadow-sm">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                    class="text-blue-500">
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
            <button id="theme-toggle-btn"
                class="w-full flex items-center justify-between px-4 py-3 hover:bg-gray-200 dark:hover:bg-[#2b2c2f] rounded-xl transition-colors text-sm font-medium">
                <span class="flex items-center gap-3 text-gray-700 dark:text-gray-300">
                    <svg id="theme-icon-dark" class="hidden w-5 h-5" xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                    </svg>
                    <svg id="theme-icon-light" class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <circle cx="12" cy="12" r="5"></circle>
                        <line x1="12" y1="1" x2="12" y2="3"></line>
                        <line x1="12" y1="21" x2="12" y2="23"></line>
                        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                        <line x1="1" y1="12" x2="3" y2="12"></line>
                        <line x1="21" y1="12" x2="23" y2="12"></line>
                        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                    </svg>
                    <span id="theme-text">Light Mode</span>
                </span>
            </button>
        </div>
    </aside>

    <!-- Main Chat Area -->
    <main class="flex-1 flex flex-col h-full relative min-w-0">

        <!-- Header -->
        <header class="flex items-center justify-between px-4 lg:px-6 py-4 h-16 shrink-0">
            <div class="flex items-center">
                <button id="hamburger-btn"
                    class="p-2 mr-3 -ml-2 rounded-full hover:bg-gray-100 dark:hover:bg-[#2b2c2f] transition-colors lg:hidden text-gray-600 dark:text-gray-300">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="3" y1="12" x2="21" y2="12"></line>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <line x1="3" y1="18" x2="21" y2="18"></line>
                    </svg>
                </button>
                <h1
                    class="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-purple-600 dark:from-blue-400 dark:to-purple-400 tracking-tight">
                    Black Wall
                </h1>
            </div>

            <!-- Chat Actions -->
            <div id="chat-actions-container" class="flex items-center gap-1 sm:gap-2 hidden">
                <button id="edit-chat-btn"
                    class="p-2 rounded-full text-gray-500 hover:bg-gray-100 dark:hover:bg-[#2b2c2f] hover:text-blue-500 transition-colors"
                    title="Edit Chat">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                    </svg>
                </button>
                <button id="delete-chat-btn"
                    class="p-2 rounded-full text-gray-500 hover:bg-gray-100 dark:hover:bg-[#2b2c2f] hover:text-red-500 transition-colors"
                    title="Delete Chat">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        <line x1="10" y1="11" x2="10" y2="17"></line>
                        <line x1="14" y1="11" x2="14" y2="17"></line>
                    </svg>
                </button>
            </div>
        </header>

        <!-- Privacy Alert Banner -->
        <div id="privacy-alert"
            class="mx-4 mt-2 px-4 py-3 bg-gradient-to-r from-orange-50 to-amber-50 dark:from-orange-950/30 dark:to-amber-950/30 border border-orange-200 dark:border-orange-800 rounded-xl shadow-sm flex items-start sm:items-center justify-between transition-all duration-300">
            <div class="flex items-center gap-3">
                <div
                    class="p-2 bg-orange-100 dark:bg-orange-900/50 rounded-lg text-orange-600 dark:text-orange-400 shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"></circle>
                        <polyline points="12 6 12 12 16 14"></polyline>
                    </svg>
                </div>
                <div class="text-sm text-gray-700 dark:text-gray-300">
                    <strong class="font-semibold text-orange-700 dark:text-orange-400">Privacy Notice:</strong> For your
                    security, chats are automatically deleted after 30 minutes. You can also manually edit or delete the
                    chat using the options above.
                </div>
            </div>
            <button onclick="document.getElementById('privacy-alert').style.display='none'"
                class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors p-1 shrink-0 ml-3">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="18" y1="6" x2="6" y2="18"></line>
                    <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
            </button>
        </div>

        <!-- Chat Content Container -->
        <div id="chat-container"
            class="flex-1 overflow-y-auto flex flex-col items-center px-4 pb-4 w-full scroll-smooth">

            <!-- Welcome Screen (Empty State) -->
            <div id="welcome-screen"
                class="flex-1 flex flex-col items-center justify-center w-full max-w-4xl text-center fade-in px-4">
                <h2
                    class="text-4xl md:text-6xl font-extrabold mb-8 tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 leading-tight">
                    Welcome to Google Gemini<br /><span class="text-3xl md:text-5xl">Secured via BlackWall</span>
                </h2>
                <a href="https://github.com/parsabe/BlackWall" target="_blank"
                    class="inline-flex items-center gap-3 px-8 py-4 bg-gray-900 dark:bg-white text-white dark:text-gray-900 rounded-full font-semibold transition-all hover:scale-105 hover:shadow-xl hover:shadow-gray-900/20 dark:hover:shadow-white/20">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                        fill="currentColor">
                        <path
                            d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
                    </svg>
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
            <div
                class="relative flex items-end w-full bg-gemini-lightInput dark:bg-gemini-darkInput rounded-[2rem] p-2 pr-3 shadow-sm border border-gray-200 dark:border-gray-800 focus-within:ring-2 focus-within:ring-blue-500/50 transition-all duration-300">
                <textarea id="chat-input" rows="1" placeholder="Ask Black Wall anything..."
                    class="flex-1 max-h-40 bg-transparent border-none focus:ring-0 resize-none px-5 py-3.5 outline-none text-gray-900 dark:text-gray-100 placeholder-gray-500 text-md"></textarea>
                <button id="send-btn"
                    class="p-3 mb-1 ml-2 rounded-full text-blue-500 hover:bg-blue-100 dark:hover:bg-blue-900/40 disabled:opacity-50 transition-colors flex shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
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
    <script src="{{ asset('assets/js/chat.js') }}?v={{ time() }}"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const editBtn = document.getElementById('edit-chat-btn');
            const deleteBtn = document.getElementById('delete-chat-btn');
            const actionContainer = document.getElementById('chat-actions-container');
            const welcomeScreen = document.getElementById('welcome-screen');

            // Try to get active chat ID (either globally set from chat.js or read from the URL)
            function getChatId() {
                if (typeof window.currentChatId !== 'undefined' && window.currentChatId) {
                    return window.currentChatId;
                }
                const match = window.location.pathname.match(/\/chat\/(\d+)/);
                return match ? match[1] : null;
            }

            // Only display action buttons when inside the actual chat area (welcome screen is hidden)
            if (welcomeScreen && actionContainer) {
                const observer = new MutationObserver(() => {
                    if (welcomeScreen.classList.contains('hidden') || welcomeScreen.style.display === 'none') {
                        actionContainer.classList.remove('hidden');
                    } else {
                        actionContainer.classList.add('hidden');
                    }
                });
                observer.observe(welcomeScreen, { attributes: true, attributeFilter: ['class', 'style'] });
                
                // Make sure buttons display correctly on initial load if directly entering a chat
                if (welcomeScreen.classList.contains('hidden') || welcomeScreen.style.display === 'none' || getChatId()) {
                    actionContainer.classList.remove('hidden');
                }
            }

            if (editBtn) {
                editBtn.addEventListener('click', async () => {
                    const chatId = getChatId();
                    if (!chatId) return alert('No active chat selected.');
                    
                    const newTitle = prompt('Enter new chat name:');
                    if (!newTitle || newTitle.trim() === '') return;

                    try {
                        const response = await fetch(`/chat/${chatId}/rename`, {
                            method: 'PUT',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                            },
                            body: JSON.stringify({ title: newTitle.trim() })
                        });
                        const data = await response.json();
                        if (data.success) window.location.reload();
                        else alert('Failed to rename chat.');
                    } catch (e) { alert('Error renaming chat.'); }
                });
            }

            if (deleteBtn) {
                deleteBtn.addEventListener('click', async () => {
                    const chatId = getChatId();
                    if (!chatId) return alert('No active chat selected.');
                    if (!confirm('Are you sure you want to delete this chat?')) return;

                    try {
                        const response = await fetch(`/chat/${chatId}`, {
                            method: 'DELETE',
                            headers: { 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') }
                        });
                        const data = await response.json();
                        if (data.success) window.location.href = '/chat';
                        else alert('Failed to delete chat.');
                    } catch (e) { alert('Error deleting chat.'); }
                });
            }
        });
    </script>
</body>

</html>