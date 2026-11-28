import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/community_model.dart';
import '../community_theme.dart';
import '../widgets/community_avatar.dart';
import '../widgets/community_header.dart';

/// What the admin changed. Returned by [EditCommunityScreen] through
/// `Navigator.pop`; the details screen sends it to the bloc.
class EditCommunityResult {
  const EditCommunityResult({
    required this.name,
    required this.description,
    this.newImage,
    this.removeImage = false,
  });

  final String name;
  final String description;
  final File? newImage;
  final bool removeImage;
}

/// Form to edit the community name, description and picture (admin only –
/// the screen is only reachable from the admin's details screen).
class EditCommunityScreen extends StatefulWidget {
  const EditCommunityScreen({super.key, required this.community});

  final CommunityModel community;

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  // Form-only UI state (no business logic): picked image / removed flag.
  final ValueNotifier<File?> _newImage = ValueNotifier<File?>(null);
  final ValueNotifier<bool> _imageRemoved = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community.name);
    _descriptionController =
        TextEditingController(text: widget.community.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _newImage.dispose();
    _imageRemoved.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      _newImage.value = File(picked.path);
      _imageRemoved.value = false;
    }
  }

  void _removeImage() {
    _newImage.value = null;
    _imageRemoved.value = true;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final unchanged = name == widget.community.name &&
        description == widget.community.description &&
        _newImage.value == null &&
        !_imageRemoved.value;

    if (unchanged) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop(EditCommunityResult(
      name: name,
      description: description,
      newImage: _newImage.value,
      removeImage: _imageRemoved.value,
    ));
  }

  InputDecoration _decoration(String label, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: CommunityColors.primary),
      filled: true,
      fillColor: CommunityColors.soft,
      border: border(CommunityColors.border),
      enabledBorder: border(CommunityColors.border),
      focusedBorder: border(CommunityColors.primary, 1.5),
    );
  }

  Widget _avatar(File? newImage, bool removed) {
    if (newImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Image.file(newImage, width: 110, height: 110, fit: BoxFit.cover),
      );
    }
    return CommunityAvatar(
      imageUrl: removed ? null : widget.community.imageUrl,
      size: 110,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommunityColors.background,
      body: Column(
        children: [
          const CommunityHeader(title: 'Edit Community'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ValueListenableBuilder<File?>(
                      valueListenable: _newImage,
                      builder: (context, newImage, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _imageRemoved,
                          builder: (context, removed, _) {
                            final hasImage = newImage != null ||
                                (!removed &&
                                    (widget.community.imageUrl ?? '').isNotEmpty);
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      _avatar(newImage, removed),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: communityBorder,
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded,
                                            size: 18,
                                            color: CommunityColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasImage)
                                  TextButton(
                                    onPressed: _removeImage,
                                    child: const Text('Remove photo'),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 60,
                      decoration: _decoration('Community name', Icons.title_rounded),
                      validator: (value) => (value == null || value.trim().length < 2)
                          ? 'Enter a community name'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: _decoration('Description', Icons.notes_rounded),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CommunityColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _save,
                        child: const Text(
                          'Save changes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}