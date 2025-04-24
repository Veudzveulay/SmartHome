#include "Routes.h"
#include "AuthMiddleware.h"

using json = nlohmann::json;

void definirRoutes(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db) {
    // Accueil
    CROW_ROUTE(app, "/")([](){
        return "✅ Serveur SmartHome actif !";
    });

    // POST /capteurs
    CROW_ROUTE(app, "/capteurs").methods(crow::HTTPMethod::Post)([&db](const crow::request& req){
        try {
            auto body = json::parse(req.body);
            int id = body["id"];
            std::string type = body["type"];
            float valeur = body["valeur"];
            std::string room = body["room"];

            bool ok = db.insererValeurCapteur(id, type, valeur, room);
            if (ok) return crow::response(201, "✅ Capteur inséré");
            else    return crow::response(500, "❌ Erreur insertion");
        } catch (const std::exception& e) {
            return crow::response(400, std::string("❌ JSON invalide : ") + e.what());
        }
    });

    // POST /ajouter_capteur
    CROW_ROUTE(app, "/ajouter_capteur").methods(crow::HTTPMethod::Post)([&db](const crow::request& req){
        try {
            auto body = json::parse(req.body);
            int id = body["id"];
            std::string type = body["type"];
            std::string room = body["room"];
    
            bool ok = db.ajouterCapteur(id, type, room);
            if (ok) {
                return crow::response(201, "✅ Capteur ajouté avec succès");
            } else {
                return crow::response(500, "❌ Erreur lors de l'ajout du capteur");
            }
        } catch (const std::exception& e) {
            return crow::response(400, std::string("❌ JSON invalide : ") + e.what());
        }
    });
    
    // GET /capteurs
    CROW_ROUTE(app, "/capteurs").methods(crow::HTTPMethod::Get)([&db](const crow::request& req){
        json capteurs = json::array();
    
        std::string roomFiltre;
        if (req.url_params.get("room")) {
            roomFiltre = req.url_params.get("room");
        }
    
        sqlite3_stmt* stmt;
        std::string sql = "SELECT id, type, valeur, horodatage, room FROM capteurs";
    
        if (!roomFiltre.empty()) {
            sql += " WHERE room = ?";
        }
    
        if (sqlite3_prepare_v2(db.getConnection(), sql.c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
            if (!roomFiltre.empty()) {
                sqlite3_bind_text(stmt, 1, roomFiltre.c_str(), -1, SQLITE_TRANSIENT);
            }
    
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                json c = {
                    {"id", sqlite3_column_int(stmt, 0)},
                    {"type", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))},
                    {"valeur", sqlite3_column_double(stmt, 2)},
                    {"horodatage", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))},
                    {"room", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))}
                };
                capteurs.push_back(c);
            }
        }
        sqlite3_finalize(stmt);
    
        return crow::response{capteurs.dump(4)};
    });
    

    // GET /alertes
    CROW_ROUTE(app, "/alertes").methods(crow::HTTPMethod::Get)([&db]() {
        auto anomalies = db.getAnomalies();
        return crow::response{json(anomalies).dump(4)};
    });

    // GET /rooms
    CROW_ROUTE(app, "/rooms").methods(crow::HTTPMethod::Get)([&db]() {
        json rooms = json::array();
        sqlite3_stmt* stmt;
        const char* sql = R"(
            SELECT room, COUNT(*) as total, AVG(valeur) as moyenne
            FROM capteurs GROUP BY room;
        )";
    
        if (sqlite3_prepare_v2(db.getConnection(), sql, -1, &stmt, nullptr) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                rooms.push_back({
                    {"room", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 0))},
                    {"nombre", sqlite3_column_int(stmt, 1)},
                    {"moyenne", sqlite3_column_double(stmt, 2)}
                });
            }
        }
        sqlite3_finalize(stmt);
        return crow::response{rooms.dump(4)};
    });    

    // Export /export?format=csv /export?format=json /export?format=csv&room=salon
    CROW_ROUTE(app, "/export").methods(crow::HTTPMethod::Get)([&db](const crow::request& req) {
        std::string format = req.url_params.get("format") ? req.url_params.get("format") : "json";
        std::string roomFilter = req.url_params.get("room") ? req.url_params.get("room") : "";
    
        std::ostringstream sql;
        sql << "SELECT id, type, valeur, horodatage, room FROM capteurs";
        if (!roomFilter.empty()) {
            sql << " WHERE room = '" << roomFilter << "'";
        }
    
        json capteurs = json::array();
        sqlite3_stmt* stmt;
    
        if (sqlite3_prepare_v2(db.getConnection(), sql.str().c_str(), -1, &stmt, nullptr) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                capteurs.push_back({
                    {"id", sqlite3_column_int(stmt, 0)},
                    {"type", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))},
                    {"valeur", sqlite3_column_double(stmt, 2)},
                    {"horodatage", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 3))},
                    {"room", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 4))}
                });
            }
        }
        sqlite3_finalize(stmt);
    
        if (format == "csv") {
            std::ostringstream csv;
            csv << "id,type,valeur,horodatage,room\n";
            for (auto& c : capteurs) {
                csv << c["id"] << "," << c["type"] << "," << c["valeur"] << ","
                    << c["horodatage"] << "," << c["room"] << "\n";
            }
            return crow::response(200, csv.str());
        } else {
            return crow::response(200, capteurs.dump(4));
        }
    });

    CROW_ROUTE(app, "/capteurs").methods(crow::HTTPMethod::Delete)([&db](){
        bool ok = db.resetCapteurs();
        return ok ? crow::response("🗑 Tous les capteurs ont été supprimés.") :
                    crow::response(500, "❌ Erreur de suppression");
    });

    // Route protégée par AuthMiddleware
    CROW_ROUTE(app, "/admin")
    .name("admin-secured")
    ([](const crow::request& req){
        return crow::response(200, "🔐 Accès autorisé à l'admin sécurisé !");
    });

    CROW_ROUTE(app, "/login").methods(crow::HTTPMethod::Post)([&db](const crow::request& req) {
        try {
            auto body = json::parse(req.body);
            std::string username = body["username"];
            std::string password = body["password"];
    
            std::string token = db.genererTokenPourUtilisateur(username, password);
            if (token.empty()) {
                return crow::response(403, "❌ Identifiants invalides");
            }
    
            return crow::response(200, json{{"token", token}}.dump());
        } catch (...) {
            return crow::response(400, "❌ JSON invalide");
        }
    });

    CROW_ROUTE(app, "/register").methods(crow::HTTPMethod::Post)([&db](const crow::request& req){
        try {
            auto body = json::parse(req.body);
            std::string username = body["username"];
            std::string password = body["password"];
    
            std::ostringstream sql;
            sql << "INSERT INTO utilisateurs (username, password, token) VALUES ('"
                << username << "', '" << password << "', '')";
    
            char* errMsg = nullptr;
            int rc = sqlite3_exec(db.getConnection(), sql.str().c_str(), nullptr, nullptr, &errMsg);
            if (rc != SQLITE_OK) {
                std::cerr << "❌ Erreur insertion utilisateur : " << errMsg << std::endl;
                sqlite3_free(errMsg);
                return crow::response(500, "❌ Erreur insertion utilisateur");
            }
    
            return crow::response(201, "✅ Utilisateur enregistré");
        } catch (const std::exception& e) {
            return crow::response(400, std::string("❌ JSON invalide : ") + e.what());
        }
    });
    
    
    
}


