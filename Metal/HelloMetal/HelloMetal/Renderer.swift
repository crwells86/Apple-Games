import SwiftUI
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    var parent: RenderedView
    var deviceGPU: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    
    init(_ parent: RenderedView) {
        self.parent = parent
        
        if let defaultDevice = MTLCreateSystemDefaultDevice() {
            self.deviceGPU = defaultDevice
        }
        
        self.metalCommandQueue = deviceGPU.makeCommandQueue()
        
        let vertices = [
            Vertex(position: [-1, -1], color: [1, 0, 0, 1]),
            Vertex(position: [1, -1], color: [0, 1, 0, 1]),
            Vertex(position: [0, 1], color: [0, 0, 1, 1])
        ]
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = deviceGPU.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = deviceGPU.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        vertexBuffer = deviceGPU.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // ?
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColorMake(0, 0.5, 0.5, 1)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

struct RenderedView: UIViewRepresentable {
    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeUIView(context: Context) -> MTKView {
        // The MTKView class provides a default implementation of a Metal-aware view that you can use to render graphics using Metal and display them onscreen.
        let metalView = MTKView()
        metalView.delegate = context.coordinator
        metalView.preferredFramesPerSecond = 60
        metalView.enableSetNeedsDisplay = true
        
        if let metelDevice = MTLCreateSystemDefaultDevice() {
            metalView.device = metelDevice
        }
        
        metalView.framebufferOnly = false
        metalView.drawableSize = metalView.frame.size
        
        return metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // ?
    }
}
