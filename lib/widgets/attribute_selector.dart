import 'package:flutter/material.dart';
import '../models/attribute.dart';
import '../theme/app_colors.dart';
import 'attribute_row.dart';

// #$ AttributeOption — item do seletor. type == null representa "Outro".
// #!! "Saúde" (Figuras Nova Missão/Nova Tarefa) é o rótulo amigável do
// atributo Força no fluxo de criação; o XP continua indo pro atributo Força
// no dashboard. Ajuste aqui se a regra de negócio definir "Saúde" como
// categoria própria no backend.
class AttributeOption {
  final String label;
  final IconData icon;
  final Color color;
  final AttributeType? type;

  const AttributeOption({required this.label, required this.icon, required this.color, this.type});
}

final attributeOptions = <AttributeOption>[
  AttributeOption(label: AttributeType.inteligencia.label, icon: AttributeType.inteligencia.icon, color: attributeColor(AttributeType.inteligencia), type: AttributeType.inteligencia),
  AttributeOption(label: AttributeType.forca.label, icon: AttributeType.forca.icon, color: attributeColor(AttributeType.forca), type: AttributeType.forca),
  AttributeOption(label: AttributeType.espiritualidade.label, icon: AttributeType.espiritualidade.icon, color: attributeColor(AttributeType.espiritualidade), type: AttributeType.espiritualidade),
  AttributeOption(label: AttributeType.carisma.label, icon: AttributeType.carisma.icon, color: attributeColor(AttributeType.carisma), type: AttributeType.carisma),
  AttributeOption(label: AttributeType.percepcaoEspacial.label, icon: AttributeType.percepcaoEspacial.icon, color: attributeColor(AttributeType.percepcaoEspacial), type: AttributeType.percepcaoEspacial),
  AttributeOption(label: AttributeType.autoconsciencia.label, icon: AttributeType.autoconsciencia.icon, color: attributeColor(AttributeType.autoconsciencia), type: AttributeType.autoconsciencia),
  AttributeOption(label: AttributeType.linguagem.label, icon: AttributeType.linguagem.icon, color: attributeColor(AttributeType.linguagem), type: AttributeType.linguagem),
  AttributeOption(label: AttributeType.raciocinioLogico.label, icon: AttributeType.raciocinioLogico.icon, color: attributeColor(AttributeType.raciocinioLogico), type: AttributeType.raciocinioLogico),
  AttributeOption(label: AttributeType.musicalidade.label, icon: AttributeType.musicalidade.icon, color: attributeColor(AttributeType.musicalidade), type: AttributeType.musicalidade),
];

class AttributeSelector extends StatelessWidget {
  final AttributeOption? selected;
  final ValueChanged<AttributeOption> onSelected;

  const AttributeSelector({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attributeOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final option = attributeOptions[i];
          final isSelected = selected?.label == option.label;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              width: 78,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.border, width: isSelected ? 1.6 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option.icon, color: option.color, size: 20),
                  const SizedBox(height: 6),
                  Text(option.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 10.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
