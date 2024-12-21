import 'package:flutter/material.dart';
import 'package:rasajogja_mobile/screens/bookmark/bookmark_entry.dart';
import 'package:rasajogja_mobile/screens/menu.dart';
import 'package:rasajogja_mobile/screens/chat/list_chat_entry.dart';
import 'package:rasajogja_mobile/screens/katalog/list_productentry.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              children: [
                Text(
                  'Rasa Jogja',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                  "Sigma sigma boy sigma boy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Lihat Product'),
            // Bagian redirection ke MoodEntryFormPage
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductEntryPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Bookmark'),
            // Bagian redirection ke MoodEntryFormPage
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Reviews'),
            // Bagian redirection ke MoodEntryFormPage
            onTap: () {
              /*
                TODO: Buatlah routing ke MoodEntryFormPage di sini,
                setelah halaman MoodEntryFormPage sudah dibuat.
                */
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Forum'),
            // Bagian redirection ke MoodEntryFormPage
            onTap: () {
              /*
                TODO: Buatlah routing ke MoodEntryFormPage di sini,
                setelah halaman MoodEntryFormPage sudah dibuat.
                */
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Chat'),
            // Bagian redirection ke MoodEntryFormPage
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatEntryPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
