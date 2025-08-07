struct IntakeItem: Identifiable {
  let id: UUID
  let name: String
  let time: Date
  var isCompleted: Bool
  var routine: Routine
}
