import Foundation
import UIKit

struct ExportService {
    static func exportCSV(tasks: [MaintenanceTask], logs: [CompletionLog]) -> URL? {
        var csv = "Task Name,Zone,Completion Date,Notes,Cost\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        for log in logs {
            let taskName = tasks.first(where: { $0.id == log.taskId })?.name ?? "Unknown"
            let zone = tasks.first(where: { $0.id == log.taskId })?.zone ?? ""
            let date = dateFormatter.string(from: log.completionDate ?? Date())
            let notes = (log.notes ?? "").replacingOccurrences(of: ",", with: ";")
            let cost = log.cost?.stringValue ?? "0"
            csv += "\"\(taskName)\",\"\(zone)\",\"\(date)\",\"\(notes)\",\"\(cost)\"\n"
        }

        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("FixMate_Export_\(Date().timeIntervalSince1970).csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    static func exportPDF(tasks: [MaintenanceTask], logs: [CompletionLog]) -> Data? {
        let pdfMetaData = [
            kCGPDFContextTitle: "FixMate Maintenance Report",
            kCGPDFContextCreator: "FixMate App"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let data = renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = 40

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
            ]
            "FixMate Maintenance Report".draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttributes)
            y += 40

            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]

            for log in logs {
                if y > pageHeight - 60 {
                    context.beginPage()
                    y = 40
                }
                let taskName = tasks.first(where: { $0.id == log.taskId })?.name ?? "Unknown"
                let date = dateFormatter.string(from: log.completionDate ?? Date())
                let cost = log.cost != nil ? "$\(log.cost!.stringValue)" : "—"

                "\(taskName)".draw(at: CGPoint(x: 40, y: y), withAttributes: headerAttributes)
                y += 18
                "Date: \(date)  |  Cost: \(cost)".draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttributes)
                y += 16
                if let notes = log.notes, !notes.isEmpty {
                    "Notes: \(notes)".draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttributes)
                    y += 16
                }
                y += 8
            }
        }
        return data
    }
}
