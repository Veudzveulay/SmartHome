#pragma once
#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "AuthMiddleware.h"

void definirRoutesEquipements(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db);
