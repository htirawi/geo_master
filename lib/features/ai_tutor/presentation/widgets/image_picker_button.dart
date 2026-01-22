import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Image picker button for selecting images from camera or gallery
class ImagePickerButton extends StatelessWidget {
  const ImagePickerButton({
    super.key,
    required this.onImageSelected,
    this.isEnabled = true,
  });

  final void Function(Uint8List imageData, String mimeType) onImageSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.image_outlined),
      onPressed: isEnabled ? () => _showImageSourceDialog(context) : null,
      tooltip: 'Add image',
      color: isEnabled
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                subtitle: const Text('Use camera to capture an image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                subtitle: const Text('Select an existing image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Read and compress the image
      final file = File(pickedFile.path);
      var imageBytes = await file.readAsBytes();

      // Determine mime type
      final extension = pickedFile.path.split('.').last.toLowerCase();
      String mimeType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      // Compress if larger than 1MB
      if (imageBytes.length > 1024 * 1024) {
        imageBytes = await _compressImage(imageBytes);
        mimeType = 'image/jpeg'; // Compressed output is always JPEG
      }

      onImageSelected(imageBytes, mimeType);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    // Decode the image
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    // Resize if too large
    img.Image resized;
    if (image.width > 1024 || image.height > 1024) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? 1024 : null,
        height: image.height >= image.width ? 1024 : null,
      );
    } else {
      resized = image;
    }

    // Encode as JPEG with 80% quality
    final compressed = img.encodeJpg(resized, quality: 80);
    return Uint8List.fromList(compressed);
  }
}

/// Widget to display the selected image attachment
class ImageAttachment extends StatelessWidget {
  const ImageAttachment({
    super.key,
    required this.imageData,
    required this.onRemove,
  });

  final Uint8List imageData;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(
        left: AppDimensions.paddingMD,
        right: AppDimensions.paddingMD,
        bottom: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD - 1),
            child: Image.memory(
              imageData,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display image in chat bubble
class ChatImageDisplay extends StatelessWidget {
  const ChatImageDisplay({
    super.key,
    required this.imageData,
    this.onTap,
  });

  final Uint8List imageData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: Image.memory(
            imageData,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(imageData),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
