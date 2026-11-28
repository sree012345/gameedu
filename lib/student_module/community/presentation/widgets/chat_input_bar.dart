import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/community_message.dart';
import '../community_theme.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendMedia,
    this.enabled = true,
  });

  final void Function(String text) onSendText;
  final void Function(CommunityMessageType type, File file) onSendMedia;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
    );
    if (file != null) {
      widget.onSendMedia(CommunityMessageType.image, File(file.path));
    }
  }

  Future<void> _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      widget.onSendMedia(CommunityMessageType.video, File(file.path));
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = result?.files.single.path;
    if (path != null) {
      widget.onSendMedia(CommunityMessageType.audio, File(path));
    }
  }

  void _showAttachSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Widget option(IconData icon, String label, Future<void> Function() action) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: CommunityColors.primary.withOpacity(0.1),
              child: Icon(icon, color: CommunityColors.primary),
            ),
            title: Text(label,
                style: const TextStyle(
                    color: CommunityColors.title, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.of(sheetContext).pop();
              action();
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                option(Icons.photo_library_rounded, 'Photo from gallery',
                    () => _pickImage(ImageSource.gallery)),
                option(Icons.photo_camera_rounded, 'Take a photo',
                    () => _pickImage(ImageSource.camera)),
                option(Icons.videocam_rounded, 'Video', _pickVideo),
                option(Icons.audiotrack_rounded, 'Audio', _pickAudio),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CommunityColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: widget.enabled ? _showAttachSheet : null,
                icon: const Icon(Icons.attach_file_rounded,
                    color: CommunityColors.primary),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: const TextStyle(color: CommunityColors.hint),
                    filled: true,
                    fillColor: CommunityColors.soft,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: CommunityColors.primary,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: widget.enabled ? _send : null,
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
