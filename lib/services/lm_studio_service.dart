import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service per comunicare con LM Studio locale via REST API.
class LmStudioService {
  // Cambia in 10.0.2.2 per emulatore Android
  static const String _baseUrl = 'http://127.0.0.1:1234';

  /// Invia il contenuto di un ticket e un messaggio opzionale dell'utente
  /// all'LLM e restituisce la risposta.
  ///
  /// Se [userMessage] è vuoto, l'AI spiega semplicemente il problema del ticket.
  static Future<String> analyzeTicket({
    required String ticketId,
    required String ticketTitle,
    required String ticketDescription,
    String userMessage = '',
  }) async {
    final systemPrompt =
        '/no_think\n'
        'Sei un assistente tecnico esperto di sviluppo software e bug tracking. '
        'Analizza i ticket che ti vengono inviati e fornisci risposte chiare, '
        'concise e strutturate. '
        'REGOLE IMPORTANTI:\n'
        '- Rispondi SOLO in italiano.\n'
        '- NON usare tag <think> o blocchi di ragionamento.\n'
        '- NON mostrare mai il tuo processo di pensiero interno.\n'
        '- Vai DRITTO alla risposta utile.\n'
        '- Usa questa struttura:\n'
        '  1. PROBLEMA: spiega il problema in modo chiaro\n'
        '  2. POSSIBILI CAUSE: elenca le cause probabili\n'
        '  3. SOLUZIONE: suggerisci come risolvere\n'
        '- Sii conciso e pratico.';

    final ticketContent =
        '--- TICKET $ticketId ---\n'
        'Titolo: $ticketTitle\n'
        'Descrizione: $ticketDescription\n'
        '--- FINE TICKET ---';

    final String userPrompt;
    if (userMessage.trim().isEmpty) {
      userPrompt =
          '$ticketContent\n\n'
          'Analizza questo ticket. Rispondi direttamente in italiano con: '
          '1) Il problema probabile, 2) Le possibili cause, 3) La soluzione suggerita. '
          'Non mostrare ragionamenti interni.';
    } else {
      userPrompt =
          '$ticketContent\n\n'
          'Domanda dell\'utente: $userMessage\n\n'
          'Rispondi direttamente in italiano. Non mostrare ragionamenti interni.';
    }

    final body = {
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.4,
      'max_tokens': 4096,
    };

    // Prova prima l'API nativa v1, poi fallback su OpenAI-compat
    try {
      final raw = await _postChat('$_baseUrl/api/v1/chat', body);
      return _cleanResponse(raw);
    } catch (_) {
      final raw = await _postChat('$_baseUrl/v1/chat/completions', {
        ...body,
        'model': 'local-model',
      });
      return _cleanResponse(raw);
    }
  }

  /// Rimuove blocchi di "thinking" / ragionamento dal testo dell'LLM.
  static String _cleanResponse(String text) {
    var cleaned = text;

    // Strategia 1: Se c'è </think>, prendi SOLO quello che viene dopo
    final closeTag = cleaned.lastIndexOf('</think>');
    if (closeTag != -1) {
      cleaned = cleaned.substring(closeTag + '</think>'.length);
      return cleaned.trim();
    }

    // Strategia 2: Se c'è <think> aperto ma non chiuso,
    // il contenuto utile potrebbe essere mischiato — prova a estrarre
    // la parte strutturata (1. PROBLEMA...)
    final thinkOpen = cleaned.indexOf('<think>');
    if (thinkOpen != -1) {
      // Cerca se c'è "1. PROBLEMA" o "PROBLEMA:" dopo il <think>
      final problemaMatch = RegExp(
        r'1\.\s*PROBLEMA',
        caseSensitive: false,
      ).firstMatch(cleaned);

      if (problemaMatch != null) {
        cleaned = cleaned.substring(problemaMatch.start);
        return cleaned.trim();
      }

      // Niente struttura trovata, rimuovi il tag e restituisci tutto
      cleaned = cleaned.replaceAll('<think>', '');
      return cleaned.trim();
    }

    // Strategia 3: Nessun tag <think>, ma potrebbe esserci
    // "Thinking Process:" o simili prima della risposta vera
    final problemaMatch = RegExp(
      r'1\.\s*PROBLEMA',
      caseSensitive: false,
    ).firstMatch(cleaned);

    if (problemaMatch != null && problemaMatch.start > 50) {
      // C'è molto testo spazzatura prima di "1. PROBLEMA"
      cleaned = cleaned.substring(problemaMatch.start);
    }

    return cleaned.trim();
  }

  static Future<String> _postChat(
    String url,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // API nativa v1 format
      if (data.containsKey('choices')) {
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'] as String;
        }
      }
      // Fallback
      if (data.containsKey('response')) {
        return data['response'] as String;
      }

      throw Exception('Formato risposta non riconosciuto');
    } else {
      throw Exception(
        'Errore LM Studio ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Verifica se il server LM Studio è raggiungibile.
  static Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/v1/models'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      // Prova endpoint OpenAI-compat
      try {
        final response = await http
            .get(Uri.parse('$_baseUrl/v1/models'))
            .timeout(const Duration(seconds: 5));
        return response.statusCode == 200;
      } catch (_) {
        return false;
      }
    }
  }
}

