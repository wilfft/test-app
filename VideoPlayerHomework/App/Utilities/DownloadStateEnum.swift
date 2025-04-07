import Foundation

enum DownloadStateEnum {
       case idle
       case downloading
       case completed(URL)
       case failed(Error)
   }
   
