import 'package:dart_frog/dart_frog.dart';
import 'package:diary_ai_backend/api/open_ai_api.dart';

/* 
  Get /diary/generate
  Body: {
    conversation: String,
    userName: String
  }
  Auth: token required in header
  Example: {
	"diaryPrompt" : "User's day: Working on a new application built in flutter, but progress was slow.\nUser's mood: Not the best.\nUser's thoughts: Wishing they had a magical power to travel back in time, and realizing that when they work on something they love, it becomes easier.",
	"userName": "Kevin"
}
*/

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  switch (request.method.value) {
    case 'POST':
      final body = await request.formData();
      final res = await OpenAIAPI.diaryCompletion(
        body['diaryPrompt']!,
        body['userName']!,
      );
      return Response.json(
        body: {'response': res[0], 'prompts': res[1]},
      );
    default:
      return Response.json(statusCode: 404, body: {'message': 'not found'});
  }
}
