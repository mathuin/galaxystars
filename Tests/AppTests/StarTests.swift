@testable import App
import XCTVapor
import Fluent

final class StarTests: XCTestCase {
    var app: Application!
    let testGalaxy = Galaxy(name: "testGalaxy")
    var testGalaxyID: Galaxy.IDValue = UUID()
    var testStars: [Star] = []

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()

        try await testGalaxy.create(on: self.app.db)
        testGalaxyID = try! testGalaxy.requireID()
        testStars = [
            Star(name: "testStar1", galaxy_id: testGalaxyID),
            Star(name: "testStar2", galaxy_id: testGalaxyID)
        ]
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testStarIndex() async throws {
        try await testStars.create(on: self.app.db)

        try await self.app.test(.GET, "stars", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([StarDTO].self).sorted(by: { $0.name < $1.name }),
                testStars.map { $0.toDTO() }.sorted(by: { $0.name < $1.name })
            )
        })
    }

    func testStarCreate() async throws {
        let newCreateDTO = StarCreateDTO(
            name: "test",
            galaxy_id: testGalaxyID,
            asteroids: [
                AsteroidDTO(name: "test")
            ],
            planets: [
                PlanetDTO(name: "test")
            ]
        )
        let newDTO = StarDTO(
            name: "test",
            asteroids: [
                AsteroidDTO(name: "test")
            ],
            planets: [
                PlanetDTO(name: "test")
            ]
        )

        try await self.app.test(.POST, "stars", beforeRequest: { req in
            try req.content.encode(newCreateDTO)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let models = try await Star.query(on: self.app.db)            .with(\.$planets)
                .with(\.$asteroids)
                .all()
            XCTAssertEqual(models.map { $0.toDTO() }, [newDTO])
        })
    }

    func testStarShow() async throws {
        try await testStars.create(on: app.db)

        try await self.app.test(.GET, "stars/\(testStars[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode(StarDTO.self), testStars[0].toDTO())
        })

        try await self.app.test(.GET, "stars/x", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testStarDelete() async throws {
        try await testStars.create(on: app.db)

        try await self.app.test(.DELETE, "stars/\(testStars[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)
            let model = try await Star.find(testStars[0].id, on: self.app.db)
            XCTAssertNil(model)
        })

        try await self.app.test(.DELETE, "stars/\(testStars[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }
}

extension StarDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.asteroids?.count != rhs.asteroids?.count { return false }
        if lhs.planets?.count != rhs.planets?.count { return false }
        return true
    }
}
