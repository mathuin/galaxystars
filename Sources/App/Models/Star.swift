import Fluent
import Vapor

final class Star: Model, @unchecked Sendable {
    // Name of the table or collection.
    static let schema = "stars"

    // Unique identifier for this Star.
    @ID(key: .id)
    var id: UUID?

    // The Star's name.
    @Field(key: "name")
    var name: String

    // Reference to the Galaxy this Star is in.
    @OptionalParent(key: "galaxy_id")
    var galaxy: Galaxy?

    // All the Planets in this Star system.
    @Children(for: \.$star)
    var planets: [Planet]

    // All the Asteroids in this Star system.
    @Children(for: \.$star)
    var asteroids: [Asteroid]

    // Creates a new, empty Star.
    init() { }

    // Creates a new Star with all properties set.
    init(id: UUID? = nil, name: String, galaxy_id: UUID) {
        self.id = id
        self.name = name
        self.$galaxy.id = galaxy_id
    }

    func toDTO() -> StarDTO {
        let asteroids = self.$asteroids.value ?? []
        let planets = self.$planets.value ?? []
        return StarDTO(
            id: self.id,
            name: self.name,
            asteroids: asteroids.map { $0.toDTO() },
            planets: planets.map { $0.toDTO() }
        )
    }
}
