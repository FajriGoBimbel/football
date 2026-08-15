import 'package:flutter/material.dart';

class Team {
  final String id;
  final String name;
  final String shortName;
  final String flag;
  final Color primaryColor;
  final Color secondaryColor;

  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.flag,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
