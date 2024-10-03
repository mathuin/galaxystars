import Fluent

struct CreateAsteroid: AsyncMigration {
    // Prepares the database for storing Asteroid models.
    func prepare(on database: Database) async throws {
        try await database.schema("asteroids")
            .id()
            .field("name", .string)
            .field("star_id", .uuid, .references("stars", "id", onDelete: .cascade))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) async throws {
        try await database.schema("asteroids").delete()
    }
}
