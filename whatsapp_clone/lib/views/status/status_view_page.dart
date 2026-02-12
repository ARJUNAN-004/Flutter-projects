import 'package:flutter/material.dart';
import '../../services/status_service.dart';
import '../../models/status_model.dart';

class StatusViewPage extends StatefulWidget {
  final List<StatusModel> statuses;
  final bool isMe;
  final int initialIndex;
  final String userName;
  final String? profileImageUrl;

  const StatusViewPage({
    super.key,
    required this.statuses,
    required this.isMe,
    this.initialIndex = 0,
    required this.userName,
    this.profileImageUrl,
  });

  @override
  State<StatusViewPage> createState() => _StatusViewPageState();
}

class _StatusViewPageState extends State<StatusViewPage>
    with SingleTickerProviderStateMixin {
  final StatusService _statusService = StatusService();
  late int _currentIndex;
  late AnimationController _controller;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStatus();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStatus() {
    if (_currentIndex < widget.statuses.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _controller.reset();
      _controller.forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _controller.reset();
      _controller.forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _deleteStatus() async {
    setState(() => _isDeleting = true);
    _controller.stop(); // Pause animation while deleting
    try {
      final statusId = widget.statuses[_currentIndex].id;
      await _statusService.deleteStatus(statusId);

      // Remove from local list to avoid showing deleted status if we stay on page
      // But simpler to just close or move next.
      // If we delete, we should probably just pop getting back to the list might be invalid
      // if we passed a list.
      // Better: Remove from list. If empty, pop. If not empty, go to next/prev.

      if (mounted) {
        setState(() {
          widget.statuses.removeAt(_currentIndex);
          if (widget.statuses.isEmpty) {
            Navigator.pop(context);
          } else {
            if (_currentIndex >= widget.statuses.length) {
              _currentIndex = widget.statuses.length - 1;
            }
            _isDeleting = false;
            _controller.reset();
            _controller.forward();
          }
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Status deleted")));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _controller.forward(); // Resume
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting status: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.statuses.isEmpty) return const SizedBox.shrink(); // Safety

    final currentStatus = widget.statuses[_currentIndex];
    final imageUrl = currentStatus.imageUrl;
    final caption = currentStatus.caption;
    final timestamp = currentStatus.timestamp;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < width / 3) {
              _previousStatus();
            } else {
              _nextStatus();
            }
          },
          onLongPressStart: (_) => _controller.stop(),
          onLongPressEnd: (_) => _controller.forward(),
          child: Stack(
            children: [
              // Status Image
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              // Progress Bars
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(widget.statuses.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            double value = 0.0;
                            if (index < _currentIndex) {
                              value = 1.0;
                            } else if (index == _currentIndex) {
                              value = _controller.value;
                            }
                            return LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.grey[700],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 2,
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Top Bar (Back + User Info + Time + Delete)
              Positioned(
                top: 25, // Below progress bars
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            widget.profileImageUrl != null &&
                                widget.profileImageUrl!.isNotEmpty
                            ? NetworkImage(widget.profileImageUrl!)
                            : null,
                        child:
                            widget.profileImageUrl == null ||
                                widget.profileImageUrl!.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isMe)
                      _isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: _deleteStatus,
                            ),
                    // If not me, maybe show 3 dots menu? Keeping it simple for now as requested.
                  ],
                ),
              ),

              // Bottom Caption
              if (caption.isNotEmpty)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black54,
                    child: Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
