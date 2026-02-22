import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/nexo_button.dart';
import '../widgets/rule_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NexoBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const NexoTitle(),
                const Spacer(),
                NexoButton(
                  label: 'JOGAR',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => Navigator.pushNamed(context, '/world-map'),
                ),
                const SizedBox(height: 14),
                NexoButton(
                  label: 'REGRAS',
                  icon: Icons.menu_book_rounded,
                  primary: false,
                  onPressed: () => showRulesModal(context),
                ),
                const SizedBox(height: 14),
                NexoButton(
                  label: 'MAIS JOGOS',
                  icon: Icons.games_outlined,
                  primary: false,
                  onPressed: () => Navigator.pushNamed(context, '/more-games'),
                ),
                const SizedBox(height: 14),
                NexoButton(
                  label: 'TERMOS E PRIVACIDADE',
                  icon: Icons.privacy_tip_outlined,
                  primary: false,
                  onPressed: () => Navigator.pushNamed(context, '/legal'),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/difficulty'),
                  child: const Text('Modo rápido (dificuldade)'),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
