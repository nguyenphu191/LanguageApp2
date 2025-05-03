import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:language_app/PhuNV/LoginSignup/login_screen.dart';
import 'package:language_app/provider/exam_provider.dart';
import 'package:language_app/provider/exercise_provider.dart';
import 'package:language_app/provider/language_provider.dart';
import 'package:language_app/provider/notification_provider.dart';
import 'package:language_app/provider/post_provider.dart';
import 'package:language_app/provider/progress_provider.dart';
import 'package:language_app/provider/question_provider.dart';
import 'package:language_app/provider/theme_provider.dart';
import 'package:language_app/provider/auth_provider.dart';
import 'package:language_app/provider/topic_provider.dart';
import 'package:language_app/provider/user_provider.dart';
import 'package:language_app/provider/vocabulary_provider.dart';
import 'package:language_app/res/imagesLA/AppImages.dart';
import 'package:language_app/service/local_notification_service.dart';
import 'package:language_app/utils/baseurl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final localNotificationService = LocalNotificationService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set ErrorWidget.builder outside of the widget tree
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Đã xảy ra lỗi. Vui lòng khởi động lại ứng dụng.',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  // Request permissions
  await Permission.microphone.request();
  await Permission.storage.request();

  // Initialize notifications
  if (!kIsWeb) {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'welcome_channel',
        'Welcome Notifications',
        channelDescription: 'Notifications when app starts',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Chào mừng đến Language App',
        'Bắt đầu học ngoại ngữ ngay hôm nay!',
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExamProvider>(
          create: (context) => ExamProvider(
            baseUrl: UrlUtils.getBaseUrl(),
            authProvider: Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) => ExamProvider(
            baseUrl: UrlUtils.getBaseUrl(),
            authProvider: authProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Language App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: const CustomSplashScreen(), // Thay bằng CustomSplashScreen
        );
      },
    );
  }
}

// Custom Splash Screen Widget
class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Thiết lập các hiệu ứng
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ),
    );

    // Bắt đầu animation
    _animationController.forward();

    // Chuyển màn hình sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if the widget is still in the tree
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pix = size.width / 375;

    return Scaffold(
      key: UniqueKey(), // Add unique key to prevent widget tree conflicts
      // Màu nền splash
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppImages.intro2), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo với hiệu ứng fade + slide
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    AppImages.imgbook,
                    width: 200 * pix,
                    height: 200 * pix,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Text với hiệu ứng fade
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Language App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32 * pix,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'BeVietnamPro',
                  ),
                ),
              ),

              SizedBox(height: 30 * pix),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),

              SizedBox(height: 20 * pix),

              // Text loading
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Đang tải ứng dụng...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16 * pix,
                  ),
                ),
              ),
              SizedBox(height: 30 * pix),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Kiến thức là sức mạnh, hành động là chìa khóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'BeVietnamPro',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Phát triển mỗi ngày, hoàn thiện mỗi giờ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * pix,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'BeVietnamPro',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
