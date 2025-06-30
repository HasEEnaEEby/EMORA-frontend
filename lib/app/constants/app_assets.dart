class AppAssets {
  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _lottie = 'assets/lottie';

  // Logo and Branding
  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String splashBackground = '$_images/splash_background.png';

  // Avatars
  static const String avatarPanda = '$_images/avatars/panda.png';
  static const String avatarElephant = '$_images/avatars/elephant.png';
  static const String avatarHorse = '$_images/avatars/horse.png';
  static const String avatarRabbit = '$_images/avatars/rabbit.png';
  static const String avatarFox = '$_images/avatars/fox.png';
  static const String avatarZebra = '$_images/avatars/zebra.png';
  static const String avatarBear = '$_images/avatars/bear.png';
  static const String avatarPig = '$_images/avatars/pig.png';
  static const String avatarRaccoon = '$_images/avatars/raccoon.png';

  // Emotion Images
  static const String moodImage1 = '$_images/moods/mood_1.jpg';
  static const String moodImage2 = '$_images/moods/mood_2.jpg';
  static const String meditationImage1 = '$_images/meditation/meditation_1.jpg';
  static const String energyImage1 = '$_images/energy/energy_1.jpg';

  // Icons
  static const String homeIcon = '$_icons/home.svg';
  static const String moodAtlasIcon = '$_icons/mood_atlas.svg';
  static const String insightsIcon = '$_icons/insights.svg';
  static const String friendsIcon = '$_icons/friends.svg';
  static const String ventingIcon = '$_icons/venting.svg';

  // Lottie Animations
  static const String loadingAnimation = '$_lottie/loading.json';
  static const String successAnimation = '$_lottie/success.json';
  static const String errorAnimation = '$_lottie/error.json';
  static const String emotionAnimation = '$_lottie/emotion.json';

  // Emotion Character Maps
  static Map<String, String> get avatarEmojis => {
    'panda': '🐼',
    'elephant': '🐘',
    'horse': '🐴',
    'rabbit': '🐰',
    'fox': '🦊',
    'zebra': '🦓',
    'bear': '🐻',
    'pig': '🐷',
    'raccoon': '🦝',
  };

  // Mood Recommendation Images
  static Map<String, String> get moodImages => {
    'mood_1.jpg': moodImage1,
    'mood_2.jpg': moodImage2,
    'meditation_1.jpg': meditationImage1,
    'energy_1.jpg': energyImage1,
  };
}
