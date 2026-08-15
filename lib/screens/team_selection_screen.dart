import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/teams.dart';
import '../models/team.dart';
import '../widgets/team_card.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  Team? selectedPlayerTeam;
  Team? selectedOpponentTeam;
  int _playerTeamIndex = 0;
  int _opponentTeamIndex = 1;

  List<Team> get teams => TeamsData.allTeams;

  List<Team> get availableOpponents {
    return teams.where((t) => t.id != selectedPlayerTeam?.id).toList();
  }

  @override
  void initState() {
    super.initState();
    selectedPlayerTeam = teams[_playerTeamIndex];
    selectedOpponentTeam = teams[_opponentTeamIndex];
  }

  void _nextPlayerTeam() {
    setState(() {
      _playerTeamIndex = (_playerTeamIndex + 1) % teams.length;
      selectedPlayerTeam = teams[_playerTeamIndex];
      // Ensure opponent is different
      if (selectedOpponentTeam?.id == selectedPlayerTeam?.id) {
        _opponentTeamIndex = (_opponentTeamIndex + 1) % teams.length;
        selectedOpponentTeam = teams[_opponentTeamIndex];
      }
    });
  }

  void _prevPlayerTeam() {
    setState(() {
      _playerTeamIndex = (_playerTeamIndex - 1 + teams.length) % teams.length;
      selectedPlayerTeam = teams[_playerTeamIndex];
      if (selectedOpponentTeam?.id == selectedPlayerTeam?.id) {
        _opponentTeamIndex = (_opponentTeamIndex + 1) % teams.length;
        selectedOpponentTeam = teams[_opponentTeamIndex];
      }
    });
  }

  void _nextOpponentTeam() {
    setState(() {
      _opponentTeamIndex = (_opponentTeamIndex + 1) % teams.length;
      selectedOpponentTeam = teams[_opponentTeamIndex];
      if (selectedOpponentTeam?.id == selectedPlayerTeam?.id) {
        _opponentTeamIndex = (_opponentTeamIndex + 1) % teams.length;
        selectedOpponentTeam = teams[_opponentTeamIndex];
      }
    });
  }

  void _prevOpponentTeam() {
    setState(() {
      _opponentTeamIndex = (_opponentTeamIndex - 1 + teams.length) % teams.length;
      selectedOpponentTeam = teams[_opponentTeamIndex];
      if (selectedOpponentTeam?.id == selectedPlayerTeam?.id) {
        _opponentTeamIndex = (_opponentTeamIndex - 1 + teams.length) % teams.length;
        selectedOpponentTeam = teams[_opponentTeamIndex];
      }
    });
  }

  void _startMatch() {
    if (selectedPlayerTeam != null && selectedOpponentTeam != null) {
      Navigator.pushNamed(
        context,
        '/game',
        arguments: {
          'playerTeam': selectedPlayerTeam,
          'opponentTeam': selectedOpponentTeam,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkGreen,
              AppTheme.primaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppTheme.white),
                    ),
                    const Expanded(
                      child: Text(
                        'SELECT TEAMS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Your Team Section
              const Text(
                'YOUR TEAM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.yellow,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildTeamSelector(
                team: selectedPlayerTeam!,
                onPrev: _prevPlayerTeam,
                onNext: _nextPlayerTeam,
              ),

              const SizedBox(height: 32),

              // VS Divider
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.white,
                    letterSpacing: 4,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Opponent Team Section
              const Text(
                'OPPONENT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.yellow,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildTeamSelector(
                team: selectedOpponentTeam!,
                onPrev: _prevOpponentTeam,
                onNext: _nextOpponentTeam,
              ),

              const Spacer(),

              // Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yellow,
                      foregroundColor: AppTheme.black,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_soccer, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'START MATCH',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSelector({
    required Team team,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left, color: AppTheme.white, size: 36),
        ),
        const SizedBox(width: 8),
        TeamCard(team: team),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, color: AppTheme.white, size: 36),
        ),
      ],
    );
  }
}
