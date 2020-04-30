
import Foundation

class MemoryWorkingManager {
    
    let dataStorage = UserDefaults.standard
    
    var level : Int = 1
    var currentScore : Int = 0
    var bestScore : Int = 0
    
    func saveData() {
        dataStorage.set(level, forKey: "level")
        dataStorage.set(currentScore, forKey: "currentScore")
    }
    
    func saveBestScore() {
        if self.currentScore > self.bestScore {
            self.bestScore = self.currentScore
            dataStorage.set(bestScore, forKey: "bestScore")
        }
    }
    
    func loadData() {
        level = dataStorage.integer(forKey: "level")
        currentScore = dataStorage.integer(forKey: "currentScore")
        bestScore = dataStorage.integer(forKey: "bestScore")
    }
    
    func saveLevel() {
        dataStorage.set(level, forKey: "level")
    }

}
