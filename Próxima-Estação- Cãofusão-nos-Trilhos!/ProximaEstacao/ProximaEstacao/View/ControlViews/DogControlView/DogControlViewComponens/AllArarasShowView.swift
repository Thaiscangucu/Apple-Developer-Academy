//
//  AllArarasShow.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 04/03/26.
//

import SwiftUI
internal import Combine

struct AllArarasShowView: View {
    
    @Binding var playersRange: [Player]
    @State var playersRangeLocal: Range<Int>? = nil
    @State var playersRangeLocalAfterExec: Range<Int>? = nil
    let assetList: [String] = [" " , "AraraAzul" , "AraraVermelha", "AraraVerde"]
    let assetListAfterExec: [String] = ["", "AraraAzulPresa", "AraraVermelhaPresa", "AraraVerdePresa"]
    
    
    var body: some View {
        GeometryReader{ geometry in
            RoundedRectangle(cornerRadius: 21)
                .frame(width: geometry.size.width / 2 , height: geometry.size.height / 4.5)
                .position(CGPoint(x: geometry.size.width / 1.6  , y: geometry.size.height / 3.2))
                .foregroundStyle(Color("NSInsideComponents"))
            HStack(spacing: 32){
                if let playersRangeLocal = playersRangeLocal {
                    ForEach(playersRangeLocal , id: \.self){ i in
                        if i == 1 {
                            NSDefalutImageView(imageName: playersRangeLocalAfterExec!.count < playersRangeLocal.count ? assetListAfterExec[i] : assetList[i], frameWidth: 110, frameHeight: 110)
                        }
                        if i == 2 {
                            NSDefalutImageView(imageName: playersRangeLocalAfterExec!.count < playersRangeLocal.count - 1 ? assetListAfterExec[i] : assetList[i], frameWidth: 110, frameHeight: 110)
                        }
                        if i == 3 {
                            NSDefalutImageView(imageName: playersRangeLocalAfterExec!.count < playersRangeLocal.count - 2 ? assetListAfterExec[i] : assetList[i], frameWidth: 110, frameHeight: 110)
                        }
                    }
                }
            }
            .position(CGPoint(x: geometry.size.width / 1.58 , y: geometry.size.height / 3.2))
        }
        .onChange(of: playersRange.count, initial: true) {
            if playersRangeLocal == nil{
                playersRangeLocal = Range(0...playersRange.count)
            }
            playersRangeLocalAfterExec = Range(0...playersRange.count)
        }
    }
}
