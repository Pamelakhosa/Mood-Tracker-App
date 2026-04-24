import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:mood_tracker/Mood_model/moodentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodCubit extends Cubit<List<MoodEntry>> {
  static const _storageKey = 'mood_entries';

  MoodCubit() : super([]){
    _loadMoods();
  }


  Future<void> addMood (MoodEntry newMood) async {
    final updatedList = List<MoodEntry>.from(state);
    updatedList.add(newMood);
    emit(updatedList);
    _saveMoods(updatedList);
  }

  Future<void> updateMood (MoodEntry mood) async{
    final updatedList = state.map((mood) {
      return mood;
    }).toList();
    emit(updatedList);
    _saveMoods(updatedList);
  }

  Future<void> deleteMood (MoodEntry mood, int index) async{
    final updatedList = state.map((mood) {
      return mood;
    }).toList();
    updatedList.removeAt(index);
    emit(updatedList);
    _saveMoods(updatedList);
  }

  Future<void> _saveMoods(List<MoodEntry> moods) async{
    final prefs = await SharedPreferences.getInstance();
    final jsonList = moods.map((mood) => jsonEncode(mood.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
  
  Future<void> _loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList != null) {
      final moodList = jsonList
          .map((moodStr) => MoodEntry.fromJson(jsonDecode(moodStr)))
          .toList();
      emit(moodList);
    }
  }
}
