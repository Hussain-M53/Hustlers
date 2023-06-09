import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:synew_gym/.env';
import 'package:synew_gym/app_theme.dart';
import 'package:synew_gym/blocs/auth/bloc/auth_bloc.dart';
import 'package:synew_gym/blocs/auth/repository/auth_repository.dart';
import 'package:synew_gym/blocs/auth_landing/cubit/auth_landing_cubit.dart';
import 'package:synew_gym/blocs/cart/cubit/cart_cubit.dart';
import 'package:synew_gym/blocs/category_toggle/cubit/category_cubit.dart';
import 'package:synew_gym/blocs/chat/bloc/chat_bloc.dart';
import 'package:synew_gym/blocs/chat/repository/message_repository.dart';
import 'package:synew_gym/blocs/date_toggle/cubit/date_toggle_cubit.dart';
import 'package:synew_gym/blocs/friends/bloc/friends_bloc.dart';
import 'package:synew_gym/blocs/friends/repositories/friends_repository.dart';
import 'package:synew_gym/blocs/nutrition/bloc/nutrition_bloc.dart';
import 'package:synew_gym/blocs/nutrition/repository/nutrition_repository.dart';
import 'package:synew_gym/blocs/nutrition/services/nutrition_api_services.dart';
import 'package:synew_gym/blocs/product/bloc/product_bloc.dart';
import 'package:synew_gym/blocs/product/repository/shop_repository.dart';
import 'package:synew_gym/blocs/product/services/sanity_api_services.dart';
import 'package:synew_gym/blocs/profile/cubit/profile_cubit.dart';
import 'package:synew_gym/blocs/profile/repository/user_repository.dart';
import 'package:synew_gym/blocs/signin/cubit/signin_cubit.dart';
import 'package:synew_gym/blocs/signup/cubit/signup_cubit.dart';
import 'package:synew_gym/blocs/tab_bar/cubit/tab_bar_cubit.dart';
import 'package:synew_gym/blocs/workout/cubit/workout_cubit.dart';
import 'package:synew_gym/build_routes.dart';
import 'package:synew_gym/firebase_options.dart';
import 'package:synew_gym/pages/splash_page.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  setPortraitOrientation();
  Stripe.publishableKey = PUBLIC_KEY;
  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void setPortraitOrientation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(
            firebaseAuth: _firebaseAuth,
            firebaseFirestore: _firebaseFirestore,
          ),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) =>
              UserRepository(_firebaseFirestore, _firebaseAuth),
        ),
        RepositoryProvider<FriendsRepository>(
          create: (context) => FriendsRepository(
            _firebaseFirestore,
          ),
        ),
        RepositoryProvider<MessageRepository>(
          create: (context) => MessageRepository(_firebaseFirestore),
        ),
        RepositoryProvider<NutritionRepository>(
          create: (context) => NutritionRepository(
            nutritionApiServices: NutritionApiServices(),
          ),
        ),
        RepositoryProvider<ShopRepository>(
          create: (context) => ShopRepository(
            sanityApiServices: SanityApiServices(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<AuthLandingCubit>(
            create: (context) => AuthLandingCubit(
                authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<SignInCubit>(
            create: (context) =>
                SignInCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<SignUpCubit>(
            create: (context) =>
                SignUpCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) =>
                ProfileCubit(profileRepository: context.read<UserRepository>()),
          ),
          BlocProvider<TabBarCubit>(
            create: (context) => TabBarCubit(),
          ),
          BlocProvider<WorkoutCubit>(
            create: (context) => WorkoutCubit(
              profileCubit: context.read<ProfileCubit>(),
            ),
          ),
          BlocProvider<ChatBloc>(
              create: (context) => ChatBloc(
                    messageRepository: context.read<MessageRepository>(),
                  )),
          BlocProvider<NutritionBloc>(
            create: (context) => NutritionBloc(
              nutritionRepository: context.read<NutritionRepository>(),
            ),
          ),
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              shopRepository: context.read<ShopRepository>(),
            ),
          ),
          BlocProvider<CategoryCubit>(
            create: (context) => CategoryCubit(),
          ),
          BlocProvider<DateToggleCubit>(
            create: (context) => DateToggleCubit(),
          ),
          BlocProvider<CartCubit>(
            create: (context) => CartCubit(),
          ),
          BlocProvider<FriendsBloc>(
            create: (context) => FriendsBloc(
              profileCubit: context.read<ProfileCubit>(),
              friendsRepository: context.read<FriendsRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Hustlers',
          key: key,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          onGenerateRoute: buildRoutes,
          debugShowCheckedModeBanner: false,
          debugShowMaterialGrid: false,
          showPerformanceOverlay: false,
          showSemanticsDebugger: false,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
