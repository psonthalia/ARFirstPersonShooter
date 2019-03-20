//: A SceneKit and ARKit based Playground

import PlaygroundSupport
import SceneKit
import ARKit

class QISceneKitViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let session = ARSession()
    var sceneView: ARSCNView!
    var cameraNode = SCNNode()
    
    var numberOfSoldiers = 2;
    var soldiersPlacedCount = 0;
    var allNodesSet = Set<SCNNode>()
//    var gun1: SCNNode?
//    var gun2: SCNNode?
//    var gun3: SCNNode?

    override func loadView() {
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        
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
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
        
//        self.gun1 = self.gun1Node("gun1")
//        gun2 = gun2Node("gun2")
//        self.gun3 = self.gun3Node("gun3")

        
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
            } else {
                if (soldiersPlacedCount < (numberOfSoldiers + 3)) {
                    var gun1 = self.gun1Node("gun1")
                    gun1.position = SCNVector3(anchor.transform.columns.3.x - 1, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                    self.sceneView.scene.rootNode.addChildNode(gun1)
                    self.allNodesSet.insert(gun1)
                    self.soldiersPlacedCount += 1
                }
//                else if (!allNodesSet.contains(gun2!)) {
//                    gun2!.position = SCNVector3(anchor.transform.columns.3.x - 1, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
//                    self.sceneView.scene.rootNode.addChildNode(gun2!)
//                    self.allNodesSet.insert(gun2!)
//                }
//                else if (!self.allNodesSet.contains(self.gun3!)) {
//                    self.gun3!.position = SCNVector3(anchor.transform.columns.3.x - 1, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
//                    self.sceneView.scene.rootNode.addChildNode(self.gun3!)
//                    self.allNodesSet.insert(self.gun3!)
//                }
            }
        }
    }

    @objc func handleTap(rec: UITapGestureRecognizer) {
        if soldiersPlacedCount >= numberOfSoldiers {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                for hit in hits {
                    let tappedNode = hit.node
                    if (allNodesSet.contains(tappedNode)) {
                        allNodesSet.remove(tappedNode)
                        tappedNode.removeFromParentNode()
                    }
                }
                
            }
        }
    }

    func soldierNode(_ name: String) -> SCNNode {
        let soldierScene = SCNScene(named: "Art.scnassets/character/soldier.scn")!
        let soldier = soldierScene.rootNode.childNode(withName: "soldier", recursively: true)!
        soldier.name = name
        soldier.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        return soldier
    }
    
//    func gun1Node(_ name: String) -> SCNNode {
//        let scene = SCNScene(named: "Art.scnassets/gun1/gun1.scn")!
//        let node = scene.rootNode.childNode(withName: "gun1", recursively: true)!
//        node.geometry?.firstMaterial?.diffuse.contents = "Art.scnassets/gun1/Tex_0004_1.png"
//        node.name = name
//        node.eulerAngles = SCNVector3(0, 90, 0)
//        node.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
//        return node
//    }
    func gun1Node(_ name: String) -> SCNNode {
        let scene = SCNScene(named: "Art.scnassets/gun2/gun2.scn")!
        let node = scene.rootNode.childNode(withName: "gun2", recursively: true)!
        node.name = name
        node.eulerAngles = SCNVector3(0, 0, 90)
//        node.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        return node
    }
    func gun3Node(_ name: String) -> SCNNode {
        let scene = SCNScene(named: "Art.scnassets/gun3/gun3.scn")!
        let node = scene.rootNode.childNode(withName: "gun3", recursively: true)!
        node.name = name
        node.eulerAngles = SCNVector3(0, 0, 90)
        node.scale = SCNVector3(x: 0.002, y: 0.002, z: 0.002)
        return node
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
