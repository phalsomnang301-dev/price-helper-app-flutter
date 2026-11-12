import 'package:flutter/material.dart';

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "យល់ព្រម",
          onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
        ),
      ),
    );
}

Future<bool?> showDeleteDialog(
  BuildContext context, {
  String itemName = 'ទំនិញនេះ',
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        icon: Icon(Icons.delete_outline, color: scheme.error, size: 32),
        title: const Text("បញ្ជាក់ការលុប"),
        content: Text("តើអ្នកប្រាកដថាចង់លុប \"$itemName\" មែនទេ?\nការលុបមិនអាចត្រឡប់វិញបានទេ។"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("បោះបង់"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("លុប"),
          ),
        ],
      );
    },
  );
}