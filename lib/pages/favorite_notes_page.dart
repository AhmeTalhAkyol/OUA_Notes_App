import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteNotesPage extends StatelessWidget {
  final List<DocumentSnapshot> favoriteNotes;

  FavoriteNotesPage({required this.favoriteNotes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Notes'),
      ),
      body: favoriteNotes.isEmpty
          ? Center(
        child: Text('No favorite notes yet'),
      )
          : ListView.builder(
        itemCount: favoriteNotes.length,
        itemBuilder: (context, index) {
          final note = favoriteNotes[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(note['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(note['content']),
            ),
          );
        },
      ),
    );
  }
}
