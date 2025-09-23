import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';
import '../features/auth/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Holds the logged-in user
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

/// Login Provider → takes {email, password}, returns UserModel
final loginProvider =
    FutureProvider.family<UserModel, Map<String, String>>((ref, credentials) async {
  final authService = ref.read(authServiceProvider);

  // 1. Call login → get token
  final token = await authService.login(
    credentials['email']!,
    credentials['password']!,
  );

  // 2. Fetch user details with token
  final user = await authService.getMe(token);

  // 3. Store user globally
  ref.read(currentUserProvider.notifier).state = user;

  return user;
});

/// Signup Provider → takes {fullname, email, password}, returns UserModel
final signupProvider =
    FutureProvider.family<UserModel, Map<String, String>>((ref, data) async {
  final authService = ref.read(authServiceProvider);

  // 1. Call signup → just confirm success
  await authService.signup(
    data['fullname']!,
    data['email']!,
    data['password']!,
  );

  // 2. Automatically login after signup
  final token = await authService.login(data['email']!, data['password']!);
  final user = await authService.getMe(token);

  // 3. Store user globally
  ref.read(currentUserProvider.notifier).state = user;

  return user;
});
