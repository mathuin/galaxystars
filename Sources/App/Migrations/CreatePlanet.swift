import Fluent

struct CreatePlanet: AsyncMigration {
    // Prepares the database for storing Planet models.
    func prepare(on database: Database) async throws {
        try await database.schema("planets")
            .id()
            .field("name", .string)
            .field("star_id", .uuid, .references("stars", "id", onDelete: .cascade))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema("planets").delete()
    }
}
