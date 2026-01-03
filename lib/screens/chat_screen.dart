import 'package:flutter/material.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:makla_app/providers/ai_chat_service.dart';

// Simple message model
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final OpenAIService _aiService = OpenAIService();
  final ScrollController _scrollController = ScrollController(); // ✅ Added for auto-scroll
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Hello! How can I help you with your nutrition today?', isUser: false),
  ];
  final List<Map<String, String>> _conversationHistory = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return; // ✅ Check for empty/whitespace
    
    final userMessage = _controller.text.trim();
    _controller.clear();
    
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    // Auto-scroll to bottom
    _scrollToBottom();

    // Add user message to conversation history
    _conversationHistory.add({
      'role': 'user',
      'content': userMessage
    });

    try {
      print('📤 Sending message: $userMessage'); // Debug log
      
      // Get AI response from OpenAI-compatible API
      final aiResponse = await _aiService.sendMessage(
        userMessage, 
        conversationHistory: _conversationHistory
      );
      
      print('📥 Received response: $aiResponse'); // Debug log
      
      // Add AI response to conversation history
      _conversationHistory.add({
        'role': 'assistant',
        'content': aiResponse
      });

      setState(() {
        _messages.add(ChatMessage(text: aiResponse, isUser: false));
        _isLoading = false;
      });

      // Auto-scroll to bottom
      _scrollToBottom();
      
    } catch (e) {
      print('❌ Error in _sendMessage: $e'); // Debug log
      
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.', 
          isUser: false
        ));
        _isLoading = false;
      });
      
      _scrollToBottom();
    }
  }

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

  Widget _buildQuickActions() {
    if (_isLoading) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionButton('🍎 Analyze Food', () {
              _sendQuickMessage('What are the nutritional benefits of this food item?');
            }),
            const SizedBox(width: 8),
            _buildQuickActionButton('🥗 Meal Ideas', () {
              _sendQuickMessage('Can you suggest some healthy meal ideas for today?');
            }),
            const SizedBox(width: 8),
            _buildQuickActionButton('💪 Protein Foods', () {
              _sendQuickMessage('What are some good sources of protein?');
            }),
            const SizedBox(width: 8),
            _buildQuickActionButton('🌱 Vitamins', () {
              _sendQuickMessage('Tell me about important vitamins and their sources');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        foregroundColor: AppColors.secondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _sendQuickMessage(String message) {
    _controller.text = message;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriDoc'),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ✅ Added scroll controller
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingMessage();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final align = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUser ? AppColors.secondary : AppColors.white;
    final textColor = message.isUser ? AppColors.white : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75, // ✅ Max width for bubbles
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              message.text,
              style: AppTextStyles.body.copyWith(color: textColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message...',
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(), // ✅ Send on enter
              ),
            ),
            IconButton(
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: AppColors.secondary),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'NutriDoc is thinking...',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}