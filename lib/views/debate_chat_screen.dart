import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../utils/chatbot_service.dart';
import '../utils/custom_chat_theme.dart';

class DebateChatScreen extends StatefulWidget {
  final String topic;
  final String prompt;
  final String initialMessage;

  const DebateChatScreen({super.key, required this.topic, required this.prompt, required this.initialMessage});

  @override
  _DebateChatScreenState createState() => _DebateChatScreenState();
}

class _DebateChatScreenState extends State<DebateChatScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot');
  bool _isSending = false;
  int _userMessageCount = 0;
  int _userFallacyCount = 0;
  int _userCorrectFallacyCount = 0;

  @override
  void initState() {
    super.initState();
    _addBotMessage(widget.initialMessage);
  }

  void _addBotMessage(String text) {
    final message = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    if (_isSending) return;
    if (message.text.split(' ').length > 50) {
      _addBotMessage('Your message is too long. Please keep it under 50 words.');
      return;
    }

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _isSending = true;
      _userMessageCount++;
    });

    if (_userMessageCount > 15) {
      _addBotMessage('You Lost. Try to address the point faster next time.');
      return;
    }

    try {
      final conversationLog = _messages.reversed.map((msg) {
        final role = msg.author.id == 'user' ? 'user' : 'assistant';
        return {'role': role, 'content': (msg as types.TextMessage).text};
      }).toList();

      final response = await ChatbotService.sendMessage(
        topic: widget.topic,
        initialMessage: widget.initialMessage,
        conversationLog: conversationLog,
      );

      final botMessage = response['botMessage'];
      final userFallacy = response['userFallacy'];
      final userFallacyCorrect = response['userFallacyCorrect'];
      final goodPoint = response['goodPoint'];

      _addBotMessage(botMessage);

      if (userFallacy != null) {
        _userFallacyCount++;
        _showFallacyAlert(userFallacy);
        if (_userFallacyCount >= 3) {
          _addBotMessage('You Lost. You used too many logical fallacies.');
        }
      }

      if (goodPoint) {
        _userCorrectFallacyCount++;
        _showGoodPointAlert();
        if (_userCorrectFallacyCount >= 3) {
          _addBotMessage('You Win. You successfully countered and debated against your oponent\'s points');
        }
      }

      if (userFallacyCorrect == true) {
        _userCorrectFallacyCount++;
        _showCorrectFallacyAlert();
        if (_userCorrectFallacyCount >= 3) {
          _addBotMessage('You Win. You successfully identified the opponent\'s logical fallacies.');
        }
      }
    } catch (e) {
      _addBotMessage('Sorry, something went wrong. Please try again.');
    }

    setState(() {
      _isSending = false;
    });
  }

  void _showFallacyAlert(String fallacy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You used: $fallacy!'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCorrectFallacyAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You detected a fallacy!'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGoodPointAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You made a good point!'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} Debate'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: DefaultChatTheme(
                inputBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundColor: Theme.of(context).colorScheme.surface,
                highlightMessageColor: Theme.of(context).colorScheme.primary,
                inputTextColor: Theme.of(context).textTheme.bodyLarge!.color!,
                inputTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!),
                sendButtonIcon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                messageBorderRadius: 16,
                messageInsetsVertical: 8,
                messageInsetsHorizontal: 16,
                inputBorderRadius: BorderRadius.circular(10),
                inputPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                inputTextDecoration: const InputDecoration(
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          if (_isSending) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
