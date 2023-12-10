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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  Builder(builder: (context) {
                    final text = _apiText;
                    if (text == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                    shrinkWrap: true, // 追加
                    physics: const NeverScrollableScrollPhysics(), // 追加
                    itemCount: apiTextList.length,
                    itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('You: ${apiTextList[index]['user']}'),
                      subtitle: Text('Answer: ${apiTextList[index]['assistant']}'),
                      );
                    },
                    );
                    },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: '検索したいテキスト',
                      ),
                      onChanged: (text) {
                        serachText = text;
                      },
                    ),
                ElevatedButton(
                    onPressed:  () async => await callAPI(),
                    child: const Text('検索')),
              ],
            ),
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
      _apiText = context;
    });
  }
}




