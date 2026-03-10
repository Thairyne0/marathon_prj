import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/ticket.dart';
import '../models/ai_conversation.dart';
import '../services/lm_studio_service.dart';
import '../widgets/widgets.dart';

/// Pagina ticket con 3 sezioni:
/// - SINISTRA: lista ticket
/// - CENTRO: dettaglio ticket + chat AI
/// - DESTRA: storico conversazioni AI
class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage>
    with TickerProviderStateMixin {
  static const _neon = Color(0xFFC6FF00);
  static const _violet = Color(0xFF470BF6);
  static const _cyan = Color(0xFF00D9FF);
  static const _dark = Color(0xFF111111);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _pixelDone = false;

  // State
  Ticket? _selectedTicket;
  final _messageController = TextEditingController();
  final _chatScrollController = ScrollController();
  bool _aiLoading = false;
  String? _lastAiResponse;
  final List<AiConversation> _history = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _sendToAi() async {
    if (_selectedTicket == null) return;
    final ticket = _selectedTicket!;
    final userMsg = _messageController.text.trim();

    setState(() {
      _aiLoading = true;
      _lastAiResponse = null;
    });

    try {
      final response = await LmStudioService.analyzeTicket(
        ticketId: ticket.id,
        ticketTitle: ticket.title,
        ticketDescription: ticket.description,
        userMessage: userMsg,
      );

      setState(() {
        _lastAiResponse = response;
        _history.insert(
          0,
          AiConversation(
            ticketId: ticket.id,
            ticketTitle: ticket.title,
            userMessage:
                userMsg.isEmpty ? '[Analisi automatica]' : userMsg,
            aiResponse: response,
            timestamp: DateTime.now(),
          ),
        );
        _messageController.clear();
      });
    } catch (e) {
      setState(() {
        _lastAiResponse = 'ERRORE: $e';
      });
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildMainContent()),
                    ],
                  ),
                ),
                _buildBrandBar(),
              ],
            ),
          ),
          if (!_pixelDone)
            Positioned.fill(
              child: IgnorePointer(
                child: PixelTransition(
                  direction: PixelTransitionDirection.greenToBlack,
                  sweepDirection: PixelSweepDirection.bottomToTop,
                  autoStart: true,
                  startDelay: const Duration(milliseconds: 200),
                  pixelInterval: const Duration(milliseconds: 5),
                  batchSize: 6,
                  onPhaseComplete: () {
                    if (mounted) setState(() => _pixelDone = true);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── MAIN 3-COLUMN CONTENT ───────────────────────────────────────────
  Widget _buildMainContent() {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 900;

          if (narrow) {
            // Stacked layout su schermi stretti
            return _selectedTicket == null
                ? _buildTicketList()
                : _buildAiChatPanel();
          }

          return Row(
            children: [
              // LEFT: Ticket list
              SizedBox(
                width: 280,
                child: _buildTicketList(),
              ),
              Container(width: 1, color: Colors.white.withValues(alpha: 0.04)),

              // CENTER: AI Chat
              Expanded(flex: 5, child: _buildAiChatPanel()),
              Container(width: 1, color: Colors.white.withValues(alpha: 0.04)),

              // RIGHT: History
              Expanded(flex: 3, child: _buildHistoryPanel()),
            ],
          );
        },
      ),
    );
  }

  // ─── TICKET LIST (LEFT) ──────────────────────────────────────────────
  Widget _buildTicketList() {
    return Container(
      color: const Color(0xFF080808),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: _neon),
                const SizedBox(width: 10),
                Text(
                  'TICKETS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sampleTickets.length}',
                  style: TextStyle(
                    color: _neon.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.04),
          ),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: sampleTickets.length,
              itemBuilder: (context, i) {
                final t = sampleTickets[i];
                final selected = _selectedTicket?.id == t.id;
                return _buildTicketTile(t, selected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTile(Ticket ticket, bool selected) {
    final priorityColor = switch (ticket.priority) {
      'CRITICO' => _neon,
      'MEDIO' => _violet,
      _ => Colors.white.withValues(alpha: 0.25),
    };

    return GestureDetector(
      onTap: () => setState(() {
        _selectedTicket = ticket;
        _lastAiResponse = null;
      }),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? _neon.withValues(alpha: 0.04)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected ? _neon : Colors.transparent,
                width: 2,
              ),
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID + priority
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    color: priorityColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ticket.id,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: priorityColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      ticket.priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                ticket.title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Status + assignee
              Row(
                children: [
                  Text(
                    ticket.status,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${ticket.assignee}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.15),
                      fontSize: 8,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AI CHAT PANEL (CENTER) ──────────────────────────────────────────
  Widget _buildAiChatPanel() {
    if (_selectedTicket == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bug_report_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 16),
            Text(
              'SELEZIONA UN TICKET',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.15),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      );
    }

    final ticket = _selectedTicket!;
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Column(
      children: [
        // Ticket detail header
        _buildTicketDetailHeader(ticket, isNarrow),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.04)),

        // AI response area
        Expanded(child: _buildResponseArea()),

        // Input area
        Container(height: 1, color: Colors.white.withValues(alpha: 0.04)),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildTicketDetailHeader(Ticket ticket, bool isNarrow) {
    final priorityColor = switch (ticket.priority) {
      'CRITICO' => _neon,
      'MEDIO' => _violet,
      _ => Colors.white.withValues(alpha: 0.25),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isNarrow) ...[
                GestureDetector(
                  onTap: () => setState(() => _selectedTicket = null),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: priorityColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  ticket.id,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: priorityColor.withValues(alpha: 0.1),
                child: Text(
                  ticket.priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: Colors.white.withValues(alpha: 0.04),
                child: Text(
                  ticket.status,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ticket.assignee,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.7,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseArea() {
    return Container(
      color: Colors.black,
      child: _aiLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _neon.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI STA ANALIZZANDO...',
                    style: TextStyle(
                      color: _neon.withValues(alpha: 0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            )
          : _lastAiResponse != null
              ? SingleChildScrollView(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 3, height: 12, color: _cyan),
                          const SizedBox(width: 8),
                          Text(
                            'RISPOSTA AI',
                            style: TextStyle(
                              color: _cyan.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        _lastAiResponse!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.8,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.smart_toy_outlined,
                        size: 36,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'INVIA IL TICKET ALL\'AI PER ANALIZZARLO',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.12),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lascia vuoto il messaggio per un\'analisi automatica',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.08),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF080808),
      child: Row(
        children: [
          Expanded(
            child: CyberTextField(
              controller: _messageController,
              hintText: 'Chiedi qualcosa sull\'issue... (vuoto = analisi auto)',
              prefixIcon: Icons.smart_toy_outlined,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _aiLoading ? null : _sendToAi,
            child: MouseRegion(
              cursor: _aiLoading
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _aiLoading
                      ? _neon.withValues(alpha: 0.2)
                      : _neon,
                ),
                child: Center(
                  child: Icon(
                    Icons.send,
                    color: _aiLoading
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HISTORY PANEL (RIGHT) ───────────────────────────────────────────
  Widget _buildHistoryPanel() {
    return Container(
      color: const Color(0xFF080808),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: _violet),
                const SizedBox(width: 10),
                Text(
                  'STORICO AI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_history.length}',
                  style: TextStyle(
                    color: _violet.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.04)),

          // History items
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Text(
                      'NESSUNA\nCONVERSAZIONE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.08),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        height: 1.6,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, i) =>
                        _buildHistoryTile(_history[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(AiConversation conv) {
    final isSelected = _selectedTicket?.id == conv.ticketId;

    return GestureDetector(
      onTap: () {
        setState(() => _lastAiResponse = conv.aiResponse);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? _violet.withValues(alpha: 0.04)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket ID + time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _violet.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      conv.ticketId,
                      style: TextStyle(
                        color: _violet.withValues(alpha: 0.7),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${conv.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${conv.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.15),
                      fontSize: 8,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // User question
              Text(
                conv.userMessage,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // AI response preview
              Text(
                conv.aiResponse,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2),
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SIDEBAR (reused from hero_page) ─────────────────────────────────
  Widget _buildSidebar() {
    final items = <_SidebarItem>[
      _SidebarItem(Icons.dashboard_outlined, 'DASHBOARD', '/hero'),
      _SidebarItem(Icons.bug_report_outlined, 'TICKETS', '/tickets'),
      _SidebarItem(Icons.code, 'PROJECTS', null),
      _SidebarItem(Icons.people_outline, 'TEAM', null),
      _SidebarItem(Icons.analytics_outlined, 'ANALYTICS', null),
      _SidebarItem(Icons.settings_outlined, 'SETTINGS', null),
    ];

    return Container(
      width: 64,
      color: _dark,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border:
                  Border.all(color: _neon.withValues(alpha: 0.4), width: 1),
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: _neon,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 24,
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 16),
          ...List.generate(items.length, (i) {
            final selected = i == 1; // TICKETS is selected
            return _buildSidebarIcon(
              icon: items[i].icon,
              label: items[i].label,
              selected: selected,
              onTap: () {
                if (items[i].route != null) {
                  context.go(items[i].route!);
                }
              },
            );
          }),
          const Spacer(),
          CyberIconBox(
            icon: Icons.add,
            size: 28,
            color: _violet,
            borderWidth: 1,
            glowOnHover: false,
          ),
          const SizedBox(height: 12),
          CyberIconBox(
            icon: Icons.fiber_manual_record,
            size: 28,
            iconSize: 6,
            color: _violet,
            borderWidth: 1,
            glowOnHover: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      preferBelow: false,
      decoration: BoxDecoration(
        color: _dark,
        border: Border.all(color: _neon.withValues(alpha: 0.2)),
      ),
      textStyle: const TextStyle(
        color: _neon,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? _neon.withValues(alpha: 0.06)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: selected ? _neon : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: selected
                    ? _neon
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      height: 52,
      color: _dark,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'BUGBOARD26',
            style: TextStyle(
              color: _neon,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(width: 12),
          Text(
            'TICKETS & AI',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          // AI Status
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _cyan,
              boxShadow: [
                BoxShadow(
                  color: _cyan.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LM STUDIO',
            style: TextStyle(
              color: _cyan.withValues(alpha: 0.6),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '[ SYS-26 ]',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 16),
          CyberIconBox(
            icon: Icons.person_outline,
            size: 30,
            color: _neon,
            borderWidth: 1,
            glowOnHover: true,
          ),
        ],
      ),
    );
  }

  // ─── BRAND BAR ───────────────────────────────────────────────────────
  Widget _buildBrandBar() {
    return Container(
      width: 56,
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(width: 8, height: 8, color: _neon),
          const SizedBox(height: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              border:
                  Border.all(color: _neon.withValues(alpha: 0.3), width: 1),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 2,
            height: 40,
            color: _neon.withValues(alpha: 0.15),
          ),
          const Spacer(),
          RotatedBox(
            quarterTurns: 1,
            child: Text(
              'BUGBOARD26',
              style: TextStyle(
                color: _neon,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 14,
                height: 1,
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 2,
            height: 40,
            color: _violet.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              border: Border.all(
                color: _violet.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 8,
            height: 8,
            color: _violet.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String? route;
  _SidebarItem(this.icon, this.label, this.route);
}


