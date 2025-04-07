import Foundation

protocol FileStorageManagerProtocol {
    func getLocalURL(forRemoteURL remoteURL: URL) -> URL?
    func fileExists(at url: URL) -> Bool
    func removeFile(at url: URL) throws
    func saveFile(data: Data, to destinationURL: URL) throws
}
