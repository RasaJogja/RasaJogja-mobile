import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:rasajogja_mobile/models/forum/forum_model.dart';
import 'package:rasajogja_mobile/screens/forum/add_new_form_page.dart';
import 'package:rasajogja_mobile/screens/forum/forum_detail.dart';
import 'package:rasajogja_mobile/widgets/forum/top_places.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late Future<List<ForumEntry>> _forumFuture;

  Future<List<ForumEntry>> fetchForums(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/forum/get-forum-entries/');
    return List<ForumEntry>.from(
      response.map((data) => ForumEntry.fromJson(data)),
    );
  }

  void _showDeleteConfirmationDialog(ForumEntry forum) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Forum"),
          content: const Text("Apakah Anda yakin ingin menghapus forum ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _deleteForum(forum); // Lakukan hapus
              },
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _forumFuture = fetchForums(request);
  }

  Future<void> _refreshForums() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() {
      _forumFuture = fetchForums(request);
    });
  }

  void _deleteForum(ForumEntry forum) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final deleteUrl =
        'http://127.0.0.1:8000/forum/delete-forum-flutter/${forum.pk}/';

    try {
      final response = await request.post(deleteUrl, {});

      if (response['success'] == true) {
        setState(() {
          _forumFuture = fetchForums(request);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forum berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Gagal menghapus forum')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // Hapus atau komentari bagian floatingActionButton
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const AddNewFormPage()),
        //     );
        //   },
        //   backgroundColor: const Color(0xFF9C6F4A),
        //   child: const Icon(Icons.add),
        // ),
        backgroundColor: const Color(0xFFF8F3EE),
        appBar: AppBar(
          title: const Text(
            'Forum Diskusi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C6F4A), Color(0xFFC89F94)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshForums,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                TopPlacesSection(), // Bagian Top Places
                FutureBuilder<List<ForumEntry>>(
                  future: _forumFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: Text('Error: ${snapshot.error}')),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Belum ada forum, tambahkan sekarang!',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // Tombol Add Forum di bawah pesan kosong
                            Center(
                              child: SizedBox(
                                width: 150, // Lebar tombol
                                height: 40, // Tinggi tombol
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddNewFormPage()),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Tambah Forum',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF9C6F4A), // Warna tombol
                                    foregroundColor:
                                        Colors.white, // Warna teks dan ikon
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8), // Sudut tombol
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final forums = snapshot.data!;
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: forums.length,
                              itemBuilder: (context, index) {
                                final forum = forums[index];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ForumDetailPage(forum: forum),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                forum.fields.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF5B4636),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                forum.fields.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF5B4636),
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${forum.fields.commentsCount} Komentar',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF5B4636),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (forum.fields.isAuthor)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                _showDeleteConfirmationDialog(forum);
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24), // Spacing sebelum tombol
                            // Tombol Add Forum di bawah daftar forum
                            Center(
                              child: SizedBox(
                                width: 150, // Lebar tombol
                                height: 40, // Tinggi tombol
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddNewFormPage()),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Tambah Forum',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF9C6F4A), // Warna tombol
                                    foregroundColor:
                                        Colors.white, // Warna teks dan ikon
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8), // Sudut tombol
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
