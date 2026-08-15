import 'team.dart';

enum MatchOutcome { win, lose, draw }

class MatchResult {
  final Team playerTeam;
  final Team opponentTeam;
  final int playerScore;
  final int opponentScore;

  const MatchResult({
    required this.playerTeam,
    required this.opponentTeam,
    required this.playerScore,
    required this.opponentScore,
  });

  MatchOutcome get outcome {
    if (playerScore > opponentScore) return MatchOutcome.win;
    if (playerScore < opponentScore) return MatchOutcome.lose;
    return MatchOutcome.draw;
  }

  String get outcomeText {
    switch (outcome) {
      case MatchOutcome.win:
        return 'YOU WIN!';
      case MatchOutcome.lose:
        return 'YOU LOSE';
      case MatchOutcome.draw:
        return 'DRAW';
    }
  }
}
