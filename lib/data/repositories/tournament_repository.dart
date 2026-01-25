import '../../domain/entities/tournament.dart';
import '../../domain/repositories/i_user_repository.dart';

/// Repository interface for tournaments
abstract class TournamentRepository {
  /// Get active tournament
  Future<Tournament?> getActiveTournament();

  /// Get upcoming tournaments
  Future<List<Tournament>> getUpcomingTournaments();

  /// Get past tournaments
  Future<List<Tournament>> getPastTournaments({int limit = 10});

  /// Get tournament by ID
  Future<Tournament?> getTournamentById(String tournamentId);

  /// Join a tournament
  Future<void> joinTournament(String userId, String tournamentId);

  /// Leave a tournament (before it starts)
  Future<void> leaveTournament(String userId, String tournamentId);

  /// Get tournament leaderboard
  Future<List<LeaderboardEntry>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 100,
  });

  /// Get user's rank in tournament
  Future<int?> getUserTournamentRank(String userId, String tournamentId);

  /// Update user's score in tournament
  Future<void> updateTournamentScore(
    String userId,
    String tournamentId,
    int xpEarned,
  );

  /// Watch tournament leaderboard updates
  Stream<List<LeaderboardEntry>> watchTournamentLeaderboard(
    String tournamentId,
  );

  /// Watch active tournament
  Stream<Tournament?> watchActiveTournament();

  /// Check if user is participating in tournament
  Future<bool> isUserParticipating(String userId, String tournamentId);
}

/// Local implementation of tournament repository
class LocalTournamentRepository implements TournamentRepository {
  LocalTournamentRepository();

  // In-memory storage
  final Map<String, Tournament> _tournaments = {};
  final Map<String, Set<String>> _participants = {}; // tournamentId -> userIds
  final Map<String, Map<String, int>> _scores = {}; // tournamentId -> userId -> score

  // Initialize with sample tournaments
  bool _initialized = false;

  void _initializeIfNeeded() {
    if (_initialized) return;
    _initialized = true;

    final now = DateTime.now();
    final weekStart = _getWeekStart(now);

    // Create sample weekly tournament (active)
    final weeklyTournament = TournamentGenerator.generateWeeklyTournament(
      weekStart: weekStart,
    ).copyWith(status: TournamentStatus.active);

    // Create sample monthly tournament
    final monthlyTournament = TournamentGenerator.generateMonthlyTournament(
      year: now.year,
      month: now.month,
    );

    // Create upcoming continent tournament
    final nextWeekStart = weekStart.add(const Duration(days: 7));
    final continentTournament = TournamentGenerator.generateWeeklyTournament(
      weekStart: nextWeekStart,
      continent: 'Africa',
    );

    _tournaments[weeklyTournament.id] = weeklyTournament;
    _tournaments[monthlyTournament.id] = monthlyTournament;
    _tournaments[continentTournament.id] = continentTournament;
  }

  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  @override
  Future<Tournament?> getActiveTournament() async {
    _initializeIfNeeded();
    try {
      return _tournaments.values.firstWhere(
        (t) => t.status == TournamentStatus.active,
      );
    } catch (_) {
      // No active tournament
      return null;
    }
  }

  @override
  Future<List<Tournament>> getUpcomingTournaments() async {
    _initializeIfNeeded();
    return _tournaments.values
        .where((t) => t.status == TournamentStatus.upcoming)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  @override
  Future<List<Tournament>> getPastTournaments({int limit = 10}) async {
    _initializeIfNeeded();
    final past = _tournaments.values
        .where((t) => t.status == TournamentStatus.completed)
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    return past.take(limit).toList();
  }

  @override
  Future<Tournament?> getTournamentById(String tournamentId) async {
    _initializeIfNeeded();
    return _tournaments[tournamentId];
  }

  @override
  Future<void> joinTournament(String userId, String tournamentId) async {
    _initializeIfNeeded();
    final tournament = _tournaments[tournamentId];
    if (tournament == null) {
      throw Exception('Tournament not found');
    }

    if (tournament.status != TournamentStatus.upcoming &&
        tournament.status != TournamentStatus.active) {
      throw Exception('Cannot join tournament that is not open');
    }

    _participants.putIfAbsent(tournamentId, () => {});
    _participants[tournamentId]!.add(userId);

    _scores.putIfAbsent(tournamentId, () => {});
    _scores[tournamentId]![userId] = 0;

    // Update participant count
    _tournaments[tournamentId] = tournament.copyWith(
      participantCount: _participants[tournamentId]!.length,
    );
  }

  @override
  Future<void> leaveTournament(String userId, String tournamentId) async {
    _initializeIfNeeded();
    final tournament = _tournaments[tournamentId];
    if (tournament == null) return;

    if (tournament.status != TournamentStatus.upcoming) {
      throw Exception('Can only leave upcoming tournaments');
    }

    _participants[tournamentId]?.remove(userId);
    _scores[tournamentId]?.remove(userId);

    _tournaments[tournamentId] = tournament.copyWith(
      participantCount: _participants[tournamentId]?.length ?? 0,
    );
  }

  @override
  Future<List<LeaderboardEntry>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 100,
  }) async {
    _initializeIfNeeded();
    final scores = _scores[tournamentId] ?? {};

    // Create entries with temporary rank 0
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Create ranked leaderboard entries
    final rankedEntries = <LeaderboardEntry>[];
    for (var i = 0; i < sortedEntries.length && i < limit; i++) {
      final entry = sortedEntries[i];
      rankedEntries.add(LeaderboardEntry(
        oduserId: entry.key,
        displayName: 'Player ${entry.key.substring(0, 4)}',
        totalXp: entry.value,
        level: 1 + entry.value ~/ 1000,
        rank: i + 1,
        countriesLearned: 0,
      ));
    }

    return rankedEntries;
  }

  @override
  Future<int?> getUserTournamentRank(
      String userId, String tournamentId) async {
    final leaderboard = await getTournamentLeaderboard(tournamentId);
    final userEntry =
        leaderboard.where((e) => e.oduserId == userId).firstOrNull;
    return userEntry?.rank;
  }

  @override
  Future<void> updateTournamentScore(
    String userId,
    String tournamentId,
    int xpEarned,
  ) async {
    _initializeIfNeeded();
    if (!(_participants[tournamentId]?.contains(userId) ?? false)) {
      throw Exception('User is not participating in this tournament');
    }

    _scores.putIfAbsent(tournamentId, () => {});
    _scores[tournamentId]![userId] =
        (_scores[tournamentId]![userId] ?? 0) + xpEarned;
  }

  @override
  Stream<List<LeaderboardEntry>> watchTournamentLeaderboard(
    String tournamentId,
  ) async* {
    yield await getTournamentLeaderboard(tournamentId);
  }

  @override
  Stream<Tournament?> watchActiveTournament() async* {
    yield await getActiveTournament();
  }

  @override
  Future<bool> isUserParticipating(
      String userId, String tournamentId) async {
    _initializeIfNeeded();
    return _participants[tournamentId]?.contains(userId) ?? false;
  }
}
