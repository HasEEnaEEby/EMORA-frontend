import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class MoodAtlasView extends StatefulWidget {
  const MoodAtlasView({super.key});

  @override
  State<MoodAtlasView> createState() => _MoodAtlasViewState();
}

class _MoodAtlasViewState extends State<MoodAtlasView> {
  bool _isTapped = false;

  void _onPlanetTap() {
    setState(() => _isTapped = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LocalMoodMapView(),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000010),
      body: Stack(
        children: [
          // Starry space background
          Positioned.fill(
            child: Image.asset(
              'assets/images/space_bg.png', // add a cool cosmic background
              fit: BoxFit.cover,
            ),
          ),

          // Planet (Earth) as the main interactive body
          Center(
            child: GestureDetector(
              onTap: _onPlanetTap,
              child: AnimatedScale(
                scale: _isTapped ? 1.3 : 1.0,
                duration: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: ModelViewer(
                    src: 'assets/images/3d/earth.glb',
                    alt: "3D Earth Planet",
                    ar: false,
                    autoRotate: true,
                    disableZoom: true,
                    cameraControls: false,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // Cosmic description text
          if (!_isTapped)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Tap the planet to explore emotional realms 🌍",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.blueAccent.withOpacity(0.5),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Optional: Add glowing orbs representing mood planets
          if (!_isTapped)
            Positioned(
              right: 40,
              top: 160,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent,
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class LocalMoodMapView extends StatelessWidget {
  const LocalMoodMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text("Emora: Local Mood Map"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Zoomed-in heatmap of your emotional world appears here...",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
