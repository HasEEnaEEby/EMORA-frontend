import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapControlsWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng userLocation;
  final VoidCallback onAIInsights;
  final VoidCallback onToggleHub;
  final VoidCallback onToggleInsights;

  const MapControlsWidget({
    super.key,
    required this.mapController,
    required this.userLocation,
    required this.onAIInsights,
    required this.onToggleHub,
    required this.onToggleInsights,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // My Location Button
          _buildControlButton(
            icon: Icons.my_location_rounded,
            onTap: () => _goToMyLocation(),
            color: const Color(0xFF2196F3),
            tooltip: 'My Location',
          ),
          
          const SizedBox(height: 12),
          
          // Zoom In Button
          _buildControlButton(
            icon: Icons.add_rounded,
            onTap: () => _zoomIn(),
            tooltip: 'Zoom In',
          ),
          
          const SizedBox(height: 12),
          
          // Zoom Out Button
          _buildControlButton(
            icon: Icons.remove_rounded,
            onTap: () => _zoomOut(),
            tooltip: 'Zoom Out',
          ),
          
          const SizedBox(height: 16),
          
          // AI Insights Button
          _buildControlButton(
            icon: Icons.psychology_rounded,
            onTap: onAIInsights,
            color: const Color(0xFF8B5CF6),
            tooltip: 'AI Insights',
          ),
          
          const SizedBox(height: 12),
          
          // Hub Toggle Button
          _buildControlButton(
            icon: Icons.hub_rounded,
            onTap: onToggleHub,
            color: const Color(0xFFFF9800),
            tooltip: 'Emotion Hub',
          ),
          
          const SizedBox(height: 12),
          
          // Insights Toggle Button
          _buildControlButton(
            icon: Icons.insights_rounded,
            onTap: onToggleInsights,
            color: const Color(0xFF10B981),
            tooltip: 'Regional Insights',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              (color ?? const Color(0xFF2a2a3e)).withValues(alpha: 0.9),
              (color ?? const Color(0xFF2a2a3e)).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (color != null)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToMyLocation() {
    mapController.move(userLocation, 12.0);
  }

  void _zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(
      mapController.camera.center,
      (currentZoom + 1).clamp(2.0, 18.0),
    );
  }

  void _zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(
      mapController.camera.center,
      (currentZoom - 1).clamp(2.0, 18.0),
    );
  }
} 