import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('es'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'NEXO',
      'subtitle': 'LOGIC CONNECTIONS',
      'play': 'PLAY',
      'rules': 'RULES',
      'more_games': 'MORE GAMES',
      'settings': 'SETTINGS',
      'terms_privacy': 'TERMS & PRIVACY',
      'quick_mode': 'Quick mode (difficulty)',
      'choose_difficulty': 'Choose difficulty',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'back': 'Back',
      'world_map': 'World Map',
      'world': 'World',
      'world_completed': 'Completed world',
      'undo': 'Undo',
      'restart': 'Restart',
      'hint': 'Hint',
      'stage_done': 'Level completed!',
      'stars': 'Stars',
      'score': 'Score',
      'time': 'Time',
      'hints_used': 'Hints used',
      'undos_used': 'Undos used',
      'restarts_used': 'Restarts used',
      'path_complete': 'Completed path',
      'next_level': 'Next level',
      'map': 'Map',
      'more_games_subtitle': 'Discover this game and install from the store:',
      'app_store_soon': 'App Store coming soon.',
      'store_open_error': 'Could not open the store right now.',
      'terms_title': 'Terms & Privacy',
      'terms_use': 'Terms of Use',
      'privacy_notice': 'Privacy Notice',
      'contact': 'Contact',
      'terms_use_body':
          'By using NEXO, you agree to use the app only for personal and lawful purposes. The app is provided as is, without guarantees of continuous availability. Features and content may be updated at any time.',
      'privacy_notice_body':
          'NEXO works offline and does not require account registration. Progress data (levels, stars and unlocks) is stored locally on your device. This app uses ads (Unity Ads) and may collect device identifiers and technical data for ad delivery, frequency capping and measurement, according to provider and store policies.',
      'contact_body':
          'For questions about these terms or privacy, use the official developer channels listed in the app stores.',
      'language': 'Language',
      'language_pt': 'Portuguese',
      'language_en': 'English',
      'language_es': 'Spanish',
      'choose_language': 'Choose app language',
      'debug_options': 'Debug options',
      'debug_unlock_all': 'Unlock all levels in debug',
      'debug_unlock_all_desc': 'Turn off to test real lock/unlock progression.',
      'unlock_level_title': 'Unlock level',
      'watch_ad_unlock': 'Watch ad',
      'locked_level_hint': 'Complete previous levels to unlock this one.',
      'unlock_with_ad_message':
          'Watch a rewarded ad to unlock level {level} now?',
      'unlock_success': 'Level {level} unlocked!',
      'reward_ad_failed': 'Could not complete rewarded ad. Try again.',
      'new_rules': 'New Rules',
      'anchor_progress': 'Anchors',
      'anchor_locked_message': 'Complete {required} to unlock {current}.',
      'rule_anchors_title': 'Rule 3: Anchors',
      'rule_anchors_body':
          'Special anchor cells must be visited in order: A1, then A2, then A3...',
      'rule_portals_title': 'Rule 3: Portals',
      'rule_portals_body':
          'When standing on a portal cell (P1, P2...), you can jump to its pair as your next move.',
      'remove_ads': 'Remove ads',
      'remove_ads_for': 'Remove ads for {price}',
      'ads_removed_active': 'Ads are disabled for this app.',
      'buy': 'Buy',
      'processing': 'Processing...',
      'restore_purchases': 'Restore purchases',
      'purchase_error_short': 'Could not complete purchase. Try again.',
      'route_error_title': 'You left the correct route.',
      'route_error_next': 'Next correct step: ({row}, {col})',
      'how_to_play': 'HOW TO PLAY',
      'objective': 'Objective',
      'objective_body':
          'Connect all cells in a single path, visiting each cell exactly once.',
      'rule_same_color': 'Rule 1: Same Color',
      'rule_same_color_body':
          'If colors are the same, numbers must differ by exactly 1.',
      'rule_diff_color': 'Rule 2: Different Color',
      'rule_diff_color_body': 'If colors are different, numbers must be equal.',
      'invalid_move': 'Invalid Move',
      'invalid_move_body':
          'Diagonal, repeated or rule-breaking moves are rejected.',
    },
    'pt': {
      'app_title': 'NEXO',
      'subtitle': 'CONEXÕES LÓGICAS',
      'play': 'JOGAR',
      'rules': 'REGRAS',
      'more_games': 'MAIS JOGOS',
      'settings': 'CONFIGURAÇÕES',
      'terms_privacy': 'TERMOS E PRIVACIDADE',
      'quick_mode': 'Modo rápido (dificuldade)',
      'choose_difficulty': 'Escolha a dificuldade',
      'easy': 'Fácil',
      'medium': 'Médio',
      'hard': 'Difícil',
      'back': 'Voltar',
      'world_map': 'Mapa de Mundos',
      'world': 'Mundo',
      'world_completed': 'Mundo concluído',
      'undo': 'Desfazer',
      'restart': 'Reiniciar',
      'hint': 'Dica',
      'stage_done': 'Fase concluída!',
      'stars': 'Estrelas',
      'score': 'Pontuação',
      'time': 'Tempo',
      'hints_used': 'Dicas usadas',
      'undos_used': 'Desfazer usado',
      'restarts_used': 'Reiniciar usado',
      'path_complete': 'Caminho completo',
      'next_level': 'Próxima fase',
      'map': 'Mapa',
      'more_games_subtitle': 'Conheça este jogo e instale pela loja:',
      'app_store_soon': 'App Store em breve.',
      'store_open_error': 'Não foi possível abrir a loja agora.',
      'terms_title': 'Termos e Privacidade',
      'terms_use': 'Termos de Uso',
      'privacy_notice': 'Aviso de Privacidade',
      'contact': 'Contato',
      'terms_use_body':
          'Ao utilizar o NEXO, você concorda em usar o aplicativo apenas para fins pessoais e lícitos. O aplicativo é fornecido no estado em que se encontra, sem garantias de disponibilidade contínua. Podemos atualizar recursos e conteúdos a qualquer momento.',
      'privacy_notice_body':
          'O NEXO funciona offline e não exige cadastro. Dados de progresso (fases, estrelas e desbloqueios) são armazenados localmente no seu dispositivo. Este app usa anúncios (Unity Ads) e pode coletar identificadores do dispositivo e dados técnicos para entrega, limitação de frequência e medição dos anúncios, conforme as políticas do provedor e das lojas.',
      'contact_body':
          'Para dúvidas sobre estes termos ou privacidade, utilize os canais oficiais do desenvolvedor informados nas lojas do aplicativo.',
      'language': 'Idioma',
      'language_pt': 'Português',
      'language_en': 'Inglês',
      'language_es': 'Espanhol',
      'choose_language': 'Escolha o idioma do app',
      'debug_options': 'Opções de debug',
      'debug_unlock_all': 'Desbloquear tudo no debug',
      'debug_unlock_all_desc':
          'Desative para testar o fluxo real de bloqueio e desbloqueio.',
      'unlock_level_title': 'Desbloquear fase',
      'watch_ad_unlock': 'Ver anúncio',
      'locked_level_hint':
          'Conclua as fases anteriores para liberar esta fase.',
      'unlock_with_ad_message':
          'Assista a um anúncio recompensado para desbloquear a fase {level} agora?',
      'unlock_success': 'Fase {level} desbloqueada!',
      'reward_ad_failed':
          'Não foi possível concluir o anúncio recompensado. Tente novamente.',
      'new_rules': 'Novas Regras',
      'anchor_progress': 'Âncoras',
      'anchor_locked_message': 'Passe por {required} para liberar {current}.',
      'rule_anchors_title': 'Regra 3: Âncoras',
      'rule_anchors_body':
          'Células especiais de âncora devem ser visitadas em ordem: A1, depois A2, depois A3...',
      'rule_portals_title': 'Regra 3: Portais',
      'rule_portals_body':
          'Ao estar em uma célula de portal (P1, P2...), você pode saltar para o portal par no próximo movimento.',
      'remove_ads': 'Remover anúncios',
      'remove_ads_for': 'Remover anúncios por {price}',
      'ads_removed_active': 'Anúncios desativados neste app.',
      'buy': 'Comprar',
      'processing': 'Processando...',
      'restore_purchases': 'Restaurar compras',
      'purchase_error_short':
          'Não foi possível concluir a compra. Tente novamente.',
      'route_error_title': 'Você saiu da rota correta.',
      'route_error_next': 'Próximo passo correto: ({row}, {col})',
      'how_to_play': 'COMO JOGAR',
      'objective': 'Objetivo',
      'objective_body':
          'Conecte todas as células em um único caminho visitando cada uma exatamente uma vez.',
      'rule_same_color': 'Regra 1: Mesma Cor',
      'rule_same_color_body':
          'Se as cores forem iguais, os números devem diferir por exatamente 1.',
      'rule_diff_color': 'Regra 2: Cor Diferente',
      'rule_diff_color_body':
          'Se as cores forem diferentes, os números devem ser iguais.',
      'invalid_move': 'Movimento Inválido',
      'invalid_move_body':
          'Movimentos diagonais, repetidos ou que violem as regras são rejeitados.',
    },
    'es': {
      'app_title': 'NEXO',
      'subtitle': 'CONEXIONES LÓGICAS',
      'play': 'JUGAR',
      'rules': 'REGLAS',
      'more_games': 'MÁS JUEGOS',
      'settings': 'CONFIGURACIÓN',
      'terms_privacy': 'TÉRMINOS Y PRIVACIDAD',
      'quick_mode': 'Modo rápido (dificultad)',
      'choose_difficulty': 'Elige la dificultad',
      'easy': 'Fácil',
      'medium': 'Medio',
      'hard': 'Difícil',
      'back': 'Volver',
      'world_map': 'Mapa de Mundos',
      'world': 'Mundo',
      'world_completed': 'Mundo completado',
      'undo': 'Deshacer',
      'restart': 'Reiniciar',
      'hint': 'Pista',
      'stage_done': '¡Nivel completado!',
      'stars': 'Estrellas',
      'score': 'Puntuación',
      'time': 'Tiempo',
      'hints_used': 'Pistas usadas',
      'undos_used': 'Deshacer usado',
      'restarts_used': 'Reiniciar usado',
      'path_complete': 'Camino completo',
      'next_level': 'Siguiente nivel',
      'map': 'Mapa',
      'more_games_subtitle': 'Conoce este juego e instálalo desde la tienda:',
      'app_store_soon': 'App Store próximamente.',
      'store_open_error': 'No se pudo abrir la tienda ahora.',
      'terms_title': 'Términos y Privacidad',
      'terms_use': 'Términos de Uso',
      'privacy_notice': 'Aviso de Privacidad',
      'contact': 'Contacto',
      'terms_use_body':
          'Al usar NEXO, aceptas utilizar la aplicación solo con fines personales y lícitos. La app se proporciona tal cual, sin garantías de disponibilidad continua. Podemos actualizar funciones y contenido en cualquier momento.',
      'privacy_notice_body':
          'NEXO funciona sin conexión y no requiere registro. Los datos de progreso (niveles, estrellas y desbloqueos) se almacenan localmente en tu dispositivo. Esta app usa anuncios (Unity Ads) y puede recopilar identificadores del dispositivo y datos técnicos para entrega, limitación de frecuencia y medición de anuncios, según las políticas del proveedor y de las tiendas.',
      'contact_body':
          'Para dudas sobre estos términos o privacidad, usa los canales oficiales del desarrollador indicados en las tiendas de aplicaciones.',
      'language': 'Idioma',
      'language_pt': 'Portugués',
      'language_en': 'Inglés',
      'language_es': 'Español',
      'choose_language': 'Elige el idioma de la app',
      'debug_options': 'Opciones de depuración',
      'debug_unlock_all': 'Desbloquear todo en depuración',
      'debug_unlock_all_desc':
          'Desactiva para probar el flujo real de bloqueo y desbloqueo.',
      'unlock_level_title': 'Desbloquear nivel',
      'watch_ad_unlock': 'Ver anuncio',
      'locked_level_hint':
          'Completa los niveles anteriores para desbloquear este.',
      'unlock_with_ad_message':
          '¿Ver un anuncio recompensado para desbloquear el nivel {level} ahora?',
      'unlock_success': '¡Nivel {level} desbloqueado!',
      'reward_ad_failed':
          'No se pudo completar el anuncio recompensado. Inténtalo de nuevo.',
      'new_rules': 'Nuevas Reglas',
      'anchor_progress': 'Anclas',
      'anchor_locked_message':
          'Completa {required} para desbloquear {current}.',
      'rule_anchors_title': 'Regla 3: Anclas',
      'rule_anchors_body':
          'Las celdas especiales de ancla deben visitarse en orden: A1, luego A2, luego A3...',
      'rule_portals_title': 'Regla 3: Portales',
      'rule_portals_body':
          'Cuando estés en una celda portal (P1, P2...), puedes saltar al portal par en el siguiente movimiento.',
      'remove_ads': 'Eliminar anuncios',
      'remove_ads_for': 'Eliminar anuncios por {price}',
      'ads_removed_active': 'Los anuncios están desactivados en esta app.',
      'buy': 'Comprar',
      'processing': 'Procesando...',
      'restore_purchases': 'Restaurar compras',
      'purchase_error_short':
          'No se pudo completar la compra. Inténtalo de nuevo.',
      'route_error_title': 'Saliste de la ruta correcta.',
      'route_error_next': 'Siguiente paso correcto: ({row}, {col})',
      'how_to_play': 'CÓMO JUGAR',
      'objective': 'Objetivo',
      'objective_body':
          'Conecta todas las celdas en un solo camino, visitando cada celda exactamente una vez.',
      'rule_same_color': 'Regla 1: Mismo Color',
      'rule_same_color_body':
          'Si los colores son iguales, los números deben diferir exactamente en 1.',
      'rule_diff_color': 'Regla 2: Color Diferente',
      'rule_diff_color_body':
          'Si los colores son diferentes, los números deben ser iguales.',
      'invalid_move': 'Movimiento Inválido',
      'invalid_move_body':
          'Los movimientos diagonales, repetidos o que rompen reglas son rechazados.',
    },
  };

  String t(String key) {
    final lang =
        _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return lang[key] ?? _localizedValues['en']![key] ?? key;
  }

  String routeErrorNext({required int row, required int col}) {
    return t(
      'route_error_next',
    ).replaceFirst('{row}', '$row').replaceFirst('{col}', '$col');
  }

  String removeAdsFor({required String price}) {
    return t('remove_ads_for').replaceFirst('{price}', price);
  }

  String anchorLockedMessage({
    required String requiredAnchor,
    required String currentAnchor,
  }) {
    return t('anchor_locked_message')
        .replaceFirst('{required}', requiredAnchor)
        .replaceFirst('{current}', currentAnchor);
  }

  String unlockWithAdMessage(int level) {
    return t('unlock_with_ad_message').replaceFirst('{level}', '$level');
  }

  String unlockSuccess(int level) {
    return t('unlock_success').replaceFirst('{level}', '$level');
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
