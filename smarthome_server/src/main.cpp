#include <iostream>
#include <thread>
#include "crow.h"
#include "DatabaseManagerSQLite.h"
#include "Routes.h"
#include "AuthMiddleware.h"

void simulerCapteurs(DatabaseManagerSQLite& db) {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> tempDist(15.0, 35.0);
    std::uniform_int_distribution<> idDist(1, 5);
    std::vector<std::string> rooms = {"salon", "cuisine", "chambre", "sdb"};
    std::uniform_int_distribution<> roomDist(0, rooms.size() - 1);

    while (true) {
        int id = idDist(gen);
        float valeur = tempDist(gen);
        std::string room = rooms[roomDist(gen)];
        db.insererValeurCapteur(id, "température", valeur, room);
        std::this_thread::sleep_for(std::chrono::seconds(500));
    }
}

int main() {
    DatabaseManagerSQLite db("maison.db");

    crow::App<AuthMiddleware> app;
    app.get_middleware<AuthMiddleware>().set_db(db);

    db.creerTableCapteurs();
    db.creerTableUtilisateurs();

    definirRoutes(app, db);

    std::thread simulateur(simulerCapteurs, std::ref(db));
    simulateur.detach();

    app.port(18080).multithreaded().run();
}
