#pragma once
#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "AuthMiddleware.h"

void definirRoutesSeuils(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db);
