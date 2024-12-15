import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rasajogja_mobile/models/chat/message_entry.dart';

class MessageEntryFormPage extends StatefulWidget {
  final String chatId;

  const MessageEntryFormPage({
    super.key,
    required this.chatId,
  });

  @override
  State<MessageEntryFormPage> createState() => _MessageEntryFormPageState();
}

class _MessageEntryFormPageState extends State<MessageEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _message = "";
  List<Message> messages = [];
  String user_loggedin = "";

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Fetch existing messages when page loads
  }

  // Function to fetch existing messages
  Future<void> fetchMessages() async {
    try {
      final url =
          "http://127.0.0.1:8000/chat/get-messages-flutter/${widget.chatId}/";
      print("Fetching messages from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final dataSent = jsonDecode(response.body);
        final String loggedInUser = dataSent['user_loggedin'];
        final List<dynamic> data = dataSent['messages'];
        setState(() {
          messages = data.map((json) => Message.fromJson(json)).toList();
          user_loggedin = loggedInUser;
        });
      } else {
        print("Error status code: ${response.statusCode}");
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Room Chat'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isMe = message.fields.sender == user_loggedin;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.fields.sender,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(message.fields.content),
                        const SizedBox(height: 4),
                        Text(
                          message.fields.timestamp.toIso8601String(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input form
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _message = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Message tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                      icon: Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        // First check if _message is not null and not empty
                        if (_formKey.currentState!.validate() &&
                            _message.isNotEmpty) {
                          try {
                            final response = await http.post(
                              Uri.parse(
                                  "http://127.0.0.1:8000/chat/send-message-flutter/"),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, String>{
                                'messages': _message,
                                'chat_id': widget.chatId
                              }),
                            );

                            if (response.statusCode == 200) {
                              final responseData = jsonDecode(response.body);
                              if (responseData['status'] == 'success') {
                                setState(() {
                                  messages.add(Message.fromJson(
                                      responseData['message']));
                                });
                                _formKey.currentState!.reset();
                                // Clear _message after sending
                                _message = '';

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Berhasil")),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        } else {
                          // Show error message if message is null or empty
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Pesan tidak boleh kosong")),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
