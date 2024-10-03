import Fluent
import Vapor

struct AsteroidController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let asteroids = routes.grouped("asteroids")

        asteroids.get(use: self.index)
        asteroids.post(use: self.create)
        asteroids.group(":asteroid_id") { asteroid in
            asteroid.get(use: self.show)
            asteroid.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [AsteroidDTO] {
        try await Asteroid.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> AsteroidDTO {
        let asteroidCreateDTO = try req.content.decode(AsteroidCreateDTO.self)
        guard let star = try await Star.find(asteroidCreateDTO.star_id, on: req.db) else {
            throw Abort(.notFound, reason: "Star not found")
        }
        let asteroid = Asteroid(name: asteroidCreateDTO.name, star_id: try! star.requireID())
        try await asteroid.create(on: req.db)

        return try await Asteroid.query(on: req.db).filter(\.$id == asteroid.requireID()).first()!.toDTO()
    }

    @Sendable
    func show(req: Request) async throws -> AsteroidDTO {
        guard let asteroid = try await Asteroid.find(req.parameters.get("asteroid_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await Asteroid.query(on: req.db).filter(\.$id == asteroid.requireID()).first()!.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let asteroid = try await Asteroid.find(req.parameters.get("asteroid_id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await asteroid.delete(on: req.db)
        return .noContent
    }
}
