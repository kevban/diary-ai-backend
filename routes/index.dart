import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(statusCode: 404, body: {'message': 'not found'});
}
