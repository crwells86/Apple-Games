import SceneKit

#if os(macOS)
typealias Scalar = CGFloat
#else
typealias Scalar = Float
#endif

extension SCNVector3 {
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func * (vector: SCNVector3, scalar: Scalar) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
    
    static func += (lhs: inout SCNVector3, rhs: SCNVector3) {
        lhs = SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    func normalized() -> SCNVector3 {
        let length = Scalar(sqrt(x * x + y * y + z * z))
        return SCNVector3(x / length, y / length, z / length)
    }
    
    func distance(to vector: SCNVector3) -> Scalar {
        return Scalar(sqrt(pow(self.x - vector.x, 2) + pow(self.y - vector.y, 2) + pow(self.z - vector.z, 2)))
    }
    
    func length() -> Scalar {
        return Scalar(sqrt(x * x + y * y + z * z))
    }
    
    func transformed(by matrix: SCNMatrix4) -> SCNVector3 {
        let x = Scalar(matrix.m11) * self.x + Scalar(matrix.m21) * self.y + Scalar(matrix.m31) * self.z + Scalar(matrix.m41)
        let y = Scalar(matrix.m12) * self.x + Scalar(matrix.m22) * self.y + Scalar(matrix.m32) * self.z + Scalar(matrix.m42)
        let z = Scalar(matrix.m13) * self.x + Scalar(matrix.m23) * self.y + Scalar(matrix.m33) * self.z + Scalar(matrix.m43)
        return SCNVector3(x, y, z)
    }
    
    func rotated(by angle: Scalar) -> SCNVector3 {
        let cosAngle = Scalar(cos(angle))
        let sinAngle = Scalar(sin(angle))
        return SCNVector3(
            x * cosAngle - z * sinAngle,
            y,
            x * sinAngle + z * cosAngle
        )
    }
    
    func crossProduct(_ vector: SCNVector3) -> SCNVector3 {
        let x = self.y * vector.z - self.z * vector.y
        let y = self.z * vector.x - self.x * vector.z
        let z = self.x * vector.y - self.y * vector.x
        return SCNVector3(x, y, z)
    }
}
