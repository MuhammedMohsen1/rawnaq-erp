part of 'pricing_item_card.dart';

mixin PricingItemCardImageActions on State<PricingItemCard> {
  PricingApiDataSource get apiDataSource;
  ImagePicker get imagePicker;
  Map<String, bool> get uploadingImages;
  Map<String, bool> get deletingImages;
  Map<String, int> get selectedImageIndex;

  Future<Uint8List?> _getClipboardImage() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes != null && bytes.isNotEmpty) {
        print('Clipboard image found: ${bytes.length} bytes');
        return bytes;
      }
    } catch (e) {
      print('Failed to read clipboard image: $e');
    }
    return null;
  }

  Future<List<MapEntry<String, Uint8List>>> _pickImagesForPreview({
    required bool tryClipboardFirst,
    required bool forceFilePicker,
  }) async {
    final pickedImages = <MapEntry<String, Uint8List>>[];

    if (tryClipboardFirst && !kIsWeb) {
      final clipboardImage = await _getClipboardImage();
      if (clipboardImage != null) {
        pickedImages.add(
          MapEntry(
            'clipboard_${DateTime.now().millisecondsSinceEpoch}.png',
            clipboardImage,
          ),
        );
        return pickedImages;
      }
    }

    final useFilePicker =
        forceFilePicker ||
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (useFilePicker) {
      await Future.delayed(const Duration(milliseconds: 50));

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
        dialogTitle: 'اختر الصور',
      );

      if (result == null) return pickedImages;

      for (final file in result.files) {
        Uint8List? imageBytes = file.bytes;

        if (imageBytes == null && file.path != null && !kIsWeb) {
          imageBytes = await File(file.path!).readAsBytes();
        }

        if (imageBytes != null) {
          pickedImages.add(MapEntry(file.name, imageBytes));
        }
      }

      return pickedImages;
    }

    List<XFile> pickedFiles = [];

    try {
      pickedFiles = await imagePicker.pickMultiImage();
    } catch (_) {
      final single = await imagePicker.pickImage(source: ImageSource.gallery);
      if (single != null) pickedFiles = [single];
    }

    for (final file in pickedFiles) {
      pickedImages.add(MapEntry(file.name, await file.readAsBytes()));
    }

    return pickedImages;
  }

  Future<void> _pickImages(String subItemId) async {
    print('_pickImages called for subItem: $subItemId');

    try {
      setState(() {
        uploadingImages[subItemId] = true;
      });

      final pickedImages = await _pickImagesForPreview(
        tryClipboardFirst: true,
        forceFilePicker: false,
      );

      if (pickedImages.isEmpty) return;

      if (mounted) {
        await _cropPickedImagesThenUpload(subItemId, pickedImages);
      }
    } catch (e, stackTrace) {
      print('Image selection error: $e');
      print(stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل اختيار الصور: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          uploadingImages[subItemId] = false;
        });
      }
    }
  }

  Future<void> _pickImagesWithFilePicker(String subItemId) async {
    print('_pickImagesWithFilePicker called for subItem: $subItemId');
    try {
      setState(() {
        uploadingImages[subItemId] = true;
      });

      final pickedImages = await _pickImagesForPreview(
        tryClipboardFirst: false,
        forceFilePicker: true,
      );

      if (pickedImages.isEmpty) return;

      if (mounted) {
        await _cropPickedImagesThenUpload(subItemId, pickedImages);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        String errorMessage = 'فشل اختيار الصور: ${e.toString()}';

        if (e.toString().contains('NotFoundException') ||
            e.toString().contains('NOT_FOUND')) {
          errorMessage =
              'لا يمكن اختيار الصور حالياً. يرجى التحقق من أن:\n'
              '1. المشروع موجود\n'
              '2. إصدار التسعير في حالة "مسودة" (DRAFT)\n'
              '3. البند والبند الفرعية موجودة في هذا الإصدار';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print('Error picking images: $e');
      print('Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          uploadingImages[subItemId] = false;
        });
      }
    }
  }

  Future<void> _deleteImage(String subItemId, String imageUrl) async {
    print('_deleteImage called for subItem: $subItemId, imageUrl: $imageUrl');
    try {
      setState(() {
        deletingImages[imageUrl] = true;
      });

      await apiDataSource.deleteSubItemImage(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        imageUrl,
      );

      try {
        final updatedVersion = await apiDataSource.getPricingVersion(
          widget.projectId,
          widget.version,
        );
        final updatedItem = updatedVersion.items?.firstWhere(
          (i) => i.id == widget.item.id,
        );

        if (updatedItem != null && mounted) {
          final subItem = updatedItem.subItems?.firstWhere(
            (si) => si.id == subItemId,
            orElse: () => updatedItem.subItems!.first,
          );
          if (subItem != null) {
            final currentIndex = selectedImageIndex[subItemId] ?? 0;
            if (currentIndex >= (subItem.images.length)) {
              setState(() {
                selectedImageIndex[subItemId] = subItem.images.isEmpty
                    ? 0
                    : subItem.images.length - 1;
              });
            }
          }
          widget.onItemChanged?.call(updatedItem);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                'تم حذف الصورة ولكن فشل تحديث البيانات: ${e.toString()}',
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الصورة بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل حذف الصورة: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          deletingImages.remove(imageUrl);
        });
      }
    }
  }

  Future<void> _uploadSelectedImages(
    String subItemId,
    List<MapEntry<String, Uint8List>> selectedImages,
  ) async {
    if (selectedImages.isEmpty) return;

    try {
      setState(() {
        uploadingImages[subItemId] = true;
      });

      final imageBytesList = selectedImages
          .map((image) => MapEntry(image.key, image.value.toList()))
          .toList();

      await apiDataSource.uploadSubItemImages(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        [],
        imageBytes: imageBytesList,
      );

      final updatedVersion = await apiDataSource.getPricingVersion(
        widget.projectId,
        widget.version,
      );

      final updatedItem = updatedVersion.items?.firstWhere(
        (i) => i.id == widget.item.id,
      );

      if (!mounted) return;

      if (updatedItem != null) {
        widget.onItemChanged?.call(updatedItem);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الصور بنجاح'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      print('Upload pending images error: $e');
      print(stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصور: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          uploadingImages[subItemId] = false;
        });
      }
    }
  }

  Future<void> _showFullScreenImage(String subItemId, String imageUrl) async {
    showDialog(
      context: context,
      builder: (context) => Stack(
        clipBehavior: Clip.antiAlias,
        fit: StackFit.passthrough,
        children: [
          Center(child: Image.network(imageUrl, fit: BoxFit.fill)),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cropExistingImage(
    String subItemId,
    String imageUrl,
    int imageIndex,
  ) async {
    try {
      setState(() {
        uploadingImages[subItemId] = true;
      });

      final response = await HttpClient().getUrl(Uri.parse(imageUrl));
      final httpResponse = await response.close();
      final bytes = await httpResponse.fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );
      final imageBytes = Uint8List.fromList(bytes);

      if (!mounted) return;

      final croppedBytes = await ImageCropDialog.show(
        context,
        imageBytes,
        fileName: 'image_$imageIndex',
      );

      if (croppedBytes == null) {
        setState(() {
          uploadingImages[subItemId] = false;
        });
        return;
      }

      await apiDataSource.deleteSubItemImage(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        imageUrl,
      );

      await apiDataSource.uploadSubItemImages(
        widget.projectId,
        widget.version,
        widget.item.id,
        subItemId,
        [],
        imageBytes: [MapEntry('cropped_image.jpg', croppedBytes.toList())],
      );

      final updatedVersion = await apiDataSource.getPricingVersion(
        widget.projectId,
        widget.version,
      );
      final updatedItem = updatedVersion.items?.firstWhere(
        (i) => i.id == widget.item.id,
      );

      if (updatedItem != null && mounted) {
        widget.onItemChanged?.call(updatedItem);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قص الصورة بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('فشل قص الصورة: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          uploadingImages[subItemId] = false;
        });
      }
    }
  }

  Future<void> _cropPickedImagesThenUpload(
    String subItemId,
    List<MapEntry<String, Uint8List>> pickedImages,
  ) async {
    if (pickedImages.isEmpty) return;

    final croppedImages = <MapEntry<String, Uint8List>>[];

    for (final image in pickedImages) {
      if (!mounted) return;

      final croppedBytes = await ImageCropDialog.show(
        context,
        image.value,
        fileName: image.key,
      );

      if (croppedBytes == null) {
        return;
      }

      croppedImages.add(MapEntry(_croppedFileName(image.key), croppedBytes));
    }

    if (croppedImages.isEmpty) return;

    await _uploadSelectedImages(subItemId, croppedImages);
  }

  String _croppedFileName(String originalName) {
    final dotIndex = originalName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == originalName.length - 1) {
      return 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
    final name = originalName.substring(0, dotIndex);
    final extension = originalName.substring(dotIndex);
    return '${name}_cropped$extension';
  }
}
