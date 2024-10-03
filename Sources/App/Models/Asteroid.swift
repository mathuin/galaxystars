import Fluent
import Vapor

final class Asteroid: Model, @unchecked Sendable {
    // Name of the table or collection.
    static let schema = "asteroids"

    // Unique identifier for this Asteroid.
    @ID(key: .id)
    var id: UUID?

    // The Asteroid's name.
    @Field(key: "name")
    var name: String

    // Reference to the Star system this Asteroid is in.
    @OptionalParent(key: "star_id")
    var star: Star?

    // Creates a new, empty Asteroid.
    init() { }

    // Creates a new Asteroid with all properties set.
    init(id: UUID? = nil, name: String, star_id: UUID) {
        self.id = id
        self.name = name
        self.$star.id = star_id
    }

    func toDTO() -> AsteroidDTO {
        .init(id: self.id, name: self.name)
    }
}
