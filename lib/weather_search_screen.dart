import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherSearchScreen extends StatefulWidget {
  const WeatherSearchScreen({
    super.key,
    required this.searchPosition,
  });

  final void Function(double, double) searchPosition;

  @override
  State<WeatherSearchScreen> createState() => _WeatherSearchScreenState();
}

class _WeatherSearchScreenState extends State<WeatherSearchScreen> {
  final TextEditingController _textController = TextEditingController();
  List<dynamic> list = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void backScreen() {
    Navigator.pop(context);
  }

  void _searchAddress(String value) async {
    const key = 'df37cacb011f29e6c0c23798b26c40c3';
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/address.json?query=$value&page=1&size=15&analyze_type=similar');
    final response =
        await http.get(url, headers: {"Authorization": "KakaoAK $key"});
    final resData = json.decode(response.body);

    setState(() {
      list = resData['documents'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: backScreen,
          icon: const Icon(Icons.arrow_back),
          color: Colors.deepPurple,
        ),
        title: const Text(
          '주소검색',
          style: TextStyle(
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Theme.of(context).colorScheme.inversePrimary,
        width: double.infinity,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: 42),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.deepPurple),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.deepPurple.withOpacity(0.6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple.withOpacity(0.6),
                            width: 1.0,
                          ),
                        ),
                        hintText: '검색 키워드를 입력해주세요',
                        hintStyle: TextStyle(
                          color: Colors.deepPurple.withOpacity(0.6),
                        ),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                alignment: Alignment.centerRight,
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.deepPurple.withOpacity(0.4),
                                ),
                                onPressed: () {
                                  _textController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      _searchAddress(_textController.text);
                    },
                    child: const Text(
                      '검색',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (list.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        widget.searchPosition(
                          double.tryParse(list[index]['y']) ?? 0.0,
                          double.tryParse(list[index]['x']) ?? 0.0,
                        );
                        backScreen();
                      },
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                            border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: Colors.deepPurple.withOpacity(0.4)),
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              list[index]['address_name'],
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'X : ${list[index]['x']}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Y : ${list[index]['y']}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
