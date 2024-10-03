@testable import App
import XCTVapor
import Fluent

final class GalaxyTests: XCTestCase {
    var app: Application!
    let testGalaxies = [
        Galaxy(name: "testGalaxy1"),
        Galaxy(name: "testGalaxy2")
        ]

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testGalaxyIndex() async throws {
        try await testGalaxies.create(on: self.app.db)

        try await self.app.test(.GET, "galaxies", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([GalaxyDTO].self).sorted(by: { $0.name < $1.name }),
                testGalaxies.map { $0.toDTO() }.sorted(by: { $0.name < $1.name })
            )
        })
    }

    func testGalaxyCreate() async throws {
        let newDTO = GalaxyDTO(
            name: "test",
            stars: [
                StarDTO(
                    name: "test",
                    asteroids: [
                        AsteroidDTO(name: "test")
                    ],
                    planets: [
                        PlanetDTO(name: "test")
                    ])
                ])

        try await self.app.test(.POST, "galaxies", beforeRequest: { req in
            try req.content.encode(newDTO)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let models = try await Galaxy.query(on: self.app.db).with(\.$stars) { star in star.with(\.$planets).with(\.$asteroids)}.all()
            XCTAssertEqual(models.map { $0.toDTO() }, [newDTO])
        })
    }

    func testGalaxyShow() async throws {
        try await testGalaxies.create(on: app.db)

        try await self.app.test(.GET, "galaxies/\(testGalaxies[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode(GalaxyDTO.self), testGalaxies[0].toDTO())
        })

        try await self.app.test(.GET, "galaxies/x", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testGalaxyDelete() async throws {
        try await testGalaxies.create(on: app.db)

        try await self.app.test(.DELETE, "galaxies/\(testGalaxies[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)
            let model = try await Galaxy.find(testGalaxies[0].id, on: self.app.db)
            XCTAssertNil(model)
        })

        try await self.app.test(.DELETE, "galaxies/\(testGalaxies[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }
}

extension GalaxyDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.stars?.count != rhs.stars?.count { return false }
        return true
    }
}
