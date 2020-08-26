class ProfileUpdate<T> {
  final T _data;

  bool get update => _data != null;
  bool get delete => _data == null;
  T get data => _data;

  const ProfileUpdate.update(this._data);
  const ProfileUpdate.delete() : _data = null;
}
