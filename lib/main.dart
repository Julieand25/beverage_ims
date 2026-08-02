import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fpupfdeucmaiyqczopyt.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwdXBmZGV1Y21haXlxY3pvcHl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU2NjYzMTYsImV4cCI6MjEwMTI0MjMxNn0.84Us7IE88QqVY0gcJaafZdhgIJdSxHGxBGb77eq_Ppc',
  );
  runApp(const App());
}
