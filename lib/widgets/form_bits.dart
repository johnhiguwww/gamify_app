import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// #f FormLabel — título de campo, com "?" opcional que abre uma dica rápida.
class FormLabel extends StatelessWidget {
  final String text;
  final String? tooltip;

  const FormLabel(this.text, {super.key, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5)),
          if (tooltip != null) ...[
            const SizedBox(width: 5),
            Tooltip(
              message: tooltip!,
              child: const Icon(Icons.help_outline, size: 14, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

// #f AppTextField — campo de texto padronizado com o visual do app,
// usado no Login e no Registro (e reaproveitável em outros formulários).
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// #$ SelectableBox — cartão clicável com ícone/título/subtítulo, usado em
// "Tipo de missão" e nos toggles de frequência.
class SelectableBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectableBox({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.primaryGreen : AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: selected ? AppColors.primaryGreen : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// #f MetricPill — caixinha "XP  0  Pontos de Experiência" (somente leitura)
// ou com um chevron (quando clicável, como em Nova Tarefa).
class MetricPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String caption;
  final bool showChevron;
  final VoidCallback? onTap;

  const MetricPill({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.caption,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(caption, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
                ],
              ),
            ),
            if (showChevron) const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
