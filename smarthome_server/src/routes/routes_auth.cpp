#include "routes/routes_auth.h"

using json = nlohmann::json;

void definirRoutesAuth(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db) {
    CROW_ROUTE(app, "/login").methods(crow::HTTPMethod::Post)([&db](const crow::request& req) {
        try {
            auto body = json::parse(req.body);
            std::string username = body["username"];
            std::string password = body["password"];
    
            std::string token = db.genererTokenPourUtilisateur(username, password);
            if (token.empty()) {
                return crow::response(403, "❌ Identifiants invalides");
            }

            db.ajouterActionHistorique("Connexion utilisateur : " + username);

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
    
    // 🔐 Route de déconnexion
    CROW_ROUTE(app, "/logout").methods(crow::HTTPMethod::Post)([&db](const crow::request& req) {
        auto token = req.get_header_value("Authorization");

        if (token.rfind("Bearer ", 0) == 0)
            token = token.substr(7);
            
        if (token.empty())
        return crow::response(400, "❌ Aucun token fourni");
    
        bool ok = db.revoquerToken(token);
        if (ok) {
            db.ajouterActionHistorique("Déconnexion d'un utilisateur (token révoqué)");
            return crow::response(200, "✅ Déconnexion réussie, token supprimé.");
        }
        else
            return crow::response(500, "❌ Échec de la déconnexion.");
    });
}
