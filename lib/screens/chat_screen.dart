
import 'package:flutter/material.dart';
import 'package:makla_app/utils/app_theme.dart';

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
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Hello! How can I help you with your nutrition today?', isUser: false),
    ChatMessage(text: 'Hi! I want to know if a pizza is a good option for dinner.', isUser: true),
    ChatMessage(text: 'While delicious, a typical pizza is high in calories and sodium. A healthier alternative could be a whole-wheat crust pizza with lots of veggies!', isUser: false),
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(text: _controller.text, isUser: true));
        _controller.clear();
        // Here you would typically send the message to the AI and get a response
        // For now, we'll just add a dummy response
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _messages.add(ChatMessage(text: 'That\'s an interesting question! Let me check...', isUser: false));
          });
        });
      });
    }
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
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
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
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.secondary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
