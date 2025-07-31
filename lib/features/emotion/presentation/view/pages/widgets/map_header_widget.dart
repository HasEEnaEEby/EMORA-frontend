import 'package:flutter/material.dart';

class MapHeaderWidget extends StatefulWidget {
  final Animation<Offset> slideAnimation;
  final TextEditingController searchController;
  final String currentRegion;
  final VoidCallback onBack;
  final Function(String) onSearch;

  const MapHeaderWidget({
    super.key,
    required this.slideAnimation,
    required this.searchController,
    required this.currentRegion,
    required this.onBack,
    required this.onSearch,
  });

  @override
  State<MapHeaderWidget> createState() => _MapHeaderWidgetState();
}

class _MapHeaderWidgetState extends State<MapHeaderWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _statusController;
  late Animation<double> _statusAnimation;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _statusAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _statusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a2e).withValues(alpha: 0.95),
              const Color(0xFF1a1a2e).withValues(alpha: 0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderRow(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                if (_showSearchResults) ...[
                  const SizedBox(height: 12),
                  _buildSearchResults(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          _buildBackButton(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ).createShader(bounds),
                    child: const Text(
                      'Global Emotion Map',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    'Live insights from ${widget.currentRegion}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildLiveStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onBack,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatusIndicator() {
    return AnimatedBuilder(
      animation: _statusAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: _statusAnimation.value),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search cities, emotions, communities...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    widget.searchController.clear();
                    setState(() => _showSearchResults = false);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() => _showSearchResults = value.isNotEmpty);
          if (value.isNotEmpty) {
            widget.onSearch(value);
          }
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onSearch(value);
            setState(() => _showSearchResults = false);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1a1a2e).withValues(alpha: 0.95),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
itemCount: 3, 
        itemBuilder: (context, index) {
          final cities = ['New York', 'London', 'Tokyo'];
          return ListTile(
            leading: Icon(
              Icons.location_city,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            title: Text(
              cities[index],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Tap to explore emotions',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            onTap: () {
              widget.onSearch(cities[index]);
              setState(() => _showSearchResults = false);
            },
          );
        },
      ),
    );
  }
} 