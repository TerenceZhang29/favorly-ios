import FavorlyData
import Testing

@Test func dataModuleDependsOnCore() {
    #expect(FavorlyDataModule.name == "FavorlyData")
    #expect(FavorlyDataModule.dependsOn == "FavorlyCore")
}
