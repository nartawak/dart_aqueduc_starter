import 'package:aqueduct/aqueduct.dart';
import 'package:heroes/models/hero.dart';

class HeroesController extends ResourceController {
  final ManagedContext context;

  HeroesController(this.context);

  @Operation.post()
  Future<Response> createHero() async {
    final hero = Hero()..read(await request.body.decode(), ignore: ["id"]);
    final query = Query<Hero>(context)..values = hero;

    final insertedHero = await query.insert();

    return Response.ok(insertedHero);
  }

  @Operation.get()
  Future<Response> getAllHeroes({@Bind.query('name') String name}) async {
    final heroQuery = Query<Hero>(context);
    if (name != null) {
      heroQuery.where((h) => h.name).contains(name, caseSensitive: false);
    }
    final heroes = await heroQuery.fetch();

    return Response.ok(heroes);
  }

  @Operation.get('id')
  Future<Response> getHeroByID(@Bind.path('id') int id) async {
    final heroQuery = Query<Hero>(context)..where((h) => h.id).equalTo(id);

    final hero = await heroQuery.fetchOne();

    if (hero == null) {
      return Response.notFound();
    }
    return Response.ok(hero);
  }
}
