import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SembastDatabase {
  late Database _instance;
  bool _hasBeenInitialized = false;
  SembastDatabase();

  Database get instance => _instance;

  Future<void> init() async {
    if (_hasBeenInitialized) return;

    final dbDirectory = await getApplicationDocumentsDirectory();
    dbDirectory.create(recursive: true);
    final dbPath = join(dbDirectory.path, 'db.sembast');
    _instance = await databaseFactoryIo.openDatabase(dbPath);
    _hasBeenInitialized = true;
  }
}
