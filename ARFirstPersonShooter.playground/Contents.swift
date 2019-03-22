//: A SceneKit and ARKit based Playground

import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var size:CGRect!
    
    var numberOfEnemies = 1;
    var enemyPlacedCount = 0;
    var enemiesLeft = 1;
    var numberOfGuns = 1;
    var gunsPlacedCount = 0;
    var numberOfAmmoBoxes = 1;
    var ammoBoxPlacedCount = 0;
    
    var allNodesSet = Set<SCNNode>()
    var ammoBoxSet = Set<SCNNode>()
    
    var sk:SKScene!
    var skLabel:SKLabelNode!
    var skAmmoLabel:SKLabelNode!
    var ammoCount = 0
    var hasGun = 0
    var handLeft:SKSpriteNode!
    var handRight:SKSpriteNode!
    var timeRemaining:SKLabelNode!
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
        sk.addChild(bg)

        let welcomeLabel = SKLabelNode(text: "Welcome to my WWDC Submission")
        welcomeLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        welcomeLabel.fontName =  "Helvetica"
        welcomeLabel.fontSize = 27
        welcomeLabel.name = "startScreen"
        welcomeLabel.position = CGPoint(x: size.width / 2, y: size.height - 70)
        sk.addChild(welcomeLabel)
        
        let contentLabel = SKLabelNode(text: "This is an Augmented Reality First Person Shooter game in which you need to kill all of the aliens before time runs out. Here is how you are going to do that:\n\n" +
                                              "Start by scanning your surroundings by rotating the iPad around you slowly. Then the game will start!\n\n" +
                                              "The first task is to pick up a gun to shoot the aliens with! Look around you, there will be one hidden! Then aim and get close to shoot. Your gun doesn't have a long range!\n\n" +
                                              "If you run out of ammo, look around for an ammo box to refill.\n\n" +
                                              "Tap anywhere to begin")
        contentLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        contentLabel.fontName =  "Helvetica"
        contentLabel.fontSize = 20
        contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        contentLabel.numberOfLines = 0
        contentLabel.preferredMaxLayoutWidth = 470
        contentLabel.name = "startScreen"
        contentLabel.position = CGPoint(x: size.width / 2, y: size.height - 480)
        sk.addChild(contentLabel)
        
        
        
        let bgBlack = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bgBlack.fillColor = SKColor.black
        bgBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgBlack.name = "endScreen"
        bgBlack.isHidden = true
        sk.addChild(bgBlack)
        
        let winLabel = SKLabelNode(text: "YOU HAVE WON!")
        winLabel.fontColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
        winLabel.fontName =  "Helvetica"
        winLabel.fontSize = 27
        winLabel.name = "endScreen"
        winLabel.isHidden = true
        winLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sk.addChild(winLabel)

        let loseLabel = SKLabelNode(text: "YOU HAVE FAILED")
        loseLabel.fontColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
        loseLabel.fontName =  "Helvetica"
        loseLabel.fontSize = 27
        loseLabel.name = "endScreenLose"
        loseLabel.isHidden = true
        loseLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sk.addChild(loseLabel)
        
        
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        sceneView.delegate = self
        sceneView.session = session
        sceneView.showsStatistics = true
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        skLabel = SKLabelNode(text: "Keep Scanning Surroundings")
        skLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        skLabel.fontName =  "Helvetica"
        skLabel.position = CGPoint(x: 240, y: 300)
        skLabel.isHidden = true
        skLabel.name = "game"
        sk.addChild(skLabel)
        
        let topBar = SKShapeNode(rectOf: CGSize(width: size.width, height: 20))
        topBar.fillColor = SKColor.white
        topBar.position = CGPoint(x: size.width / 2, y: size.height - 10)
        topBar.name = "game"
        topBar.isHidden = true
        sk.addChild(topBar)
        
        skAmmoLabel = SKLabelNode(text: "Ammo: 0")
        skAmmoLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        skAmmoLabel.fontName =  "Helvetica"
        skAmmoLabel.fontSize = 18
        skAmmoLabel.position = CGPoint(x: size.width - 50, y: size.height - 20)
        skAmmoLabel.isHidden = true
        skAmmoLabel.name = "game"
        sk.addChild(skAmmoLabel)
        
        timeRemaining = SKLabelNode(text: "Time Remaining: " + String(timeRemainingCount))
        timeRemaining.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        timeRemaining.fontName =  "Helvetica"
        timeRemaining.fontSize = 18
        timeRemaining.position = CGPoint(x: 100, y: size.height - 20)
        timeRemaining.isHidden = true
        timeRemaining.name = "game"
        sk.addChild(timeRemaining)
        
        handLeft = SKSpriteNode(imageNamed: "Art.scnassets/images/handLeft.png")
        handLeft.position = CGPoint(x: 70, y: 150)
        handLeft.isHidden = true
        handLeft.name = "game"
        sk.addChild(handLeft)
        
        handRight = SKSpriteNode(imageNamed: "Art.scnassets/images/handRight.png")
        handRight.position = CGPoint(x: size.width - 70, y: 150)
        handRight.isHidden = true
        handRight.name = "game"
        sk.addChild(handRight)
        
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        sceneView.overlaySKScene = sk
        self.view = sceneView
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if gameStage == 1 {
            for anchor in anchors {
                if (gunsPlacedCount < numberOfGuns) {
                    let gun = self.gunNode("gun")
                    gun.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                    self.allNodesSet.insert(gun)
                    self.gunsPlacedCount += 1
                } else if (enemyPlacedCount < numberOfEnemies) {
                    let enemy = self.enemyNode("enemy " + String(enemyPlacedCount))
                    enemy.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                    self.allNodesSet.insert(enemy)
                    self.enemyPlacedCount += 1
                } else if (ammoBoxPlacedCount < numberOfAmmoBoxes) {
                    let box = self.ammoBoxNode("ammoBox " + String(ammoBoxPlacedCount))
                    box.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                    self.allNodesSet.insert(box)
                    self.ammoBoxSet.insert(box)
                    self.ammoBoxPlacedCount += 1
                    
                    if self.ammoBoxPlacedCount == self.numberOfAmmoBoxes {
                        skLabel.removeFromParent()
                        
                        for node in self.allNodesSet {
                            //SHOW A START MESSAGE
                            if (!node.name!.contains("ammoBox")) {
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
                timeRemaining.text = "Time Remaining: " + String(timeRemainingCount)
            }
            for node in self.allNodesSet {
                if node != nil && node.name!.contains("enemy") {
                    let yaw = sceneView.session.currentFrame?.camera.eulerAngles.y
                    node.eulerAngles.y = yaw!
                    node.position.x = node.position.x + 0.001*sin(yaw!)
                    node.position.y = node.position.y + 0.001*cos(yaw!)
                    
                }
            }
        }
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            if gameStage == 0 {
                for node in sk.children {
                    if node.name! == "startScreen" {
                        node.removeFromParent()
                    } else if node.name! == "game" {
                        node.isHidden = false
                    }
                }
                gameStage += 1
            }
            if gameStage == 1 && enemyPlacedCount >= numberOfEnemies && gunsPlacedCount >= numberOfGuns && ammoBoxPlacedCount >= numberOfAmmoBoxes {
                let location: CGPoint = rec.location(in: sceneView)
                sceneView.session.currentFrame?.camera
                
                if self.hasGun >= 1 && self.ammoCount > 0 {
                    self.ammoCount -= 1
                    skAmmoLabel.text = "Ammo: " + String(self.ammoCount)
                    
                    let shotNode = SKSpriteNode(imageNamed: "Art.scnassets/images/shot.png")
                    shotNode.position = CGPoint(x: 240, y: 310)
                    shotNode.name = "game"
                    sk.addChild(shotNode)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        shotNode.removeFromParent()
                    }
                    
                    if self.ammoCount == 0 && self.ammoBoxSet.count > 0 {
                        self.sceneView.scene.rootNode.addChildNode(self.ammoBoxSet.removeFirst())
                    }
                }
                
                let hits = sceneView.hitTest(location, options: nil)
                if !hits.isEmpty {
                    let tappedNode:SCNNode? = hits.last?.node
                    if (allNodesSet.contains(tappedNode!)) {
                        if tappedNode!.name!.contains("enemy") && self.hasGun >= 1 && self.ammoCount > 0 {
                            allNodesSet.remove(tappedNode!)
                            enemiesLeft -= 1
                            tappedNode!.removeFromParentNode()
                            
                            if enemiesLeft == 0 {
                                for node in sk.children {
                                    if node.name! == "game" {
                                        node.removeFromParent()
                                    } else if node.name! == "endScreen" {
                                        node.isHidden = false
                                    }
                                }
                                gameStage += 1
                            }
                        }
                        else if tappedNode!.name!.contains("gun") {
                            allNodesSet.remove(tappedNode!)
                            tappedNode!.removeFromParentNode()
                            handLeft.removeFromParent()
                            handRight.removeFromParent()
                            
                            let handGun = SKSpriteNode(imageNamed: "Art.scnassets/images/gunHolding.png")
                            handGun.position = CGPoint(x: 70, y: 150)
                            handGun.name = "game"
                            sk.addChild(handGun)
                            
                            self.hasGun += 1
                            self.ammoCount += 2
                            skAmmoLabel.text = "Ammo: " + String(self.ammoCount)
                        } else if tappedNode!.name!.contains("ammoBox") && self.hasGun >= 1 {
                            allNodesSet.remove(tappedNode!)
                            tappedNode!.removeFromParentNode()
                            self.ammoCount += 2
                            skAmmoLabel.text = "Ammo: " + String(self.ammoCount)
                        }
                    }
                }
            }
        }
    }

    func enemyNode(_ name: String) -> SCNNode {
        let scene = SCNScene(named: "Art.scnassets/character/enemy.scn")!
        let node = scene.rootNode.childNode(withName: "enemy", recursively: true)!
        node.name = name
        node.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        return node
    }
    func gunNode(_ name: String) -> SCNNode {
        let scene = SCNScene(named: "Art.scnassets/gun/gun.scn")!
        let node = scene.rootNode.childNode(withName: "gun", recursively: true)!
        node.name = name
        node.eulerAngles = SCNVector3(0, 0, 90)
        return node
    }
    func ammoBoxNode(_ name: String) -> SCNNode {
        let scene = SCNScene(named: "Art.scnassets/box/box.scn")!
        let node = scene.rootNode.childNode(withName: "box", recursively: true)!
        node.name = name
        return node
    }
}

PlaygroundPage.current.liveView = QISceneKitViewController()
PlaygroundPage.current.needsIndefiniteExecution = true
