class SupabaseConfig {
  static const String supabaseUrl = 'https://ksjvnbgmnmadmkrgdxrm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzanZuYmdtbm1hZG1rcmdkeHJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NjcyMTAsImV4cCI6MjA5MDU0MzIxMH0.-XRblKKzQ6Eqhn4wbzP4kUNt0n88Zxf7IEPIPrgs-HA';

  // Deep link scheme for Google OAuth callback
  // Must match what you put in Supabase dashboard → Auth → URL Configuration
  static const String redirectUrl =
      'io.supabase.drivingautosilencer://login-callback';
}