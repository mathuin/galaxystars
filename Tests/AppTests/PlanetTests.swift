@testable import App
import XCTVapor
import Fluent

final class PlanetTests: XCTestCase {
    var app: Application!
    let testGalaxy = Galaxy(name: "testGalaxy")
    var testStarID: Star.IDValue = UUID()
    var testPlanets: [Planet] = []

    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()

        try await testGalaxy.create(on: self.app.db)
        let testStar = Star(name: "testStar", galaxy_id: try! testGalaxy.requireID())
        try await testStar.create(on: self.app.db)
        testStarID = try! testStar.requireID()
        testPlanets = [
            Planet(name: "testPlanet1", star_id: testStarID),
            Planet(name: "testPlanet2", star_id: testStarID)
        ]
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testPlanetIndex() async throws {
        try await testPlanets.create(on: self.app.db)

        try await self.app.test(.GET, "planets", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([PlanetDTO].self).sorted(by: { $0.name < $1.name }),
                testPlanets.map { $0.toDTO() }.sorted(by: { $0.name < $1.name })
            )
        })
    }

    func testPlanetCreate() async throws {
        let newCreateDTO = PlanetCreateDTO(name: "test", star_id: testStarID)
        let newDTO = PlanetDTO(id: nil, name: "test")

        try await self.app.test(.POST, "planets", beforeRequest: { req in
            try req.content.encode(newCreateDTO)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let models = try await Planet.query(on: self.app.db).all()
            XCTAssertEqual(models.map { $0.toDTO() }, [newDTO])
        })
    }

    func testPlanetShow() async throws {
        try await testPlanets.create(on: app.db)

        try await self.app.test(.GET, "planets/\(testPlanets[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode(PlanetDTO.self), testPlanets[0].toDTO())
        })

        try await self.app.test(.GET, "planets/x", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func testPlanetDelete() async throws {
        try await testPlanets.create(on: app.db)

        try await self.app.test(.DELETE, "planets/\(testPlanets[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .noContent)
            let model = try await Planet.find(testPlanets[0].id, on: self.app.db)
            XCTAssertNil(model)
        })

        try await self.app.test(.DELETE, "planets/\(testPlanets[0].requireID())", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .notFound)
        })
    }
}

extension PlanetDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.name != rhs.name { return false }
        return true
    }
}
