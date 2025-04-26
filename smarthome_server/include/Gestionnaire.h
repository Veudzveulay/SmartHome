#ifndef GESTIONNAIRE_H
#define GESTIONNAIRE_H

#include "Maison.h"
#include <string>

class Gestionnaire {
private:
    Maison maison;

public:
    Gestionnaire();

    void initialiserDonneesDeTest();

    Maison& getMaison();

    std::shared_ptr<Capteur> getCapteurParId(int id);
    std::string getResumeEtat();
};

#endif
