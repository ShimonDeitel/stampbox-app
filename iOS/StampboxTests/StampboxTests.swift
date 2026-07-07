import XCTest
@testable import Stampbox

@MainActor
final class StampboxTests: XCTestCase {
    var store: StampboxStore!

    override func setUp() {
        super.setUp()
        store = StampboxStore()
    }

    func testSeedDataLoadedOnFreshInstall() {
        XCTAssertFalse(store.entries.isEmpty)
    }

    func testSeedCountIsBelowFreeLimit() {
        XCTAssertLessThan(StampboxStore.seedData().count, StampboxStore.freeLimit)
    }

    func testAddEntrySucceedsUnderLimit() {
        let before = store.entries.count
        let added = store.add(StampEntry(name: "Test Entry", detail: "Detail", date: Date()))
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testAddEntryFailsAtLimit() {
        while store.canAddMore {
            store.add(StampEntry(name: "Filler", detail: "x", date: Date()))
        }
        let added = store.add(StampEntry(name: "Overflow", detail: "x", date: Date()))
        XCTAssertFalse(added)
        XCTAssertEqual(store.entries.count, StampboxStore.freeLimit)
    }

    func testDeleteEntry() {
        let entry = StampEntry(name: "ToDelete", detail: "x", date: Date())
        store.add(entry)
        let before = store.entries.count
        store.delete(entry)
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testUpdateEntry() {
        var entry = StampEntry(name: "Original", detail: "x", date: Date())
        store.add(entry)
        entry.name = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.name, "Updated")
    }

    func testToggleFavorite() {
        let entry = StampEntry(name: "Fav", detail: "x", date: Date())
        store.add(entry)
        store.toggleFavorite(entry)
        XCTAssertTrue(store.entries.first(where: { $0.id == entry.id })?.isFavorite ?? false)
    }

    func testCanAddMoreReflectsLimit() {
        XCTAssertTrue(store.canAddMore)
    }
}
