import Fluent
import struct Foundation.UUID
import Vapor

final class Galaxy: Model, @unchecked Sendable {
    // Name of the table or collection.
    static let schema = "galaxies"

    // Unique identifier for this Galaxy.
    @ID(key: .id)
    var id: UUID?

    // The Galaxy's name.
    @Field(key: "name")
    var name: String

    // All the Stars in this Galaxy.
    @Children(for: \.$galaxy)
    var stars: [Star]

    // Creates a new, empty Galaxy.
    init() { }

    // Creates a new Galaxy with all properties set.
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

    func toDTO() -> GalaxyDTO {
        let stars = self.$stars.value ?? []
        return GalaxyDTO(
            id: self.id,
            name: self.name,
            stars: stars.map { $0.toDTO() }
        )
    }
}
