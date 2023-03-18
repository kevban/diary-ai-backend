// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
    @EnviedField(varName: 'OPEN_AI_API_KEY')
    static const apiKey = _Env.apiKey;
    
    @EnviedField(varName: 'MONGODB_URI')
    static const mongodbUri = _Env.mongodbUri;

    @EnviedField(varName: 'JWT_SECRET')
    static const jwtSecret = _Env.jwtSecret;
}

// dart run build_runner build