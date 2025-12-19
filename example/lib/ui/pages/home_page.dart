import 'package:example/config/ia/app_agents/message_agent.dart';
import 'package:example/config/state/app_state.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: appState.appColor,

      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Image.asset('assets/images/weincode.png'),
        ),
        backgroundColor: Colors.deepPurple[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: appState.appColor.withOpacity(0.3)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'data',
                style: TextStyle(
                  fontSize: 24,
                  color: appState.appColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: appState.appColor,
            onPressed: () {
              // Handle first button press
            },
            child: Icon(
              Icons.mic,
              color: appState.appColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: appState.appColor,
            onPressed: () {
              // Handle second button press
              submitFeedback(context);
            },
            child: Icon(
              Icons.message,
              color: appState.appColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  void submitFeedback(BuildContext context) {
    BetterFeedback.of(context).show((UserFeedback feedback) {
      final manager = MessageAgent();
      manager.initialize();
      manager.submitFeedback(context, feedback.screenshot, feedback.text);
    });
  }
}
