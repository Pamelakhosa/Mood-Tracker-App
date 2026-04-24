import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mood_tracker/Bloc/Home/mood_cubit.dart';
import 'package:mood_tracker/Bloc/Stats_and_notifications/notifications_cubit.dart';
import 'package:mood_tracker/Mood_model/moodentry.dart';
import 'package:mood_tracker/Provider/Mode/mode.dart';
import 'package:mood_tracker/Provider/Mood/mood_border.dart';
import 'package:mood_tracker/Notifications/noti_service.dart';
import 'package:mood_tracker/Provider/Reason/reason_border.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  //Notification count parameter to pass the number of notifications to the home screen
  final int notificationCount;

  const HomeScreen({super.key, required this.notificationCount});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Stores mood entry data
  String? _selectedMood;
  int? _selectedTime = 1;
  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();

  //Function called when user submits mood entry
  void _onSave() {
    //Mood entry validation
    if (_selectedMood == null ||
        _selectedReason == null ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select a mood')),
      );
      return;
    }

    //Initializing MoodEntry with user mood entry data
    final moodEntry = MoodEntry(
      mood: _selectedMood!,
      reason: _selectedReason!,
      description: _descriptionController.text,
      timeOfDay: _selectedTime,
      date: DateTime.now(),
    );

    // Log new mood entry
    log('New mood created: ${moodEntry.toJson()}');

    // Read new mood entry using the home cubit
    context.read<MoodCubit>().addMood(moodEntry);
  }

  // Time of day selection dialog
  Future<void> showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Enter Time of Day')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 50, right: 50),
                  child: Divider(color: Colors.black),
                ),
                SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, state) => Column(
                    children: [
                      ListTile(
                        title: const Text('Morning'),
                        leading: Radio<int>(
                          value: 1,
                          groupValue: _selectedTime,
                          onChanged: (value) {
                            state(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Afternoon'),
                        leading: Radio<int>(
                          value: 2,
                          groupValue: _selectedTime,
                          onChanged: (value) {
                            state(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Night'),
                        leading: Radio<int>(
                          value: 3,
                          groupValue: _selectedTime,
                          onChanged: (value) {
                            state(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            //Save button for submitting mood entry
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                //Function for handling submission
                _onSave();

                //If statement to log data, and display success snackbar when mood entry submission is successful
                if (_selectedMood != null &&
                    _selectedReason != null &&
                    _descriptionController.text.isNotEmpty &&
                    _selectedTime != null) {
                  log('Selected mood: $_selectedMood');
                  log('Selected reason: $_selectedReason');
                  log('Description: ${_descriptionController.text}');
                  log('Selected time: $_selectedTime');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mood added to calendar'),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  //If statements to set and display notifications based on time of day selected
                  if (_selectedTime == 1) {
                    NotiService().initNotification().then((_) {
                      Future.delayed(const Duration(seconds: 1), () {
                        NotiService().showNotification(
                          title: "Reminder",
                          body: "Remember to track your mood in the afternoon.",
                        );
                      });
                    });
                    context.read<NotificationsCubit>().addNotifaction(
                      "Remember to track your mood in the afternoon.",
                    );
                  }
                  if (_selectedTime == 2) {
                    NotiService().initNotification().then((_) {
                      Future.delayed(const Duration(seconds: 1), () {
                        NotiService().showNotification(
                          title: "Reminder",
                          body: "Remember to track your mood tonight.",
                        );
                      });
                    });
                    context.read<NotificationsCubit>().addNotifaction(
                      "Remember to track your mood tonight.",
                    );
                  }
                  if (_selectedTime == 3) {
                    NotiService().initNotification().then((_) {
                      Future.delayed(const Duration(seconds: 1), () {
                        NotiService().showNotification(
                          title: "Reminder",
                          body: "Remember to track your mood in the morning.",
                        );
                      });
                    });
                    context.read<NotificationsCubit>().addNotifaction(
                      "Remember to track your mood in the morning.",
                    );
                  }

                  //Clear description text field
                  _descriptionController.clear();

                  //Pop out of dialog
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Mood and border provider controllers
    final modeController = Provider.of<ModeController>(
      context,
    ); //Controls colors based on dark/light mode
    final moodController = Provider.of<MoodController>(
      context,
    ); //Controls container borders when clicked
    final reasonController = Provider.of<ReasonController>(
      context,
    ); //Controls container borders when clicked

    //Logging selected mood
    log('Selected mood: $_selectedMood');

    log(
      'Home notification count: ${context.watch<NotificationsCubit>().state.length}',
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //Light/dark mode toggle
        leading: IconButton(
          onPressed: () {
            modeController.toggleMode();
          },
          icon: Icon(
            modeController.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
        //Displaying current date
        title: Text(getCurrentDate(), style: TextStyle(fontSize: 15)),
        //Calendar navigation button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                context.push('/calendar');
              },
              icon: Icon(Icons.calendar_month_outlined),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                    'How Are You Feeling Today?',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 5,
                    ),
                  )
                  .animate()
                  .fade(duration: Duration(seconds: 3))
                  .scale(), //Scaling animation for home message on app launch
              const SizedBox(height: 10),
              Wrap(
                children: [
                  //Carousel slider for mood containers
                  //Each container has a gesture detector to set mood and highlight mood when selected
                  CarouselSlider(
                    options: CarouselOptions(height: 250.0),
                    items: [
                      GestureDetector(
                        onTap: () {
                          _selectedMood = "Happy";
                          moodController.toggleMood();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(250),
                            border: _selectedMood == "Happy"
                                ? Border.all(width: 10, color: Colors.grey)
                                : null,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/Happy.webp',
                              width: 170,
                              height: 170,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectedMood = "Sad";
                          moodController.toggleMood();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(250),
                            border: _selectedMood == "Sad"
                                ? Border.all(width: 10, color: Colors.grey)
                                : null,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/Sad.webp',
                              width: 170,
                              height: 170,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectedMood = "Angry";
                          moodController.toggleMood();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(250),
                            border: _selectedMood == "Angry"
                                ? Border.all(width: 10, color: Colors.grey)
                                : null,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/Angry.png',
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _selectedMood = "Calm";
                          moodController.toggleMood();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(250),
                            border: _selectedMood == "Calm"
                                ? Border.all(width: 10, color: Colors.grey)
                                : null,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/Calm.webp',
                              width: 160,
                              height: 160,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Text('What\'s the reason?'),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                //Horizontal list view for reason containers
                //Each container has a gesture detector that sets the reason and highlights to selected reason
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Work";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Work"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Work',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "School";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "School"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'School',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Friends";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Friends"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Friends',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Family";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Family"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Family',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Hobby";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Hobby"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Hobby',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Health";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Health"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Health',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Relationship";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Relationship"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Relationship',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _selectedReason = "Money";
                        reasonController.toggleReason();
                      },
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(200),
                          border: _selectedReason == "Money"
                              ? Border.all(width: 5, color: Colors.grey)
                              : null,
                        ),
                        child: Center(
                          child: const Text(
                            'Money',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text('Let\'s talk about it'),
              const SizedBox(height: 20),
              // Mood description text field
              TextField(
                controller: _descriptionController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Describe how you feel...',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(16),
                  fillColor: Colors.grey[450],
                ),
              ),
              const SizedBox(height: 20),
              //Add to calendar button that displays a dialog to select time of day and save button submit mood entry
              GestureDetector(
                onTap: () {
                  showMyDialog();
                },
                child: Container(
                  height: 30,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: const Text(
                      'Add to calendar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: const Divider(color: Color.fromARGB(255, 7, 7, 7)),
              ),
              //Bottom stats and notifications nav image button with notification count
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () {
                        //Navigate to stats and notifications
                        //Pass moods parameter
                        Map<String, dynamic> data = {
                          'moodEntries': context.read<MoodCubit>().state,
                        };
                        context.push('/stats_notis', extra: data);
                      },
                      child: Image.asset(
                        'assets/images/Moods.webp',
                        height: 50,
                        width: 50,
                      ),
                    ),
                    Positioned(
                      top: 35,
                      left: 30,
                      child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          //Notification count
                          child: Text(
                            '${context.watch<NotificationsCubit>().state.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        //Bottom fade in animation
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, duration: 1000.ms, curve: Curves.easeOut),
    );
  }

  //Function to get the current date
  getCurrentDate() {
    var date = DateTime.now().toString();

    var dateParse = DateTime.parse(date);

    String day = DateFormat('EEEE').format(DateTime.now());

    // Month removed


    var formattedDate = "$day, ${dateParse.day}";

    return formattedDate;
  }
}
