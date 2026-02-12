import 'package:flutter/material.dart';

// Centralized color definitions for the app
// Centralized color definitions for the app
class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF008069); // WhatsApp Teal Green
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color chatBackgroundLight = Color(
    0xFFEFE7DE,
  ); // Classic Chat Wallpaper
  static const Color sentMessageLight = Color(0xFFE7FFDB); // Pale Green Bubble
  static const Color receivedMessageLight = Color(0xFFFFFFFF); // White Bubble

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF202C33); // Dark Grey-Blue AppBar
  static const Color backgroundDark = Color(0xFF111B21); // Very Dark Background
  static const Color chatBackgroundDark = Color(0xFF0B141A);
  static const Color sentMessageDark = Color(0xFF005C4B); // Dark Green Bubble
  static const Color receivedMessageDark = Color(
    0xFF202C33,
  ); // Dark Grey Bubble

  // Accents & Text
  static const Color accent = Color(0xFF25D366); // WhatsApp Logo Green
  static const Color error = Color(0xFFCF1928); // Red
  static const Color textPrimaryLight = Color(0xFF111B21);
  static const Color textSecondaryLight = Color(0xFF667781);
  static const Color textPrimaryDark = Color(0xFFE9EDEF);
  static const Color textSecondaryDark = Color(0xFF8696A0);

  // Backward compatibility getters (mapping to Light theme default)
  static const Color primary = primaryLight;
  static const Color secondary = accent;
  static const Color background = backgroundLight;
  static const Color chatBackground = chatBackgroundLight;
  static const Color sentMessage = sentMessageLight;
  static const Color receivedMessage = receivedMessageLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color sentMessageText = Color(
    0xFF111B21,
  ); // Dark text on light bubble
}
