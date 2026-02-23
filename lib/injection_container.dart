import 'package:get_it/get_it.dart';
import 'core/services/api_service.dart';
import 'features/chat/data/datasources/encryption_service.dart';

// --- TopUp Feature ---
import 'features/topup/data/datasources/topup_remote_datasource.dart';
import 'features/topup/data/repositories/topup_repository_impl.dart';
import 'features/topup/domain/repositories/topup_repository.dart';
import 'features/topup/domain/usecases/get_topup_history_usecase.dart';
import 'features/topup/presentation/providers/topup_history_provider.dart';

// --- Auth Feature ---
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/update_public_key_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// --- Product Feature ---
import 'features/product/data/datasources/product_remote_datasource.dart';
import 'features/product/data/datasources/product_remote_datasource_impl.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/create_product_usecase.dart';
import 'features/product/domain/usecases/delete_product_usecase.dart';
import 'features/product/domain/usecases/get_categories_usecase.dart';
import 'features/product/domain/usecases/get_my_products_usecase.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/domain/usecases/update_product_usecase.dart';
import 'features/product/presentation/providers/product_provider.dart';

// --- Chat Feature ---
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/datasources/chat_remote_datasource_impl.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/delete_chat_usecase.dart';
import 'features/chat/domain/usecases/get_my_chats_usecase.dart';
import 'features/chat/domain/usecases/get_room_status_usecase.dart';
import 'features/chat/domain/usecases/init_private_chat_usecase.dart';
import 'features/chat/domain/usecases/toggle_meetup_ready_usecase.dart';
import 'features/chat/domain/usecases/upload_chat_media_usecase.dart';
import 'features/chat/domain/usecases/download_chat_media_usecase.dart';
import 'features/chat/presentation/providers/chat_provider.dart';

// --- User Feature ---
import 'features/user/data/datasources/user_remote_datasource.dart';
import 'features/user/data/datasources/user_remote_datasource_impl.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/repositories/user_repository.dart';
import 'features/user/domain/usecases/get_user_profile_usecase.dart';
import 'features/user/domain/usecases/search_users_usecase.dart';
import 'features/user/domain/usecases/update_public_key_usecase.dart'
    as user_usecase;
import 'features/user/presentation/providers/user_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Core ---
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<EncryptionService>(() => EncryptionService());

  // --- Features ---
  _initAuthFeature();
  _initProductFeature();
  _initChatFeature();
  _initUserFeature();
  _initTopUpFeature();
}

void _initAuthFeature() {
  // Provider
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      registerUseCase: sl(),
      updatePublicKeyUseCase: sl(),
      encryptionService: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePublicKeyUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: sl()),
  );
}

void _initProductFeature() {
  // Provider
  sl.registerFactory(
    () => ProductProvider(
      getProductsUseCase: sl(),
      getMyProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      createProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiService: sl()),
  );
}

void _initChatFeature() {
  // Provider
  sl.registerFactory(
    () => ChatProvider(
      getMyChatsUseCase: sl(),
      initPrivateChatUseCase: sl(),
      getRoomStatusUseCase: sl(),
      toggleMeetupReadyUseCase: sl(),
      deleteChatUseCase: sl(),
      uploadChatMediaUseCase: sl(),
      downloadChatMediaUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetMyChatsUseCase(sl()));
  sl.registerLazySingleton(() => InitPrivateChatUseCase(sl()));
  sl.registerLazySingleton(() => GetRoomStatusUseCase(sl()));
  sl.registerLazySingleton(() => ToggleMeetupReadyUseCase(sl()));
  sl.registerLazySingleton(() => DeleteChatUseCase(sl()));
  sl.registerLazySingleton(() => UploadChatMediaUseCase(sl()));
  sl.registerLazySingleton(() => DownloadChatMediaUseCase());

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(apiService: sl()),
  );
}

void _initUserFeature() {
  // Provider
  sl.registerFactory(
    () => UserProvider(
      getUserProfileUseCase: sl(),
      searchUsersUseCase: sl(),
      updatePublicKeyUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));
  sl.registerLazySingleton(() => user_usecase.UpdatePublicKeyUseCase(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiService: sl()),
  );
}

void _initTopUpFeature() {
  // Provider
  sl.registerFactory(() => TopUpHistoryProvider(getTopUpHistoryUseCase: sl()));

  // UseCase
  sl.registerLazySingleton(() => GetTopUpHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TopUpRepository>(
    () => TopUpRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<TopUpRemoteDataSource>(
    () => TopUpRemoteDataSourceImpl(apiService: sl()),
  );
}
