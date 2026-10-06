-- Natural Coach : script de création de la base (MySQL / MariaDB)

DROP DATABASE IF EXISTS natural_coach;
CREATE DATABASE natural_coach CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE natural_coach;

CREATE TABLE region (
    idRegion  INT AUTO_INCREMENT PRIMARY KEY,
    nomRegion VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE lieu (
    idLieu   INT AUTO_INCREMENT PRIMARY KEY,
    nomLieu  VARCHAR(100) NOT NULL,
    idRegion INT NOT NULL,
    FOREIGN KEY (idRegion) REFERENCES region(idRegion)
);

CREATE TABLE excursion (
    idExcursion       INT AUTO_INCREMENT PRIMARY KEY,
    nom               VARCHAR(100) NOT NULL,
    planCircuit       VARCHAR(255),
    tarif             DECIMAL(8,2) NOT NULL CHECK (tarif >= 0),
    nbMaxParticipants INT NOT NULL CHECK (nbMaxParticipants > 0),
    idLieuDepart      INT NOT NULL,
    idLieuArrivee     INT NOT NULL,
    FOREIGN KEY (idLieuDepart)  REFERENCES lieu(idLieu),
    FOREIGN KEY (idLieuArrivee) REFERENCES lieu(idLieu)
);

CREATE TABLE photo (
    idPhoto     INT AUTO_INCREMENT PRIMARY KEY,
    fichier     VARCHAR(255) NOT NULL,
    legende     VARCHAR(255),
    idExcursion INT NOT NULL,
    FOREIGN KEY (idExcursion) REFERENCES excursion(idExcursion) ON DELETE CASCADE
);

CREATE TABLE point_passage (
    idPoint     INT AUTO_INCREMENT PRIMARY KEY,
    nom         VARCHAR(100) NOT NULL,
    description TEXT,
    ordre       INT NOT NULL,
    idExcursion INT NOT NULL,
    FOREIGN KEY (idExcursion) REFERENCES excursion(idExcursion) ON DELETE CASCADE
);

CREATE TABLE occurrence (
    idOccurrence INT AUTO_INCREMENT PRIMARY KEY,
    dateDepart   DATE NOT NULL,
    dateRetour   DATE NOT NULL,
    idExcursion  INT NOT NULL,
    FOREIGN KEY (idExcursion) REFERENCES excursion(idExcursion),
    CHECK (dateRetour >= dateDepart)
);

CREATE TABLE participant (
    idParticipant INT AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(50) NOT NULL,
    prenom        VARCHAR(50) NOT NULL,
    telephone     VARCHAR(20) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE guide (
    numLicence VARCHAR(20) PRIMARY KEY,
    nom        VARCHAR(50) NOT NULL,
    prenom     VARCHAR(50) NOT NULL,
    telMobile  VARCHAR(20) NOT NULL
);

CREATE TABLE inscription (
    idOccurrence    INT NOT NULL,
    idParticipant   INT NOT NULL,
    dateInscription DATE NOT NULL,
    PRIMARY KEY (idOccurrence, idParticipant),
    FOREIGN KEY (idOccurrence)  REFERENCES occurrence(idOccurrence),
    FOREIGN KEY (idParticipant) REFERENCES participant(idParticipant)
);

CREATE TABLE animer (
    idOccurrence INT NOT NULL,
    numLicence   VARCHAR(20) NOT NULL,
    PRIMARY KEY (idOccurrence, numLicence),
    FOREIGN KEY (idOccurrence) REFERENCES occurrence(idOccurrence),
    FOREIGN KEY (numLicence)   REFERENCES guide(numLicence)
);

-- Contrainte non exprimable en SQL simple : nombre d'inscrits <= nbMaxParticipants.
-- À vérifier dans l'application (ou via un trigger BEFORE INSERT sur inscription).
