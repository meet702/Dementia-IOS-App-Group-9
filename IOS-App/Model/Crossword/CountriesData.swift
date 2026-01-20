import Foundation

public struct CrosswordData {
    let name: String
    let clue: String
}

// Simple, easy, beginner-friendly clues
let allCountries: [CrosswordData] = [

    // 5-letter
    CrosswordData(name: "CHINA", clue: "Country with the Great Wall"),
    CrosswordData(name: "INDIA", clue: "Country with the Taj Mahal"),
    CrosswordData(name: "JAPAN", clue: "Country with sushi and anime"),
    CrosswordData(name: "NEPAL", clue: "Country with Mount Everest"),
    CrosswordData(name: "SPAIN", clue: "Country known for bullfighting"),
    CrosswordData(name: "ITALY", clue: "Country shaped like a boot"),
    CrosswordData(name: "EGYPT", clue: "Country with the Pyramids"),
    CrosswordData(name: "CHILE", clue: "Long thin country in South America"),
    CrosswordData(name: "KENYA", clue: "Country famous for safaris"),
    CrosswordData(name: "GHANA", clue: "Country famous for cocoa"),
    CrosswordData(name: "NIGER", clue: "Country named after a river"),
    CrosswordData(name: "BENIN", clue: "Small country in West Africa"),
    CrosswordData(name: "GABON", clue: "Country with many rainforests"),
    CrosswordData(name: "LIBYA", clue: "Country in North Africa with desert"),
    CrosswordData(name: "SUDAN", clue: "Country split into North and South"),
    CrosswordData(name: "YEMEN", clue: "Country near Saudi Arabia"),
    CrosswordData(name: "SYRIA", clue: "Country with the city Damascus"),
    CrosswordData(name: "HAITI", clue: "Country sharing island with Dominican Republic"),
    CrosswordData(name: "MALTA", clue: "Small island country near Italy"),
    CrosswordData(name: "SAMOA", clue: "Pacific island country"),
    CrosswordData(name: "TONGA", clue: "Island kingdom in the Pacific"),
    CrosswordData(name: "PALAU", clue: "Island country famous for clear water"),

    // 4-letter
    CrosswordData(name: "IRAN", clue: "Country known for Persian culture"),
    CrosswordData(name: "IRAQ", clue: "Country with Baghdad city"),
    CrosswordData(name: "LAOS", clue: "Only landlocked country in SE Asia"),
    CrosswordData(name: "FIJI", clue: "Country famous for blue beaches"),
    CrosswordData(name: "CUBA", clue: "Country famous for cigars"),
    CrosswordData(name: "MALI", clue: "Country with Timbuktu"),
    CrosswordData(name: "CHAD", clue: "Country with Lake Chad"),
    CrosswordData(name: "TOGO", clue: "Small African country on the coast"),
    CrosswordData(name: "OMAN", clue: "Country near the Arabian Sea"),
    CrosswordData(name: "PERU", clue: "Country with Machu Picchu"),

    // 6-letter
    CrosswordData(name: "FRANCE", clue: "Country with the Eiffel Tower"),
    CrosswordData(name: "BRAZIL", clue: "Country famous for Carnival"),
    CrosswordData(name: "MEXICO", clue: "Country famous for tacos"),
    CrosswordData(name: "RUSSIA", clue: "Largest country in the world"),
    CrosswordData(name: "CANADA", clue: "Country famous for maple leaves"),
    CrosswordData(name: "GREECE", clue: "Country with ancient temples"),
    CrosswordData(name: "TURKEY", clue: "Country in both Europe and Asia"),
    CrosswordData(name: "POLAND", clue: "Country known for pierogi"),
    CrosswordData(name: "SWEDEN", clue: "Country famous for IKEA"),
    CrosswordData(name: "NORWAY", clue: "Country with fjords"),
    CrosswordData(name: "ISRAEL", clue: "Country with the Dead Sea"),
    CrosswordData(name: "JORDAN", clue: "Country with Petra"),
    CrosswordData(name: "KUWAIT", clue: "Small rich Gulf country"),
    CrosswordData(name: "PANAMA", clue: "Country with the Panama Canal"),
    CrosswordData(name: "GUYANA", clue: "Only English-speaking country in South America"),
    CrosswordData(name: "BELIZE", clue: "Country with the Blue Hole"),

    // 7-letter
    CrosswordData(name: "GERMANY", clue: "Country with Berlin city"),
    CrosswordData(name: "ENGLAND", clue: "Country with Big Ben"),
    CrosswordData(name: "BELGIUM", clue: "Country famous for waffles"),
    CrosswordData(name: "AUSTRIA", clue: "Country famous for classical music"),
    CrosswordData(name: "HUNGARY", clue: "Country with Budapest"),
    CrosswordData(name: "DENMARK", clue: "Country famous for LEGO"),
    CrosswordData(name: "IRELAND", clue: "Country famous for green landscapes"),
    CrosswordData(name: "ICELAND", clue: "Country with hot springs"),
    CrosswordData(name: "FINLAND", clue: "Country with many lakes"),
    CrosswordData(name: "ROMANIA", clue: "Country known for Dracula"),
    CrosswordData(name: "UKRAINE", clue: "Country known for sunflowers"),
    CrosswordData(name: "GEORGIA", clue: "Country known for wine"),
    CrosswordData(name: "ARMENIA", clue: "One of the oldest Christian countries"),
    CrosswordData(name: "ALBANIA", clue: "Country in the Balkans"),
    CrosswordData(name: "CROATIA", clue: "Country with beautiful beaches"),
    CrosswordData(name: "MOROCCO", clue: "Country famous for colorful markets"),
    CrosswordData(name: "ALGERIA", clue: "Largest country in Africa"),
    CrosswordData(name: "TUNISIA", clue: "Country near Italy across sea"),
    CrosswordData(name: "NIGERIA", clue: "Most populated African country"),
    CrosswordData(name: "SENEGAL", clue: "Country with Dakar city"),
    CrosswordData(name: "SOMALIA", clue: "Country on the Horn of Africa"),
    CrosswordData(name: "NAMIBIA", clue: "Country with desert dunes"),
    CrosswordData(name: "JAMAICA", clue: "Birthplace of reggae"),
    CrosswordData(name: "URUGUAY", clue: "Small country in South America"),
    CrosswordData(name: "BOLIVIA", clue: "High-altitude country in South America"),
    CrosswordData(name: "ECUADOR", clue: "Country on the equator"),
    CrosswordData(name: "VIETNAM", clue: "Country famous for pho"),
    CrosswordData(name: "MYANMAR", clue: "Country formerly called Burma"),
    CrosswordData(name: "BAHRAIN", clue: "Tiny Gulf island nation"),

    // 8-letter
    CrosswordData(name: "PORTUGAL", clue: "Country with Cristiano Ronaldo"),
    CrosswordData(name: "THAILAND", clue: "Country known for street food"),
    CrosswordData(name: "PAKISTAN", clue: "Country famous for biryani"),
    CrosswordData(name: "MONGOLIA", clue: "Country of Genghis Khan"),
    CrosswordData(name: "CAMEROON", clue: "Central African country"),
    CrosswordData(name: "ETHIOPIA", clue: "Origin of coffee"),
    CrosswordData(name: "ZIMBABWE", clue: "Country near Victoria Falls"),
    CrosswordData(name: "BOTSWANA", clue: "Country famous for safari parks"),
    CrosswordData(name: "COLOMBIA", clue: "Country famous for coffee"),
    CrosswordData(name: "HONDURAS", clue: "Central American country"),
    CrosswordData(name: "BARBADOS", clue: "Birthplace of Rihanna"),

    // 9-letter
    CrosswordData(name: "AUSTRALIA", clue: "Country with kangaroos"),
    CrosswordData(name: "ARGENTINA", clue: "Country famous for tango"),
    CrosswordData(name: "SINGAPORE", clue: "Very clean city country"),
    CrosswordData(name: "INDONESIA", clue: "Country with many islands"),
    CrosswordData(name: "VENEZUELA", clue: "Country rich in oil"),
    CrosswordData(name: "GUATEMALA", clue: "Country known for volcanoes")
]

// Filter countries by length for better crossword generation
func getCountriesByLength(min: Int, max: Int) -> [CrosswordData] {
    return allCountries.filter { $0.name.count >= min && $0.name.count <= max }
}

// Get random subset with variety of lengths
func getRandomCountrySet(count: Int) -> [CrosswordData] {
    let preferred = allCountries.filter { $0.name.count >= 4 && $0.name.count <= 7 }
    return Array(preferred.shuffled().prefix(min(count, preferred.count)))
}
