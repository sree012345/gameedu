import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/core/widgets/base/base_textfield.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import 'package:game_edu/init_dependencies.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/create_community/create_community_bloc.dart';
import '../community_navigator.dart';
import '../community_theme.dart';
import '../widgets/community_header.dart';

class CreateCommunityScreen extends StatelessWidget {
  const CreateCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<CreateCommunityBloc>(),
      child: const _CreateCommunityView(),
    );
  }
}

class _CreateCommunityView extends StatefulWidget {
  const _CreateCommunityView();

  @override
  State<_CreateCommunityView> createState() => _CreateCommunityViewState();
}

class _CreateCommunityViewState extends State<_CreateCommunityView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final bloc = context.read<CreateCommunityBloc>();

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked != null && !bloc.isClosed) {
      bloc.add(CreateCommunityImageChanged(File(picked.path)));
    }
  }

  Future<void> _pickParticipants(
    BuildContext context,
    CreateCommunityState state,
  ) async {
    final bloc = context.read<CreateCommunityBloc>();

    final ids = await CommunityNavigator.openParticipantPicker(
      context,
      initialSelected: state.participantIds.toSet(),
      title: 'Add participants',
    );

    if (ids != null && !bloc.isClosed) {
      bloc.add(CreateCommunityParticipantsChanged(ids));
    }
  }

  void _submit(BuildContext context) {
    context
        .read<CreateCommunityBloc>()
        .add(const CreateCommunitySubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCommunityBloc, CreateCommunityState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreateCommunityStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Community created')),
          );

          Navigator.of(context).pop(state.createdCommunityId);
        } else if (state.status == CreateCommunityStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Could not create community',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final image = state.imageFile;

        return Scaffold(
          backgroundColor: CommunityColors.background,
          body: Column(
            children: [
              const CommunityHeader(
                title: 'New Community',
                subtitle: 'Only admins can post by default',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: state.isSubmitting
                            ? null
                            : () => _pickImage(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: image == null
                                    ? communityGradient
                                    : null,
                                borderRadius: BorderRadius.circular(34),
                                image: image == null
                                    ? null
                                    : DecorationImage(
                                        image: FileImage(image),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              child: image == null
                                  ? const Icon(
                                      Icons.groups_rounded,
                                      color: Colors.white,
                                      size: 52,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: communityBorder,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: CommunityColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (image != null)
                        TextButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context
                                  .read<CreateCommunityBloc>()
                                  .add(
                                    const CreateCommunityImageChanged(null),
                                  ),
                          child: const Text('Remove photo'),
                        ),
                      const SizedBox(height: 20),

                      BaseTextfield(
                        controller: _nameController,
                        enabled: !state.isSubmitting,
                        maxLength: 60,
                        hintText: 'Community name',
                        prefixIcon: const Icon(
                          Icons.title_rounded,
                          color: CommunityColors.primary,
                        ),
                        borderRadius: 16,
                        fillColor: CommunityColors.soft,
                        borderColor: CommunityColors.border,
                        focusedBorderColor: CommunityColors.primary,
                        errorText: state.nameError,
                        onChanged: (value) {
                          context
                              .read<CreateCommunityBloc>()
                              .add(CreateCommunityNameChanged(value));
                        },
                      ),
                      const SizedBox(height: 8),

                      BaseTextfield(
                        controller: _descriptionController,
                        enabled: !state.isSubmitting,
                        maxLines: 3,
                        maxLength: 300,
                        hintText: 'Description',
                        prefixIcon: const Icon(
                          Icons.notes_rounded,
                          color: CommunityColors.primary,
                        ),
                        borderRadius: 16,
                        fillColor: CommunityColors.soft,
                        borderColor: CommunityColors.border,
                        focusedBorderColor: CommunityColors.primary,
                        onChanged: (value) {
                          context
                              .read<CreateCommunityBloc>()
                              .add(
                                CreateCommunityDescriptionChanged(value),
                              );
                        },
                      ),
                      const SizedBox(height: 8),

                      Material(
                        color: CommunityColors.soft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: CommunityColors.border,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: state.isSubmitting
                              ? null
                              : () => _pickParticipants(context, state),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: CommunityColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.participantIds.isEmpty
                                        ? 'Add participants'
                                        : '${state.participantIds.length} participant(s) selected',
                                    style: const TextStyle(
                                      color: CommunityColors.title,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: CommunityColors.subtitle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      MediumButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => _submit(context),
                        isLoading: state.isSubmitting,
                        text: 'Create Community',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}