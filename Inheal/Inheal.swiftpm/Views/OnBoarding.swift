
import SwiftUI

enum OnBoardingPage: Int, CaseIterable {
    case pageOne
    case pageTwo
    case pageThree
    
    var text: String {
        switch self {
        case .pageOne:
            return "Anxiety is a natural reaction of the human body to stimuli and situations that cause fear and stress."
        case .pageTwo:
            return "New situations, like starting college, meeting new people can cause more anxiety and make it harder to handle them."
        case .pageThree:
            return "Fourtunately, there are practices that help deal with anxiety and make you feel better. Breathe, meditate, good sleep routine, exercise, eat healthy and talk to someone can all help you feel less anxious."
        }
    }
    var image: String {
        switch self {
        case .pageOne:
            return "Person"
        case .pageTwo:
            return "Hat"
        case .pageThree:
            return "Meditading"
        }
    }
}

struct OnBoarding: View {
    @State var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    var body: some View{
        VStack{
            TabView(selection: $currentPage){
                ForEach(OnBoardingPage.allCases, id: \.rawValue) {  page in
                    getPageView(for: page)
                        .tag(page.rawValue)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.spring(), value: currentPage)
            
            HStack(spacing: 12){
                ForEach(0..<OnBoardingPage.allCases.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                        .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                        .animation(.spring(), value: currentPage)
                }
            }
            .padding()
            
            Button{
                withAnimation(.spring()){
                    if currentPage < OnBoardingPage.allCases.count - 1 {
                        currentPage += 1
                    }
                    else {
                        hasSeenOnboarding = false
                    }
                }
            }label:{
                Text(currentPage < OnBoardingPage.allCases.count - 1 ? "Next" : "Get Starded")
                    .font(.title3)
                    .bold()
                    .frame(width: 300)
                    .padding(.vertical)
                    .foregroundStyle(.white)
                    .background{
                        LinearGradient(gradient: Gradient(colors:[
                            .blue,
                            .blue.opacity(0.8)
                        ]), startPoint: .leading, endPoint: .trailing)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .preferredColorScheme(.light)
        .padding()
    }
    
    @ViewBuilder
    private func getPageView(for page: OnBoardingPage) -> some View{
        VStack(spacing: 30) {
            Text(page.text)
                .font(.title3)
                .multilineTextAlignment(.center)
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(width: 250)
        }
        .preferredColorScheme(.light)
        .padding()
    }
}

