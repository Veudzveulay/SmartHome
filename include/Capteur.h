#ifndef CAPTEUR_H
#define CAPTEUR_H

#include <string>
#include <chrono>

class Capteur {
private:
    int id;
    std::string type; // ex : "température", "fumée"
    std::string statut; // ON/OFF, OUVERT/FERMÉ
    float valeur;
    std::string horodatage;

public:
    Capteur(int id, std::string type);

    void mettreAJourValeur(float val);
    float getValeur() const;
    std::string getType() const;
    std::string getStatut() const;
    std::string getHorodatage() const;

    void setStatut(const std::string& statut);
};

#endif
