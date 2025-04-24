#include "Gestionnaire.h"
#include <sstream>

Gestionnaire::Gestionnaire() {}

Maison& Gestionnaire::getMaison() {
    return maison;
}

void Gestionnaire::initialiserDonneesDeTest() {
    auto salon = std::make_shared<Room>(1, "Salon");
    auto chambre = std::make_shared<Room>(2, "Chambre");

    auto c1 = std::make_shared<Capteur>(1, "température");
    auto c2 = std::make_shared<Capteur>(2, "fumée");
    auto c3 = std::make_shared<Capteur>(3, "lumière");

    c1->mettreAJourValeur(21.5);
    c2->mettreAJourValeur(0);
    c3->setStatut("OFF");

    salon->ajouterCapteur(c1);
    salon->ajouterCapteur(c2);
    chambre->ajouterCapteur(c3);

    maison.ajouterPiece(salon);
    maison.ajouterPiece(chambre);
}

std::shared_ptr<Capteur> Gestionnaire::getCapteurParId(int id) {
    for (const auto& piece : maison.getPieces()) {
        for (const auto& capteur : piece->getCapteurs()) {
            if (capteur->getType() == "lumière" || capteur->getValeur() == id) {
                return capteur;
            }
        }
    }
    return nullptr;
}

std::string Gestionnaire::getResumeEtat() {
    std::ostringstream oss;
    for (const auto& piece : maison.getPieces()) {
        oss << ">> " << piece->getNom() << ":\n";
        for (const auto& capteur : piece->getCapteurs()) {
            oss << "   - " << capteur->getType() << " = " << capteur->getValeur()
                << " (" << capteur->getStatut() << ")\n";
        }
    }
    return oss.str();
}