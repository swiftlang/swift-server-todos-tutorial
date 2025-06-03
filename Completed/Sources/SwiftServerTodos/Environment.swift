import Foundation

enum EnvVarError: Error, CustomStringConvertible {
    case malformedEnvVarValue(name: String)

    var description: String {
        switch self {
        case .malformedEnvVarValue(let name):
            return "Malformed environment variable value for name: \(name)"
        }
    }
}

func getOptionalEnvVar(_ name: String) -> String? {
    ProcessInfo.processInfo.environment[name]
}

func getOptionalEnvVar<Value: LosslessStringConvertible>(_ name: String) throws -> Value? {
    guard let stringValue = getOptionalEnvVar(name) else {
        return nil
    }
    guard let typedValue = Value.init(stringValue) else {
        throw EnvVarError.malformedEnvVarValue(name: name)
    }
    return typedValue
}

func getOptionalURLEnvVar(_ name: String) throws -> URL? {
    guard let stringValue = ProcessInfo.processInfo.environment[name] else {
        return nil
    }
    guard let typedValue = URL(string: stringValue) else {
        throw EnvVarError.malformedEnvVarValue(name: name)
    }
    return typedValue
}
