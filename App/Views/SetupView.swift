import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Rotation") {
                    Picker("Change quotes and words", selection: $model.rotationInterval) {
                        ForEach(RotationInterval.allCases) { Text($0.label).tag($0) }
                    }
                    Toggle("Only use favorites", isOn: $model.favoritesOnly)
                }

                Section {
                    Step(1, "Lock your phone, then touch and hold the lock screen and tap Customize.")
                    Step(2, "Choose Lock Screen, then tap the area under the clock.")
                    Step(3, "Add the FA Quote or FA Word widget. The wide size fits the most text.")
                } header: {
                    Text("Add lock screen widgets")
                } footer: {
                    Text("Widgets update on their own at the interval above.")
                }

                Section {
                    Step(1, "Open Shortcuts, go to Automation, and tap + then Create Personal Automation.")
                    Step(2, "Pick a trigger such as Time of Day (e.g. 7:00 AM, daily). Set it to Run Immediately.")
                    Step(3, "Add the action Get Next Wallpaper from FA. Turn on Add Current Quote if you want the quote on the wallpaper.")
                    Step(4, "Add the action Set Wallpaper, choose Lock Screen, and turn off Show Preview.")
                } header: {
                    Text("Cycle wallpapers automatically")
                } footer: {
                    Text("iOS doesn't let apps change your wallpaper directly, so a Shortcuts automation does it. You only need to set this up once.")
                }

                Section {
                    Link("Open Shortcuts", destination: URL(string: "shortcuts://")!)
                }
            }
            .navigationTitle("Setup")
        }
    }
}

private struct Step: View {
    let number: Int
    let text: String

    init(_ number: Int, _ text: String) {
        self.number = number
        self.text = text
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number)")
                .font(.footnote.weight(.bold))
                .frame(width: 22, height: 22)
                .background(Color.accentColor.opacity(0.2), in: Circle())
            Text(text)
        }
    }
}
