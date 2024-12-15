// teach_word/presentation/widgets/recording_playback_controls.dar

import 'package:flutter/material.dart';

class RecordingControls extends StatelessWidget {
  final double? audioLevel;
  final int recordingSeconds;
  final VoidCallback onStop;
  final String transcribedText;
  final double fontSize;

  const RecordingControls({
    super.key,
    this.audioLevel,
    required this.recordingSeconds,
    required this.onStop,
    required this.transcribedText,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final elapsedSecondsText = "${recordingSeconds.toDouble().toStringAsFixed(1)} 秒";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "即時辨識中：",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Ensuring good contrast
          ),
        ),
        SizedBox(height: fontSize * 0.5),
        Text(
          "已錄製時間: $elapsedSecondsText",
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white, // High contrast against dark background
          ),
        ),
        SizedBox(height: fontSize * 0.5),
        
        if (transcribedText.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(vertical: fontSize * 0.5),
            padding: EdgeInsets.all(fontSize * 0.5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "目前辨識結果：",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  transcribedText,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

        ElevatedButton(
          onPressed: onStop,
          child: Text(
            "停止錄音",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}


class PlaybackControls extends StatelessWidget {
  final String transcribedText;
  final VoidCallback? onPlay;
  final VoidCallback? onRetry;
  final VoidCallback onComplete;
  final int remainingTrials;
  final double fontSize;

  const PlaybackControls({
    super.key,
    required this.transcribedText,
    this.onPlay,
    this.onRetry,
    required this.onComplete,
    required this.remainingTrials,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Show final transcription result
        if (transcribedText.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(vertical: fontSize * 0.5),
            padding: EdgeInsets.all(fontSize * 0.5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "您的朗讀：",
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  transcribedText,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),                         
                ),
              ],
            ),
          ),

        // Play recording button
        if (onPlay != null)
          ElevatedButton(
            onPressed: onPlay,
            child: Text("播放錄音", 
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    )),                   
          ),
        SizedBox(height: fontSize),

        // Retry and complete buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: remainingTrials > 0 ? onRetry : null,
              child: Text("重新練習 (剩餘$remainingTrials次)",
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      )),                       
            ),
            ElevatedButton(
              onPressed: onComplete,
              child: Text("完成練習", 
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      )),                     
            ),
          ],
        ),
      ],
    );
  }
}
