import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/chatgpt_api.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';

/* 
  POST /diary/extract
  Body: {
    conversation: String,
    topics: String (topic1||topic2||...)
  }
  Auth: token required in header
  Example: {
	"conversation" : "Nagisa: Good day, Kevin! How has your day been? (smiling warmly) I'm sure it's been as wonderful as Tomoyo's.\nUser: Hello! My day has not been the best to be honest\nNagisa: Oh no, it can't be that bad. At least you haven't had as busy a day as my parents in the bakery! (Smiles) Tell me more about your day, if you'd like.\nUser: I was working all day on a new application bulit in flutter. However, the progress has been qutie slow\nNagisa: Maybe things weren't so tough because you have a friend or loved one to help you? I know my brother Ushio is always by my side whenever I'm feeling overwhelmed. Did you have someone to help you?\nUser: no, too bad no one is by my side on this one. I just have to focus and push through\nNagisa: You can always count on that special someone, even if they're not in the room with you. When I'm feeling overwhelmed, I often think of my pink ribbon that I wear in my hair. It reminds me that no matter what I'm dealing with, I can always find strength within myself. Do you have a token like that, Kevin?\nUser: Well, I have a collection of songs when I listen to whenever I need motivation.\nNagisa: Your collection of songs must provide you with the courage to face any challenge. I know that I'm lucky enough to be able to manipulate time in difficult situations. Do you have a magical power that you can rely on, Kevin?\nUser: I sure wish I have magical power. Sometimes I think about what I could do if I can travel back in time. But thinking about that fills me with determination that I must value what time I have in the present.\nNagisa: It sounds like you have a strong sense of justice and morality, Kevin. Do you ever find yourself standing up for what you believe is right even when it puts you at odds with those around you?\nUser: Sometimes, but other times I choose to ignore because it is easier that way.\nNagisa: That must be difficult, Kevin, but it is admirable that you are able to stand up for what you believe in. Are there any other errands or tasks you need to tend to this day before returning to the Furukawa Bakery?\nUser: Yes, I also want to note that I realized that when I am working on something I love, it actually becomes so much easier. For example, I was able to get through 8 work sessions today while working on the flutter app.\nNagisa: It's admirable that you are able to keep going, Kevin. There is no end to the tasks and errands one must attend to when putting their heart into something. Is there anything else you need to take care of today before heading back to the Furukawa Bakery?\nUser: That is all for today, thank you.\nNagisa: Nagisa desu! If there is nothing else, I wish you a wonderful day. Be sure to take care, Kevin!",
	"topics": [
		"User's day",
		"User's mood",
		"User's thoughts"
	],
	"charName": "Nagisa"
}
*/

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  switch (request.method.value) {
    case 'POST':
      final body = await request.json();
      final res = await ChatGPTAPI.contentExtraction(
          conversation: body['conversation'] as String,
          topics: body['topics'] as List<dynamic>,
          userName: body['userName'] as String,);
      return Response.json(
        body: res,
      );
    default:
      return Response.json(statusCode: 404, body: {'error': 'not found'});
  }
}
