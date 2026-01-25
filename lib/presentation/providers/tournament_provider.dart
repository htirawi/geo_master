import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tournament_repository.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/i_user_repository.dart';

/// Provider for the tournament repository
final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return LocalTournamentRepository();
});

/// Provider for active tournament
final activeTournamentProvider = FutureProvider<Tournament?>((ref) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.getActiveTournament();
});

/// Stream provider for active tournament updates
final activeTournamentStreamProvider = StreamProvider<Tournament?>((ref) {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.watchActiveTournament();
});

/// Provider for upcoming tournaments
final upcomingTournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.getUpcomingTournaments();
});

/// Provider for past tournaments
final pastTournamentsProvider =
    FutureProvider.family<List<Tournament>, int>((ref, limit) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.getPastTournaments(limit: limit);
});

/// Provider for tournament by ID
final tournamentByIdProvider =
    FutureProvider.family<Tournament?, String>((ref, tournamentId) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.getTournamentById(tournamentId);
});

/// Provider for tournament leaderboard
final tournamentLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>(
        (ref, tournamentId) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.getTournamentLeaderboard(tournamentId);
});

/// Stream provider for tournament leaderboard updates
final tournamentLeaderboardStreamProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>(
        (ref, tournamentId) {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.watchTournamentLeaderboard(tournamentId);
});

/// Provider for checking user participation
final isUserParticipatingProvider =
    FutureProvider.family<bool, TournamentParticipationKey>(
        (ref, key) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.isUserParticipating(key.userId, key.tournamentId);
});

/// Provider for user's tournament rank
final userTournamentRankProvider =
    FutureProvider.family<int?, TournamentParticipationKey>((ref, key) async {
  final repository = ref.read(tournamentRepositoryProvider);
  return repository.getUserTournamentRank(key.userId, key.tournamentId);
});

/// Key for tournament participation providers
class TournamentParticipationKey {
  const TournamentParticipationKey({
    required this.userId,
    required this.tournamentId,
  });

  final String userId;
  final String tournamentId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TournamentParticipationKey &&
        other.userId == userId &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode => userId.hashCode ^ tournamentId.hashCode;
}

/// State notifier for tournament actions
class TournamentActionsNotifier extends StateNotifier<AsyncValue<void>> {
  TournamentActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  final TournamentRepository _repository;

  Future<void> joinTournament(String userId, String tournamentId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.joinTournament(userId, tournamentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> leaveTournament(String userId, String tournamentId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.leaveTournament(userId, tournamentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateScore(
    String userId,
    String tournamentId,
    int xpEarned,
  ) async {
    try {
      await _repository.updateTournamentScore(userId, tournamentId, xpEarned);
    } catch (_) {
      // Silently ignore score update failures
    }
  }
}

/// Provider for tournament actions
final tournamentActionsProvider =
    StateNotifierProvider<TournamentActionsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(tournamentRepositoryProvider);
  return TournamentActionsNotifier(repository);
});
