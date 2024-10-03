import Fluent
import Vapor

struct AsteroidDTO: Content {
    var id: UUID?
    var name: String

    func toModel(star: Star? = nil) -> Asteroid {
        let model = Asteroid()

        model.id = self.id
        model.name = self.name

        if let star {
            model.$star.id = star.id
        }

        return model
    }
}
