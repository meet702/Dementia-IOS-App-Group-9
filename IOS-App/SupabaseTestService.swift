//
//  SupabaseTestService.swift
//  IOS-App
//
//  Created by SDC-USER on 05/03/26.
//
import Foundation
internal import PostgREST
import Supabase

class SupabaseTestService {

    static func testConnection() async {

        do {

            let data: [Person] = try await SupabaseManager.shared.client
                .from("Person")
                .select()
                .execute()
                .value

            print("Persons before update:", data)

            if let first = data.first {

                await updatePerson(pid: first.pid, newName: "Updated Name")

                let updated: [Person] = try await SupabaseManager.shared.client
                    .from("Person")
                    .select()
                    .execute()
                    .value

                print("Persons after update:", updated)
            }

        } catch {

            print("Supabase error:", error)
        }
    }
    
    static func insertPerson() async {

        let newPerson = Person(
            pid: UUID(),
            name: "Test Person"
        )

        do {

            try await SupabaseManager.shared.client
                .from("Person")
                .insert(newPerson)
                .execute()

            print("✅ Person inserted")

        } catch {

            print("❌ Insert failed:", error)
        }
    }
    
    static func deletePerson(pid: UUID) async {

        do {

            try await SupabaseManager.shared.client
                .from("Person")
                .delete()
                .eq("pid", value: pid)
                .execute()

            print("✅ Person deleted")

        } catch {

            print("❌ Delete failed:", error)
        }
    }
    
    static func updatePerson(pid: UUID, newName: String) async {

        do {

            try await SupabaseManager.shared.client
                .from("Person")
                .update([
                    "name": newName
                ])
                .eq("pid", value: pid)
                .execute()

            print("✅ Person updated")

        } catch {

            print("❌ Update failed:", error)
        }
    }
}
