

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_tracker/Bloc/Home/mood_cubit.dart';
import 'package:mood_tracker/Bloc/Stats_and_notifications/notifications_cubit.dart';
import 'package:mood_tracker/Bloc/observer.dart';
import 'package:mood_tracker/Provider/Mode/mode.dart';
import 'package:mood_tracker/Provider/Mood/mood_border.dart';
import 'package:mood_tracker/Notifications/noti_service.dart';
import 'package:mood_tracker/Provider/Reason/reason_border.dart';
import 'package:mood_tracker/Router/router.dart';
import 'package:provider/provider.dart';

void main() async {
  //Ensure that an instance of WidgetsFlutterBinding is initialized before calling runApp()
  WidgetsFlutterBinding.ensureInitialized();

  //Initialise app start up notification
  NotiService().initNotification().then((_) {
    NotiService().showNotification(
      title: 'Welcome',
      body: 'Ready to track your mood?',
    );
  });

  //Initilize BLoC observer
  Bloc.observer = const Observer();

  runApp(
    MultiProvider(
      providers: [
        //Handles light/dark mode switching
        ChangeNotifierProvider(create: (context) => ModeController()),

        //Handles highlighting mood selection
        ChangeNotifierProvider(create: (context) => MoodController()),

        //Handles highlighting reason selection
        ChangeNotifierProvider(create: (context) => ReasonController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final modeController = Provider.of<ModeController>(context);

    return MultiBlocProvider(
      providers: [
        // Handles mood state management 
        BlocProvider<MoodCubit>(create: (_) => MoodCubit()),
        // Handles notifications state management
        BlocProvider<NotificationsCubit>(create: (_) => NotificationsCubit()),
      ],
      child: MaterialApp.router(
        theme: ThemeData(
          // Dynamically applies light or dark theme based on user preference
          brightness: modeController.isDarkMode
              ? Brightness.dark
              : Brightness.light,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}


