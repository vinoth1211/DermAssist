import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'shared_widgets.dart';
import '../config/api_config.dart';
import '../utils/theme.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  bool _quotaExceeded = false; // Track quota status

  // Replace with your actual Gemini API Key
  static const String apiKey = ApiConfig.geminiApiKey;
  late GenerativeModel _textModel;
  late GenerativeModel _visionModel;

  @override
  void initState() {
    super.initState();
    _initializeModels();
  }

  void _initializeModels() {
    _textModel = GenerativeModel(
      model: 'models/gemini-2.0-flash',
      apiKey: apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'models/gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomHeader(),
      body: SafeArea(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              const CustomNavigationBar(activeRoute: 'Chat Bot'),
              if (_quotaExceeded) _buildQuotaWarning(theme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index], theme);
                          },
                        ),
                      ),
                      if (!_quotaExceeded) _buildQuickActions(theme),
                      _buildInputArea(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaWarning(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.warningColor.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppTheme.warningColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Service temporarily unavailable due to API quota limits. Please contact support.",
              style: const TextStyle(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, ThemeData theme) {
    final isUser = message.isUser;
    final bubbleColor =
        isUser ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardColor;
    final textColor =
        isUser
            ? theme.colorScheme.primary
            : theme.textTheme.bodyLarge?.color ?? Colors.black;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    message.image!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              if (message.image != null) const SizedBox(height: 8),
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final quickQuestions = [
      'Dry and flaky skin remedies?',
      'Acne on cheeks treatment?',
      'How to fade dark spots?',
      'Sensitive skin routine?',
    ];

    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            onPressed: () => _sendMessage(quickQuestions[index]),
            child: Text(
              quickQuestions[index],
              style: TextStyle(color: theme.colorScheme.primary, fontSize: 13),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon:
                _selectedImage != null
                    ? Badge(
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.image,
                        color: theme.colorScheme.primary,
                      ),
                    )
                    : Icon(Icons.image_outlined, color: theme.disabledColor),
            onPressed: _quotaExceeded ? null : _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 3,
              enabled: !_quotaExceeded,
              decoration: InputDecoration(
                hintText:
                    _quotaExceeded
                        ? 'Service unavailable'
                        : 'Ask about skin concerns...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(Icons.send, color: theme.colorScheme.primary),
            onPressed:
                _quotaExceeded || _isLoading
                    ? null
                    : () {
                      if (_messageController.text.isNotEmpty ||
                          _selectedImage != null) {
                        _sendMessage(_messageController.text);
                      }
                    },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty && _selectedImage == null) return;

    final messageText = text.trim();
    final imageToSend = _selectedImage;

    setState(() {
      _messages.add(
        Message(
          text:
              messageText.isEmpty && imageToSend != null
                  ? "Analyze this skin condition"
                  : messageText,
          isUser: true,
          image: imageToSend,
        ),
      );
      _messageController.clear();
      _isLoading = true;
      _selectedImage = null;
    });
    _scrollToBottom();

    try {
      final response = await _getGeminiResponse(messageText, imageToSend);
      if (response != null) {
        setState(() {
          _messages.add(Message(text: response, isUser: false));
          _quotaExceeded = false; // Reset quota flag on success
        });
      } else {
        throw Exception('No response received from the AI model');
      }
    } catch (e) {
      final errorMessage = _handleApiError(e);
      setState(() {
        _messages.add(Message(text: errorMessage, isUser: false));
        // Check if the error is quota related and set the flag based on message content
        if (e.toString().contains("quota") ||
            e.toString().contains("billing") ||
            e.toString().contains("exceeded")) {
          _quotaExceeded = true;
        }
      });
      print('Chatbot Error: ${e.toString()}'); // Keep logging the raw error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  String _handleApiError(dynamic error) {
    // Check error message string for keywords instead of relying on a specific exception type
    if (error.toString().contains("quota") ||
        error.toString().contains("billing") ||
        error.toString().contains("exceeded")) {
      return "I'm currently unavailable due to API quota limits. "
          "Please contact support to resolve this issue.";
    } else if (error.toString().contains('API key')) {
      return "Authentication error. Please check API configuration.";
    } else if (error.toString().contains('network')) {
      return "Network error. Please check your internet connection.";
    } else if (error.toString().contains('timeout')) {
      return "Request timed out. Please try again.";
    }
    return "Sorry, something went wrong. Please try again later.";
  }

  Future<String?> _getGeminiResponse(String text, File? image) async {
    const systemPrompt = """
      You are a professional dermatology assistant. When responding to skin concerns:
      1. First, analyze the condition briefly
      2. Then, provide 2-3 recommended treatments
      3. List key ingredients to look for in products
      4. Finally, mention when to see a dermatologist
      
      Keep responses clear, concise, and structured with bullet points.
      If the query is not related to skincare, politely redirect to skincare topics.
    """;

    try {
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        final prompt = """
          $systemPrompt
          
          Analyze this skin condition image. User query: 
          ${text.isEmpty ? "Please analyze this skin condition" : text}
          
          Format your response as follows:
          📝 Analysis: [Brief analysis]
          💊 Treatments: [List treatments]
          🧪 Key Ingredients: [List ingredients]
          ⚕️ When to See a Doctor: [Guidance]
        """;

        final response = await _visionModel.generateContent([
          Content.text(prompt),
          Content.data('image/jpeg', imageBytes),
        ]);

        final textResponse = response.text;
        if (textResponse == null || textResponse.isEmpty) {
          throw Exception('No response received from the AI model');
        }
        return textResponse;
      } else {
        if (text.isEmpty) return null;

        final prompt = """
          $systemPrompt
          
          User Query: $text
          
          Format your response as follows:
          📝 Analysis: [Brief analysis]
          💊 Treatments: [List treatments]
          🧪 Key Ingredients: [List ingredients]
          ⚕️ When to See a Doctor: [Guidance]
        """;

        final response = await _textModel.generateContent([
          Content.text(prompt),
        ]);
        final textResponse = response.text;
        if (textResponse == null || textResponse.isEmpty) {
          throw Exception('No response received from the AI model');
        }
        return textResponse;
      }
    } catch (e) {
      rethrow; // Rethrow to handle in calling function
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
}

class Message {
  final String text;
  final bool isUser;
  final File? image;

  Message({required this.text, required this.isUser, this.image});
}
