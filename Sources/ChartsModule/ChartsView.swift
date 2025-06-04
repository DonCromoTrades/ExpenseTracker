#if canImport(SwiftUI) && canImport(Charts)
import SwiftUI
import Charts

@available(iOS 16.0, *)
public struct MonthlySummaryChart: View {
    public var data: [Double]

    public init(data: [Double]) {
        self.data = data
    }

    public var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { i in
                BarMark(x: .value("Month", i), y: .value("Amount", data[i]))
            }
        }
    }
}
#else
public struct MonthlySummaryChart {
    public var data: [Double]
    public init(data: [Double]) {
        self.data = data
    }
}
#endif
