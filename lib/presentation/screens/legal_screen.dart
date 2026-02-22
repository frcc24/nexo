import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  static const routeName = '/legal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Privacidade'),
        backgroundColor: Colors.transparent,
      ),
      body: NexoBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: const [
              _LegalCard(
                title: 'Termos de Uso',
                body:
                    'Ao utilizar o NEXO, você concorda em usar o aplicativo apenas para fins pessoais e lícitos. '
                    'O aplicativo é fornecido no estado em que se encontra, sem garantias de disponibilidade contínua. '
                    'Podemos atualizar recursos, corrigir falhas e ajustar conteúdos a qualquer momento.',
              ),
              SizedBox(height: 12),
              _LegalCard(
                title: 'Aviso de Privacidade',
                body:
                    'O NEXO funciona offline e não exige cadastro. Dados de progresso (fases, estrelas e desbloqueios) '
                    'são armazenados localmente no seu dispositivo. O app pode exibir anúncios via provedores externos '
                    'que podem usar identificadores do dispositivo conforme políticas dessas plataformas.',
              ),
              SizedBox(height: 12),
              _LegalCard(
                title: 'Contato',
                body:
                    'Para dúvidas sobre estes termos ou privacidade, utilize os canais oficiais do desenvolvedor '
                    'informados na loja do aplicativo.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
