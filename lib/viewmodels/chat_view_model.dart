import 'package:flutter/material.dart';
import 'package:muslim_app/models/chat_message_model.dart';
import 'package:muslim_app/services/gemini_services.dart';

class ChatViewModel extends ChangeNotifier {
  final GeminiService _geminiService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatViewModel(this._geminiService);

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Prevent sending while already loading
    if (_isLoading) return;

    _error = null;
    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _geminiService.getResponse(text);
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      _error = e.toString();
      _messages.add(ChatMessage(
        text: 'Maaf, terjadi kesalahan. Silakan coba lagi.',
        isUser: false,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}