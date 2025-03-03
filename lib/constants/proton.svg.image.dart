import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';

/// Better performance and have better error handling during name mismatch.
/// Follows Flutter’s ThemeData structure makes it easier to manage with theming.
/// More scalable adding new icons is simpler.
/// Auto-applies light/dark icons when the theme changes.
///
///
/// if the svg image is using clear background with simple color. we can dirrect
///   use it with ProtonColors signle file will fit both light and dark theme
@immutable
class ProtonSvgImages extends ThemeExtension<ProtonSvgImages> {
  final SvgGenImage iconPencil;
  final SvgGenImage iconNotes;
  final SvgGenImage deleteWarning;
  final SvgGenImage iconReceive;
  final SvgGenImage iconSend;
  final SvgGenImage drawerMenu;

  /// top right settings
  final SvgGenImage walletEdit;

  ///
  final SvgGenImage protonWalletLogo;

  /// transaction list one of the bar icons
  final SvgGenImage iconSearch;
  final SvgGenImage setupPreference;

  final List<SvgGenImage> walletIcons;

  SvgGenImage getWalletIcon({int index = 0}) {
    return walletEdit;
  }

  const ProtonSvgImages({
    required this.iconPencil,
    required this.iconNotes,
    required this.deleteWarning,
    required this.iconReceive,
    required this.iconSend,
    required this.iconSearch,
    required this.protonWalletLogo,
    required this.setupPreference,
    required this.walletEdit,
    required this.drawerMenu,
    required this.walletIcons,
  });

  @override
  ProtonSvgImages copyWith({
    SvgGenImage? iconPencil,
    SvgGenImage? iconNotes,
    SvgGenImage? deleteWarning,
    SvgGenImage? iconReceive,
    SvgGenImage? iconSend,
    SvgGenImage? iconSearch,
    SvgGenImage? protonWalletLogo,
    SvgGenImage? setupPreference,
    SvgGenImage? walletEdit,
    SvgGenImage? drawerMenu,
    List<SvgGenImage>? walletIcons,
  }) {
    return ProtonSvgImages(
      iconPencil: iconPencil ?? this.iconPencil,
      iconNotes: iconNotes ?? this.iconNotes,
      deleteWarning: deleteWarning ?? this.deleteWarning,
      iconReceive: iconReceive ?? this.iconReceive,
      iconSend: iconSend ?? this.iconSend,
      iconSearch: iconSearch ?? this.iconSearch,
      protonWalletLogo: protonWalletLogo ?? this.protonWalletLogo,
      setupPreference: setupPreference ?? this.setupPreference,
      walletEdit: walletEdit ?? this.walletEdit,
      drawerMenu: drawerMenu ?? this.drawerMenu,
      walletIcons: walletIcons ?? this.walletIcons,
    );
  }

  @override
  ProtonSvgImages lerp(ThemeExtension<ProtonSvgImages>? other, double t) {
    if (other is! ProtonSvgImages) {
      return this;
    }
    return ProtonSvgImages(
      iconPencil: other.iconPencil,
      iconNotes: other.iconNotes,
      deleteWarning: other.deleteWarning,
      iconReceive: other.iconReceive,
      iconSend: other.iconSend,
      iconSearch: other.iconSearch,
      protonWalletLogo: other.protonWalletLogo,
      setupPreference: other.setupPreference,
      walletEdit: other.walletEdit,
      drawerMenu: other.drawerMenu,
      walletIcons: other.walletIcons,
    );
  }
}

final lightSvgImageExtension = ProtonSvgImages(
  iconPencil: Assets.images.icon.pencil,
  iconNotes: Assets.images.icon.note,
  deleteWarning: Assets.images.icon.deleteWarning,
  iconReceive: Assets.images.icon.receive,
  iconSend: Assets.images.icon.send,
  iconSearch: Assets.images.icon.search,
  protonWalletLogo: Assets.images.walletCreation.protonWalletLogoLight,
  setupPreference: Assets.images.icon.setupPreference,
  walletEdit: Assets.images.icon.walletEdit,
  drawerMenu: Assets.images.icon.drawerMenu,
  walletIcons: const [],
);

final darkSvgImageExtension = ProtonSvgImages(
  iconPencil: Assets.images.icon.pencilDark,
  iconNotes: Assets.images.icon.noteDark,
  deleteWarning: Assets.images.icon.deleteWarningDark,
  iconReceive: Assets.images.icon.receiveDark,
  iconSend: Assets.images.icon.sendDark,
  iconSearch: Assets.images.icon.searchDark,
  protonWalletLogo: Assets.images.walletCreation.protonWalletLogoDark,
  setupPreference: Assets.images.icon.setupPreferenceDark,
  walletEdit: Assets.images.icon.walletEditDark,
  drawerMenu: Assets.images.icon.drawerMenuDark,
  walletIcons: const [],
);
