import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Profile? _currentProfile;
  Profile? get currentProfile => _currentProfile;

  final ValueNotifier<Profile?> currentProfileNotifier = ValueNotifier<Profile?>(null);

  /// Initializes or retrieves the current active user profile.
  Future<Profile> initializeProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user != null) {
        // Try fetching existing profile
        final response = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          _currentProfile = Profile.fromJson(response);
          currentProfileNotifier.value = _currentProfile;
          return _currentProfile!;
        } else {
          // Create profile for authenticated user
          final newProfile = {
            'id': user.id,
            'name': user.userMetadata?['name'] ?? user.email?.split('@').first ?? 'You',
            'email': user.email ?? 'you@contri.app',
            'created_at': DateTime.now().toIso8601String(),
          };
          await client.from('profiles').insert(newProfile);
          _currentProfile = Profile.fromJson(newProfile);
          currentProfileNotifier.value = _currentProfile;
          return _currentProfile!;
        }
      }

      // If no auth session, check if any profile exists or pick/create the primary default profile
      final profilesRes = await client.from('profiles').select().order('created_at').limit(1);
      if (profilesRes.isNotEmpty) {
        _currentProfile = Profile.fromJson(profilesRes.first);
        currentProfileNotifier.value = _currentProfile;
        return _currentProfile!;
      }

      // Create a default demo profile for the user
      final defaultProfile = {
        'id': '00000000-0000-0000-0000-000000000001',
        'name': 'Aditya Raghav',
        'email': 'aditya@contri.app',
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await client.from('profiles').upsert(defaultProfile);
      } catch (e) {
        debugPrint('Note on profile upsert: $e');
      }

      _currentProfile = Profile.fromJson(defaultProfile);
      currentProfileNotifier.value = _currentProfile;
      return _currentProfile!;
    } catch (e) {
      debugPrint('Error initializing profile: $e');
      _currentProfile = Profile(
        id: '00000000-0000-0000-0000-000000000001',
        name: 'Aditya Raghav',
        email: 'aditya@contri.app',
        createdAt: DateTime.now(),
      );
      currentProfileNotifier.value = _currentProfile;
      return _currentProfile!;
    }
  }
}
