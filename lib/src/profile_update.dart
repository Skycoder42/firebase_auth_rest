/// A helper class to create profile updates.
class ProfileUpdate<T> {
  /// Returns the data associated with this update.
  ///
  /// If [update] is true, this will return the actual data to be used by the
  /// update. If [delete] is true instead, [data] will always be null.
  final T data;

  /// Specifies, if this is an update with new data.
  bool get update => data != null;

  /// Specifies, if this is an update to delete data.
  bool get delete => data == null;

  /// Creates a new profile update to update data.
  ///
  /// This method sets [data] to [_data], [update] to true and [delete] to
  /// false.
  const ProfileUpdate.update(this.data);

  /// Creates a new profile update to delete data.
  ///
  /// This method sets [data] to null, [update] to false and [delete] to
  /// true.
  const ProfileUpdate.delete() : data = null;
}
