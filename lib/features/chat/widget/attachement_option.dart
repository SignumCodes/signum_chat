import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentOptions extends StatelessWidget {
  final Function(ImageSource) onImagePicked;
  final VoidCallback onFilePicked;
  final VoidCallback onLocationPicked;

  const AttachmentOptions({
    Key? key,
    required this.onImagePicked,
    required this.onFilePicked,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOption(
            color: Colors.blue[700]!,
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => onImagePicked(ImageSource.camera),
          ),
          _buildOption(
            color: Colors.green[700]!,
            icon: Icons.photo,
            label: 'Gallery',
            onTap: () => onImagePicked(ImageSource.gallery),
          ),
          _buildOption(
            color: Colors.orange[700]!,
            icon: Icons.file_copy,
            label: 'Document',
            onTap: onFilePicked,
          ),
          _buildOption(
            color: Colors.red[700]!,
            icon: Icons.location_on,
            label: 'Location',
            onTap: onLocationPicked,
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
