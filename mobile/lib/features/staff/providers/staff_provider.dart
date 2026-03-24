import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../data/staff_repository.dart';
import '../data/visit_model.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.watch(apiClientProvider).dio);
});

// ---------------------------------------------------------------------------
// Visits state
// ---------------------------------------------------------------------------

class VisitsState {
  final List<VisitModel> visits;
  final bool isLoading;
  final String? error;

  const VisitsState({
    this.visits = const [],
    this.isLoading = false,
    this.error,
  });

  VisitsState copyWith({
    List<VisitModel>? visits,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return VisitsState(
      visits: visits ?? this.visits,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Visits notifier
// ---------------------------------------------------------------------------

class VisitsNotifier extends StateNotifier<VisitsState> {
  final StaffRepository _repository;

  VisitsNotifier(this._repository) : super(const VisitsState());

  Future<void> loadVisits({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final visits = await _repository.getVisits(page: page);
      state = VisitsState(visits: visits);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadVisits();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('error')) {
      return data['error'] as String;
    }
    if (e.response?.statusCode == 401) {
      return 'Unauthorized. Please sign in again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final visitsProvider =
    StateNotifierProvider<VisitsNotifier, VisitsState>((ref) {
  return VisitsNotifier(ref.watch(staffRepositoryProvider));
});

// ---------------------------------------------------------------------------
// Check-in state
// ---------------------------------------------------------------------------

class CheckInState {
  final bool isLoading;
  final Map<String, dynamic>? result;
  final String? error;

  const CheckInState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  CheckInState copyWith({
    bool? isLoading,
    Map<String, dynamic>? result,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Check-in notifier
// ---------------------------------------------------------------------------

class CheckInNotifier extends StateNotifier<CheckInState> {
  final StaffRepository _repository;

  CheckInNotifier(this._repository) : super(const CheckInState());

  Future<void> performCheckIn({
    required String qrCode,
    required String serviceName,
    required int amountCents,
  }) async {
    state = const CheckInState(isLoading: true);

    try {
      final result = await _repository.checkIn(
        qrCode: qrCode,
        serviceName: serviceName,
        amountCents: amountCents,
      );
      state = CheckInState(result: result);
    } on DioException catch (e) {
      state = CheckInState(error: _extractError(e));
    } catch (e) {
      state = CheckInState(error: e.toString());
    }
  }

  void reset() {
    state = const CheckInState();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('error')) {
      return data['error'] as String;
    }
    if (e.response?.statusCode == 404) {
      return 'Customer not found. Invalid QR code.';
    }
    if (e.response?.statusCode == 422) {
      return 'Check-in failed. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final checkInProvider =
    StateNotifierProvider<CheckInNotifier, CheckInState>((ref) {
  return CheckInNotifier(ref.watch(staffRepositoryProvider));
});
