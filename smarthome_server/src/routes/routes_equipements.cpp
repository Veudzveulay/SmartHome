#include "routes/routes_equipements.h"

using json = nlohmann::json;

void definirRoutesEquipements(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db) {

    CROW_ROUTE(app, "/equipements/<string>").methods(crow::HTTPMethod::Post)([&db](const crow::request& req, const std::string& equipement){
        auto action = req.url_params.get("action");
        if (!action) {
            return crow::response(400, "❌ Action manquante");
        }
    
        std::ostringstream log;
        log << "📦 Commande reçue : " << equipement << " -> " << action;
        std::cout << log.str() << std::endl;

        db.ajouterActionHistorique("Commande sur " + equipement + " -> " + action);
    
        return crow::response(200, "✅ " + equipement + " : action " + action + " exécutée !");
    });
}