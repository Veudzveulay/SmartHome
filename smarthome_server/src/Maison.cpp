#include "Maison.h"

Maison::Maison() {}

void Maison::ajouterPiece(std::shared_ptr<Room> piece) {
    pieces.push_back(piece);
}

std::vector<std::shared_ptr<Room>> Maison::getPieces() const {
    return pieces;
}

std::shared_ptr<Room> Maison::getPieceParNom(const std::string& nom) const {
    for (const auto& piece : pieces) {
        if (piece->getNom() == nom)
            return piece;
    }
    return nullptr;
}
