import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/utils/image_compressor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/create_profile_bloc.dart';
import '../../constants/profile_constants.dart';
import '../../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class BasicDetailsStep extends StatelessWidget {
  const BasicDetailsStep({
    super.key,
    required this.state,
    required this.nameController,
  });

  final CreateProfileState state;
  final TextEditingController nameController;

Future<void> _showSourceSheet(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(sheetCtx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(sheetCtx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

  if (source == null || !context.mounted) return;
  await _pickPhoto(context, source);
}

Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
  final bloc = context.read<CreateProfileBloc>();
  final messenger = ScaffoldMessenger.of(context);

  // 👇 PUT IT HERE: before pickImage, camera only
  if (source == ImageSource.camera) {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Camera permission is required'),
          behavior: SnackBarBehavior.floating,
          action: status.isPermanentlyDenied
              ? SnackBarAction(
                  label: 'Settings',
                  onPressed: openAppSettings,
                )
              : null,
        ),
      );
      return; // stop, don't open camera
    }
  }

  try {
    final file = await ImagePicker().pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file == null) return;

    final raw = await file.readAsBytes();
    final bytes = await ImageCompressor.compress(raw);

    final baseName = file.name.contains('.')
        ? file.name.substring(0, file.name.lastIndexOf('.'))
        : file.name;

    bloc.add(
      ProfilePhotoSelected(
        PickedPhoto(bytes: bytes, fileName: '$baseName.jpg'),
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          source == ImageSource.camera
              ? 'Could not open the camera'
              : 'Could not open your photos',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.authTextPrimaryColor,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateProfileBloc>();
    final hasPhoto = state.photo != null || state.photoUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileTitle(
          title: "Let's set up your profile",
          subtitle: 'Add a photo and tell us who you are',
        ),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            onTap: () => _showSourceSheet(context),
            child: _Avatar(
              photo: state.photo,
              photoUrl: state.photoUrl,
              onRemovePhoto: hasPhoto
                  ? () => bloc.add(const ProfilePhotoRemoved())
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: InkWell(
            onTap: () => _showSourceSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                'Add profile photo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.primaryBlue,
                ),
              ),
            ),
          ),
        ),
        const Center(
          child: Text(
            'JPG or PNG, up to 5 MB',
            style: TextStyle(
              fontSize: 13,
              color: AppPalette.authTextSecondaryColor,
            ),
          ),
        ),
        if (state.photoError != null)
          Center(child: ProfileErrorText(state.photoError!, center: true)),
        const SizedBox(height: 22),
        ProfileTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline_rounded,
          controller: nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          maxLength: ProfileConstants.nameMaxLength,
          errorText: state.fullNameError,
          onChanged: (v) => bloc.add(ProfileFullNameChanged(v)),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: 18),
        const ProfileLabel('Gender'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final g in Gender.values)
              ProfileChoicePill(
                label: g.label,
                selected: state.gender == g,
                onTap: () => bloc.add(ProfileGenderSelected(g)),
              ),
          ],
        ),
        if (state.genderError != null) ProfileErrorText(state.genderError!),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photo,
    required this.photoUrl,
    this.onRemovePhoto,
  });

  final PickedPhoto? photo;
  final String photoUrl;
  final VoidCallback? onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (photo != null) {
      inner = Image.memory(photo!.bytes, fit: BoxFit.cover);
    } else if (photoUrl.isNotEmpty) {
      inner = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
      );
    } else {
      inner = const _AvatarPlaceholder();
    }

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.authCardSurfaceColor,
              border: Border.all(color: AppPalette.inputBorderColor, width: 2),
            ),
            child: ClipOval(child: inner),
          ),
         Positioned(
  right: 2,
  bottom: 6,
  child: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: onRemovePhoto == null
          ? AppPalette.primaryBlue
          : AppPalette.errorText,
      border: Border.all(color: AppPalette.white, width: 3),
    ),
    child: onRemovePhoto == null
        ? const Icon(
            Icons.camera_alt_outlined,
            color: AppPalette.white,
            size: 19,
          )
        : IconButton(
            onPressed: onRemovePhoto,
            tooltip: 'Remove photo',
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppPalette.white,
              size: 19,
            ),
          ),
  ),
),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.primaryBlue.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_outline_rounded,
        size: 62,
        color: AppPalette.primaryBlueLight,
      ),
    );
  }
}