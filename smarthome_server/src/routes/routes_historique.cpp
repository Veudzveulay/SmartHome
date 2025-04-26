#include "routes/routes_historique.h"

using json = nlohmann::json;

void definirRoutesHistorique(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db) {

    // GET /historique
    CROW_ROUTE(app, "/historique").methods(crow::HTTPMethod::Get)([&db]() {
        sqlite3_stmt* stmt;
        const char* sql = "SELECT id, action, horodatage FROM historique ORDER BY horodatage DESC";

        json historique = json::array();

        if (sqlite3_prepare_v2(db.getConnection(), sql, -1, &stmt, nullptr) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                historique.push_back({
                    {"id", sqlite3_column_int(stmt, 0)},
                    {"action", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1))},
                    {"horodatage", reinterpret_cast<const char*>(sqlite3_column_text(stmt, 2))}
                });
            }
        }
        sqlite3_finalize(stmt);

        return crow::response{historique.dump(4)};
    });
}
