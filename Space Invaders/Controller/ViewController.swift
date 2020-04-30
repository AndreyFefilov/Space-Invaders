

import UIKit

class ViewController: UIViewController {

    var memoryWorkingManager = MemoryWorkingManager()
    
    var timer: Timer?
    let destroyPoints = 5
    
    var invadersImages = [[UIImageView]]()
    var invaderBullets = [UIImageView]()
    var invadersNumber : Int = 0
    var invadersFireRate : Int = 70
    var invadersXPosition : CGFloat = 1.0
    var invadersYPosition : CGFloat = 0
    var invadersFireCoolDown : Int = 100

    var shipPosition : CGFloat = 0
    var shipFireRate : Int = 20
    var shipFireCoolDown : Int = 40
    var shipMoveSpeed : CGFloat = 10.0
    var shipBullets = [UIImageView]()
    
    
    @IBOutlet weak var levelValueText: UITextField!
    @IBOutlet weak var bestScoreValueText: UITextField!
    @IBOutlet weak var bestScoreLabelText: UITextField!
    @IBOutlet weak var playerScoreText: UITextField!
    @IBOutlet weak var gameOverLogoButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var spaceShipView: UIImageView!
    

    @IBAction func moveShipToRightTouchDown(_ sender: Any) {
        shipPosition = 1 * shipMoveSpeed
    }
    
    @IBAction func stopMoveToRightTouchUp(_ sender: Any) {
        shipPosition = 0
    }
    
    
    @IBAction func moveShipToLeftTouchDown(_ sender: Any) {
        shipPosition = -1 * shipMoveSpeed
    }
    
    @IBAction func stopMoveToLeftTouchUp(_ sender: Any) {
        shipPosition = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
        memoryWorkingManager.level = 1
    }
    
    
    func startGame() {
        gameOverLogoButton.isHidden = false
        bestScoreValueText.isHidden = false
        bestScoreLabelText.isHidden = false
        
        memoryWorkingManager.loadData()
        
        playerScoreText.text = String(memoryWorkingManager.currentScore)
        bestScoreValueText.text = String(memoryWorkingManager.bestScore)
        levelValueText.text = String(memoryWorkingManager.level)
        
        spaceShipView.frame = CGRect(x: view.frame.width / 2 - spaceShipView.frame.width / 2,
                                     y: view.frame.height - 80,
                                     width: 60,
                                     height: 60)
        
        bestScoreValueText.isHidden = true
        
        setupInvaders()
        setupShip()
    }
    
    @objc func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1/30,
                                     target: self,
                                     selector: #selector(drawInvadersAndShip),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func restartGame() {
        for i in 0...invadersImages.count - 1 {
            for j in 0...invadersImages[0].count - 1 {
                invadersImages[i][j].removeFromSuperview()
            }
        }
        invadersImages.removeAll()
        
        playerScoreText.text = String(memoryWorkingManager.currentScore)
        bestScoreValueText.text = String(memoryWorkingManager.bestScore)
        levelValueText.text = String(memoryWorkingManager.level)
        
        spaceShipView.frame = CGRect(x: view.frame.width / 2 - spaceShipView.frame.width / 2,
                                     y: view.frame.height - 80,
                                     width: 60,
                                     height: 60)
    }
    
    
    func setupInvaders() {
        for i in 0...2 {
            var invadersRow = [UIImageView]()
            for j in 0...5 {
                let invader = UIImageView(image: #imageLiteral(resourceName: "InvaderA_00"))
                let invaderCGRect = CGRect(x: view.frame.width / 6 + CGFloat(j*50),
                                         y: view.frame.width / 7 + CGFloat(i*50) + CGFloat(25),
                                         width: view.frame.width / 10,
                                         height: view.frame.width / 10)
                invader.frame = invaderCGRect
                invadersRow.append(invader)
                view.addSubview(invader)
            }
            invadersImages.append(invadersRow)
        }
    }
    
    func invaderShoots() {
        invadersFireCoolDown += 1
        
        if (invadersFireCoolDown >= invadersFireRate) {
            
            var randomShootedInvaderXposition = Int.random(in: 0...5)
            var randomShootedInvaderYposition = Int.random(in: 0...2)
            var randomInvader = invadersImages[randomShootedInvaderYposition][randomShootedInvaderXposition]
            
            while (randomInvader.isHidden) {
                randomShootedInvaderYposition = Int.random(in: 0...2)
                randomShootedInvaderXposition = Int.random(in: 0...5)
                randomInvader = invadersImages[randomShootedInvaderYposition][randomShootedInvaderXposition]
            }
            
            // invader`s bullet
            let invaderBulletCGRect = CGRect(x: randomInvader.frame.origin.x + randomInvader.frame.width / 4,
                                             y: randomInvader.frame.origin.y + randomInvader.frame.height,
                                             width: randomInvader.frame.width / 2,
                                             height: randomInvader.frame.height / 2)
            
            let bulletOfInvader = UIImageView(frame: invaderBulletCGRect)
            bulletOfInvader.image = #imageLiteral(resourceName: "invadersBullet")
            view.addSubview(bulletOfInvader)
            invaderBullets.append(bulletOfInvader)
            invadersFireCoolDown = 0
        }
        
        // move bullet
        for (i, bullet) in invaderBullets.enumerated() {
            bullet.frame.origin.y += 4
            if (bullet.frame.origin.y + bullet.frame.height > view.frame.height) {
                invaderBullets[i].removeFromSuperview()
                invaderBullets.remove(at: i)
            }
        }
        checkShipDestroy()
    }
    
    func setupShip() {
        spaceShipView.frame = CGRect(x: view.frame.width / 2 - spaceShipView.frame.width / 2,
                                     y: view.frame.height - 70,
                                     width: 30,
                                     height: 30)
    }
    
    func shipShoots() {
        
        shipFireCoolDown += 1
        
        if (shipFireCoolDown >= shipFireRate) {
            let shipBulletCGRect = CGRect(x: spaceShipView.frame.origin.x + spaceShipView.frame.width / 4,
                                          y: spaceShipView.frame.origin.y,
                                          width: spaceShipView.frame.width / 2,
                                          height: spaceShipView.frame.height / 2)
            
            let shipFireBullet = UIImageView(frame: shipBulletCGRect)
            shipFireBullet.image = #imageLiteral(resourceName: "bullet")
            view.addSubview(shipFireBullet)
            shipBullets.append(shipFireBullet)
            shipFireCoolDown = 0
        }
        
        checkInvaderDestroy()
    }
    
    
    @objc func drawInvadersAndShip() {
        
        // Invaders
        for invaderRow in invadersImages {
            for invader in invaderRow {
                invader.frame.origin.x += invadersXPosition
            }
        }
        
        if (invadersImages[0][invadersImages[0].count - 1].frame.origin.x + invadersImages[0][invadersImages[0].count - 1].frame.width >= view.frame.width - 8) {
                invadersXPosition = -1
                invadersYPosition = view.frame.height / CGFloat(80 - 10 * memoryWorkingManager.level)
            }else if (invadersImages[0][0].frame.origin.x <= 8) {
                invadersXPosition = 1
                invadersYPosition = view.frame.height / CGFloat(80 - 10 * memoryWorkingManager.level)
            }
        
        for enemyRow in invadersImages {
            for enemy in enemyRow {
                enemy.frame.origin.y += invadersYPosition
            }
        }
        invadersYPosition = 0
        invaderShoots()
        
        // Space ship
        if ((spaceShipView.frame.origin.x + shipPosition > 10) &&
            (spaceShipView.frame.origin.x + spaceShipView.frame.width + shipPosition < view.frame.width - 10)) {
            spaceShipView.frame.origin.x += shipPosition
        }
        shipShoots()
    }
    
    func destroyShip() {
        gameOverLogoButton.isHidden = false
        bestScoreValueText.isHidden = false
        bestScoreLabelText.isHidden = false
        stopTimer()
        
        if (memoryWorkingManager.currentScore > memoryWorkingManager.bestScore) {
            memoryWorkingManager.bestScore = memoryWorkingManager.currentScore
        }
        
        memoryWorkingManager.saveBestScore()
        memoryWorkingManager.level = 1
        memoryWorkingManager.currentScore = 0
        memoryWorkingManager.saveData()
    }
    

    func checkShipDestroy() {
        // intersect with space ship
        if (invadersImages[invadersImages.count - 1][0].frame.origin.y +
            invadersImages[invadersImages.count - 1][0].frame.height > spaceShipView.frame.origin.y) {
            destroyShip()
        }
        
        for (i, bullet) in invaderBullets.enumerated() {
            if (bullet.frame.origin.y + bullet.frame.height > spaceShipView.frame.origin.y - 8){
                if (bullet.frame.intersects(spaceShipView.frame)) {
                    invaderBullets[i].removeFromSuperview()
                    invaderBullets.remove(at: i)
                    destroyShip()
                }
            }
        }
    }
    
    func checkInvaderDestroy() {
        let lastInvaderPosition = invadersImages[invadersImages.count - 1][0].frame.origin.y +
            invadersImages[invadersImages.count - 1][0].frame.height
        
        outerLoop: for (k, bullet) in shipBullets.enumerated() {
            bullet.frame.origin.y -= 10
            
            if (bullet.frame.origin.y + bullet.frame.height < 0) {
                shipBullets[k].removeFromSuperview()
                shipBullets.remove(at: k)
            } else if (bullet.frame.origin.y <= lastInvaderPosition) {
                innerLoop : for i in 0...invadersImages.count - 1 {
                    for j in 0...invadersImages[0].count - 1 {
                        if (bullet.frame.intersects(invadersImages[i][j].frame) && !invadersImages[i][j].isHidden) {
                            shipBullets[k].removeFromSuperview()
                            shipBullets.remove(at: k)
                            invadersImages[i][j].isHidden = true
                            memoryWorkingManager.currentScore += destroyPoints
                            playerScoreText.text = String(memoryWorkingManager.currentScore)
                            invadersNumber -= 1
                            
                            if invadersNumber == 0 {
                                levelUp()
                                
                                break outerLoop
                            }
                            
                            break innerLoop
                        }
                    }
                }
            }
        }
    }
    
    func levelUp() {
        // clear screen
        for i in 0...invadersImages.count - 1 {
            for j in 0...invadersImages[0].count - 1 {
                invadersImages[i][j].removeFromSuperview()
            }
        }
        invadersImages.removeAll()
        
        memoryWorkingManager.level += 1
        stopTimer()
        memoryWorkingManager.saveData()
        startGame()
        startTimer()
    }
    
    @IBAction func gameOverLogoTouch(_ sender: Any) {
        gameOverLogoButton.isHidden = true
        bestScoreLabelText.isHidden = true
        bestScoreValueText.isHidden = true
        restartGame()
        startTimer()
    }
}

