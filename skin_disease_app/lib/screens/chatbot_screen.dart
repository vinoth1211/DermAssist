import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:skin_disease_app/widgets/custom_text_field.dart';
import 'package:skin_disease_app/widgets/custom_button.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m DermBot, your skin health assistant. How can I help you today?',
    );
    _addBotMessage(
      'You can ask me questions about skin conditions, skincare routines, or general skin health information.',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Add a slight delay to ensure the list has updated
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for the bot's response
    // In a real app, this would be replaced with an actual API call to Dialogflow or another chatbot service
    await Future.delayed(const Duration(seconds: 1));

    _processMessage(message);

    setState(() {
      _isLoading = false;
    });
  }

  void _processMessage(String message) {
    // This is a simple rule-based response for demonstration
    // In a real app, you would integrate with Dialogflow or a similar service
    
    final lowercaseMessage = message.toLowerCase();
    
    if (lowercaseMessage.contains('hello') || 
        lowercaseMessage.contains('hi') || 
        lowercaseMessage.contains('hey')) {
      _addBotMessage('Hello! How can I help you with your skin health today?');
    } else if (lowercaseMessage.contains('acne') || lowercaseMessage.contains('pimple')) {
      _addBotMessage(
        'Acne is a common skin condition that occurs when hair follicles become clogged with oil and dead skin cells. '
        'It can cause pimples, blackheads, and whiteheads. Here are some tips:\n\n'
        '• Wash your face twice daily with a gentle cleanser\n'
        '• Use non-comedogenic products\n'
        '• Don\'t pick or squeeze pimples\n'
        '• Consider over-the-counter products with benzoyl peroxide or salicylic acid\n\n'
        'Would you like to learn more about acne treatments?'
      );
    } else if (lowercaseMessage.contains('psoriasis')) {
      _addBotMessage(
        'Psoriasis is a chronic autoimmune condition that causes rapid skin cell growth, resulting in red, '
        'scaly patches that can be itchy and painful. Common treatments include:\n\n'
        '• Topical corticosteroids\n'
        '• Vitamin D analogues\n'
        '• Light therapy\n'
        '• Oral medications for severe cases\n\n'
        'It\'s important to see a dermatologist for proper diagnosis and treatment plan.'
      );
    } else if (lowercaseMessage.contains('eczema') || lowercaseMessage.contains('dermatitis')) {
      _addBotMessage(
        'Eczema (atopic dermatitis) is a condition that makes your skin red and itchy. It\'s common in children but can occur at any age. '
        'To manage eczema:\n\n'
        '• Moisturize your skin at least twice a day\n'
        '• Identify and avoid triggers\n'
        '• Take lukewarm (not hot) baths or showers\n'
        '• Use gentle, fragrance-free soaps\n'
        '• Apply prescribed medications as directed\n\n'
        'Would you like to know more about specific eczema treatments?'
      );
    } else if (lowercaseMessage.contains('rash') || lowercaseMessage.contains('itchy')) {
      _addBotMessage(
        'Skin rashes can have many causes, including allergic reactions, infections, heat, or underlying medical conditions. '
        'For temporary relief:\n\n'
        '• Apply a cold compress\n'
        '• Use over-the-counter hydrocortisone cream\n'
        '• Take an antihistamine for itching\n'
        '• Avoid scratching\n\n'
        'If the rash is severe, spreads quickly, or is accompanied by other symptoms, please consult a healthcare provider.'
      );
    } else if (lowercaseMessage.contains('routine') || lowercaseMessage.contains('skincare')) {
      _addBotMessage(
        'A basic skincare routine should include:\n\n'
        '1. Cleansing: Wash your face morning and night\n'
        '2. Toning: Optional step to balance pH\n'
        '3. Treatments: Apply serums for specific concerns\n'
        '4. Moisturizing: Hydrate the skin\n'
        '5. Sun protection: Use SPF 30+ during the day\n\n'
        'Would you like personalized recommendations for your skin type?'
      );
    } else if (lowercaseMessage.contains('spf') || lowercaseMessage.contains('sunscreen')) {
      _addBotMessage(
        'Sunscreen is crucial for skin health! Here are some tips:\n\n'
        '• Use SPF 30 or higher daily, even on cloudy days\n'
        '• Apply 15-30 minutes before sun exposure\n'
        '• Reapply every 2 hours, or after swimming/sweating\n'
        '• Don\'t forget often-missed areas like ears, neck, and tops of feet\n'
        '• Choose broad-spectrum protection against both UVA and UVB rays\n\n'
        'Regular sunscreen use helps prevent skin cancer, premature aging, and hyperpigmentation.'
      );
    } else if (lowercaseMessage.contains('thank')) {
      _addBotMessage('You\'re welcome! Is there anything else I can help you with?');
    } else if (lowercaseMessage.contains('doctor') || lowercaseMessage.contains('dermatologist')) {
      _addBotMessage(
        'If you\'re looking to consult a dermatologist, you can book an appointment through our app! '
        'Go to the "Doctors" section to view available dermatologists and schedule a virtual or in-person consultation.'
      );
    } else {
      _addBotMessage(
        'I\'m not sure I understand your question. Could you rephrase or ask about specific skin conditions, '
        'skincare routines, or treatments? I\'m here to help with your skin health questions!'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DermBot Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show information dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About DermBot'),
                  content: const Text(
                    'DermBot provides general information about skin conditions and skincare. '
                    'It is not a substitute for professional medical advice, diagnosis, or treatment. '
                    'Always seek the advice of a qualified health provider with any questions you may have.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Understood'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Bot is typing indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('DermBot is typing'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    labelText: 'Message',
                    hintText: 'Type your question here...',
                    maxLines: 3,
                    minLines: 1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                CustomButton(
                  onPressed: _handleSubmit,
                  icon: Icons.send,
                  text: 'Send',
                  isLoading: _isLoading,
                  width: 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 16,
              child: const Text(
                'DB',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Bubble(
              margin: const BubbleEdges.only(top: 6),
              nip: message.isUser ? BubbleNip.rightBottom : BubbleNip.leftBottom,
              color: message.isUser
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              alignment: message.isUser ? Alignment.topRight : Alignment.topLeft,
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : null,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
