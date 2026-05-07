import Foundation

struct Occupation: Identifiable, Hashable {
    let id: Int
    let name: String
}

extension Occupation {
    static let all: [Occupation] = [
        .init(id: 1,  name: "Software Engineer"),
        .init(id: 2,  name: "Product Manager"),
        .init(id: 3,  name: "Designer"),
        .init(id: 4,  name: "Data Analyst"),
        .init(id: 5,  name: "Consultant"),
        .init(id: 6,  name: "Marketing Professional"),
        .init(id: 7,  name: "Sales Professional"),
        .init(id: 8,  name: "HR Professional"),
        .init(id: 9,  name: "Finance Professional"),
        .init(id: 10, name: "Entrepreneur"),
        .init(id: 11, name: "Freelancer"),
        .init(id: 12, name: "Content Creator"),
        .init(id: 13, name: "Photographer"),
        .init(id: 14, name: "Video Editor"),
        .init(id: 15, name: "Writer"),
        .init(id: 16, name: "Doctor"),
        .init(id: 17, name: "Lawyer"),
        .init(id: 18, name: "Chartered Accountant"),
        .init(id: 19, name: "Teacher"),
        .init(id: 20, name: "Student"),
        .init(id: 21, name: "Research Scholar"),
        .init(id: 22, name: "Architect"),
        .init(id: 23, name: "Interior Designer"),
        .init(id: 24, name: "Chef"),
        .init(id: 25, name: "Fitness Trainer"),
        .init(id: 26, name: "Event Manager"),
        .init(id: 27, name: "Government Employee"),
        .init(id: 28, name: "Startup Founder"),
        .init(id: 29, name: "Business Owner"),
        .init(id: 30, name: "Remote Worker"),
        .init(id: 31, name: "Intern"),
        .init(id: 32, name: "Self-employed"),
        .init(id: 33, name: "Other")
    ]

    static func find(by id: Int) -> Occupation? {
        all.first { $0.id == id }
    }
}
