#ifndef ROOM_H
#define ROOM_H

#include <string>
#include <vector>
#include <memory>
#include "Capteur.h"

class Room {
private:
    int id;
    std::string nom;
    std::vector<std::shared_ptr<Capteur>> capteurs;

public:
    Room(int id, const std::string& nom);

    void ajouterCapteur(std::shared_ptr<Capteur> capteur);
    std::vector<std::shared_ptr<Capteur>> getCapteurs() const;
    std::string getNom() const;
    int getId() const;
};

#endif
