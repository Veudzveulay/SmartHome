#include "Room.h"

Room::Room(int id, const std::string& nom) : id(id), nom(nom) {}

void Room::ajouterCapteur(std::shared_ptr<Capteur> capteur) {
    capteurs.push_back(capteur);
}

std::vector<std::shared_ptr<Capteur>> Room::getCapteurs() const {
    return capteurs;
}

std::string Room::getNom() const {
    return nom;
}

int Room::getId() const {
    return id;
}
