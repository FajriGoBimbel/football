import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamsData {
  static const List<Team> allTeams = [
    Team(
      id: 'indonesia',
      name: 'Indonesia',
      shortName: 'IND',
      flag: '🇮🇩',
      primaryColor: Color(0xFFD32F2F),
      secondaryColor: Color(0xFFFFFFFF),
    ),
    Team(
      id: 'brazil',
      name: 'Brazil',
      shortName: 'BRA',
      flag: '🇧🇷',
      primaryColor: Color(0xFFFFC107),
      secondaryColor: Color(0xFF1B5E20),
    ),
    Team(
      id: 'argentina',
      name: 'Argentina',
      shortName: 'ARG',
      flag: '🇦🇷',
      primaryColor: Color(0xFF42A5F5),
      secondaryColor: Color(0xFFFFFFFF),
    ),
    Team(
      id: 'france',
      name: 'France',
      shortName: 'FRA',
      flag: '🇫🇷',
      primaryColor: Color(0xFF1565C0),
      secondaryColor: Color(0xFFFFFFFF),
    ),
    Team(
      id: 'germany',
      name: 'Germany',
      shortName: 'GER',
      flag: '🇩🇪',
      primaryColor: Color(0xFF212121),
      secondaryColor: Color(0xFFFFFFFF),
    ),
    Team(
      id: 'spain',
      name: 'Spain',
      shortName: 'SPA',
      flag: '🇪🇸',
      primaryColor: Color(0xFFD32F2F),
      secondaryColor: Color(0xFFFFC107),
    ),
    Team(
      id: 'england',
      name: 'England',
      shortName: 'ENG',
      flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFF1565C0),
    ),
    Team(
      id: 'japan',
      name: 'Japan',
      shortName: 'JPN',
      flag: '🇯🇵',
      primaryColor: Color(0xFF1565C0),
      secondaryColor: Color(0xFFFFFFFF),
    ),
  ];

  static Team getTeamById(String id) {
    return allTeams.firstWhere((team) => team.id == id);
  }
}
