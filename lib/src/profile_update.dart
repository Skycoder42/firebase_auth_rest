/// A helper class to create profile updates.
class ProfileUpdate<T> {
  final T _data;

  /// Specifies, if this is an update with new data.
  bool get update => _data != null;

  /// Specifies, if this is an update to delete data.
  bool get delete => _data == null;

  /// Returns the data associated with this update.
  ///
  /// If [update] is true, this will return the actual data to be used by the
  /// update. If [delete] is true instead, [data] will always be null.
  T get data => _data;

  /// Creates a new profile update to update data.
  ///
  /// This method sets [data] to [_data], [update] to true and [delete] to
  /// false.
  const ProfileUpdate.update(this._data);

  /// Creates a new profile update to delete data.
  ///
  /// This method sets [data] to null, [update] to false and [delete] to
  /// true.
  const ProfileUpdate.delete() : _data = null;
}
