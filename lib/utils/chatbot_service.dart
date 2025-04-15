// chatbot_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String openAiApiKey = 'secret'; 
  static const String assemblyAiApiKey = 'secret'; 

  static Future<Map<String, dynamic>> sendMessage({
    required String topic,
    required String initialMessage,
    required List<Map<String, String>> conversationLog,
  }) async {
    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content': 'You are the system, or the chatbot, a debate opponent used to illustrate debate practices. Argue your case using obvious logical fallacies. Here are the specifics of your debate: $topic. The following message in the list is the stance you are going to defend.'
      },
      {
        'role': 'assistant',
        'content': initialMessage
      },
      ...conversationLog,
      {
        'role': 'system',
        'content': '''
        Provide a JSON response in the following format:{ 
        "botMessage": "Your answer to the user here. It should contain an obvious logical fallacy. Admit to the user winning the debate if they correctly point out a fallacy thrice",
        "userFallacy": "return null in most situations here unless the user, in their last message, uses an obvious logical fallacy such as ad hominem, straw man, or red herring, in which case you should return the name of the fallacy.",
        "userFallacyCorrect": return true if a logical fallacy was correctly spotted.
        "goodPoint": return true if the user made a good, valid point against your argument, false otherwise
        } 
        Don't forget that in your message you should use some very obvious fallacy. Make the fallacy clear. Be willing to engage in a conversation but dont allow the user to convince you unless they detect your fallacies three times.
        
        '''
      }
    ];

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String messageContent = data['choices'][0]['message']['content'].trim();
      return jsonDecode(messageContent);
    } else {
      throw Exception('Failed to get response from OpenAI API');
    }
  }

  static Future<Map<String, double>> analyzeSpeech(String transcription, String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a speech analysis assistant. Analyze the following speech based on the criteria of conciseness, logic use, clarity, appeal, and focus. Provide the ratings on a scale of 1 to 10 for each criterion.'
          },
          {
            'role': 'user',
            'content': '''
The prompt for the speech is:
"$prompt"

Speech:
"$transcription"

Response format: JSON with keys 'conciseness', 'logic_use', 'clarity', 'appeal', 'focus' and their respective ratings.
          '''
          }
        ],
        'max_tokens': 150,
        'temperature': 0.7,
      }),
    );

    print('OpenAI Response: ${response.body}'); // Debugging line

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, double> results = Map<String, double>.from(
          jsonDecode(data['choices'][0]['message']['content'].trim()).map((key, value) => MapEntry(key, (value as num).toDouble()))
      );
      return results;
    } else {
      throw Exception('Failed to analyze speech: ${response.body}');
    }
  }

  static Future<String> uploadAudio(File audioFile) async {
    final response = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/upload'),
      headers: {
        'authorization': assemblyAiApiKey,
        'Content-Type': 'application/octet-stream',
      },
      body: audioFile.readAsBytesSync(),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final audioUrl = result['upload_url'];
      if (!audioUrl.startsWith('http')) {
        throw Exception('Invalid audio URL: $audioUrl');
      }
      return audioUrl;
    } else {
      throw Exception('Failed to upload audio: ${response.body}');
    }
  }

  static Future<String> transcribeAudio(String audioUrl) async {
    final response = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/transcript'),
      headers: {
        'authorization': assemblyAiApiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({'audio_url': audioUrl}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final transcriptId = result['id'];
      return await _pollTranscriptionResult(transcriptId);
    } else {
      throw Exception('Failed to transcribe audio: ${response.body}');
    }
  }

  static Future<String> _pollTranscriptionResult(String transcriptId) async {
    final uri = Uri.parse('https://api.assemblyai.com/v2/transcript/$transcriptId');
    while (true) {
      final response = await http.get(uri, headers: {'authorization': assemblyAiApiKey});
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'completed') {
          return result['text'];
        } else if (result['status'] == 'failed') {
          throw Exception('Transcription failed: ${result['error']}');
        }
      } else {
        throw Exception('Error polling transcription result: ${response.body}');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  static Future<Map<String, dynamic>> analyzeTranscription(String transcription) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a speech analysis assistant. Analyze the following transcription for logical fallacies and manipulative tactics. Provide the ratings on a scale of 1 to 100 for each criterion.'
          },
          {
            'role': 'user',
            'content': '''
Analyze the following transcription for logical fallacies and manipulative tactics:
"$transcription"
Return a JSON object with the following structure, providing unique values for the risk probability and severity after analyzing the transcript, also include personalized summaries and descriptions, add any logical fallacies or manipulative tactics to the list as you notice them in the transcript. If a fallacy could be present but doesn't seem to be employed with ill intent or intention to harm, give it a low severity score, otherwise, if it misinforms or leads to potential harm, give it a high one. Recognize the difference between light-hearted banter and intention to misinform and rate them accordingly:
{
  "risk_probability": {a value from 0 to 100},
  "summary": "{A summary of the video's use of manipulation tactics}",
  "tactics": [
    {
      "name": "{A logical fallacy employed in the transcript}",
      "severity": {a value from 0 to 100, showing how severely the fallacy is used},
      "description": "{Short summary of how the tactic is employed in the video}"
    },
    {
      "name": "{A logical fallacy employed in the transcript}",
      "severity": {a value from 0 to 100, showing how severely the fallacy is used},
      "description": "{Short summary of how the tactic is employed in the video}"
    }
    {multiple list elements following the element structure of the list, as appropriate. If the video doesn't contain logical fallacies or manipulative tactics return a risk_probability of 0, and a tactic card with the name "No manipulation tactics employed", a severity of zero, and a description. }
  ]
}
            '''
          }
        ],
        'max_tokens': 800,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return jsonDecode(data['choices'][0]['message']['content'].trim());
    } else {
      throw Exception('Failed to analyze transcription: ${response.body}');
    }
  }
}
