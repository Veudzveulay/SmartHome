#include "routes/routes_seuils.h"

using json = nlohmann::json;

void definirRoutesSeuils(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db) {

    CROW_ROUTE(app, "/seuils").methods(crow::HTTPMethod::Post)([&db](const crow::request& req) {
        try {
            auto body = json::parse(req.body);
            std::string type = body["type"];
            float valeur = body["valeur"];
    
            bool ok = db.setSeuil(type, valeur);
            return ok
                ? crow::response(200, "✅ Seuil mis à jour")
                : crow::response(500, "❌ Erreur lors de la mise à jour");
        } catch (const std::exception& e) {
            return crow::response(400, std::string("❌ JSON invalide : ") + e.what());
        }
    });    

    CROW_ROUTE(app, "/seuils").methods(crow::HTTPMethod::Get)([&db]() {
        std::cout << "📥 Route /seuils appelée" << std::endl;
        auto seuils = db.getSeuils();
        return crow::response{seuils.dump(4)};
    });    
    
}
