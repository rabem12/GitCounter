import Foundation

struct GitHubTrafficClones: Codable {
    let count: Int
    let uniques: Int
}

struct GitHubTrafficViews: Codable {
    let count: Int
    let uniques: Int
}

let session = URLSession.shared

func fetchCSV() async {
    let safeOwner = "rabem12"
    let safeRepo = "Barony-MacOS"
    var totalClones = 0
    var totalViews = 0
    var uniqueCloners = 0
    var uniqueVisitors = 0
    
    if let csvURL = URL(string: "https://raw.githubusercontent.com/\(safeOwner)/\(safeRepo)/main/stats/downloads.csv") {
        print("URL: \(csvURL)")
        var req = URLRequest(url: csvURL)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        if let (csvData, csvRes) = try? await session.data(for: req),
           let httpRes = csvRes as? HTTPURLResponse {
           print("Status: \(httpRes.statusCode)")
           if httpRes.statusCode == 200,
              let csvString = String(data: csvData, encoding: .utf8) {
               
               let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
               if lines.count > 1, let lastLine = lines.last {
                   print("Last line: \(lastLine)")
                   let cols = lastLine.components(separatedBy: ",")
                   if cols.count >= 8 {
                       totalClones = Int(cols[4]) ?? 0
                       uniqueCloners = Int(cols[5]) ?? 0
                       totalViews = Int(cols[6]) ?? 0
                       uniqueVisitors = Int(cols[7]) ?? 0
                       print("Clones: \(totalClones), Views: \(totalViews)")
                   } else {
                       print("Cols length is less than 8")
                   }
               } else {
                   print("Not enough lines")
               }
           }
        } else {
           print("Failed request")
        }
    }
}

let group = DispatchGroup()
group.enter()
Task {
    await fetchCSV()
    group.leave()
}
group.wait()
