import Fluent
import Vapor

struct PlanetCreateDTO: Content {
    var name: String
    var star_id: Star.IDValue
}
