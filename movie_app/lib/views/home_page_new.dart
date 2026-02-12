import 'dart:async';
import 'dart:ui';

import 'package:dioapidemo/controllers/apicontroller.dart';
import 'package:dioapidemo/models/movie.dart';
import 'package:dioapidemo/views/details_page.dart';
import 'package:dioapidemo/views/search_delegate.dart';
import 'package:flutter/material.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  // -------------------
  // State Variables
  // -------------------
  late Future<List<Movie>> _moviesFuture;
  int _currentPage = 0;
  Timer? _timer;

  // -------------------
  // Data Logic
  // -------------------
  List<Movie> _allMovies = [];
  List<Movie> _displayMovies = [];
  List<String> _genres = ['All'];
  String _selectedGenre = 'All';

  // -------------------
  // Keys & Controllers
  // -------------------
  // Exposed for the timer to animate the child controller
  final GlobalKey<_ResponsiveCarouselState> _carouselKey = GlobalKey();

  // -------------------
  // Lifecycle Methods
  // -------------------
  @override
  void initState() {
    super.initState();
    _moviesFuture = getData().then((value) {
      if (mounted) {
        setState(() {
          _allMovies = value;
          _displayMovies = value;

          // Extract unique genres
          final uniqueGenres = <String>{'All'};
          for (var movie in value) {
            uniqueGenres.addAll(movie.genres);
          }
          _genres = uniqueGenres.toList();

          if (_displayMovies.isNotEmpty) {
            _startAutoPlay();
          }
        });
      }
      return value;
    });
  }

  // -------------------
  // Event Handlers
  // -------------------
  void _onGenreSelected(String genre) {
    setState(() {
      _selectedGenre = genre;
      _currentPage = 0; // Reset to first item

      // Reset carousel to first page immediately
      _carouselKey.currentState?.jumpToPage(0);

      if (genre == 'All') {
        _displayMovies = List.from(_allMovies);
      } else {
        _displayMovies = _allMovies
            .where((m) => m.genres.contains(genre))
            .toList();
      }

      // key-based widget update is handled by state change,
      // but we might need to reset timer or carousel key if we want a fresh animation
    });
    // Restart timer for the new list
    _timer?.cancel();
    if (_displayMovies.isNotEmpty) _startAutoPlay();
  }

  // -------------------
  // Autoplay & Timer Logic
  // -------------------
  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_displayMovies.isEmpty) return;

      if (_currentPage < _displayMovies.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      // Animate via key
      _carouselKey.currentState?.animateToPage(_currentPage);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // -------------------
  // Main UI Build
  // -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (_displayMovies.isEmpty) {
            // If main list is empty (no data) or filter result is empty
            if (_allMovies.isEmpty) {
              return const Center(
                child: Text(
                  "No movies found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            // Filter result empty
            return Column(
              children: [
                const SizedBox(height: 100),
                _buildGenreSelector(),
                const Expanded(
                  child: Center(
                    child: Text(
                      "No movies in this category",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            );
          }

          return Stack(
            children: [
              // Dynamic Blurred Background
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey<String>(
                    _displayMovies[_currentPage].primaryImage ?? '',
                  ),
                  decoration: BoxDecoration(
                    image: _displayMovies[_currentPage].primaryImage != null
                        ? DecorationImage(
                            image: NetworkImage(
                              _displayMovies[_currentPage].primaryImage!,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Now Playing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        IconButton(
                          onPressed: _openSearch,
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Genre Selector
                  _buildGenreSelector(),

                  const SizedBox(height: 10),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;
                        // Target card width is ~350px.
                        double viewportFraction = (350 / screenWidth).clamp(
                          0.2,
                          0.85,
                        );

                        return _ResponsiveCarousel(
                          key: _carouselKey, // Use the GlobalKey for control
                          movies: _displayMovies,
                          viewportFraction: viewportFraction,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                            _timer?.cancel();
                            _startAutoPlay();
                          },
                          initialPage: _currentPage,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------
  // Helper Methods
  // -------------------
  void _openSearch() {
    showSearch(context: context, delegate: MovieSearchDelegate(_allMovies));
  }

  Widget _buildGenreSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final isSelected = genre == _selectedGenre;
          return GestureDetector(
            onTap: () => _onGenreSelected(genre),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                ),
              ),
              child: Center(
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// Responsive Carousel Widget
// ==========================================
class _ResponsiveCarousel extends StatefulWidget {
  final List<Movie> movies;
  final double viewportFraction;
  final ValueChanged<int> onPageChanged;
  final int initialPage;

  const _ResponsiveCarousel({
    super.key,
    required this.movies,
    required this.viewportFraction,
    required this.onPageChanged,
    required this.initialPage,
  });

  @override
  State<_ResponsiveCarousel> createState() => _ResponsiveCarouselState();
}

class _ResponsiveCarouselState extends State<_ResponsiveCarousel> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: widget.viewportFraction,
      initialPage: widget.initialPage,
    );
  }

  @override
  void didUpdateWidget(covariant _ResponsiveCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportFraction != widget.viewportFraction) {
      int currentPage = _controller.hasClients
          ? _controller.page!.round()
          : widget.initialPage;
      _controller.dispose();
      _controller = PageController(
        viewportFraction: widget.viewportFraction,
        initialPage: currentPage,
      );
    }
  }

  void animateToPage(int page) {
    if (_controller.hasClients) {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void jumpToPage(int page) {
    if (_controller.hasClients) {
      _controller.jumpToPage(page);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.movies.length,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final movie = widget.movies[index];
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Parallax/Scale effect logic
            double value = 1.0;
            if (_controller.position.haveDimensions) {
              value = _controller.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
            } else {
              // If strict initial load, assume active page is fully scaled
              // But this might be wrong if we start at page X.
              // Simply using 1.0 for now if exact calculation fails.
              value = 1.0;
            }

            // Apply scale
            final double scale = Curves.easeOut.transform(value);

            return Center(
              child: SizedBox(
                height: scale * MediaQuery.of(context).size.height * 0.7,
                // Width is determined by viewportFraction, but we can constrain it further if needed.
                // But the viewportFraction logic handles the width.
                child: child,
              ),
            );
          },
          child: _MovieCard(movie: movie),
        );
      },
    );
  }
}

// ==========================================
// Movie Card Widget
// ==========================================
class _MovieCard extends StatelessWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      // Glassmorphism / Shadow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailsPage(movie: movie)),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (movie.primaryImage != null)
                Hero(
                  tag: 'movie_image_${movie.id}',
                  child: Image.network(
                    movie.primaryImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[900]),
                  ),
                )
              else
                Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white54, size: 50),
                  ),
                ),

              // Gradient Overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.5, 0.8, 1.0],
                  ),
                ),
              ),

              // Text Info
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.primaryTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          movie.averageRating?.toString() ?? "N/A",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (movie.releaseDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              movie.releaseDate!.split('-')[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.description ?? "No description available.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
