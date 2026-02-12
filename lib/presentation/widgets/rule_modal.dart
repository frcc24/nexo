import 'package:flutter/material.dart';

import '../../domain/entities/cell_data.dart';
import '../theme/app_theme.dart';

Future<void> showRulesModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RulesSheet(),
  );
}

class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            Center(
              child: Text(
                'COMO JOGAR',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 14),
            _RuleSection(
              title: 'Objetivo',
              body:
                  'Conecte todas as células em um único caminho visitando cada uma exatamente uma vez.',
            ),
            _RuleSection(
              title: 'Regra 1: Mesma Cor',
              body:
                  'Se as cores forem iguais, os números devem diferir por exatamente 1.',
              example: _RuleExample(
                left: _BoxData(value: 2, color: CellColor.blue),
                right: _BoxData(value: 3, color: CellColor.blue),
                isValid: true,
              ),
            ),
            _RuleSection(
              title: 'Regra 2: Cor Diferente',
              body:
                  'Se as cores forem diferentes, os números devem ser iguais.',
              example: _RuleExample(
                left: _BoxData(value: 3, color: CellColor.blue),
                right: _BoxData(value: 3, color: CellColor.red),
                isValid: true,
              ),
            ),
            _RuleSection(
              title: 'Movimento Inválido',
              body:
                  'Movimentos diagonais, repetidos ou que violem as regras são rejeitados.',
              example: _RuleExample(
                left: _BoxData(value: 2, color: CellColor.red),
                right: _BoxData(value: 4, color: CellColor.blue),
                isValid: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleSection extends StatelessWidget {
  const _RuleSection({required this.title, required this.body, this.example});

  final String title;
  final String body;
  final Widget? example;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF38E0FF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(color: AppTheme.textSecondary)),
            if (example != null) ...[const SizedBox(height: 12), example!],
          ],
        ),
      ),
    );
  }
}

class _BoxData {
  const _BoxData({required this.value, required this.color});

  final int value;
  final CellColor color;
}

class _RuleExample extends StatelessWidget {
  const _RuleExample({
    required this.left,
    required this.right,
    required this.isValid,
  });

  final _BoxData left;
  final _BoxData right;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ruleBox(left),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, color: Colors.white70),
        ),
        _ruleBox(right),
        const SizedBox(width: 10),
        Icon(
          isValid ? Icons.check : Icons.close,
          color: isValid ? const Color(0xFF46E07F) : const Color(0xFFFF656B),
        ),
      ],
    );
  }

  Widget _ruleBox(_BoxData data) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: data.color.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${data.value}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
