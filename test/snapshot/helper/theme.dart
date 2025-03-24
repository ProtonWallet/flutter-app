import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/constants/proton.color.dart';

import '../../mocks/theme.provider.mocks.dart';

@isTest
MockThemeProvider darkTheme() {
  final mockThemeProvider = MockThemeProvider();
  ProtonColors.updateDarkTheme();
  when(mockThemeProvider.isDarkMode()).thenReturn(true);
  return mockThemeProvider;
}

@isTest
MockThemeProvider lightTheme() {
  final mockThemeProvider = MockThemeProvider();
  ProtonColors.updateLightTheme();
  when(mockThemeProvider.isDarkMode()).thenReturn(false);
  return mockThemeProvider;
}
