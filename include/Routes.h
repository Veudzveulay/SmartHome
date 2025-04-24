#ifndef ROUTES_H
#define ROUTES_H

#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "json.hpp"
#include "AuthMiddleware.h"

void definirRoutes(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db);

#endif
