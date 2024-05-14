import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Audio Player')),
        body: Center(child: PlayAudio()),
      ),
    );
  }
}

class PlayAudio extends StatefulWidget {
  @override
  _PlayAudioState createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  AudioPlayer audioPlayer = AudioPlayer();
  String? audioUrl;

  @override
  void initState() {
    super.initState();
    fetchAudioUrl().then((url) {
      setState(() {
        audioUrl = url;
      });
      audioPlayer.play(UrlSource(audioUrl!));
    });
  }

  Future<String?> fetchAudioUrl() async {
    final apiKey =
    dotenv.env['INTERNAL_API_KEY']; // YouTube Web Music API Key
    final videoId =
        'JGwWNGJdvx8'; // Replace with the video ID of the song you want to play
    final response = await http.post(
      Uri.parse('https://www.youtube.com/youtubei/v1/player?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36 Edg/105.0.1343.42',
        'Accept': '*/*',
        'Origin': 'https://www.youtube.com',
        'Referer': 'https://www.youtube.com/',
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'de,de-DE;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6'
      },
      body: jsonEncode({
        "context": {
          "client": {
            "hl": "en",
            "gl": "US",
            "clientName": "ANDROID_CREATOR",
            "clientVersion": "22.36.102",
            "clientScreen": "WATCH",
            "androidSdkVersion": 31
          },
          "thirdParty": {"embedUrl": "https://www.youtube.com/"}
        },
        "videoId": videoId, // Change this to the desired YouTube video ID
        "playbackContext": {
          "contentPlaybackContext": {"signatureTimestamp": 19250}
        },
        "racyCheckOk": true,
        "contentCheckOk": true
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // print(jsonResponse);
      final audioFormats = jsonResponse['streamingData']['adaptiveFormats'];
      final audioUrl = audioFormats.firstWhere((format) =>
      format['mimeType'].contains('audio') &&
          format['audioQuality'] == 'AUDIO_QUALITY_MEDIUM')['url'];
      print(audioUrl);
      return audioUrl;
    } else {
      throw Exception('Failed to load audio URL');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Playing audio...'),
        ElevatedButton(
          onPressed: () async {
            await audioPlayer.pause();
            setState(() {});
          },
          child: Text('Pause'),
        ),
        ElevatedButton(
          onPressed: () async {
            await audioPlayer.resume();
            setState(() {});
          },
          child: Text('Resume'),
        ),
      ],
    );
  }
}