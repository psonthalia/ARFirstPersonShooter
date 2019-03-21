//: A SceneKit and ARKit based Playground

import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var size:CGRect!
    
//    var numberOfSoldiers = 0;
//    var soldiersPlacedCount = 0;
    
    var numberOfEnemies = 1;
    var enemyPlacedCount = 0;
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
    
    var gameStage = 0
    
    override func loadView() {
        size = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0)
        sceneView = ARSCNView(frame: size)
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        
        
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
        
        sk = SKScene(size: CGSize(width: size.width, height: size.height))
        skLabel = SKLabelNode(text: "Keep Scanning Surroundings")
        skLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        skLabel.fontName =  "Helvetica"
        skLabel.position = CGPoint(x: 240, y: 300)
        sk.addChild(skLabel)
        
        skAmmoLabel = SKLabelNode(text: "")
        skAmmoLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        skAmmoLabel.fontName =  "Helvetica"
        skAmmoLabel.position = CGPoint(x: size.width - 50, y: 300)
        sk.addChild(skAmmoLabel)
        
        handLeft = SKSpriteNode(imageNamed: "Art.scnassets/images/handLeft.png")
        handLeft.position = CGPoint(x: 70, y: 150)
        sk.addChild(handLeft)
        
        handRight = SKSpriteNode(imageNamed: "Art.scnassets/images/handRight.png")
        handRight.position = CGPoint(x: size.width - 70, y: 150)
        sk.addChild(handRight)
        
        
        sceneView.overlaySKScene = sk
        
//        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateSoldiers), userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
        sceneView.scene.rootNode.name = "aaa"
        
        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
             if (gunsPlacedCount < numberOfGuns) {
                let gun = self.gunNode("gun")
                gun.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(gun)
                self.allNodesSet.insert(gun)
                self.gunsPlacedCount += 1
             } else if (enemyPlacedCount < numberOfEnemies) {
                let enemy = self.enemyNode("enemy " + String(enemyPlacedCount))
                enemy.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(enemy)
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
                }
            }
        }
    }
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
//        for node in self.allNodesSet {
//            if node != nil && node.name!.contains("soldier") {
//                let pitch = sceneView.session.currentFrame?.camera.eulerAngles.x
//                let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
//                let roll = sceneView.session.currentFrame?.camera.eulerAngles.z
//                let newRotation = SCNVector3Make(pitch!, yawn!, roll!)
//                node.eulerAngles = newRotation
//            }
//        }
//    }
    
//    @objc func animateSoldiers() {
//        if soldiersPlacedCount >= numberOfSoldiers && gunsPlacedCount >= numberOfGuns && ammoBoxPlacedCount >= numberOfAmmoBoxes {
//          for node in self.allNodesSet {
//              if node.name!.contains("soldier") {
////                  node.position = SCNVector3(x: node.position.x + 0.01, y: node.position.y, z: node.position.z)
//
//                  let pitch = sceneView.session.currentFrame?.camera.eulerAngles.x
//                  let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
//                  let roll = sceneView.session.currentFrame?.camera.eulerAngles.z
//                  let newRotation = SCNVector3Make(pitch!, yawn!, roll!)
//                  node.eulerAngles = newRotation
//              }
//          }
//      }
//    }

    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended && enemyPlacedCount >= numberOfEnemies && gunsPlacedCount >= numberOfGuns && ammoBoxPlacedCount >= numberOfAmmoBoxes {
            let location: CGPoint = rec.location(in: sceneView)
            sceneView.session.currentFrame?.camera
            
            if self.hasGun == 1 && self.ammoCount > 0 {
                self.ammoCount -= 1
                self.updateAmmo()
                self.shotFired()
                if self.ammoCount == 0 && self.ammoBoxSet.count > 0 {
                    self.sceneView.scene.rootNode.addChildNode(self.ammoBoxSet.removeFirst())
                }
            }
            
            let hits = sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                let tappedNode:SCNNode? = hits.last?.node
                if (allNodesSet.contains(tappedNode!)) {
                    if tappedNode!.name!.contains("enemy") && self.hasGun == 1 && self.ammoCount > 0 {
                        allNodesSet.remove(tappedNode!)
                        tappedNode!.removeFromParentNode()
                    }
                    else if tappedNode!.name!.contains("gun") {
                        allNodesSet.remove(tappedNode!)
                        tappedNode!.removeFromParentNode()
                        handLeft.removeFromParent()
                        handRight.removeFromParent()
                        
                        let handGun = SKSpriteNode(imageNamed: "Art.scnassets/images/gunHolding.png")
                        handGun.position = CGPoint(x: 70, y: 150)
                        sk.addChild(handGun)
                        
                        self.hasGun = 1
                        self.ammoCount += 2
                        updateAmmo()
                    } else if tappedNode!.name!.contains("ammoBox") && self.hasGun == 1 {
                        allNodesSet.remove(tappedNode!)
                        tappedNode!.removeFromParentNode()
                        self.ammoCount += 2
                        updateAmmo()
                    }
                }
            }
        }
    }
    
    func updateAmmo() {
//          for i in sk.children {
//              if i.name == "bullet" {
//                  i.removeFromParent()
//              }
//          }
        for i in 0..<self.ammoCount {
            let bullet = SKSpriteNode(imageNamed: "Art.scnassets/images/bullet.png")
            bullet.name = "bullet " + String(i)
            bullet.position = CGPoint(x: (size.width - 10 - CGFloat(i * 6)), y: size.height - 15)
//              sk.addChild(bullet)
        }
    }
    
    func shotFired() {
        let shotNode = SKSpriteNode(imageNamed: "Art.scnassets/images/shot.png")
        shotNode.position = CGPoint(x: 240, y: 310)
        sk.addChild(shotNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            shotNode.removeFromParent()
        }
    }
    
//    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        DispatchQueue.main.async {
//            // Rotate Max to face the camera?
//            self.cameraNode.frame.maxX
//            self.characterOrientation?.runAction(
//                SCNAction.rotateTo(x: self.cameraNode.frame.maxX, y: self.cameraNode.frame.maxY, z: 0.0, duration: 0.1, usesShortestUnitArc:true))
//        }
//    }
    
    func enemyNode(_ name: String) -> SCNNode {
        let scene = SCNScene(named: "Art.scnassets/character/soldier.scn")!
        let node = scene.rootNode.childNode(withName: "soldier", recursively: true)!
        node.name = name
        node.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
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
