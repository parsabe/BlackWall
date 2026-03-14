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

                    // Update local storage directly since the UI depends on it
                    let localChats = JSON.parse(localStorage.getItem('blackwall_chats') || '[]');
                    let chatIndex = localChats.findIndex(c => String(c.id) === String(chatId));
                    if (chatIndex !== -1) {
                        localChats[chatIndex].title = newTitle.trim();
                        localStorage.setItem('blackwall_chats', JSON.stringify(localChats));
                    }

                    try {
                        await fetch(`/chat/${chatId}/rename`, {
                            method: 'PUT',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                            },
                            body: JSON.stringify({ title: newTitle.trim() })
                        });
                    } catch (e) {
                        console.warn('Backend sync failed or table not found, but local storage updated.');
                    }
                    window.location.reload();
                });
            }

            if (deleteBtn) {
                deleteBtn.addEventListener('click', async () => {
                    const chatId = getChatId();
                    if (!chatId) return alert('No active chat selected.');
                    if (!confirm('Are you sure you want to delete this chat?')) return;

                    // Remove from local storage directly
                    let localChats = JSON.parse(localStorage.getItem('blackwall_chats') || '[]');
                    localChats = localChats.filter(c => String(c.id) !== String(chatId));
                    localStorage.setItem('blackwall_chats', JSON.stringify(localChats));

                    try {
                        await fetch(`/chat/${chatId}`, {
                            method: 'DELETE',
                            headers: { 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') }
                        });
                    } catch (e) { 
                        console.warn('Backend sync failed or table not found, but local storage updated.');
                    }
                    window.location.href = '/';
                });
            }
        });