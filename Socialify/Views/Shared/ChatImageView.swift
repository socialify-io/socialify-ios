//
//  ChatImageView.swift
//  Socialify
//
//  Created by Tomasz on 06/05/2022.
//

import SwiftUI
import UIKit
import Combine

struct ChatImageView: View {
    let syncedImage: AsyncImage<Image>
    
    @State var url: URL?
    @State var isLoading = false
    @State var cache: ImageCache? = Environment(\.imageCache).wrappedValue
    @State var cancellable: AnyCancellable?
    @State var image: UIImage?
    
    init(syncedImage: AsyncImage<Image>) {
        self.syncedImage = syncedImage
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url!] = $0 }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            syncedImage
                .onAppear {
                    self.url = syncedImage.url
                }
                .scaledToFit()
                .pinchToZoom()
            
            Spacer()
            
            HStack {
                Button(action: {
                    let imageProcessingQueue = DispatchQueue(label: "image-processing")
                                    
                    cancellable = URLSession.shared.dataTaskPublisher(for: url!)
                        .map { UIImage(data: $0.data) }
                        .replaceError(with: nil)
                        .handleEvents(receiveSubscription: { _ in self.onStart() },
                                      receiveOutput: { self.cache($0) },
                                      receiveCompletion: {_ in
                                        self.onFinish()
                                        },
                                      receiveCancel: { self.onFinish() })
                        .subscribe(on: imageProcessingQueue)
                        .receive(on: DispatchQueue.main)
                        .sink { image = $0
                            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
                        }
                    
                    
                    
                    
                }) {
                    Image(systemName: "arrow.down")
                }
            }
        }
    }
}

class PinchZoomView: UIView {

    weak var delegate: PinchZoomViewDelgate?

    private(set) var scale: CGFloat = 1.0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .leading {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    private var startScale: CGFloat = 1.0
    private var latestPinchScale: CGFloat = 0

    init(scale: CGFloat, anchor: UnitPoint, offset: CGSize) {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func pinch(gesture: UIPinchGestureRecognizer) {

        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
            numberOfTouches = gesture.numberOfTouches
           

        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)

                numberOfTouches = gesture.numberOfTouches
            }
            
            
            if(gesture.scale>latestPinchScale) {
                //if(scale < 3.0) {
                    scale += (gesture.scale*startScale)/scale*0.01
                    latestPinchScale = gesture.scale
                //}
            } else {
                //if(scale > 1.0){
                    scale -= (gesture.scale*startScale)*scale*0.01
                    latestPinchScale = gesture.scale
                //}
            }
            
            print(gesture.scale)

            location = gesture.location(in: self)
            offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)

        case .ended, .cancelled, .failed:
            isPinching = false
            startScale = scale
            
            if(scale < 1.0) {
                scale = 1.0
                anchor = .center
            }
            if(scale > 10.0) {
                scale = 10.0
            }
            
        default:
            break
        }
    }
}

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    @Binding var isPinching: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView(scale: scale, anchor: anchor, offset: offset)
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }

    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }

    class Coordinator: NSObject, PinchZoomViewDelgate {
        var pinchZoom: PinchZoom

        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }

        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }
}

struct PinchToZoom: ViewModifier {
    @State var scale: CGFloat = 1.0
    @State var anchor: UnitPoint = .center
    @State var offset: CGSize = .zero
    @State var isPinching: Bool = true

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .animation(isPinching ? .none : .spring())
            .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
    }
}

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}

func documentDirectoryPath() -> URL? {
    let path = FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)
    return path.first
}

func saveJpg(_ image: UIImage, name: String) {
    print(image)
    if let jpgData = image.jpegData(compressionQuality: 0.5),
        let path = documentDirectoryPath()?.appendingPathComponent("\(name).jpg") {
        try? jpgData.write(to: path)
    } else {
        print("NIE DZIALAAAAAAAAAAAAAAAAAAaaa")
    }
}
