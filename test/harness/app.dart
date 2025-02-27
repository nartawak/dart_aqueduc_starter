import 'package:aqueduct_test/aqueduct_test.dart';
import 'package:heroes/heroes.dart';

export 'package:aqueduct/aqueduct.dart';
export 'package:aqueduct_test/aqueduct_test.dart';
export 'package:heroes/heroes.dart';
export 'package:test/test.dart';

/// A testing harness for heroes.
///
/// A harness for testing an aqueduct application. Example test file:
///
///         void main() {
///           Harness harness = Harness()..install();
///
///           test("GET /path returns 200", () async {
///             final response = await harness.agent.get("/path");
///             expectResponse(response, 200);
///           });
///         }
///
class Harness extends TestHarness<HeroesChannel> with TestHarnessORMMixin {
  @override
  ManagedContext get context => channel.context;

  @override
  Future onSetUp() async {
    await resetData();
  }
}
