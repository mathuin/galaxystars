import Fluent
import Vapor

struct StarCreateDTO: Content {
    var name: String
    var galaxy_id: Galaxy.IDValue
    var asteroids: [AsteroidDTO]?
    var planets: [PlanetDTO]?
}
