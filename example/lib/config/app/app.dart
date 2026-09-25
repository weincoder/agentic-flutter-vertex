import 'package:example/config/state/app_state.dart';
import 'package:example/ui/pages/diary_home_page.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return BetterFeedback(
            theme: FeedbackThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: appState.appTheme.colorScheme.primary,
              ),
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: appState.appTheme,
              home: const DiaryHomePage(),
            ),
          );
        },
      ),
    );
  }
}
