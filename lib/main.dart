import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/pages/auth_checker.dart';
import 'providers/carrinho_emprestimo_provider.dart';
import 'providers/bloco_provider.dart';
import 'firebase_options.dart';
import 'utils/brasilia_time.dart';
import 'utils/app_colors.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  // timezone de brasilia
  BrasiliaTime.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CarrinhoEmprestimo()),
        ChangeNotifierProvider(create: (context) => BlocoProvider()),
      ],
      child: MaterialApp(
        title: 'LabMovel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: AppColors.primary,
            onPrimary: AppColors.textWhite,
            secondary: AppColors.primary,
            onSecondary: AppColors.textWhite,
            error: AppColors.error,
            onError: AppColors.textWhite,
            surface: AppColors.textWhite,
            onSurface: AppColors.primary,
            background: AppColors.background,
            onBackground: AppColors.primary,
          ),
          fontFamily: 'Avignon',
        ),
        home: const AuthChecker(),
      ),
    );
  }
}
