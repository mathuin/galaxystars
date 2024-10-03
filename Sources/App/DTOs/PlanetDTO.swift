import Fluent
import Vapor

struct PlanetDTO: Content {
    var id: UUID?
    var name: String

    func toModel(star: Star? = nil) -> Planet {
        let model = Planet()

        model.id = self.id
        model.name = self.name

        if let star {
            model.$star.id = star.id
        }

        return model
    }
}
