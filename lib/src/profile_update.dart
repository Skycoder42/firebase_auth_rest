/// A helper class to create profile updates.
class ProfileUpdate<T> {
  /// Returns the data associated with this update.
  ///
  /// If [isUpdate] is true, this will return the actual data to be used by the
  /// update. If [isDelete] is true instead, [data] will always be null.
  final T? data;

  /// Specifies, if this is an update with new data.
  bool get isUpdate => data != null;

  /// Specifies, if this is an update to delete data.
  bool get isDelete => data == null;

  /// Returns the [data] value, if [isUpdate], otherwise [defaultValue].
  T? updateOr([T? defaultValue]) => data ?? defaultValue;

  /// Creates a new profile update to update data.
  ///
  /// This method sets [this.data] to [data], [isUpdate] to true and [isDelete]
  /// to false.
  const ProfileUpdate.update(this.data);

  /// Creates a new profile update to delete data.
  ///
  /// This method sets [data] to null, [isUpdate] to false and [isDelete] to
  /// true.
  const ProfileUpdate.delete() : data = null;
}
