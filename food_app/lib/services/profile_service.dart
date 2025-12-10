import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  /// Load user profile data from Supabase
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  /// Update avatar URL in Supabase
  Future<void> updateAvatar(String imageUrl) async {
    final uid = supabase.auth.currentUser!.id;

    await supabase.from('profiles').update({
      'avatar_url': imageUrl,
    }).eq('id', uid);
  }

  /// Optional: Update name
  Future<void> updateName(String newName) async {
    final uid = supabase.auth.currentUser!.id;

    await supabase.from('profiles').update({
      'name': newName,
    }).eq('id', uid);
  }
}
