/// A single exchange between the user and the AI about a ticket.
class AiConversation {
  final String ticketId;
  final String ticketTitle;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;

  const AiConversation({
    required this.ticketId,
    required this.ticketTitle,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
  });
}

