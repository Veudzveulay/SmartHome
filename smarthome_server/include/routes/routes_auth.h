#pragma once
#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "AuthMiddleware.h"

void definirRoutesAuth(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db);
