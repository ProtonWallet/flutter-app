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
class ProtonImages extends ThemeExtension<ProtonImages> {
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

  /// address list icons
  final SvgGenImage iconCopy;
  final SvgGenImage iconQrCode;
  final SvgGenImage iconSign;

  /// large view title icons
  final AssetGenImage iconSignHeader;

  final List<SvgGenImage> walletIcons;

  SvgGenImage getWalletIcon({int index = 0}) {
    return walletEdit;
  }

  const ProtonImages({
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
    required this.iconCopy,
    required this.iconQrCode,
    required this.iconSign,
    required this.iconSignHeader,
  });

  @override
  ProtonImages copyWith({
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
    SvgGenImage? iconCopy,
    SvgGenImage? iconQrCode,
    SvgGenImage? iconSign,
    AssetGenImage? iconSignHeader,
  }) {
    return ProtonImages(
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
      iconCopy: iconCopy ?? this.iconCopy,
      iconQrCode: iconQrCode ?? this.iconQrCode,
      iconSign: iconSign ?? this.iconSign,
      iconSignHeader: iconSignHeader ?? this.iconSignHeader,
    );
  }

  @override
  ProtonImages lerp(ThemeExtension<ProtonImages>? other, double t) {
    if (other is! ProtonImages) {
      return this;
    }
    return ProtonImages(
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
      iconCopy: other.iconCopy,
      iconQrCode: other.iconQrCode,
      iconSign: other.iconSign,
      iconSignHeader: other.iconSignHeader,
    );
  }
}

final lightImageExtension = ProtonImages(
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
  iconCopy: Assets.images.icon.icCopy,
  iconQrCode: Assets.images.icon.icQrCode,
  iconSign: Assets.images.icon.icSign,
  iconSignHeader: Assets.images.icon.signHeader,
);

final darkImageExtension = ProtonImages(
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
  iconCopy: Assets.images.icon.icCopyDark,
  iconQrCode: Assets.images.icon.icQrCodeDark,
  iconSign: Assets.images.icon.icSignDark,
  iconSignHeader: Assets.images.icon.signHeaderDark,
);
