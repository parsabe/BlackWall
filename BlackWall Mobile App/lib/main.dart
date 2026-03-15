import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Main entry point of the application
void main() {
  runApp(const BlackwallApp());
}

// Enum to represent the type of message for styling purposes
enum MessageType { user, ai, rejected, error }

// A model class to hold the data for a single chat message
class ChatMessage {
  final String text;
  final MessageType type;

  ChatMessage({required this.text, required this.type});
}

// The root widget of the application
class BlackwallApp extends StatefulWidget {
  const BlackwallApp({super.key});

  @override
  State<BlackwallApp> createState() => _BlackwallAppState();
}

class _BlackwallAppState extends State<BlackwallApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey[900],
      scaffoldBackgroundColor: const Color(0xFF121212), // Deep charcoal
      cardColor: Colors.grey[850], // User message bubble
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[850],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[100],
      cardColor: Colors.blueGrey[50], // User message bubble
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );

    return MaterialApp(
      title: 'Blackwall',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: ChatScreen(toggleTheme: _toggleTheme),
    );
  }
}

// The main chat screen widget
class ChatScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const ChatScreen({super.key, required this.toggleTheme});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  // Handles sending the message to the backend
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Add user message to UI
    setState(() {
      _messages.add(ChatMessage(text: text, type: MessageType.user));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    // API details
    const apiUrl = 'https://blackwall.parsabe.com/api/chat/send';
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer Blackwall-App-Token-2026-Parsa',
    };
    final body = json.encode({'message': text});

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

     if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final status = responseData['status'];

        if (status == 'success') {
          final aiResponse = responseData['response'];
          _addMessage(ChatMessage(text: aiResponse, type: MessageType.ai));
        } else if (status == 'rejected') {
          // This catches if the server sends 200 but the JSON says rejected
          final reason = responseData['reason'];
          _addMessage(ChatMessage(text: reason, type: MessageType.rejected));
        }
      } 
      // MOVED OUTSIDE: This catches the actual 403 Forbidden error from Blackwall
      else if (response.statusCode == 403) { 
        final responseData = json.decode(response.body);
        final reason = responseData['reason'] ?? "Security Rejection";
        _addMessage(ChatMessage(text: reason, type: MessageType.rejected));
      } 
      else {
        // This catches 500 errors, 404s, etc.
        _addMessage(
          ChatMessage(
            text: 'Error: ${response.statusCode}\n${response.body}',
            type: MessageType.error,
          ),
        );
      }


    } catch (e) {
      // Handle network errors
      _addMessage(
        ChatMessage(
          text:
              'Network Error: Could not reach the server. Please check your connection.',
          type: MessageType.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // Helper to add a message and update the UI
  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  // Auto-scrolls the list to the latest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blackwall'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _clearChat,
            tooltip: 'New Chat',
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const _WelcomeView()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(),
            ),
          _buildTextInputArea(),
        ],
      ),
    );
  }

  // Builds the appropriate bubble based on message type
  Widget _buildMessageBubble(ChatMessage message) {
    switch (message.type) {
      case MessageType.user:
        return _UserMessageBubble(message: message);
      case MessageType.ai:
        return _AiMessageBubble(message: message);
      case MessageType.rejected:
        return _RejectedMessageBubble(message: message);
      case MessageType.error:
        return _RejectedMessageBubble(message: message, isError: true);
    }
  }

  // The text input field and send button at the bottom
  Widget _buildTextInputArea() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _sendMessage(),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Message Blackwall...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(25),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: _isLoading ? null : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.send,
                    color: _isLoading ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The initial view when the chat is empty
class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: const Text( // Restoring original welcome text for consistency
              'Welcome to Blackwall',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white, // This color is necessary for ShaderMask
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Secure AI Entry Point.',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying user's messages
class _UserMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(message.text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

// Widget for displaying AI's messages


// Widget for displaying rejected or error messages
// --- UPGRADED REJECTION BUBBLE ---
class _RejectedMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isError;
  const _RejectedMessageBubble({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    // Cyberpunk Red for Security, Orange for Network Errors
    final mainColor = isError ? Colors.orangeAccent : const Color(0xFFFF0033);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.05),
        border: Border.all(color: mainColor, width: 1.5),
        borderRadius: BorderRadius.circular(8), // Sharper corners for a "system" feel
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isError ? Icons.bolt : Icons.security_rounded, color: mainColor, size: 22),
              const SizedBox(width: 8),
              Text(
                isError ? "SYSTEM ERROR" : "BLACKWALL PROTOCOL: REJECTED",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Text(
            message.text.toUpperCase(),
            style: TextStyle(
              color: mainColor,
              fontSize: 14,
              fontFamily: 'Courier', // Gives it that "Terminal" look
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- UPGRADED AI BUBBLE (The "Shield" look) ---
class _AiMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _AiMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.blueAccent, blurRadius: 4)],
            ),
            child: const Icon(Icons.shield_outlined, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 16, 
                  height: 1.5, // Better readability
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}