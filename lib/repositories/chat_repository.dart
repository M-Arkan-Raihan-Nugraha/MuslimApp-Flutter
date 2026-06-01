import 'package:muslim_app/services/gemini_services.dart';

class ChatRepository {
  final GeminiService _service;

  ChatRepository(this._service);

  Future<String> sendMessage(String message) async {
    return await _service.getResponse(message);
  }
}