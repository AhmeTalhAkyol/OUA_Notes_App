import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorite_notes_page.dart';
import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        hintColor: Colors.purpleAccent,
        buttonTheme: ButtonThemeData(buttonColor: Colors.purple),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isAddingNote = false;
  String? _editingNoteId;
  List<DocumentSnapshot> favoriteNotes = [];

  Future<void> _addOrUpdateNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isNotEmpty && content.isNotEmpty) {
      if (_editingNoteId == null) {
        await _firestore.collection('Notes').add({
          'title': title,
          'content': content,
          'createdAt': Timestamp.now(),
        });
      } else {
        await _firestore.collection('Notes').doc(_editingNoteId).update({
          'title': title,
          'content': content,
        });
        setState(() {
          _editingNoteId = null;
        });
      }

      _titleController.clear();
      _contentController.clear();
      setState(() {
        _isAddingNote = false;
      });
    }
  }

  Future<void> _deleteNote(String noteId) async {
    await _firestore.collection('Notes').doc(noteId).delete();
  }

  void _editNote({
    required String noteId,
    required String title,
    required String content,
  }) {
    _titleController.text = title;
    _contentController.text = content;
    setState(() {
      _isAddingNote = true;
      _editingNoteId = noteId;
    });
  }

  void _toggleFavorite(String noteId) async {
    final noteRef = _firestore.collection('Notes').doc(noteId);
    final noteSnapshot = await noteRef.get();
    final isFavorite = noteSnapshot['isFavorite'] ?? false;
    await noteRef.update({'isFavorite': !isFavorite});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () async {
              final favoriteNotes = await _firestore
                  .collection('Notes')
                  .where('isFavorite', isEqualTo: true)
                  .get();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoriteNotesPage(
                    favoriteNotes: favoriteNotes.docs,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isAddingNote
          ? Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _editingNoteId == null ? 'Yeni bir not ekle' : 'Notu güncelle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addOrUpdateNote,
              child: Text(_editingNoteId == null ? 'Add Note' : 'Update Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAddingNote = false;
                });
              },
              child: Text('Back to Notes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Notes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz notunuz yok', style: TextStyle(fontSize: 18)));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(doc['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['content']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite, color: doc['isFavorite'] ? Colors.red : Colors.grey),
                        onPressed: () => _toggleFavorite(doc.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editNote(
                          noteId: doc.id,
                          title: doc['title'],
                          content: doc['content'],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingNote = !_isAddingNote;
            if (_isAddingNote) {
              _titleController.clear();
              _contentController.clear();
              _editingNoteId = null;
            }
          });
        },
        child: Icon(_isAddingNote ? Icons.arrow_back : Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
