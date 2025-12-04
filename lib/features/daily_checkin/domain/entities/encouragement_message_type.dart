/// Encouragement message type for consecutive check-in days
///
/// This enum represents different types of encouragement messages shown to users
/// based on their check-in streak. Application Layer returns this type,
/// and Presentation Layer converts it to localized messages using l10n.
enum EncouragementMessageType {
  firstDay, // First check-in
  secondDay, // Second day check-in
  almostMilestone, // Close to next milestone (1-2 days remaining)
  generic, // Generic encouragement message
}
