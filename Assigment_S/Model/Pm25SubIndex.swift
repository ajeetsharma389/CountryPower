// File Generated by Codable tool
import Foundation
struct Pm25SubIndex : Codable {
	let west : Int?
	let national : Int?
	let east : Int?
	let central : Int?
	let south : Int?
	let north : Int?

	enum CodingKeys: String, CodingKey {

		case west = "west"
		case national = "national"
		case east = "east"
		case central = "central"
		case south = "south"
		case north = "north"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		west = try values.decodeIfPresent(Int.self, forKey: .west)
		national = try values.decodeIfPresent(Int.self, forKey: .national)
		east = try values.decodeIfPresent(Int.self, forKey: .east)
		central = try values.decodeIfPresent(Int.self, forKey: .central)
		south = try values.decodeIfPresent(Int.self, forKey: .south)
		north = try values.decodeIfPresent(Int.self, forKey: .north)
	}

}