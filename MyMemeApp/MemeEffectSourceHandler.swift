import CameraCommon
import Combine
import EffectBitmapOverlay
import EffectCommon
import EffectPen
import EffectPhoto
import EffectFilter
import EffectText
import DefaultBoards
import DefaultFilter
import EffectBoard
/*import DefaultFont
import OneCameraDefaultImpl

class MemeEffectSourceHandler: DefaultEffectSourceManager {
     var penManager: PenEffectSourceHandler?
    var pensource: EffectSource?

    override func setupEffectSources(resolution: VideoResolution, undoRedoService: UndoService) {
        super.setupEffectSources(resolution: resolution, undoRedoService: undoRedoService)
        
        penManager = PenEffectSourceHandler(orientationService: orientationService, resolution: resolution, undoRedoService: undoRedoService, delegate: self, telemetryServiceWrapper: telemetryServiceWrapper)
    }
    
    override func getEffectSources(layerCoordinator: EffectLayerCoordinator, captureMode: CaptureMode) -> [EffectSource] {
        pensource = penManager?.effectSource()
        super.getEffectSources(layerCoordinator: layerCoordinator, captureMode: captureMode)
        effectSources.append(pensource!)
        return effectSources
    }
}*/
