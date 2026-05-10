import SwiftUI
import Charts

struct BarChart: View {
    var borderWidth: CGFloat
    let data = [
       Data(
           x: 0.0,
           height: 0.5
       ),
       Data(
           x:0.5,
           height: 1.0
       ),
       Data(
           x: 1,
           height: 2.0
       ),
       Data(
           x: 1.5,
           height: 1.0
       ),
       Data(
           x: 2,
           height: 3.0
       ),
       Data(
           x: 2.5,
           height: 4.0
       ),
       Data(
           x: 3,
           height: 3.0
       ),
       Data(
           x: 3.5,
           height: 3.5
       ),
       Data(
           x: 4,
           height: 2.0
       ),
       Data(
           x: 4.5,
           height: 1.0
       )
       
   ]
    var body: some View {
         
        Chart{
            ForEach(data) { d in
                BarMark(x: .value("", d.x), y: .value("",d.height), width: .fixed(borderWidth))
                    .cornerRadius(0.0)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .foregroundStyle(.otherGray)
    }
}

