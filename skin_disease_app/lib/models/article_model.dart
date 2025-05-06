import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime publishDate;
  final String? imageUrl;
  final List<String> tags;
  final int readTime; // in minutes
  final int likes;
  final String category;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishDate,
    this.imageUrl,
    required this.tags,
    required this.readTime,
    required this.likes,
    required this.category,
  });

  // Create an ArticleModel from Firestore data
  factory ArticleModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ArticleModel(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? '',
      publishDate: (data['publishDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
      readTime: data['readTime'] ?? 5,
      likes: data['likes'] ?? 0,
      category: data['category'] ?? 'General',
    );
  }

  // Convert ArticleModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'publishDate': Timestamp.fromDate(publishDate),
      'imageUrl': imageUrl,
      'tags': tags,
      'readTime': readTime,
      'likes': likes,
      'category': category,
    };
  }
}
