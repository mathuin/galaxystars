import Fluent
import Vapor

struct PlanetController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let planets = routes.grouped("planets")

        planets.get(use: self.index)
        planets.post(use: self.create)
        planets.group(":planet_id") { planet in
            planet.get(use: self.show)
            planet.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [PlanetDTO] {
        try await Planet.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> PlanetDTO {
        let planetCreateDTO = try req.content.decode(PlanetCreateDTO.self)
        guard let star = try await Star.find(planetCreateDTO.star_id, on: req.db) else {
            throw Abort(.notFound, reason: "Star not found")
        }
        let planet = Planet(name: planetCreateDTO.name, star_id: try! star.requireID())
        try await planet.create(on: req.db)

        return try await Planet.query(on: req.db).filter(\.$id == planet.requireID()).first()!.toDTO()
    }

    @Sendable
    func show(req: Request) async throws -> PlanetDTO {
        guard let planet = try await Planet.find(req.parameters.get("planet_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await Planet.query(on: req.db).filter(\.$id == planet.requireID()).first()!.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let planet = try await Planet.find(req.parameters.get("planet_id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await planet.delete(on: req.db)
        return .noContent
    }
}
