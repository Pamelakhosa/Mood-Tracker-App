import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/Bloc/Stats_and_notifications/notifications_cubit.dart';
import 'package:mood_tracker/Provider/Mode/mode.dart';
import 'package:mood_tracker/Mood_model/moodentry.dart';
import 'package:provider/provider.dart';

class StatsNotis extends StatefulWidget {
  //Mood entries and parameter to pass to the Stats and notfications screen
  final List<MoodEntry> moodEntries;

  const StatsNotis({
    super.key,
    required this.moodEntries,
  });

  @override
  State<StatsNotis> createState() => _StatsNotisState();
}

class _StatsNotisState extends State<StatsNotis> {
  @override
  Widget build(BuildContext context) {
    final modeController = Provider.of<ModeController>(
      context,
    ); //Mode provider controller that controls colors based on dark/light mode

    //Mood colors to map on chart
    final Map<String, Color> moodColorMap = {
      'Happy': Colors.amber,
      'Sad': Colors.lightBlue,
      'Angry': Colors.red,
      'Calm': Colors.lightGreen,
    };

    //Stores the number of times a mood was selected
    final Map<String, int> moodCount = {};

    //Increment a mood count by 1 each time it is selected
    //Keep mood count at 0 if not selected
    for (var entry in widget.moodEntries) {
      moodCount[entry.mood] = (moodCount[entry.mood] ?? 0) + 1;
    }

    //Setting pie chart data sections
    final sections = moodCount.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: moodColorMap[entry.key] ?? Colors.grey,
        showTitle: false,
        radius: 40,
      );
    }).toList();

    //Calculating highest mood selected
    int happyCounter = 0;
    int sadCounter = 0;
    int angryCounter = 0;
    int calmCounter = 0;
    int noMood = 0;

    for (var mood in widget.moodEntries) {
      if (mood.mood == "Happy") {
        happyCounter++;
      }
      if (mood.mood == "Sad") {
        sadCounter++;
      }
      if (mood.mood == "Angry") {
        angryCounter++;
      }
      if (mood.mood == "Calm") {
        calmCounter++;
      }
      if (mood.mood.isEmpty) {
        noMood;
      }
    }

    log('Mood entries length: ${widget.moodEntries.length}');

    String? highestValue;

    Map<Object?, Object?>? points = {
      "Happy": happyCounter,
      "Sad": sadCounter,
      "Angry": angryCounter,
      "Calm": calmCounter,
      "No Mood": noMood,
    };

    highestValue =
        points.entries.reduce((a, b) {
              final aValue = a.value;
              final bValue = b.value;

              if (aValue is! int) {
                return b;
              }

              if (bValue is! int) {
                return a;
              }

              return aValue > bValue ? a : b;
            }).key
            as String?;

    log('Highest mood selected: $highestValue');

    //Setting mood message based on highest mood selected
    Text getMoodMessage() {
      if (highestValue == "Happy") {
        return Text(
          'Seems like a good week!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        );
      }
      if (highestValue == "Sad") {
        return Text(
          'That sucks. Hope you feel better soon.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        );
      }
      if (highestValue == "Angry") {
        return Text(
          'Seems rough. Try taking a walk to relax.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        );
      }
      if (highestValue == "Calm") {
        return Text(
          'That\'s great! Keep enjoying yourself.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        );
      }
      if (highestValue == "No Mood") {
        return Text(
          'Start tracking your mood.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
        );
      }

      return Text('Start tracking your mood!');
    }

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<NotificationsCubit, List<String>>(
        builder: (context, state) {
          log('Notification length: ${state.length}');
          
          return SingleChildScrollView(
                child: Column(
                  children: [
                    Center(child: Text('Average mood this week')),
                    SizedBox(height: 80),
                    SizedBox(
                      height: 150,
                      width: 150,
                      //Pie chart
                      //Display blank pie chart if there are no mood entries
                      child: PieChart(
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.easeInQuint,
                        moodCount.isNotEmpty
                            ? PieChartData(
                                centerSpaceRadius: 80,
                                sections: sections,
                              )
                            : PieChartData(
                                centerSpaceRadius: 80,
                                sections: [
                                  PieChartSectionData(
                                    value: 10,
                                    color: modeController.isDarkMode
                                        ? Colors.grey[900]
                                        : Colors.grey[350],
                                    showTitle: false,
                                    radius: 40,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 80),
                    //Mood color indicators
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 45),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Angry'),
                          Text('Sad'),
                          Text('Happy'),
                          Text('Calm'),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 35, right: 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 2,
                            width: 65,
                            decoration: BoxDecoration(color: Colors.red),
                          ),
                          Container(
                            height: 2,
                            width: 65,
                            decoration: BoxDecoration(color: Colors.lightBlue),
                          ),
                          Container(
                            height: 2,
                            width: 65,
                            decoration: BoxDecoration(color: Colors.amber),
                          ),
                          Container(
                            height: 2,
                            width: 65,
                            decoration: BoxDecoration(color: Colors.lightGreen),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    //Display mood message
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: getMoodMessage()
                          .animate()
                          .fade(duration: Duration(seconds: 2))
                          .scale(),
                    ),
                    //Notification container
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        height: 250,
                        width: 500,
                        decoration: BoxDecoration(
                          color: modeController.isDarkMode
                              ? Colors.grey[900]
                              : Colors.grey[350],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Notifications',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            //Display notifications
                            //Display message if there are no notifications
                            SizedBox(
                              height: 100,
                              width: 500,
                              child: state.isEmpty
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'No notifications at the moment.',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      itemCount: state.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                state[index],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            SizedBox(height: 10),
                            //Delete notifications and display success snackbar
                            //Show no notifications snackbar if there are no notifications to delete
                            Center(
                              child: state.isEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('No notifications.'),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.delete_outline),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        //Clear notifications
                                        //Update state using the notifications cubit
                                        context
                                            .read<NotificationsCubit>()
                                            .deleteNotifications(state);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Notifications deleted.',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.delete_outline),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideX(begin: 0.2, duration: 1000.ms, curve: Curves.easeOut);
        },
      ), //Right fade in animation
    );
  }
}
