import Fluent
import Vapor

struct StarController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let stars = routes.grouped("stars")

        stars.get(use: self.index)
        stars.post(use: self.create)
        stars.group(":star_id") { star in
            star.get(use: self.show)
            star.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [StarDTO] {
        try await Star.query(on: req.db)
            .with(\.$planets)
            .with(\.$asteroids)
            .all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> StarDTO {
        let starCreateDTO = try req.content.decode(StarCreateDTO.self)
        guard let galaxy = try await Galaxy.find(starCreateDTO.galaxy_id, on: req.db) else {
            throw Abort(.notFound, reason: "Galaxy not found")
        }
        let star = Star(name: starCreateDTO.name, galaxy_id: try! galaxy.requireID())
        try await star.create(on: req.db)

        if let asteroidDTOs = starCreateDTO.asteroids {
            for asteroidDTO in asteroidDTOs {
                let asteroid = asteroidDTO.toModel(star: star)
                try await asteroid.create(on: req.db)
            }
        }

        if let planetDTOs = starCreateDTO.planets {
            for planetDTO in planetDTOs {
                let planet = planetDTO.toModel(star: star)
                try await planet.create(on: req.db)
            }
        }

        return try await Star.query(on: req.db)
            .with(\.$planets)
            .with(\.$asteroids)
            .filter(\.$id == star.requireID())
            .first()!.toDTO()
    }

    @Sendable
    func show(req: Request) async throws -> StarDTO {
        guard let star = try await Star.find(req.parameters.get("star_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await Star.query(on: req.db)
            .with(\.$planets)
            .with(\.$asteroids)
            .filter(\.$id == star.requireID())
            .first()!.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let star = try await Star.find(req.parameters.get("star_id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await star.delete(on: req.db)
        return .noContent
    }
}
