import 'package:flutter/material.dart';
import 'package:mensajeria/config/helpers/get_answer.dart';
import 'package:mensajeria/dominio/mesagge.dart';
import 'package:image_picker/image_picker.dart';

class ChatProvider extends ChangeNotifier {
  String contactName = "Contacto";
  String contactIconUrl =
      'https://upload.wikimedia.org/wikipedia/commons/b/b7/Google_Contacts_logo.png';
  
  final ImagePicker _picker = ImagePicker();
  String? userName; // Variable para almacenar el nombre del usuario
  bool isAskingForName = true; // Indica si está esperando el nombre

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      contactIconUrl = pickedFile.path;
      notifyListeners();
    }
  }

  void updateContact(String newName, String newIconUrl) {
    contactName = newName;
    contactIconUrl = newIconUrl;
    notifyListeners();
  }

  final GetAnswer getAnswer = GetAnswer();
  final ScrollController chatScrollController = ScrollController();
  List<Message> messageList = [];

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // Si estamos esperando el nombre del usuario
    if (isAskingForName) {
      userName = text; // Almacena el nombre del usuario
      isAskingForName = false; // Ya no está preguntando por el nombre
      final greetingMessage = Message(
        text: "Hola, $userName!",
        yooEl: YooEl.hers,
        timestamp: DateTime.now(),
        isRead: true,
      );
      messageList.add(greetingMessage);
    } else {
      // Procesar otros mensajes después de recibir el nombre
      final newMessage = Message(
        text: text,
        yooEl: YooEl.me,
        timestamp: DateTime.now(),
        isRead: true,
      );
      messageList.add(newMessage);

      if (text.toLowerCase().endsWith("?")) {
        await herReply();
      } else if (text.toLowerCase() == 'mañana') {
        final autoResponse = Message(
          text: "Lo pensaré mañana.",
          yooEl: YooEl.hers,
          timestamp: DateTime.now(),
          isRead: true,
        );
        messageList.add(autoResponse);
      } else if (text.toLowerCase() == 'tarde') {
        final autoResponse = Message(
          text: "Lo vemos más tarde.",
          yooEl: YooEl.hers,
          timestamp: DateTime.now(),
          isRead: true,
        );
        messageList.add(autoResponse);
      } else {
        final autoResponse = Message(
          text: "No me hiciste una pregunta.",
          yooEl: YooEl.hers,
          timestamp: DateTime.now(),
          isRead: true,
        );
        messageList.add(autoResponse);
      }
    }

    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> herReply() async {
    final herMessage = await getAnswer.getAnswer();

    final herMessageWithSender = Message(
      text: herMessage.text,
      imageUrl: herMessage.imageUrl,
      yooEl: YooEl.hers,
      timestamp: DateTime.now(),
      isRead: true,
    );

    messageList.add(herMessageWithSender);
    notifyListeners();
    moveScrollToBottom();
  }

  void moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Pregunta inicial para el nombre
  void askForName() {
    final nameRequestMessage = Message(
      text: "¿Cómo te llamas?",
      yooEl: YooEl.hers,
      timestamp: DateTime.now(),
      isRead: true,
    );
    messageList.add(nameRequestMessage);
    notifyListeners();
  }
}
