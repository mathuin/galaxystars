import Fluent
import Vapor

struct GalaxyController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let galaxies = routes.grouped("galaxies")

        galaxies.get(use: self.index)
        galaxies.post(use: self.create)
        galaxies.group(":galaxy_id") { galaxy in
            galaxy.get(use: self.show)
            galaxy.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [GalaxyDTO] {
        try await Galaxy.query(on: req.db).with(\.$stars) { star in star.with(\.$planets).with(\.$asteroids) }.all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> GalaxyDTO {
        let galaxyDTO = try req.content.decode(GalaxyDTO.self)
        let galaxy = galaxyDTO.toModel()
        try await galaxy.create(on: req.db)

        if let starDTOs = galaxyDTO.stars {
            for starDTO in starDTOs {
                let star = starDTO.toModel(galaxy: galaxy)
                try await star.create(on: req.db)

                if let asteroidDTOs = starDTO.asteroids {
                    for asteroidDTO in asteroidDTOs {
                        let asteroid = asteroidDTO.toModel(star: star)
                        try await asteroid.create(on: req.db)
                    }
                }

                if let planetDTOs = starDTO.planets {
                    for planetDTO in planetDTOs {
                        let planet = planetDTO.toModel(star: star)
                        try await planet.create(on: req.db)
                    }
                }
            }
        }
        return try await Galaxy.query(on: req.db)
            .filter(\.$id == galaxy.requireID())
            .with(\.$stars) {
                star in star.with(\.$planets).with(\.$asteroids)
            }.first()!.toDTO()
    }

    @Sendable
    func show(req: Request) async throws -> GalaxyDTO {
        guard let galaxy = try await Galaxy.find(req.parameters.get("galaxy_id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await Galaxy.query(on: req.db).filter(\.$id == galaxy.requireID()).with(\.$stars) { star in star.with(\.$planets).with(\.$asteroids)}.first()!.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let galaxy = try await Galaxy.find(req.parameters.get("galaxy_id"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await galaxy.delete(on: req.db)
        return .noContent
    }
}
