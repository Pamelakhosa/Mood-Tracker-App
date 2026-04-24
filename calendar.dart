import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mood_tracker/Bloc/Home/mood_cubit.dart';
import 'package:mood_tracker/Provider/Mode/mode.dart';
import 'package:mood_tracker/Mood_model/moodentry.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now(); //Sets focused day on calendar
  DateTime? _selectedDay; //Sets selected day on calendar
  List<MoodEntry> _selectedMoods =
      []; //List to display moods on the selected day

  TextEditingController reasonController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; //Set focused day as the day selected
  
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<MoodCubit, List<MoodEntry>>(
        builder: (context, state) {
          context.read<MoodCubit>().state;
          _selectedMoods = state
              .where((moods) => isSameDay(moods.date, _selectedDay))
              .toList();
          return SingleChildScrollView(
            child: Column(
              children: [
                //Calendar
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //Display mood entries or show a message if there are no mood entries on the selected day
                _selectedMoods.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: const Text('No mood entries for this day.'),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ListView.builder(
                            itemCount: _selectedMoods.length,
                            itemBuilder: (context, index) {
                              final mood = _selectedMoods[index];
                              final String? time;

                              //If statement to set time of day based on time of day value
                              if (mood.timeOfDay == 1) {
                                time = "Morning";
                              } else if (mood.timeOfDay == 2) {
                                time = "Afternoon";
                              } else {
                                time = "Night";
                              }

                              //Color function to set card color based on mood parameter
                              Color getCardColor(String mood) {
                                if (mood == "Sad") {
                                  return Colors.lightBlue;
                                }
                                if (mood == "Happy") {
                                  return Colors.amber;
                                }
                                if (mood == "Angry") {
                                  return Colors.red;
                                }
                                if (mood == "Calm") {
                                  return Colors.lightGreen;
                                }
                                return Colors.grey;
                              }

                              //String function to set card mood image based on mood parameter
                              String getMoodImage(String mood) {
                                if (mood == "Sad") {
                                  return 'assets/images/Sad.webp';
                                }
                                if (mood == "Happy") {
                                  return 'assets/images/Happy.webp';
                                }
                                if (mood == "Angry") {
                                  return 'assets/images/Angry.png';
                                }
                                if (mood == "Calm") {
                                  return 'assets/images/Calm.webp';
                                }
                                return 'assets/images/Happy.webp';
                              }

                              final modeController = Provider.of<ModeController>(
                                context,
                              ); //Mode provider controller that controls colors based on dark/light mode

                              //Mood entry update sheet
                              void sheet() async {
                                await showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.all(20),
                                    child: ListView(
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Update Mood',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 50),
                                            SizedBox(height: 30),
                                            TextField(
                                              controller: reasonController,
                                              decoration: InputDecoration(
                                                labelText: 'Reason',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 50),
                                            TextField(
                                              controller: descriptionController,
                                              decoration: InputDecoration(
                                                labelText: 'Description',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 100),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (reasonController
                                                        .text
                                                        .isNotEmpty &&
                                                    descriptionController
                                                        .text
                                                        .isNotEmpty) {
                                                  mood.reason =
                                                      reasonController.text;
                                                  mood.description =
                                                      descriptionController
                                                          .text;
                                                  //Update mood entry
                                                  context
                                                      .read<MoodCubit>()
                                                      .updateMood(mood);
                                                      reasonController.clear();
                                                      descriptionController.clear();
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Mood updated successfully',
                                                      ),
                                                    ),
                                                  );
                                                }
                                                log(
                                                  'Reason controller text: ${reasonController.text}',
                                                );
                                                log(
                                                  'Description controller text: ${descriptionController.text}',
                                                );
                                              },
                                              child: Text('Save'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              //Returns card with mood entry details
                              //Opens a modal sheet for each mood entry to be updated when clicked
                              return GestureDetector(
                                onTap: () {
                                  sheet();
                                },
                                child: Slidable(
                                  startActionPane: ActionPane(
                                    motion: BehindMotion(),
                                    children: [
                                      SizedBox(height: 5),
                                      SlidableAction(
                                        borderRadius: BorderRadius.circular(5),
                                        backgroundColor:
                                            modeController.isDarkMode
                                            ? Colors.black12
                                            : Colors.white,
                                        onPressed: ((context) {
                                          //Delete mood entry
                                          context
                                              .read<MoodCubit>()
                                              .deleteMood(mood, index);
                                          log(
                                            'Mood entry lenth: ${_selectedMoods.length}',
                                          );
                                          log(
                                            'State Mood entry lenth: ${state.length}',
                                          );
                                        }),
                                        icon: Icons.delete,
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    color: getCardColor(mood.mood),
                                    margin: EdgeInsets.all(8),
                                    child: ListTile(
                                      title: Text(
                                        time,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: modeController.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mood.reason,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: modeController.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            mood.description,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: modeController.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Image.asset(
                                        getMoodImage(mood.mood),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.2, duration: 1000.ms, curve: Curves.easeOut),
          );
        },
      ), //Right fade in effect
    );
  }
}
