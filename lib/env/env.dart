// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
    @EnviedField(varName: 'OPEN_AI_API_KEY')
    static const apiKey = _Env.apiKey;
    
    @EnviedField(varName: 'MONGODB_URI')
    static const mongodbUri = _Env.mongodbUri;
}

// dart run build_runner build