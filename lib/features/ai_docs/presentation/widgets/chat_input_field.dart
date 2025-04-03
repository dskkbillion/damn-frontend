import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart'; // Import the record package
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

import '../bloc/ai_chat/ai_chat_bloc.dart';
// Remove direct imports of part files
// import '../bloc/ai_chat/ai_chat_state.dart';
// import '../bloc/ai_chat/ai_chat_event.dart';

// Convert to StatefulWidget to manage local recording state for UI feedback
class ChatInputField extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback onPickImage;
  final Function(String) onSendMessage;
  // TODO: Add a callback for when voice recording finishes
  // final Function(String filePath) onSendVoice; 

  const ChatInputField({
    super.key,
    required this.textController,
    required this.onPickImage,
    required this.onSendMessage,
    // required this.onSendVoice,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _isRecording = false; // Local state to track recording status
  final AudioRecorder _audioRecorder = AudioRecorder(); // Instance of the recorder
  String? _recordingPath; // To store the path of the recording

  @override
  void dispose() {
    _audioRecorder.dispose(); // Dispose the recorder when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AiChatBloc, AiChatState, AiChatStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        final bool isStreaming = status == AiChatStatus.streamingResponse;
        final bool isBusy = status == AiChatStatus.sendingMessage ||
                           status == AiChatStatus.transcribingAudio ||
                           status == AiChatStatus.allocatingResource ||
                           isStreaming; 
        
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.textController, // Access controller via widget
          builder: (context, textValue, child) {
             final bool canSendMessage = !isBusy && textValue.text.trim().isNotEmpty;

             return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                 color: Theme.of(context).cardColor,
                 boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.05),
                    )
                 ]
               ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Attach Image Button
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    onPressed: isBusy || _isRecording ? null : widget.onPickImage, // Disable if busy or recording 
                    tooltip: 'Attach Image',
                  ),
                  // Attach Voice Button (Stateful)
                  IconButton(
                     // Change icon based on recording state
                     icon: Icon(_isRecording ? Icons.stop_circle_outlined : Icons.mic_none_outlined, 
                                color: _isRecording ? Colors.red : null),
                     onPressed: isBusy ? null : _handleVoiceButtonPress, // Disable if busy
                     tooltip: _isRecording ? 'Stop Recording' : 'Record Voice', // Updated tooltip
                   ),
                  // Text Input Field
                  Expanded(
                    child: TextField(
                      controller: widget.textController,
                      enabled: !isBusy && !_isRecording, // Disable if busy or recording
                      decoration: InputDecoration(
                        hintText: _isRecording ? 'Recording... Tap stop to send' : 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      ),
                      onSubmitted: canSendMessage ? (_) => widget.onSendMessage(widget.textController.text) : null, 
                      textInputAction: TextInputAction.send, 
                    ),
                  ),
                  // Send / Stop Generation Button
                   if (isStreaming)
                      IconButton(
                        icon: const Icon(Icons.stop_circle, color: Colors.red),
                        tooltip: 'Stop Generation',
                        // Use correct event: CancelStreaming
                        onPressed: () => context.read<AiChatBloc>().add(CancelStreaming()),
                      )
                   else
                      IconButton(
                        icon: const Icon(Icons.send),
                        // Disable if busy, recording, or no text
                        onPressed: canSendMessage && !_isRecording
                                     ? () => widget.onSendMessage(widget.textController.text)
                                     : null,
                        tooltip: 'Send Message',
                      ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Handle voice button logic with actual recording
  void _handleVoiceButtonPress() async {
    if (!_isRecording) {
      // --- Start Recording ---
      // 1. Check for microphone permission
      if (!await _audioRecorder.hasPermission()) {
         // Request permission (consider using permission_handler for better flow)
         // For simplicity, show a snackbar if permission denied.
         // You might want a more robust permission handling flow.
         final status = await Permission.microphone.request();
         if (!status.isGranted) {
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Microphone permission denied.')),
               );
            }
            return; // Stop if permission is not granted
         }
      }

       // 2. Start recording to a temporary path
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac'; // Unique filename, AAC format
      
      // Prepare recorder config (AAC-LC is a common choice, check backend requirements)
      // TODO: Revisit encoder and bitrate settings based on final requirements
       const recordConfig = RecordConfig(
         encoder: AudioEncoder.aacLc, // Example: AAC-LC
         // bitRate: 16000, // TODO: Confirm if record package allows this directly
         // sampleRate: 16000, // Sample rate often related to quality/bitrate
       );

      try {
          await _audioRecorder.start(recordConfig, path: filePath);
          print("Recording started: $filePath");
          setState(() {
             _isRecording = true;
             _recordingPath = filePath; // Store the path
             widget.textController.clear(); // Clear text field
           });
      } catch (e) {
         print("Error starting recording: $e");
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error starting recording: $e')),
            );
         }
      }

    } else {
      // --- Stop Recording ---
      try {
         final String? path = await _audioRecorder.stop();
         print("Recording stopped: $path");

         setState(() {
           _isRecording = false;
         });

         if (path != null) {
            final recordedFile = File(path);
            if (await recordedFile.exists()) {
                // TODO: Add encoding/compression step here if needed to meet 16kbps
                print("Recorded file size: ${await recordedFile.length()} bytes");

               // Dispatch the event with the **actual recorded file**
                if (mounted) { 
                   context.read<AiChatBloc>().add(SendVoiceMessage(audioFile: recordedFile));
                } 
             } else {
               print("Error: Recorded file not found at path: $path");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Recorded file not found.')),
                  );
               }
             }
         } else {
            print("Error: Stopping recording failed, path is null.");
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Error stopping recording.')),
               );
            }
         }
      } catch (e) {
         print("Error stopping recording: $e");
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error stopping recording: $e')),
            );
         }
          // Ensure recording state is reset even if stopping fails
         if (mounted && _isRecording) {
           setState(() => _isRecording = false);
         }
      }
    }
  }
} 