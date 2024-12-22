import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_test/WebRtcViewModel.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final viewModel = WebRtcViewModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('WebRTC Demo'),
          ),
          body: Column(
            children: [
              TextButton(
                  onPressed: () {
                    viewModel.offerConnection();
                  },
                  child: const Text("Generate Offer and copy to clipboard")),
              TextButton(
                onPressed: () async {
                  viewModel.answerConnection(RTCSessionDescription(
                      json.decode(((await Clipboard.getData('text/plain'))
                          ?.text)!)["sdp"],
                      'offer'));
                },
                child: const Text(
                    "Generate Answer based on offer in clipboard and copy to clipboard"),
              ),
              TextButton(
                  onPressed: () async {
                    viewModel.acceptAnswer(RTCSessionDescription(
                        json.decode(((await Clipboard.getData('text/plain'))
                            ?.text)!)["sdp"],
                        'answer'));
                  },
                  child: const Text("Accept Answer from clipboard")),
              TextButton(
                  onPressed: () {
                    viewModel.sendMessage("Hello World!");
                  },
                  child: const Text("Send Hello World!"))
            ],
          )),
    );
  }
}
