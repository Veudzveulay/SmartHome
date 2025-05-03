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
    bool creerTableHistorique();
    bool creerTableUtilisateurs();
    bool insererValeurCapteur(int id, const std::string& type, float valeur, const std::string& room);
    bool ajouterCapteur(const std::string& type, const std::string& room);
    bool resetCapteurs();
    bool utilisateurExiste(const std::string& username, const std::string& password);
    bool ajouterUtilisateur(const std::string& username, const std::string& password);
    bool tokenValide(const std::string& token);
    bool revoquerToken(const std::string& token);
    bool ajouterActionHistorique(const std::string& action);
    bool supprimerCapteur(int id);  

    std::string genererTokenPourUtilisateur(const std::string& username, const std::string& password);
    std::vector<json> getAnomalies(float seuilTemp = 30.0);
    std::vector<json> getRoomsWithCapteurs();

    sqlite3* getConnection() const { return db; }
};

#endif
