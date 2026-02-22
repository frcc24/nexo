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
      'undo': 'Undo',
      'restart': 'Restart',
      'hint': 'Hint',
      'stage_done': 'Level completed!',
      'stars': 'Stars',
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
      'undo': 'Desfazer',
      'restart': 'Reiniciar',
      'hint': 'Dica',
      'stage_done': 'Fase concluída!',
      'stars': 'Estrelas',
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
      'undo': 'Deshacer',
      'restart': 'Reiniciar',
      'hint': 'Pista',
      'stage_done': '¡Nivel completado!',
      'stars': 'Estrellas',
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
