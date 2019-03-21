//: A SceneKit and ARKit based Playground

import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var size:CGRect!
    
    var numberOfSoldiers = 0;
    var soldiersPlacedCount = 0;
    var numberOfGuns = 1;
    var gunsPlacedCount = 0;
    var numberOfAmmoBoxes = 1;
    var ammoBoxPlacedCount = 0;

    var allNodesSet = Set<SCNNode>()
    var ammoBoxSet = Set<SCNNode>()
    var currentGunsList:[SCNNode?] = []
    var currentGun:Int = 0
    
    var sk:SKScene!
    var skLabel:SKLabelNode!
    var ammoCount:Int = 0
    var hasGun = 0

    override func loadView() {
        size = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0)
        sceneView = ARSCNView(frame: size)
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        sceneView.setup()
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
        sceneView.overlaySKScene = sk
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.animateSoldiers), userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
        sceneView.scene.rootNode.name = "aaa"
        
        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if (soldiersPlacedCount < numberOfSoldiers) {
                let soldier = soldierNode("soldier " + String(soldiersPlacedCount))
                soldier.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(soldier)
                self.allNodesSet.insert(soldier)
                self.soldiersPlacedCount += 1
            } else if (gunsPlacedCount < numberOfGuns) {
                let gun = self.gunNode("gun")
                gun.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(gun)
                self.allNodesSet.insert(gun)
                self.gunsPlacedCount += 1
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
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
    }
    
    @objc func animateSoldiers() {
//      if self.soldiersPlacedCount >= self.numberOfSoldiers {
//          for node in self.allNodesSet {
//              if node.name!.contains("soldier") {
//                  node.position = SCNVector3(x: node.position.x + 0.01, y: node.position.y, z: node.position.z)
//
//                  let pitch = sceneView.session.currentFrame?.camera.eulerAngles.x
//                  let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
//                  let roll = sceneView.session.currentFrame?.camera.eulerAngles.z
//                  let newRotation = SCNVector3Make(pitch!, yawn!, roll!)
//                  node.eulerAngles = newRotation
//              }
//          }
//      }
    }

    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended && soldiersPlacedCount >= numberOfSoldiers && gunsPlacedCount >= numberOfGuns && ammoBoxPlacedCount >= numberOfAmmoBoxes {
            let location: CGPoint = rec.location(in: sceneView)
            if self.hasGun == 1 && self.ammoCount > 0 {
                self.ammoCount -= 1
                updateAmmo()
                if self.ammoCount == 0 && self.ammoBoxSet.count > 0 {
                    self.sceneView.scene.rootNode.addChildNode(self.ammoBoxSet.removeFirst())
                }
            }
            let hits = sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                let tappedNode:SCNNode? = hits.last?.node
                if (allNodesSet.contains(tappedNode!)) {
                    if tappedNode!.name!.contains("soldier") && self.hasGun == 1 {
                        allNodesSet.remove(tappedNode!)
                        tappedNode!.removeFromParentNode()
                    }
                    else if tappedNode!.name!.contains("gun") {
                        allNodesSet.remove(tappedNode!)
                        tappedNode!.removeFromParentNode()
                        self.hasGun = 1
                        self.ammoCount += 2
                        let gunImage = SKSpriteNode(imageNamed: "Art.scnassets/images/gun.png")
                        gunImage.position = CGPoint(x: size.width - 100, y: 0)
                        self.sk.addChild(gunImage)
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

    func soldierNode(_ name: String) -> SCNNode {
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
    
    func updateAmmo() {
        for i in sk.children {
            if (i.name == "bullet") {
                i.removeFromParent()
            }
        }
        for i in 0..<self.ammoCount {
            let bullet = SKSpriteNode(imageNamed: "Art.scnassets/images/bullet.png")
            bullet.name = "bullet"
            bullet.position = CGPoint(x: (size.width - 10 - CGFloat(i * 6)), y: size.height - 15)
            sk.addChild(bullet)
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
}


extension ARSCNView {
    func setup() {
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = false
        
        preferredFramesPerSecond = 60
        contentScaleFactor = 1.3
    }
}


PlaygroundPage.current.liveView = QISceneKitViewController()
PlaygroundPage.current.needsIndefiniteExecution = true
