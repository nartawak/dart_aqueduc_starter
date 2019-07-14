import 'package:aqueduct/managed_auth.dart';
import 'package:heroes/models/user.dart';

import 'controllers/heroes_controller.dart';
import 'controllers/register_controller.dart';
import 'heroes.dart';

class HeroConfig extends Configuration {
  DatabaseConfiguration database;

  HeroConfig(String path) : super.fromFile(File(path));
}

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class HeroesChannel extends ApplicationChannel {
  ManagedContext context;

  AuthServer authServer;

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/auth/token').link(() => AuthController(authServer));

    router
        .route('/heroes/[:id]')
        .link(() => Authorizer.bearer(authServer))
        .link(() => HeroesController(context));

    router
        .route('/register')
        .link(() => RegisterController(context, authServer));

    return router;
  }

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = HeroConfig(options.configurationFilePath);
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);

    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }
}
