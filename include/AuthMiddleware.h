#ifndef AUTH_MIDDLEWARE_H
#define AUTH_MIDDLEWARE_H

#include "crow.h"
#include <unordered_set>

struct AuthMiddleware {
    struct context {};

    void before_handle(crow::request& req, crow::response& res, context&) {
        // Routes publiques
        static const std::unordered_set<std::string> routesPubliques = {
            "/register",
            "/login"
        };

        // Si route publique → ne rien faire
        if (routesPubliques.count(req.url)) return;

        const std::string tokenAttendu = "secret123"; // ou token dynamique plus tard
        auto tokenRecu = req.get_header_value("Authorization");

        if (tokenRecu != "Bearer " + tokenAttendu) {
            res.code = 401;
            res.set_header("Content-Type", "text/plain");
            res.write("❌ Accès refusé : token invalide");
            res.end();
        }
    }

    void after_handle(crow::request&, crow::response& res, context&) {
        // Rien à faire
    }
};

#endif // AUTH_MIDDLEWARE_H
