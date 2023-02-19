import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';
import 'package:diary_ai_backend/models/character.dart';

/* 
  Get /question
  Body: {
    name: String,
    desc: String,
    vocab: String,
    characteristics: List<String>,
    sequence: int,
    topic: String,
    userName: String,
    userResponse: String?,
    prevQuestion: String?
  }
  Auth: token required in header

  Example:
  {
    "name": "Nagisa",
    "desc": "Anime character from Clannad",
    "vocab": "Casual, poetic language",
    "characteristics": [
		"",
		"Is a student at Hikarizaka Private High School",
		"Is a member of the school's drama club",
		"Is a shy and timid girl who is often seen as an outsider by her peers",
		"Has a strong admiration for her classmate Tomoya Okazaki, whom she eventually falls in love with",
		"Is the daughter of Akio and Sanae Furukawa, who run the local bakery",
		"Has an older brother named Ushio, who she is very close to",
		"Is known for her catchphrase \"Nagisa desu!\" (I'm Nagisa!)",
		"Often has difficulty expressing her feelings and emotions to others",
		"Is an aspiring actress and singer, often performing in school plays and concerts ",
		"Has a strong sense of justice and morality, often standing up for what she believes is right even when it puts her at odds with those around her ",
		"Develops a close friendship with Tomoyo Sakagami, another student at Hikarizaka Private High School ",
		"Gains the ability to manipulate time after being granted magical powers by the mysterious robot girl Botan ",
		"Often wears a pink ribbon in her hair as part of her signature look ",
		"Is known for being kindhearted and compassionate towards others"
	],
    "sequence": 4,
    "topic": "User's mood",
    "userName": "Kevin",
    "userResponse": "That is all, thank you.",
    "prevQuestion": "It's admirable that you are able to keep going, Kevin. There is no end to the tasks and errands one must attend to when putting their heart into something. Is there anything else you need to take care of today before heading back to the Furukawa Bakery?"
}

*/

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final body = await request.json() as Map<String, dynamic>;
  final character = Character(
    body['name'] as String,
    body['desc'] as String,
    body['vocab'] as String,
    (body['characteristics'] as List<dynamic>)
        .map((e) => e.toString())
        .toList(),
  );
  final res = await OpenAIAPI.responseCompletion(
    character,
    body['sequence'] as int,
    body['topic'] as String,
    body['userName'] as String,
    (body['userResponse'] == null) ? null : body['userResponse'] as String,
    (body['prevQuestion'] == null) ? null : body['prevQuestion'] as String,
  );
  return Response.json(
    body: {'response': res[0], 'prompts': res[1]},
  );
}
