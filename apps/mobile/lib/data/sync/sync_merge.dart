/// Later [updatedAt] wins. Equal timestamps keep the remote copy so a push
/// that the server already stored is not sent again.
bool remoteWins({required DateTime? localUpdated, required DateTime remoteUpdated}) {
  if (localUpdated == null) return true;
  return !remoteUpdated.isBefore(localUpdated);
}
