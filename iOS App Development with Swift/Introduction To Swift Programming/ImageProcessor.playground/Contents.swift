//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")!

// Process the image!

enum Color: String {
    case RED
    case GREEN
    case BLUE
}


protocol ImageFilter {
    func apply(image: RGBAImage) -> RGBAImage
}

class ImageUtility {
    static func calculateAverageColors(image: RGBAImage) -> [Color:Int] {
        var average : [Color: Int] = [
            Color.RED: 0,
            Color.BLUE: 0,
            Color.GREEN: 0
        ]
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                let pixel = image.pixels[index]
                average[Color.RED] = average[Color.RED]! + Int(pixel.red)
                average[Color.GREEN] = average[Color.GREEN]! + Int(pixel.green)
                average[Color.BLUE] = average[Color.BLUE]! + Int(pixel.blue)
            }
        }
        
        let count = image.width * image.height
        average[Color.RED] = average[Color.RED]!/count
        average[Color.GREEN] = average[Color.GREEN]!/count
        average[Color.BLUE] = average[Color.BLUE]!/count

        return average
    }
}

class ImageFilterManager: ImageFilter {
    let predefinedFilters: [String:ImageFilter] = ["150% brightness": BrightnessFilter(brightness: 1.5),
                                            "5x red": ColorBoostingFilter(color: Color.RED, boost: 5),
                                            "10x blue": ColorBoostingFilter(color: Color.BLUE, boost: 10),
                                            "15x green": ColorBoostingFilter(color: Color.GREEN, boost: 15),
                                            "sharper": SharpeningFilter()]

    var filters = [ImageFilter]()
    
    func addFilter(filter: String) {
        filters.append(predefinedFilters[filter]!)
    }
    
    func apply(image: RGBAImage) -> RGBAImage {
        var resultImage: RGBAImage = image
        
        for filter in filters {
            resultImage = filter.apply(resultImage)
        }
        
        return resultImage
    }
}

class ColorBoostingFilter: ImageFilter {
    let color: Color
    let boost: Int
    
    required init(color: Color, boost: Int) {
        self.color = color
        self.boost = boost
    }
    
    func apply(image: RGBAImage) -> RGBAImage {
        var localImage = image
        
        let average = ImageUtility.calculateAverageColors(image)
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                var pixel = image.pixels[index]
                
                switch color {
                case .RED:
                    pixel.red = UInt8(min(255, max(0, (Int(pixel.red) - average[Color.RED]!) * boost)))
                case .BLUE:
                    pixel.blue = UInt8(min(255, max(0, (Int(pixel.blue) - average[Color.BLUE]!) * boost)))
                case .GREEN:
                    pixel.green = UInt8(min(255, max(0, (Int(pixel.green) - average[Color.GREEN]!) * boost)))
                }
                localImage.pixels[index] = pixel
            }
        }
        
        return localImage
    }
}

class SharpeningFilter: ImageFilter {
    
    func apply(image: RGBAImage) -> RGBAImage {
        var localImage = image
        let sharpMatrix = [[-1, -1, -1],
                           [-1,  8, -1],
                           [-1, -1, -1]]
        
        for y in 1..<image.height-1 {
            for x in 1..<image.width-1 {
                let indexMatrix = [[(y-1) * image.width + x-1, (y-1) * image.width + x, (y-1) * image.width + x+1],
                             [y * image.width + x-1, y * image.width + x, y * image.width + x+1],
                             [(y+1) * image.width + x-1, (y+1) * image.width + x, (y+1) * image.width + x+1]]
                
                let index = y * image.width + x
                
                var red = 0, blue = 0, green = 0
                for r in 0..<3 {
                    for c in 0..<3 {
                        red += sharpMatrix[r][c] * Int(image.pixels[indexMatrix[r][c]].red)
                        blue += sharpMatrix[r][c] * Int(image.pixels[indexMatrix[r][c]].blue)
                        green += sharpMatrix[r][c] * Int(image.pixels[indexMatrix[r][c]].green)
                    }
                }
                
                var pixel = image.pixels[index]
                
                pixel.red = UInt8(min(255, max(0, red)))
                pixel.blue = UInt8(min(255, max(0, blue)))
                pixel.green = UInt8(min(255, max(0, green)))
                
                localImage.pixels[index] = pixel
            }
        }
        
        return localImage
    }
}

class BrightnessFilter: ImageFilter {
    let brightness: Float
    
    init(brightness: Float) {
        self.brightness = brightness
    }
    
    func apply(image: RGBAImage) -> RGBAImage {
        var localImage = image
        
        for y in 0..<image.height {
            for x in 0..<image.width {
                let index = y * image.width + x
                var pixel = image.pixels[index]
                
                pixel.red = UInt8(min(255, max(Int(Float(pixel.red) * brightness), 0)))
                pixel.blue = UInt8(min(255, max(Int(Float(pixel.blue) * brightness), 0)))
                pixel.green = UInt8(min(255, max(Int(Float(pixel.green) * brightness), 0)))
                
                localImage.pixels[index] = pixel
            }
        }
        
        return localImage
    }
}

let imageFilterManager = ImageFilterManager()

imageFilterManager.addFilter("150% brightness")
imageFilterManager.addFilter("sharper")

let myRGBA = imageFilterManager.apply(RGBAImage(image: image)!)

myRGBA.toUIImage()
