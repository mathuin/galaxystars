import Fluent
import Vapor

final class Planet: Model, @unchecked Sendable {
    // Name of the table or collection.
    static let schema = "planets"

    // Unique identifier for this Planet.
    @ID(key: .id)
    var id: UUID?

    // The Planet's name.
    @Field(key: "name")
    var name: String

    // Reference to the Star system this Planet is in.
    @OptionalParent(key: "star_id")
    var star: Star?

    // Creates a new, empty Planet.
    init() { }

    // Creates a new Planet with all properties set.
    init(id: UUID? = nil, name: String, star_id: UUID) {
        self.id = id
        self.name = name
        self.$star.id = star_id
    }

    func toDTO() -> PlanetDTO {
        .init(id: self.id, name: self.name)
    }
}
