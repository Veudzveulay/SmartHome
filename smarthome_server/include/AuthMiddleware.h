#ifndef AUTH_MIDDLEWARE_H
#define AUTH_MIDDLEWARE_H

#include "crow.h"
#include <unordered_set>
#include "DatabaseManagerSQLite.h"

class AuthMiddleware {
public:
    struct context {};

    AuthMiddleware() = default;
    AuthMiddleware(DatabaseManagerSQLite& db) : db_(&db) {}

    void before_handle(crow::request& req, crow::response& res, context&) {
        static const std::unordered_set<std::string> routesPubliques = {
            "/register", "/login"
        };

        if (routesPubliques.count(req.url)) return;

        auto tokenRecu = req.get_header_value("Authorization");
        if (tokenRecu.rfind("Bearer ", 0) == 0)
            tokenRecu = tokenRecu.substr(7);

        if (!db_ || !db_->tokenValide(tokenRecu)) {
            res.code = 401;
            res.write("❌ Accès refusé : token invalide");
            res.end();
        }
        std::cout << "🔐 Token reçu : " << tokenRecu << std::endl;
    }

    void after_handle(crow::request&, crow::response& res, context&) {}
    void set_db(DatabaseManagerSQLite& db) {
        db_ = &db;
    }

private:
    DatabaseManagerSQLite* db_ = nullptr; 
};

#endif
