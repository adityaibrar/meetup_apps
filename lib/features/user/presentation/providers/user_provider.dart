import 'package:flutter/material.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/update_public_key_usecase.dart';
import '../../domain/usecases/submit_rating_usecase.dart';
import '../../domain/usecases/get_user_ratings_usecase.dart';
import '../../domain/entities/rating_entity.dart';
import 'dart:developer';

class UserProvider with ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  final SearchUsersUseCase searchUsersUseCase;
  final UpdatePublicKeyUseCase updatePublicKeyUseCase;
  final SubmitRatingUseCase submitRatingUseCase;
  final GetUserRatingsUseCase getUserRatingsUseCase;

  UserProvider({
    required this.getUserProfileUseCase,
    required this.searchUsersUseCase,
    required this.updatePublicKeyUseCase,
    required this.submitRatingUseCase,
    required this.getUserRatingsUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  List<RatingEntity> _userRatings = [];
  List<RatingEntity> get userRatings => _userRatings;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> searchUsers(String token, String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _setError(null);

    final result = await searchUsersUseCase(token, query);

    result.fold(
      (failure) {
        _setError(failure.message);
        _searchResults = [];
        log('Error searching users: ${failure.message}');
      },
      (data) {
        _searchResults = data;
      },
    );

    _setLoading(false);
  }

  Future<void> clearSearch() async {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> loadUserProfile(String token, int userId) async {
    _setLoading(true);
    _setError(null);

    final result = await getUserProfileUseCase(token, userId);

    bool isSuccess = false;
    result.fold(
      (failure) {
        _setError(failure.message);
        log('Error loading user profile: ${failure.message}');
      },
      (data) {
        _userProfile = data;
        isSuccess = true;
      },
    );

    _setLoading(false);
    return isSuccess;
  }

  Future<bool> updatePublicKey(String token, String publicKey) async {
    _setLoading(true);
    _setError(null);

    final result = await updatePublicKeyUseCase(token, publicKey);

    bool isSuccess = false;
    result.fold(
      (failure) {
        _setError(failure.message);
        log('Error updating public key: ${failure.message}');
      },
      (_) {
        isSuccess = true;
      },
    );

    _setLoading(false);
    return isSuccess;
  }

  Future<bool> submitRating(
    String token,
    int ratedUserId,
    int score,
    String review,
  ) async {
    _setLoading(true);
    _setError(null);

    final params = SubmitRatingParams(
      ratedUserId: ratedUserId,
      score: score,
      review: review,
    );
    final result = await submitRatingUseCase(token, params);

    bool isSuccess = false;
    result.fold(
      (failure) {
        _setError(failure.message);
        log('Error submitting rating: ${failure.message}');
      },
      (_) {
        isSuccess = true;
      },
    );

    _setLoading(false);
    return isSuccess;
  }

  Future<void> loadUserRatings(String token, int ratedUserId) async {
    _setLoading(true);
    _setError(null);

    final result = await getUserRatingsUseCase(token, ratedUserId);

    result.fold(
      (failure) {
        _setError(failure.message);
        _userRatings = [];
        log('Error loading user ratings: ${failure.message}');
      },
      (data) {
        _userRatings = data;
      },
    );

    _setLoading(false);
  }
}
