#pragma once
#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "AuthMiddleware.h"

void definirRoutesCapteurs(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db);
