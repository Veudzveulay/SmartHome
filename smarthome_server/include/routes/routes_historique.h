#pragma once
#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "AuthMiddleware.h"

void definirRoutesHistorique(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db);
