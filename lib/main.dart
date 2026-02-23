import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/product/presentation/providers/product_provider.dart';
import 'features/user/presentation/providers/user_provider.dart';
import 'features/topup/presentation/providers/topup_history_provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MeetupApp());
}

class MeetupApp extends StatelessWidget {
  const MeetupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<TopUpHistoryProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProductProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserProvider>()),
      ],
      child: MaterialApp(
        title: 'Meetup',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
      ),
    );
  }
}
