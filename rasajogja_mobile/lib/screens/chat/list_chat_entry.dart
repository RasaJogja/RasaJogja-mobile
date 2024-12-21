import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rasajogja_mobile/models/auth/profile_entry.dart';
import 'package:rasajogja_mobile/screens/chat/room_chat.dart';
import 'package:rasajogja_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;

class ChatEntryPage extends StatefulWidget {
  const ChatEntryPage({super.key});

  @override
  State<ChatEntryPage> createState() => _ChatEntryPageState();
}

class _ChatEntryPageState extends State<ChatEntryPage> {
  Future<List<User>> fetchUsers() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/chat/create-chat-flutter/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<User> users = userFromJson(responseData['users']);
        return users;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching/parsing data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<User>>(
        future: fetchUsers(),
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No available users to chat with.',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
                SizedBox(height: 8),
              ],
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                final user = snapshot.data![index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.fields.username.toUpperCase()),
                    ),
                    title: Text(
                      user.fields.username,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: () async {
                          try {
                            final response = await http.post(
                              Uri.parse(
                                  "http://127.0.0.1:8000/chat/handle-room-flutter/"),
                              headers: {
                                "Content-Type": "application/json",
                              },
                              body: jsonEncode({
                                "id": user.pk,
                              }),
                            );

                            if (response.statusCode == 200) {
                              final data = jsonDecode(response.body);
                              print(data); // Handle the response data

                              // Navigate to new screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageEntryFormPage(
                                    chatId: data[
                                        "chat_id"], // Passing chat_id ke screen berikutnya
                                  ),
                                ),
                              );
                            } else {
                              print(
                                  'Request failed with status: ${response.statusCode}');
                            }
                          } catch (e) {
                            print('Error: $e');
                          }
                        }),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}