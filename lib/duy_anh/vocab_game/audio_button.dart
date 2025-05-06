import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'package:provider/provider.dart';

class AudioButton extends StatefulWidget {
  final String text;
  final double size;
  final Color color;
  final bool showText;

  const AudioButton({
    Key? key,
    required this.text,
    this.size = 24.0,
    this.color = Colors.blue,
    this.showText = false,
  }) : super(key: key);

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    // Schedule a post-frame callback to check initial playback state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePlaybackState();
    });
  }

  void _updatePlaybackState() {
    final audioService =
        Provider.of<AudioPlaybackService>(context, listen: false);
    final isThisPlaying =
        audioService.isPlaying && audioService.lastPlayedText == widget.text;

    if (isThisPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isThisPlaying;
      });

      if (_isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePlaybackState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlaybackService>(
        builder: (context, audioService, child) {
      // Just check the state here, don't call setState
      final isThisPlaying =
          audioService.isPlaying && audioService.lastPlayedText == widget.text;

      // Don't call setState here - use the same logic in didChangeDependencies
      if (isThisPlaying != _isPlaying) {
        // Instead of setState, schedule update after this build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updatePlaybackState();
        });
      }

      return GestureDetector(
        onTap: () => _playAudio(audioService),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isPlaying
                  ? widget.color.withOpacity(0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                  color: widget.color,
                  size: widget.size,
                ),
                if (widget.showText) ...[
                  SizedBox(width: 8),
                  Text(
                    _isPlaying ? 'Đang phát' : 'Nghe',
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  void _playAudio(AudioPlaybackService audioService) {
    if (_isPlaying) return;
    audioService.tryPlayWithFallbacks(widget.text);
  }
}
