import Fluent
import Vapor

struct AsteroidCreateDTO: Content {
    var name: String
    var star_id: Star.IDValue
}
