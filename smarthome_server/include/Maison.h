#ifndef MAISON_H
#define MAISON_H

#include <vector>
#include <memory>
#include "Room.h"

class Maison {
private:
    std::vector<std::shared_ptr<Room>> pieces;

public:
    Maison();

    void ajouterPiece(std::shared_ptr<Room> piece);
    std::vector<std::shared_ptr<Room>> getPieces() const;
    std::shared_ptr<Room> getPieceParNom(const std::string& nom) const;
};

#endif
