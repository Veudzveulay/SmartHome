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
    bool creerTableSeuils();
    bool insererValeurCapteur(int id, const std::string& type, float valeur, const std::string& room);
    bool ajouterCapteur(const std::string& type, const std::string& room);
    bool resetCapteurs();
    bool utilisateurExiste(const std::string& username, const std::string& password);
    bool ajouterUtilisateur(const std::string& username, const std::string& password);
    bool tokenValide(const std::string& token);
    bool revoquerToken(const std::string& token);
    bool ajouterActionHistorique(const std::string& action);
    bool supprimerCapteur(int id);  
    bool setSeuil(const std::string& type, float valeur);

    std::string genererTokenPourUtilisateur(const std::string& username, const std::string& password);
    std::vector<json> getAnomalies();
    std::vector<json> getRoomsWithCapteurs();
    nlohmann::json getSeuils();

    sqlite3* getConnection() const { return db; }
};

#endif
