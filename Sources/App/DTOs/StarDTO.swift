import Fluent
import Vapor

struct StarDTO: Content {
    var id: UUID?
    var name: String
    var asteroids: [AsteroidDTO]?
    var planets: [PlanetDTO]?

    func toModel(galaxy: Galaxy? = nil) -> Star {
        let model = Star()

        model.id = self.id
        model.name = self.name

        if let galaxy {
            model.$galaxy.id = galaxy.id
        }

        return model
    }
}
