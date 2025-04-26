#include "Routes.h"
#include "routes/routes_capteurs.h"
#include "routes/routes_auth.h"
#include "routes/routes_historique.h"
#include "routes/routes_equipements.h"

void definirRoutes(crow::App<AuthMiddleware>& app, DatabaseManagerSQLite& db) {
    definirRoutesCapteurs(app, db);
    definirRoutesAuth(app, db);
    definirRoutesHistorique(app, db);
    definirRoutesEquipements(app, db);

    CROW_ROUTE(app, "/")([](){
        return "✅ Serveur SmartHome actif !";
    });
}
