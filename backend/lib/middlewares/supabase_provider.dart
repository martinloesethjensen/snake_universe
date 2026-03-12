import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart';

Middleware supabaseProvider(SupabaseClient supabase) {
  return provider<SupabaseClient>((_) => supabase);
}
