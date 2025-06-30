// lib/app/constants/app_dimensions.dart
import '../../core/config/app_config.dart';

/// Clean wrapper for all app dimensions - imports from app_config.dart
/// This provides organized access to emotional design spacing and sizing
class AppDimensions {
  // ===========================
  // EMOTIONAL DESIGN SPACING
  // ===========================

  /// Tiny spacing (4px) - minimal gaps
  static const double paddingTiny = AppConfig.paddingTiny;

  /// Small spacing (8px) - compact layouts
  static const double paddingSmall = AppConfig.paddingSmall;

  /// Medium spacing (12px) - standard gaps
  static const double paddingMedium = AppConfig.paddingMedium;

  /// Large spacing (16px) - comfortable gaps
  static const double paddingLarge = AppConfig.paddingLarge;

  /// Extra large spacing (24px) - primary spacing unit
  static const double paddingXLarge = AppConfig.paddingXLarge;

  /// Extra extra large spacing (32px) - section spacing
  static const double paddingXXLarge = AppConfig.paddingXXLarge;

  /// Huge spacing (40px) - breathing room
  static const double paddingHuge = AppConfig.paddingHuge;

  /// Massive spacing (48px) - maximum breathing room
  static const double paddingMassive = AppConfig.paddingMassive;

  // ===========================
  // MARGIN CONSTANTS (Mirror padding)
  // ===========================

  /// Margin variants (same as padding for consistency)
  static const double marginTiny = paddingTiny;
  static const double marginSmall = paddingSmall;
  static const double marginMedium = paddingMedium;
  static const double marginLarge = paddingLarge;
  static const double marginXLarge = paddingXLarge;
  static const double marginXXLarge = paddingXXLarge;
  static const double marginHuge = paddingHuge;
  static const double marginMassive = paddingMassive;

  // ===========================
  // BORDER RADIUS - SOFT & CALMING
  // ===========================

  /// Tiny radius (4px) - subtle rounding
  static const double radiusTiny = AppConfig.radiusTiny;

  /// Small radius (8px) - gentle curves
  static const double radiusSmall = AppConfig.radiusSmall;

  /// Medium radius (12px) - standard rounding
  static const double radiusMedium = AppConfig.radiusMedium;

  /// Large radius (16px) - primary radius for cards
  static const double radiusLarge = AppConfig.radiusLarge;

  /// Extra large radius (20px) - cards and containers
  static const double radiusXLarge = AppConfig.radiusXLarge;

  /// Extra extra large radius (24px) - special components
  static const double radiusXXLarge = AppConfig.radiusXXLarge;

  /// Huge radius (28px) - large cards
  static const double radiusHuge = AppConfig.radiusHuge;

  /// Circular radius (100px) - fully rounded
  static const double radiusCircular = AppConfig.radiusCircular;

  // ===========================
  // TEXT SIZES - CALM HIERARCHY
  // ===========================

  /// Tiny text (10px) - captions and fine print
  static const double textTiny = AppConfig.textTiny;

  /// Small text (12px) - helper text and labels
  static const double textSmall = AppConfig.textSmall;

  /// Medium text (14px) - body text
  static const double textMedium = AppConfig.textMedium;

  /// Large text (16px) - emphasized body text
  static const double textLarge = AppConfig.textLarge;

  /// Extra large text (18px) - subheadings
  static const double textXLarge = AppConfig.textXLarge;

  /// Extra extra large text (20px) - headings
  static const double textXXLarge = AppConfig.textXXLarge;

  /// Header text (24px) - section titles
  static const double textHeader = AppConfig.textHeader;

  /// Title text (28px) - page headings
  static const double textTitle = AppConfig.textTitle;

  /// Display text (32px) - hero text
  static const double textDisplay = AppConfig.textDisplay;

  /// Hero text (36px) - largest text
  static const double textHero = AppConfig.textHero;

  // ===========================
  // ICON SIZES - EMOTIONAL CONTENT OPTIMIZED
  // ===========================

  /// Tiny icon (12px) - inline indicators
  static const double iconTiny = AppConfig.iconTiny;

  /// Small icon (16px) - compact layouts
  static const double iconSmall = AppConfig.iconSmall;

  /// Medium icon (20px) - standard size
  static const double iconMedium = AppConfig.iconMedium;

  /// Large icon (24px) - prominent elements
  static const double iconLarge = AppConfig.iconLarge;

  /// Extra large icon (32px) - feature icons
  static const double iconXLarge = AppConfig.iconXLarge;

  /// Extra extra large icon (48px) - hero icons
  static const double iconXXLarge = AppConfig.iconXXLarge;

  /// Huge icon (64px) - emotion displays
  static const double iconHuge = AppConfig.iconHuge;

  /// Massive icon (80px) - largest icons
  static const double iconMassive = AppConfig.iconMassive;

  // ===========================
  // COMPONENT SIZES - COMFORTABLE & ACCESSIBLE
  // ===========================

  /// Standard button height (48px) - primary buttons
  static const double buttonHeight = AppConfig.buttonHeight;

  /// Small button height (36px) - compact buttons
  static const double buttonHeightSmall = AppConfig.buttonHeightSmall;

  /// Large button height (56px) - prominent buttons
  static const double buttonHeightLarge = AppConfig.buttonHeightLarge;

  /// Input field height (48px) - text inputs
  static const double inputHeight = AppConfig.inputHeight;

  /// Standard card height (160px) - content cards
  static const double cardHeight = AppConfig.cardHeight;

  /// Large card height (200px) - detailed cards
  static const double cardHeightLarge = AppConfig.cardHeightLarge;

  /// Standard avatar size (48px) - user avatars
  static const double avatarSize = AppConfig.avatarSize;

  /// Large avatar size (80px) - profile avatars
  static const double avatarSizeLarge = AppConfig.avatarSizeLarge;

  // ===========================
  // EMOTION-SPECIFIC DIMENSIONS
  // ===========================

  /// Emotion tile size (80px) - emotion grid tiles
  static const double emotionTileSize = AppConfig.emotionTileSize;

  /// Emotion dot size (12px) - emotion indicators
  static const double emotionDotSize = AppConfig.emotionDotSize;

  /// Earth section height (320px) - 3D earth component
  static const double earthSectionHeight = AppConfig.earthSectionHeight;

  /// Map height (280px) - global emotion map component - ADDED
  static const double mapHeight = 280.0;

  /// Slider height (48px) - emotion intensity slider
  static const double sliderHeight = AppConfig.sliderHeight;

  /// Progress bar height (8px) - progress indicators
  static const double progressBarHeight = AppConfig.progressBarHeight;

  // ===========================
  // LAYOUT CONSTRAINTS
  // ===========================

  /// Maximum content width (400px) - responsive design
  static const double maxContentWidth = AppConfig.maxContentWidth;

  /// Section spacing (32px) - between major sections
  static const double sectionSpacing = AppConfig.sectionSpacing;

  /// Item spacing (16px) - between related items
  static const double itemSpacing = AppConfig.itemSpacing;

  /// Grid spacing (12px) - grid item gaps
  static const double gridSpacing = AppConfig.gridSpacing;

  // ===========================
  // ACCESSIBILITY - TOUCH TARGETS
  // ===========================

  /// Minimum touch target (44px) - WCAG compliance
  static const double minTouchTarget = AppConfig.minTouchTarget;

  /// Comfortable touch target (48px) - recommended size
  static const double comfortableTouchTarget = AppConfig.comfortableTouchTarget;

  // ===========================
  // ELEVATION & SHADOWS
  // ===========================

  /// No elevation (0px)
  static const double elevationNone = 0.0;

  /// Low elevation (2px) - subtle lift
  static const double elevationLow = 2.0;

  /// Medium elevation (4px) - standard cards
  static const double elevationMedium = 4.0;

  /// High elevation (8px) - important elements
  static const double elevationHigh = 8.0;

  /// Extra high elevation (12px) - floating elements
  static const double elevationXHigh = 12.0;

  /// Maximum elevation (16px) - modals and overlays
  static const double elevationMax = 16.0;

  // ===========================
  // RESPONSIVE BREAKPOINTS
  // ===========================

  /// Mobile breakpoint (600px)
  static const double mobileBreakpoint = 600.0;

  /// Tablet breakpoint (900px)
  static const double tabletBreakpoint = 900.0;

  /// Desktop breakpoint (1200px)
  static const double desktopBreakpoint = 1200.0;

  // ===========================
  // SPECIALIZED COMPONENTS
  // ===========================

  /// Navigation bar height (80px)
  static const double bottomNavHeight = 80.0;

  /// App bar height (56px)
  static const double appBarHeight = 56.0;

  /// Tab bar height (48px)
  static const double tabBarHeight = 48.0;

  /// Floating action button size (56px)
  static const double fabSize = 56.0;

  /// Small floating action button size (40px)
  static const double fabSizeSmall = 40.0;

  /// Large floating action button size (64px)
  static const double fabSizeLarge = 64.0;

  // ===========================
  // HELPER METHODS
  // ===========================

  /// Get responsive padding based on screen width
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return paddingLarge;
    } else if (screenWidth < tabletBreakpoint) {
      return paddingXLarge;
    } else {
      return paddingXXLarge;
    }
  }

  /// Get responsive text size
  static double getResponsiveText(double baseSize, double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return baseSize;
    } else if (screenWidth < tabletBreakpoint) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  /// Get emotion tile size based on screen width
  static double getEmotionTileSize(double screenWidth) {
    final availableWidth =
        screenWidth - (paddingXLarge * 2) - (gridSpacing * 3);
    final tileSize = availableWidth / 4;
    return tileSize.clamp(60.0, 100.0);
  }

  /// Get touch target size for accessibility
  static double getTouchTargetSize(bool isAccessibilityEnabled) {
    return isAccessibilityEnabled ? 56.0 : comfortableTouchTarget;
  }

  /// Get card padding based on card size
  static double getCardPadding(double cardWidth) {
    if (cardWidth < 200) return paddingMedium;
    if (cardWidth < 300) return paddingLarge;
    return paddingXLarge;
  }

  /// Get appropriate text size for container width
  static double getTextSizeForWidth(double containerWidth) {
    if (containerWidth < 200) return textSmall;
    if (containerWidth < 300) return textMedium;
    if (containerWidth < 400) return textLarge;
    return textXLarge;
  }
}
