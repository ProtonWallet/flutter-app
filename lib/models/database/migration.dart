class Migration {
  int startVersion;
  int endVersion;
  final Future<void> Function() migrate;
  Migration(this.startVersion, this.endVersion, this.migrate);
}
