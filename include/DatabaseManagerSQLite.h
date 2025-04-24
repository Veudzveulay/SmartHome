#ifndef DATABASEMANAGERSQLITE_H
#define DATABASEMANAGERSQLITE_H

#include <string>
#include <sqlite3.h>
#include "json.hpp"

using json = nlohmann::json;

class DatabaseManagerSQLite {

private:
    sqlite3* db;

public:
    DatabaseManagerSQLite(const std::string& dbPath);
    ~DatabaseManagerSQLite();

    bool creerTableCapteurs();
    bool insererValeurCapteur(int id, const std::string& type, float valeur, const std::string& room);
    bool ajouterCapteur(int id, const std::string& type, const std::string& room);
    bool resetCapteurs();
    bool creerTableUtilisateurs();
    bool utilisateurExiste(const std::string& username, const std::string& password);
    bool ajouterUtilisateur(const std::string& username, const std::string& password);
    bool tokenValide(const std::string& token);

    std::string genererTokenPourUtilisateur(const std::string& username, const std::string& password);
    std::vector<json> getAnomalies(float seuilTemp = 30.0);
    std::vector<json> getRoomsWithCapteurs();

    sqlite3* getConnection() const { return db; }
};

#endif
