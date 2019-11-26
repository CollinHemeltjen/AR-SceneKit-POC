//
//  ViewController.swift
//  AR+SceneKit-POC
//
//  Created by Collin Hemeltjen on 22/11/2019.
//  Copyright © 2019 Collin Hemeltjen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

		addTapGestureToSceneView()
    }

	func addVase(x: Float = 0, y: Float = 0, z: Float = -0.2) {
		let filePath = Bundle.main.path(forResource: "vase", ofType: "scn", inDirectory: "art.scnassets")!
		guard let node = SCNReferenceNode(url: URL(fileURLWithPath: filePath)) else {
			fatalError()
		}

		node.position = SCNVector3(x,y,z)
		node.load()
		
		sceneView.scene.rootNode.addChildNode(node)
	}

	func addTapGestureToSceneView() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
		sceneView.addGestureRecognizer(tapGestureRecognizer)
	}

	@objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
		let tapLocation = recognizer.location(in: sceneView)
		let hitTestResults = sceneView.hitTest(tapLocation)
		guard let node = hitTestResults.first?.node else {
			let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .estimatedHorizontalPlane)
			if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
				let translation = hitTestResultWithFeaturePoints.worldTransform.translation
				addVase(x: translation.x, y: translation.y, z: translation.z)
			}
			return
		}
		node.removeFromParentNode()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        return node
    }
*/

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }

}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
