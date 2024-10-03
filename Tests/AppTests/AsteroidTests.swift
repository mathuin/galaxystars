@testable import App
import XCTVapor
import Fluent

final class AsteroidTests: XCTestCase {
    var app: Application!
    let testGalaxy = Galaxy(name: "testGalaxy")
    var testStarID: Star.IDValue = UUID()
    var testAsteroids: [Asteroid] = []

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()

        try await testGalaxy.create(on: self.app.db)
        let testStar = Star(name: "testStar", galaxy_id: try! testGalaxy.requireID())
        try await testStar.create(on: self.app.db)
        testStarID = try! testStar.requireID()
        testAsteroids = [
            Asteroid(name: "testAsteroid1", star_id: testStarID),
            Asteroid(name: "testAsteroid2", star_id: testStarID)
        ]
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testAsteroidIndex() async throws {
        try await testAsteroids.create(on: self.app.db)

        try await self.app.test(.GET, "asteroids", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([AsteroidDTO].self).sorted(by: { $0.name < $1.name }),
                testAsteroids.map { $0.toDTO() }.sorted(by: { $0.name < $1.name })
            )
        })
    }

    func testAsteroidCreate() async throws {
        let newCreateDTO = AsteroidCreateDTO(name: "test", star_id: testStarID)
        let newDTO = AsteroidDTO(id: nil, name: "test")

        try await self.app.test(.POST, "asteroids", beforeRequest: { req in
            try req.content.encode(newCreateDTO)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let models = try await Asteroid.query(on: self.app.db).all()
            XCTAssertEqual(models.map { $0.toDTO() }, [newDTO])
        })
    }

    func testAsteroidShow() async throws {
        try await testAsteroids.create(on: app.db)

        try await self.app.test(.GET, "asteroids/\(testAsteroids[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode(AsteroidDTO.self), testAsteroids[0].toDTO())
        })

        try await self.app.test(.GET, "asteroids/x", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testAsteroidDelete() async throws {
        try await testAsteroids.create(on: app.db)

        try await self.app.test(.DELETE, "asteroids/\(testAsteroids[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)
            let model = try await Asteroid.find(testAsteroids[0].id, on: self.app.db)
            XCTAssertNil(model)
        })

        try await self.app.test(.DELETE, "asteroids/\(testAsteroids[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }
}

extension AsteroidDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.name != rhs.name { return false }
        return true
    }
}
