import Foundation

struct ExtraInfoValue: Identifiable, Hashable {
    var id: String
    var value: String
}

struct ExtraInfoKey: Identifiable, Hashable {
    var id: String
    var title: String
    var values: [ExtraInfoValue]
}

// 앱 실행 시 직접 사용할 더미 데이터
let sampleExtraInfo: [ExtraInfoKey] = [
    ExtraInfoKey(
        id: "disease",
        title: "앓고 있는 질환을 모두 선택하세요",
        values: [
            ExtraInfoValue(id: "disease_1", value: "고혈압"),
            ExtraInfoValue(id: "disease_2", value: "당뇨병"),
            ExtraInfoValue(id: "disease_3", value: "심장병")
        ]
    ),
    ExtraInfoKey(
        id: "allergy",
        title: "알레르기가 있으신가요?",
        values: [
            ExtraInfoValue(id: "allergy_1", value: "땅콩"),
            ExtraInfoValue(id: "allergy_2", value: "달걀")
        ]
    )
]
