/// Represents an issue ticket in the tracker.
class Ticket {
  final String id;
  final String title;
  final String description;
  final String priority; // CRITICO, MEDIO, BASSO
  final String status; // APERTO, IN CORSO, CHIUSO
  final String assignee;
  final DateTime createdAt;

  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.assignee,
    required this.createdAt,
  });
}

/// Sample tickets for UI demonstration.
final List<Ticket> sampleTickets = [
  Ticket(
    id: 'BUG-1042',
    title: 'Memory leak nel modulo di autenticazione',
    description:
        'Il modulo auth mantiene riferimenti ai controller anche dopo il dispose. '
        'Dopo circa 15 login/logout consecutivi la memoria heap cresce di ~200MB. '
        'Riprodotto su iOS 17 e Android 14. Stack trace allegato nei commenti.',
    priority: 'CRITICO',
    status: 'APERTO',
    assignee: 'Marco R.',
    createdAt: DateTime(2026, 3, 8),
  ),
  Ticket(
    id: 'BUG-1041',
    title: 'Offset UI nelle card della dashboard',
    description:
        'Le card statistiche nella dashboard hanno un offset di 4px a sinistra '
        'su schermi con larghezza < 400px. Il problema è visibile solo in modalità '
        'portrait. Probabilmente legato al padding del CyberPanel.',
    priority: 'MEDIO',
    status: 'IN CORSO',
    assignee: 'Laura B.',
    createdAt: DateTime(2026, 3, 7),
  ),
  Ticket(
    id: 'FEAT-089',
    title: 'Aggiungere filtro per data di creazione',
    description:
        'Gli utenti chiedono la possibilità di filtrare i ticket per data di '
        'creazione. Serve un date range picker coerente con lo stile UI attuale. '
        'Priorità bassa ma richiesto da 12 utenti nel feedback.',
    priority: 'BASSO',
    status: 'APERTO',
    assignee: 'Non assegnato',
    createdAt: DateTime(2026, 3, 6),
  ),
  Ticket(
    id: 'BUG-1040',
    title: 'API timeout su carico pesante',
    description:
        'Le chiamate REST all\'endpoint /api/tickets restituiscono timeout 504 '
        'quando ci sono più di 500 ticket nel database. Il problema è nel query '
        'di aggregazione che non usa indici. Necessario ottimizzare la query MongoDB.',
    priority: 'CRITICO',
    status: 'APERTO',
    assignee: 'Davide S.',
    createdAt: DateTime(2026, 3, 5),
  ),
  Ticket(
    id: 'BUG-1039',
    title: 'Glitch nel rendering dei font',
    description:
        'Su macOS con display Retina, il font monospace usato nei label HUD '
        'mostra artefatti di rendering a dimensioni < 10px. Il problema non '
        'si presenta su Windows o Linux. Potrebbe essere un bug di Skia.',
    priority: 'MEDIO',
    status: 'IN CORSO',
    assignee: 'Marco R.',
    createdAt: DateTime(2026, 3, 4),
  ),
  Ticket(
    id: 'FEAT-088',
    title: 'Notifiche push per ticket assegnati',
    description:
        'Implementare le notifiche push quando un ticket viene assegnato a un '
        'membro del team. Serve integrazione con Firebase Cloud Messaging per '
        'Android/iOS e Web Push API per la versione web.',
    priority: 'BASSO',
    status: 'APERTO',
    assignee: 'Non assegnato',
    createdAt: DateTime(2026, 3, 3),
  ),
];

