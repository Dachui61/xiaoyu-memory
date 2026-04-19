import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../app/theme.dart';

class VoiceRecordButton extends StatefulWidget {
  final Function(String path) onRecorded;
  final VoidCallback? onCancel;

  const VoiceRecordButton({super.key, required this.onRecorded, this.onCancel});

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> with SingleTickerProviderStateMixin {
  bool _recording = false;
  String _duration = '00:00';
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  final AudioRecorder _recorder = AudioRecorder();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.reverse();
      } else if (status == AnimationStatus.dismissed && _recording) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
          path: path,
        );
        setState(() {
          _recording = true;
          _seconds = 0;
          _duration = '00:00';
        });
        _animController.forward();
        _timer = Timer.periodic(Duration(seconds: 1), (_) {
          setState(() {
            _seconds++;
            _duration = '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';
          });
        });
      }
    } catch (e) {
      debugPrint('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _recorder.stop();
      setState(() {
        _recording = false;
        _animController.stop();
        _animController.reset();
      });
      if (path != null && path.isNotEmpty) {
        widget.onRecorded(path);
      }
    } catch (e) {
      debugPrint('Failed to stop recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration display
        AnimatedOpacity(
          opacity: _recording ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(_duration, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.voiceRed)),
          ),
        ),
        // Record button
        GestureDetector(
          onTapDown: (_) => _startRecording(),
          onTapUp: (_) => _stopRecording(),
          onTapCancel: () => _stopRecording(),
          child: AnimatedBuilder(
            animation: _scaleAnim,
            builder: (_, __) {
              return Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.voiceRed,
                    shape: BoxShape.circle,
                    boxShadow: _recording
                        ? [BoxShadow(color: AppTheme.voiceRed.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4)]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: Icon(_recording ? Icons.stop : Icons.mic, color: Colors.white, size: 28),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12),
        Text(_recording ? '松开结束' : '按住说话', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}
