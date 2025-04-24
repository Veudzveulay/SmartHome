#include "DatabaseManagerSQLite.h"
#include <iostream>
#include <sstream>
#include "json.hpp"
#include <random>

using json = nlohmann::json;

std::string generateRandomToken() {
    std::ostringstream oss;
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, 15);
    for (int i = 0; i < 32; ++i) {
        oss << std::hex << dis(gen);
    }
    return oss.str();
}

DatabaseManagerSQLite::DatabaseManagerSQLite(const std::string& dbPath) {
    if (sqlite3_open(dbPath.c_str(), &db)) {
        std::cerr << "❌ Erreur ouverture SQLite : " << sqlite3_errmsg(db) << std::endl;
        db = nullptr;
    } else {
        std::cout << "✅ Connexion SQLite réussie (" << dbPath << ")" << std::endl;
    }
}

DatabaseManagerSQLite::~DatabaseManagerSQLite() {
    if (db) sqlite3_close(db);
}

bool DatabaseManagerSQLite::creerTableCapteurs() {
    const char* sql = R"(
        CREATE TABLE IF NOT EXISTS capteurs (
            id INTEGER,
            type TEXT,
            valeur REAL,
            horodatage TEXT,
            room TEXT
        );
    )";
    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);
    if (rc != SQLITE_OK) {
        std::cerr << "❌ Erreur création table : " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

bool DatabaseManagerSQLite::insererValeurCapteur(int id, const std::string& type, float valeur, const std::string& room) {
    std::ostringstream sql;
    sql << "INSERT INTO capteurs (id, type, valeur, horodatage, room) VALUES ("
        << id << ", '" << type << "', " << valeur << ", datetime('now'), '" << room << "');";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.str().c_str(), nullptr, nullptr, &errMsg);
    if (rc != SQLITE_OK) {
        std::cerr << "❌ Erreur insertion : " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cout << "📥 Donnée insérée : " << type << " = " << valeur << " (" << room << ")" << std::endl;
    return true;
}

std::vector<json> DatabaseManagerSQLite::getAnomalies(float seuilTemp) {
    std::vector<json> anomalies;

    sqlite3_stmt* stmt;
    const char* sql = "SELECT id, type, valeur, horodatage, room FROM capteurs WHERE type = 'température' AND valeur > ?";

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        sqlite3_bind_double(stmt, 1, seuilTemp);

        while (sqlite3_step(stmt) == SQLITE_ROW) {
            json capteur = {
                {"id", sqlite3_column_int(stmt, 0)},
                {"type", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))},
                {"valeur", sqlite3_column_double(stmt, 2)},
                {"horodatage", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))},
                {"room", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))}
            };
            anomalies.push_back(capteur);
        }
    }

    sqlite3_finalize(stmt);
    return anomalies;
}

std::vector<json> DatabaseManagerSQLite::getRoomsWithCapteurs() {
    std::map<std::string, std::vector<json>> mapping;
    std::vector<json> resultat;

    const char* sql = "SELECT id, type, valeur, horodatage, room FROM capteurs";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            std::string room = reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4));
            json capteur = {
                {"id", sqlite3_column_int(stmt, 0)},
                {"type", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))},
                {"valeur", sqlite3_column_double(stmt, 2)},
                {"horodatage", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))}
            };
            mapping[room].push_back(capteur);
        }
        sqlite3_finalize(stmt);
    }

    for (const auto& pair : mapping) {
        resultat.push_back({
            {"room", pair.first},
            {"capteurs", pair.second}
        });
    }

    return resultat;
}

bool DatabaseManagerSQLite::ajouterCapteur(int id, const std::string& type, const std::string& room) {
    std::ostringstream sql;
    sql << "INSERT INTO capteurs (id, type, valeur, horodatage, room) VALUES ("
        << id << ", '" << type << "', NULL, NULL, '" << room << "');";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.str().c_str(), nullptr, nullptr, &errMsg);
    if (rc != SQLITE_OK) {
        std::cerr << "❌ Erreur ajout capteur : " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    std::cout << "🆕 Capteur ajouté : ID " << id << " (" << type << ") dans " << room << std::endl;
    return true;
}

bool DatabaseManagerSQLite::resetCapteurs() {
    const char* sql = "DELETE FROM capteurs;";
    return sqlite3_exec(db, sql, nullptr, nullptr, nullptr) == SQLITE_OK;
}

bool DatabaseManagerSQLite::creerTableUtilisateurs() {
    const char* sql = R"(
        CREATE TABLE IF NOT EXISTS utilisateurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            token TEXT
        );
    )";
    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);
    if (rc != SQLITE_OK) {
        std::cerr << "❌ Erreur création table utilisateurs : " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

bool DatabaseManagerSQLite::ajouterUtilisateur(const std::string& username, const std::string& password) {
    std::ostringstream sql;
    sql << "INSERT INTO utilisateurs (username, password) VALUES ('"
        << username << "', '" << password << "');";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.str().c_str(), nullptr, nullptr, &errMsg);
    if (rc != SQLITE_OK) {
        std::cerr << "❌ Erreur insertion utilisateur : " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    return true;
}


bool DatabaseManagerSQLite::utilisateurExiste(const std::string& username, const std::string& password) {
    const char* sql = "SELECT COUNT(*) FROM users WHERE username = ? AND password = ?";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, username.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, password.c_str(), -1, SQLITE_TRANSIENT);

        if (sqlite3_step(stmt) == SQLITE_ROW) {
            int count = sqlite3_column_int(stmt, 0);
            sqlite3_finalize(stmt);
            return count > 0;
        }
    }
    sqlite3_finalize(stmt);
    return false;
}

std::string DatabaseManagerSQLite::genererTokenPourUtilisateur(const std::string& username, const std::string& password) {
    std::string token = generateRandomToken();
    const char* sql = "INSERT INTO tokens (token, username) VALUES (?, ?)";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, token.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, username.c_str(), -1, SQLITE_TRANSIENT);
        sqlite3_step(stmt);
    }
    sqlite3_finalize(stmt);
    return token;
}

bool DatabaseManagerSQLite::tokenValide(const std::string& token) {
    const char* sql = "SELECT COUNT(*) FROM tokens WHERE token = ?";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, token.c_str(), -1, SQLITE_TRANSIENT);
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            int count = sqlite3_column_int(stmt, 0);
            sqlite3_finalize(stmt);
            return count > 0;
        }
    }
    sqlite3_finalize(stmt);
    return false;
}
