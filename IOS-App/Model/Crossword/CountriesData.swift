import Foundation

public struct CountryData {
    let name: String
    let clue: String
}

// Simple, easy, beginner-friendly clues
let allCountries: [CountryData] = [

    // 5-letter
    CountryData(name: "CHINA", clue: "Country with the Great Wall"),
    CountryData(name: "INDIA", clue: "Country with the Taj Mahal"),
    CountryData(name: "JAPAN", clue: "Country with sushi and anime"),
    CountryData(name: "NEPAL", clue: "Country with Mount Everest"),
    CountryData(name: "SPAIN", clue: "Country known for bullfighting"),
    CountryData(name: "ITALY", clue: "Country shaped like a boot"),
    CountryData(name: "EGYPT", clue: "Country with the Pyramids"),
    CountryData(name: "CHILE", clue: "Long thin country in South America"),
    CountryData(name: "KENYA", clue: "Country famous for safaris"),
    CountryData(name: "GHANA", clue: "Country famous for cocoa"),
    CountryData(name: "NIGER", clue: "Country named after a river"),
    CountryData(name: "BENIN", clue: "Small country in West Africa"),
    CountryData(name: "GABON", clue: "Country with many rainforests"),
    CountryData(name: "LIBYA", clue: "Country in North Africa with desert"),
    CountryData(name: "SUDAN", clue: "Country split into North and South"),
    CountryData(name: "YEMEN", clue: "Country near Saudi Arabia"),
    CountryData(name: "SYRIA", clue: "Country with the city Damascus"),
    CountryData(name: "HAITI", clue: "Country sharing island with Dominican Republic"),
    CountryData(name: "MALTA", clue: "Small island country near Italy"),
    CountryData(name: "SAMOA", clue: "Pacific island country"),
    CountryData(name: "TONGA", clue: "Island kingdom in the Pacific"),
    CountryData(name: "PALAU", clue: "Island country famous for clear water"),

    // 4-letter
    CountryData(name: "IRAN", clue: "Country known for Persian culture"),
    CountryData(name: "IRAQ", clue: "Country with Baghdad city"),
    CountryData(name: "LAOS", clue: "Only landlocked country in SE Asia"),
    CountryData(name: "FIJI", clue: "Country famous for blue beaches"),
    CountryData(name: "CUBA", clue: "Country famous for cigars"),
    CountryData(name: "MALI", clue: "Country with Timbuktu"),
    CountryData(name: "CHAD", clue: "Country with Lake Chad"),
    CountryData(name: "TOGO", clue: "Small African country on the coast"),
    CountryData(name: "OMAN", clue: "Country near the Arabian Sea"),
    CountryData(name: "PERU", clue: "Country with Machu Picchu"),

    // 6-letter
    CountryData(name: "FRANCE", clue: "Country with the Eiffel Tower"),
    CountryData(name: "BRAZIL", clue: "Country famous for Carnival"),
    CountryData(name: "MEXICO", clue: "Country famous for tacos"),
    CountryData(name: "RUSSIA", clue: "Largest country in the world"),
    CountryData(name: "CANADA", clue: "Country famous for maple leaves"),
    CountryData(name: "GREECE", clue: "Country with ancient temples"),
    CountryData(name: "TURKEY", clue: "Country in both Europe and Asia"),
    CountryData(name: "POLAND", clue: "Country known for pierogi"),
    CountryData(name: "SWEDEN", clue: "Country famous for IKEA"),
    CountryData(name: "NORWAY", clue: "Country with fjords"),
    CountryData(name: "ISRAEL", clue: "Country with the Dead Sea"),
    CountryData(name: "JORDAN", clue: "Country with Petra"),
    CountryData(name: "KUWAIT", clue: "Small rich Gulf country"),
    CountryData(name: "PANAMA", clue: "Country with the Panama Canal"),
    CountryData(name: "GUYANA", clue: "Only English-speaking country in South America"),
    CountryData(name: "BELIZE", clue: "Country with the Blue Hole"),

    // 7-letter
    CountryData(name: "GERMANY", clue: "Country with Berlin city"),
    CountryData(name: "ENGLAND", clue: "Country with Big Ben"),
    CountryData(name: "BELGIUM", clue: "Country famous for waffles"),
    CountryData(name: "AUSTRIA", clue: "Country famous for classical music"),
    CountryData(name: "HUNGARY", clue: "Country with Budapest"),
    CountryData(name: "DENMARK", clue: "Country famous for LEGO"),
    CountryData(name: "IRELAND", clue: "Country famous for green landscapes"),
    CountryData(name: "ICELAND", clue: "Country with hot springs"),
    CountryData(name: "FINLAND", clue: "Country with many lakes"),
    CountryData(name: "ROMANIA", clue: "Country known for Dracula"),
    CountryData(name: "UKRAINE", clue: "Country known for sunflowers"),
    CountryData(name: "GEORGIA", clue: "Country known for wine"),
    CountryData(name: "ARMENIA", clue: "One of the oldest Christian countries"),
    CountryData(name: "ALBANIA", clue: "Country in the Balkans"),
    CountryData(name: "CROATIA", clue: "Country with beautiful beaches"),
    CountryData(name: "MOROCCO", clue: "Country famous for colorful markets"),
    CountryData(name: "ALGERIA", clue: "Largest country in Africa"),
    CountryData(name: "TUNISIA", clue: "Country near Italy across sea"),
    CountryData(name: "NIGERIA", clue: "Most populated African country"),
    CountryData(name: "SENEGAL", clue: "Country with Dakar city"),
    CountryData(name: "SOMALIA", clue: "Country on the Horn of Africa"),
    CountryData(name: "NAMIBIA", clue: "Country with desert dunes"),
    CountryData(name: "JAMAICA", clue: "Birthplace of reggae"),
    CountryData(name: "URUGUAY", clue: "Small country in South America"),
    CountryData(name: "BOLIVIA", clue: "High-altitude country in South America"),
    CountryData(name: "ECUADOR", clue: "Country on the equator"),
    CountryData(name: "VIETNAM", clue: "Country famous for pho"),
    CountryData(name: "MYANMAR", clue: "Country formerly called Burma"),
    CountryData(name: "BAHRAIN", clue: "Tiny Gulf island nation"),

    // 8-letter
    CountryData(name: "PORTUGAL", clue: "Country with Cristiano Ronaldo"),
    CountryData(name: "THAILAND", clue: "Country known for street food"),
    CountryData(name: "PAKISTAN", clue: "Country famous for biryani"),
    CountryData(name: "MONGOLIA", clue: "Country of Genghis Khan"),
    CountryData(name: "CAMEROON", clue: "Central African country"),
    CountryData(name: "ETHIOPIA", clue: "Origin of coffee"),
    CountryData(name: "ZIMBABWE", clue: "Country near Victoria Falls"),
    CountryData(name: "BOTSWANA", clue: "Country famous for safari parks"),
    CountryData(name: "COLOMBIA", clue: "Country famous for coffee"),
    CountryData(name: "HONDURAS", clue: "Central American country"),
    CountryData(name: "BARBADOS", clue: "Birthplace of Rihanna"),

    // 9-letter
    CountryData(name: "AUSTRALIA", clue: "Country with kangaroos"),
    CountryData(name: "ARGENTINA", clue: "Country famous for tango"),
    CountryData(name: "SINGAPORE", clue: "Very clean city country"),
    CountryData(name: "INDONESIA", clue: "Country with many islands"),
    CountryData(name: "VENEZUELA", clue: "Country rich in oil"),
    CountryData(name: "GUATEMALA", clue: "Country known for volcanoes")
]

// Filter countries by length for better crossword generation
func getCountriesByLength(min: Int, max: Int) -> [CountryData] {
    return allCountries.filter { $0.name.count >= min && $0.name.count <= max }
}

// Get random subset with variety of lengths
func getRandomCountrySet(count: Int) -> [CountryData] {
    let preferred = allCountries.filter { $0.name.count >= 4 && $0.name.count <= 7 }
    return Array(preferred.shuffled().prefix(min(count, preferred.count)))
}
