#include "Capteur.h"
#include <ctime>
#include <iomanip>
#include <sstream>

Capteur::Capteur(int id, std::string type)
    : id(id), type(type), valeur(0.0), statut("OFF") {
    horodatage = "Jamais";
}

void Capteur::mettreAJourValeur(float val) {
    valeur = val;
    auto now = std::time(nullptr);
    std::stringstream ss;
    ss << std::put_time(std::localtime(&now), "%Y-%m-%d %H:%M:%S");
    horodatage = ss.str();
}

float Capteur::getValeur() const { return valeur; }

std::string Capteur::getType() const { return type; }

std::string Capteur::getStatut() const { return statut; }

void Capteur::setStatut(const std::string& s) { statut = s; }

std::string Capteur::getHorodatage() const { return horodatage; }
