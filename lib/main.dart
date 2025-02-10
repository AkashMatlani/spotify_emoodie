import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_emoodie/bloc/search_bloc.dart';
import 'package:spotify_emoodie/cubit/search_type_cubit.dart';
import 'package:spotify_emoodie/ui/search_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SearchTypeCubit()),
        BlocProvider(create: (_) => SearchBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: BlocProvider(
          create: (context) => SearchBloc(),
          child: SearchScreen(),
        ));
  }
}
