import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var size:CGRect!
    var sk:SKScene!
    var allNodesSet = Set<SCNNode>()
    var skLabelNodesSet = Set<SKLabelNode>()
    var skSpriteNodesSet = Set<SKSpriteNode>()
    var skShapeNodesSet = Set<SKShapeNode>()

    let numberOfEnemies = 3
    var enemyPlacedCount = 0
    var enemiesLeft = 3
    let numberOfGuns = 1
    var gunsPlacedCount = 0
    let numberOfAmmoBoxes = 1
    var ammoBoxPlacedCount = 0
    var ammoCount = 0
    var hasGun = 0
    var timeCount = 0
    var timeRemainingCount = 150
    var gameStage = 0
    
    override func loadView() {
        size = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0)
        sceneView = ARSCNView(frame: size)
        sk = SKScene(size: CGSize(width: size.width, height: size.height))
        let scene = SCNScene()
        
        let bg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bg.fillColor = SKColor.white
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.name = "startScreen"
        skShapeNodesSet.insert(bg)
        sk.addChild(bg)

        let welcomeLabel = SKLabelNode(text: "Welcome to my WWDC Submission")
        welcomeLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        welcomeLabel.fontName =  "Helvetica-Bold"
        welcomeLabel.fontSize = 25
        welcomeLabel.name = "startScreen"
        welcomeLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        skLabelNodesSet.insert(welcomeLabel)
        sk.addChild(welcomeLabel)
        
        let contentLabel = SKLabelNode(text: "This is an Augmented Reality First Person Shooter game in which you need to kill all of the aliens before time runs out. Here is how you are going to do that:\n\n" +
                                              "Start by scanning your surroundings by rotating the iPad around you slowly and angles towards the floor. Then the game will start!\n\n" +
                                              "The first task is to pick up a gun to shoot the aliens with! Look around you, there will be one hidden! Get very close and tap to pick it up. Then aim and get up close to the alien and shoot by tapping on the enmy. Your gun doesn't have a long range!\n\n" +
                                              "If you run out of ammo, look around for an ammo box to refill. Get very close to the ammo box and then tap to pick it up\n\n" +
                                              "You only get penalized for time, so don't be worried to get close to the alien!")
        contentLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        contentLabel.fontName =  "Helvetica"
        contentLabel.fontSize = 18
        contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.preferredMaxLayoutWidth = 470
        contentLabel.name = "startScreen"
        contentLabel.position = CGPoint(x: size.width / 2, y: size.height - 520)
        skLabelNodesSet.insert(contentLabel)
        sk.addChild(contentLabel)
        
        let startBg = SKShapeNode(rectOf: CGSize(width: 300, height: 30))
        startBg.fillColor = SKColor.black
        startBg.position = CGPoint(x: size.width / 2, y: 27)
        startBg.name = "startScreen"
        skShapeNodesSet.insert(startBg)
        sk.addChild(startBg)
        
        let startLabel = SKLabelNode(text: "TAP ANYWHERE TO BEGIN")
        startLabel.fontColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        startLabel.fontName =  "Helvetica-Bold"
        startLabel.fontSize = 20
        startLabel.position = CGPoint(x: size.width / 2, y: 20)
        startLabel.name = "startScreen"
        skLabelNodesSet.insert(startLabel)
        sk.addChild(startLabel)
        
        let bgBlack = SKShapeNode(rectOf: CGSize(width: 290, height: 70))
        bgBlack.fillColor = SKColor.gray
        bgBlack.strokeColor = SKColor.gray
        bgBlack.position = CGPoint(x: size.width / 2, y: size.height / 2 + 190)
        bgBlack.alpha = 0.8
        bgBlack.name = "endScreenWin"
        skShapeNodesSet.insert(bgBlack)
        
        let bgBlack2 = SKShapeNode(rectOf: CGSize(width: 290, height: 70))
        bgBlack2.fillColor = SKColor.gray
        bgBlack2.strokeColor = SKColor.gray
        bgBlack2.position = CGPoint(x: size.width / 2, y: size.height / 2 + 190)
        bgBlack2.alpha = 0.8
        bgBlack2.name = "endScreenLose"
        skShapeNodesSet.insert(bgBlack)
        
        let winLabel = SKLabelNode(text: "V I C T O R Y")
        winLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        winLabel.fontName =  "Helvetica-Bold"
        winLabel.fontSize = 43
        winLabel.name = "endScreenWin"
        winLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 170)
        skLabelNodesSet.insert(winLabel)

        let loseLabel = SKLabelNode(text: "F A I L U R E")
        loseLabel.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        loseLabel.fontName =  "Helvetica"
        loseLabel.fontSize = 43
        loseLabel.name = "endScreenLose"
        loseLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 170)
        skLabelNodesSet.insert(loseLabel)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        sceneView.delegate = self
        sceneView.session = session
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        let keepScanningLabel = SKLabelNode(text: "Keep Scanning Surroundings")
        keepScanningLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        keepScanningLabel.fontName =  "Helvetica"
        keepScanningLabel.position = CGPoint(x: 240, y: 300)
        keepScanningLabel.name = "gameKeepScanning"
        skLabelNodesSet.insert(keepScanningLabel)
        
        let topBar = SKShapeNode(rectOf: CGSize(width: size.width, height: 35))
        topBar.fillColor = SKColor.white
        topBar.position = CGPoint(x: size.width / 2, y: size.height - 18)
        topBar.name = "gameTopBar"
        skShapeNodesSet.insert(topBar)
        
        let skAmmoLabel = SKLabelNode(text: "Ammo: 0")
        skAmmoLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        skAmmoLabel.fontName =  "Helvetica"
        skAmmoLabel.fontSize = 22
        skAmmoLabel.position = CGPoint(x: size.width - 60, y: size.height - 25)
        skAmmoLabel.name = "gameAmmoLabel"
        skLabelNodesSet.insert(skAmmoLabel)

        let timeEnemiesRemaining = SKLabelNode(text: "Time Left: " + String(timeRemainingCount) + "      Enemies Left: " + String(enemiesLeft))
        timeEnemiesRemaining.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        timeEnemiesRemaining.fontName =  "Helvetica"
        timeEnemiesRemaining.fontSize = 22
        timeEnemiesRemaining.position = CGPoint(x: 190, y: size.height - 25)
        timeEnemiesRemaining.name = "gameTimeEnemiesRemaining"
        skLabelNodesSet.insert(timeEnemiesRemaining)

        let handLeft = SKSpriteNode(imageNamed: "Art.scnassets/images/handLeft.png")
        handLeft.position = CGPoint(x: 70, y: 150)
        handLeft.name = "gameHand"
        skSpriteNodesSet.insert(handLeft)

        let handRight = SKSpriteNode(imageNamed: "Art.scnassets/images/handRight.png")
        handRight.position = CGPoint(x: size.width - 70, y: 150)
        handRight.name = "gameHand"
        skSpriteNodesSet.insert(handRight)
        
        let handGun = SKSpriteNode(imageNamed: "Art.scnassets/images/gunHolding.png")
        handGun.position = CGPoint(x: 70, y: 150)
        handGun.name = "gameHandGun"
        skSpriteNodesSet.insert(handGun)

        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        sceneView.overlaySKScene = sk
        sceneView.isUserInteractionEnabled = true
        sk.isUserInteractionEnabled = true
        self.view = sceneView
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if gameStage == 1 && ammoBoxPlacedCount < numberOfAmmoBoxes {
            for anchor in anchors {
                if (enemyPlacedCount < numberOfEnemies) {
                    let scene = SCNScene(named: "Art.scnassets/character/enemy.scn")!
                    let enemy = scene.rootNode.childNode(withName: "enemy", recursively: true)!
                    enemy.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                    enemy.name = "enemy " + String(enemyPlacedCount)
                    enemy.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)

                    DispatchQueue.main.async {
                        self.allNodesSet.insert(enemy)
                        self.enemyPlacedCount += 1
                    }
                } else if (gunsPlacedCount < numberOfGuns) {
                    let scene = SCNScene(named: "Art.scnassets/gun/gun.scn")!
                    let gun = scene.rootNode.childNode(withName: "gun", recursively: true)!
                    gun.name = "gun"
                    gun.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                    gun.eulerAngles = SCNVector3(0, 0, 90)
                    
                    DispatchQueue.main.async {
                        self.allNodesSet.insert(gun)
                        self.gunsPlacedCount += 1
                    }
                } else if (ammoBoxPlacedCount < numberOfAmmoBoxes) {
                    let scene = SCNScene(named: "Art.scnassets/box/box.scn")!
                    let box = scene.rootNode.childNode(withName: "box", recursively: true)!
                    box.name = "ammoBox " + String(ammoBoxPlacedCount)
                    box.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)

                    DispatchQueue.main.async {
                        self.allNodesSet.insert(box)
                        self.ammoBoxPlacedCount += 1
                        
                        if self.ammoBoxPlacedCount == self.numberOfAmmoBoxes {
                            for node in self.skLabelNodesSet {
                                if node.name == "gameKeepScanning" {
                                    node.removeFromParent()
                                }
                            }
                            let startGameLabel = SKLabelNode(text: "BEGIN")
                            startGameLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                            startGameLabel.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
                            startGameLabel.fontName =  "Helvetica"
                            startGameLabel.fontSize = 40
                            self.sk.addChild(startGameLabel)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                startGameLabel.removeFromParent()
                            }
                            for node in self.allNodesSet {
                                self.sceneView.scene.rootNode.addChildNode(node)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if gameStage == 1 && enemyPlacedCount >= numberOfEnemies && gunsPlacedCount >= numberOfGuns && ammoBoxPlacedCount >= numberOfAmmoBoxes {
            timeCount += 1
            if timeCount >= 60 {
                timeCount -= 60
                timeRemainingCount -= 1
                for node in skLabelNodesSet {
                    if node.name == "gameTimeEnemiesRemaining" {
                        node.text = "Time Left: " + String(timeRemainingCount) + "      Enemies Left: " + String(enemiesLeft)
                    }
                }
                
                if timeRemainingCount == 0 {
                    for node in skShapeNodesSet {
                        if node.name!.contains("game") {
                            node.removeFromParent()
                        } else if node.name! == "endScreenLose" {
                            sk.addChild(node)
                        }
                    }
                    for node in skLabelNodesSet {
                        if node.name!.contains("game") {
                            node.removeFromParent()
                        } else if node.name! == "endScreenLose" {
                            sk.addChild(node)
                        }
                    }
                    for node in skSpriteNodesSet {
                        if node.name!.contains("game") {
                            node.removeFromParent()
                        } else if node.name! == "endScreenLose" {
                            sk.addChild(node)
                        }
                    }
                    
                    gameStage += 1
                }
            }
            for node in allNodesSet {
                if node.name!.contains("enemy") {
                    let yaw = sceneView.session.currentFrame?.camera.eulerAngles.y
                    node.eulerAngles.y = yaw!
                    node.position.x = node.position.x + 0.0005*sin(yaw!)
                    node.position.y = node.position.y + 0.0005*cos(yaw!)
                }
            }
        }
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            if gameStage == 0 {
                for node in skShapeNodesSet {
                    if node.name! == "startScreen" {
                        node.removeFromParent()
                    } else if node.name!.contains("game") && node.name! != "gameHandGun" {
                        sk.addChild(node)
                    }
                }
                for node in skLabelNodesSet {
                    if node.name! == "startScreen" {
                        node.removeFromParent()
                    } else if node.name!.contains("game") && node.name! != "gameHandGun" {
                        sk.addChild(node)
                    }
                }
                for node in skSpriteNodesSet {
                    if node.name! == "startScreen" {
                        node.removeFromParent()
                    } else if node.name!.contains("game") && node.name! != "gameHandGun" {
                        sk.addChild(node)
                    }
                }
                gameStage += 1
            }
            if gameStage == 1 && enemyPlacedCount >= numberOfEnemies && gunsPlacedCount >= numberOfGuns && ammoBoxPlacedCount >= numberOfAmmoBoxes {
                let location: CGPoint = rec.location(in: sceneView)
                var shot = false
                if hasGun >= 1 && ammoCount > 0 {
                    ammoCount -= 1
                    for node in skLabelNodesSet {
                        if node.name == "gameAmmoLabel" {
                            node.text = "Ammo: " + String(ammoCount)
                        }
                    }
                    shot = true
                    
                    let shotNode = SKSpriteNode(imageNamed: "Art.scnassets/images/shot.png")
                    shotNode.position = CGPoint(x: 240, y: 310)
                    shotNode.name = "game"
                    sk.addChild(shotNode)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        shotNode.removeFromParent()
                    }
                }
                let hits = sceneView.hitTest(location, options: [.boundingBoxOnly: true, .rootNode: sceneView.scene.rootNode])
                if hits != nil && !hits.isEmpty {
                    for hit in hits {
                        if (hit != nil && hit.node != nil) {
                            let tappedNode:SCNNode = hit.node
                            if let tappedName:String = tappedNode.name {
                                if tappedName.contains("enemy") && hasGun >= 1 && shot == true {
                                    DispatchQueue.main.async {
                                        tappedNode.removeFromParentNode()
                                    }
                                    enemiesLeft -= 1
                                    for node in skLabelNodesSet {
                                        if node.name == "gameTimeEnemiesRemaining" {
                                            node.text = "Time Left: " + String(timeRemainingCount) + "      Enemies Left: " + String(enemiesLeft)
                                        }
                                    }
                                    
                                    if enemiesLeft == 0 {
                                        for node in skShapeNodesSet {
                                            if node.name! == "endScreenWin" {
                                                sk.addChild(node)
                                            }
                                        }
                                        for node in skLabelNodesSet {
                                            if node.name! == "endScreenWin" {
                                                sk.addChild(node)
                                            }
                                        }
                                        
                                        gameStage += 1
                                    }
                                }
                                else if tappedName.contains("gun") {
                                    DispatchQueue.main.async {
                                        tappedNode.removeFromParentNode()
                                    }
                                    hasGun += 1
                                    ammoCount += 2
                                    for node in skSpriteNodesSet {
                                        if node.name == "gameHand" {
                                            node.removeFromParent()
                                        }
                                        if node.name == "gameHandGun" {
                                            sk.addChild(node)
                                        }
                                    }
                                    for node in skLabelNodesSet {
                                        if node.name == "gameAmmoLabel" {
                                            node.text = "Ammo: " + String(ammoCount)
                                        }
                                    }
                                }
                                else if tappedName.contains("ammoBox") && hasGun > 0 {
                                    DispatchQueue.main.async {
                                        tappedNode.removeFromParentNode()
                                    }
                                    ammoCount += 2
                                    for node in skLabelNodesSet {
                                        if node.name == "gameAmmoLabel" {
                                            node.text = "Ammo: " + String(ammoCount)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

PlaygroundPage.current.liveView = QISceneKitViewController()
PlaygroundPage.current.needsIndefiniteExecution = true
