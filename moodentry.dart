// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

//Mood entry class

class MoodEntry {
  final String mood;
  String reason;
  String description;
  final int? timeOfDay;
  final DateTime date;

  MoodEntry({
    required this.mood,
    required this.reason,
    required this.description,
    required this.timeOfDay,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mood': mood,
      'reason': reason,
      'description': description,
      'timeOfDay': timeOfDay,
      'date': date.toIso8601String(),
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: json['mood'],
      reason: json['reason'],
      description: json['description'],
      timeOfDay: json['timeOfDay'],
      date: DateTime.parse(json['date']),
    );
  }
}
