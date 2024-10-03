import Fluent
import Vapor

struct GalaxyDTO: Content {
    var id: UUID?
    var name: String
    var stars: [StarDTO]?

    func toModel() -> Galaxy {
        let model = Galaxy()

        model.id = self.id
        model.name = self.name

        return model
    }
}
