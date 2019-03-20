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
    var soldierSet = Set<SCNNode>()

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
        
        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if (soldiersPlacedCount < numberOfSoldiers) {
                let soldier = soldierNode("soldier " + String(soldiersPlacedCount))
                soldier.position = SCNVector3(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(soldier)
                
                self.soldierSet.insert(soldier)
                self.soldiersPlacedCount += 1
            }
        }
    }

    @objc func handleTap(rec: UITapGestureRecognizer) {
        if soldiersPlacedCount == numberOfSoldiers {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = sceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                for hit in hits {
                    let tappedNode = hit.node
                    if (soldierSet.contains(tappedNode)) {
                        soldierSet.remove(tappedNode)
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
        soldier.scale = SCNVector3(x: 0.03, y: 0.03, z: 0.03)
        return soldier
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
