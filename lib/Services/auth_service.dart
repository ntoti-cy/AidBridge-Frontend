class AuthService {
  // LOGIN
  Future<String> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    // Simulated token
    return 'mock_access_token_123';
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required');
    }

    return {
      'id': 1,
      'name': name,
      'email': email,
    };
  }
}
