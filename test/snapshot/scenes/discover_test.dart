import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/components/discover/proton.feeditem.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.view.dart';

import '../../mocks/discovery.mocks.dart';
import '../../mocks/theme.provider.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('discover content ', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final viewModel = MockDiscoverViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.initialized).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockDiscoverCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockDiscoverViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);
    when(viewModel.protonFeedItems).thenAnswer((_) => sampleData);

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: DiscoverView(viewModel),
    );

    await testAcrossAllDevices(tester, () => widget, 'discover/discover_view');
  });

  testSnapshot('discover content dark', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateDarkTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);

    final viewModel = MockDiscoverViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.initialized).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockDiscoverCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockDiscoverViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);
    when(viewModel.protonFeedItems).thenAnswer((_) => sampleData);

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: DiscoverView(viewModel),
    );

    await testAcrossAllDevices(tester, () => widget, 'discover/dark_view');
  });
}

List<ProtonFeedItem> get sampleData {
  return [
    ProtonFeedItem(
      title: 'Title 1 guide for newcomers',
      pubDate: '2022-01-01',
      link: 'https://example.com/1',
      description: 'Description 1',
      category: 'Category 1',
      author: 'Author 1',
      coverImage: 'https://example.com/image1.png',
    ),
    ProtonFeedItem(
      title: 'Title 2 what is bitcoin',
      pubDate: '2022-01-02',
      link: 'https://example.com/2',
      description: 'Description 2',
      category: 'Category 2',
      author: 'Author 2',
      coverImage: 'https://example.com/image2.png',
    ),
    ProtonFeedItem(
      title: 'Title 3 proton wallet launch',
      pubDate: '2022-01-01',
      link: 'https://example.com/1',
      description: 'Description 1',
      category: 'Category 1',
      author: 'Author 1',
      coverImage: 'https://example.com/image1.png',
    ),
    ProtonFeedItem(
      title: 'Title 4 proton wallet security',
      pubDate: '2022-01-02',
      link: 'https://example.com/2',
      description: 'Description 2',
      category: 'Category 2',
      author: 'Author 2',
      coverImage: 'https://example.com/image2.png',
    ),
    ProtonFeedItem(
      title: 'Title 5 bitcoin via email',
      pubDate: '2022-01-01',
      link: 'https://example.com/1',
      description: 'Description 1',
      category: 'Category 1',
      author: 'Author 1',
      coverImage: 'https://example.com/image1.png',
    ),
    ProtonFeedItem(
      title: 'Title 6 protect your proton wallet',
      pubDate: '2022-01-02',
      link: 'https://example.com/2',
      description: 'Description 2',
      category: 'Category 2',
      author: 'Author 2',
      coverImage: 'https://example.com/image2.png',
    ),
    ProtonFeedItem(
      title: 'Title 1',
      pubDate: '2022-01-01',
      link: 'https://example.com/1',
      description: 'Description 1',
      category: 'Category 1',
      author: 'Author 1',
      coverImage: 'https://example.com/image1.png',
    ),
  ];
}
