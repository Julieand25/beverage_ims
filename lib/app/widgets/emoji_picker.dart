import 'package:flutter/material.dart';
import '../app_colors.dart';

const List<String> kEmojiOptions = [
  '🧋', '🍵', '☕', '🥤', '🍹', '🧃', '🥛', '🍶',
  '🍯', '🍦', '🧊', '🍓', '🍎', '🍋', '🍊', '🥭',
  '🍇', '🍑', '🍍', '🍌', '🥝', '🥥', '🥑', '🍫',
  '🍪', '🧁', '🍩', '🍞', '🥞', '🥚', '🧀', '🥡',
  '🥫', '🫘', '🌾', '🧂', '📦', '🛍️', '🧴', '🧽',
];

class EmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final double size;

  const EmojiPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kEmojiOptions.map((emoji) {
        final isSelected = emoji == selected;
        return GestureDetector(
          onTap: () => onChanged(emoji),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? colors.card : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF5BA154) : colors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(emoji, style: TextStyle(fontSize: size - 14)),
          ),
        );
      }).toList(),
    );
  }
}