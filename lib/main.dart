import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _apiText = '';
  List<Map<String, String>> apiTextList = [];
  final String? _apiKey = '';
  String serachText = '';
  List<String> serachTextList = [];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Builder(builder: (context) {
                  final text = _apiText;
                  if (text == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        controller: _scrollController,
                        physics: const NeverScrollableScrollPhysics(), // 追加
                        itemCount: apiTextList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: const Text('You'),
                                subtitle: Text('Answer: ${apiTextList[index]['user']}'),
                                leading: const Icon(Icons.person_pin),
                                isThreeLine: true,
                              ),
                              ListTile(
                                leading: const Icon(Icons.android_sharp),
                                title: const Text('ChatGPT'),
                                subtitle: Text('Answer: ${apiTextList[index]['assistant']}'),
                                isThreeLine: true,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '検索したいテキスト',
                    ),
                    onChanged: (text) {
                      serachText = text;
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed:  () async {
                      await callAPI();
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      _controller.clear();
                    },
                    child: const Text('検索')),
              ],
            ),
          ),
        ),
      );
  }
  Future<void> callAPI() async {

    setState(() {
      _apiText = null;
    });

    final response = await http
        .post(Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(<String, dynamic>{
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": serachText},
          // // 初回のAPI呼び出し時は空文字列
          {"role": "assistant", "content": _apiText ?? ''},
        ]
      },),
    );

    final body = response.bodyBytes;
    final jsonString = utf8.decode(body);
    final json = jsonDecode(jsonString);
    final context = json['choices'][0]['message']['content'];

    // 質問と回答の履歴を追加
    apiTextList.add({"user": serachText, "assistant": context});

    setState(() {
      serachText = '';
      _apiText = context;
    });
  }
}