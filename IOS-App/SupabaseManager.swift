import Supabase
import Foundation

final class SupabaseManager {

    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://hhjuickcalqqloocvmbi.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhoanVpY2tjYWxxcWxvb2N2bWJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2OTYzNDksImV4cCI6MjA4ODI3MjM0OX0.Qppc0JVEgdNexBAY1AG9Ecppuv63TET5o0x45apdvkw"
        )
    }
}
