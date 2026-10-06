# Natural Coach : modélisation

Association d'excursions et de randonnées au Maroc. Ce dépôt contient la modélisation statique (base de données) et fonctionnelle (contexte et cas d'utilisation) de l'application.

## Contenu du dépôt

| Fichier | Description |
|---|---|
| `README.md` | Modélisation complète (diagrammes et modèle relationnel) |
| `schema.sql` | Script de création de la base (MySQL / MariaDB) |

## Hypothèses de modélisation

- Un **abonné** est un participant : une seule entité `PARTICIPANT`.
- Un **lieu** (point de départ ou d'arrivée) appartient à une région. L'excursion référence deux lieux, d'où deux associations distinctes.
- L'**occurrence** (ou « sortie ») porte les dates. L'excursion reste le produit du catalogue : nom, plan, tarif unique, nombre maximum de participants.
- Les **guides** et les **inscriptions** se rattachent à l'occurrence, pas à l'excursion.
- Les trois variantes sont intégrées : occurrences multiples, photos, points de passage.

## 1. Modélisation statique

### Diagramme de classes

```mermaid
classDiagram
    class Region {
        idRegion
        nomRegion
    }
    class Lieu {
        idLieu
        nomLieu
    }
    class Excursion {
        idExcursion
        nom
        planCircuit
        tarif
        nbMaxParticipants
    }
    class Photo {
        idPhoto
        fichier
        legende
    }
    class PointPassage {
        idPoint
        nom
        description
        ordre
    }
    class Occurrence {
        idOccurrence
        dateDepart
        dateRetour
    }
    class Participant {
        idParticipant
        nom
        prenom
        telephone
        email
    }
    class Guide {
        numLicence
        nom
        prenom
        telMobile
    }
    class Inscription {
        dateInscription
    }

    Region "1" -- "0..*" Lieu : situe
    Lieu "1" -- "0..*" Excursion : départ
    Lieu "1" -- "0..*" Excursion : arrivée
    Excursion "1" -- "0..*" Photo : illustre
    Excursion "1" -- "0..*" PointPassage : jalonne
    Excursion "1" -- "1..*" Occurrence : est programmée
    Occurrence "1..*" -- "1..*" Guide : est menée par
    Occurrence "1" -- "0..*" Inscription : reçoit
    Participant "1" -- "0..*" Inscription : effectue
```

### Contraintes à respecter

- Nombre d'inscrits d'une occurrence ≤ `nbMaxParticipants` de l'excursion.
- `dateRetour` ≥ `dateDepart`.
- Un participant ne peut s'inscrire qu'une seule fois à une même occurrence (clé composée).
- Une occurrence a au moins un guide.

### Modèle relationnel

Convention : `PK` = clé primaire, `#` = clé étrangère.

```
REGION (PK idRegion, nomRegion)

LIEU (PK idLieu, nomLieu, #idRegion)

EXCURSION (PK idExcursion, nom, planCircuit, tarif, nbMaxParticipants,
           #idLieuDepart, #idLieuArrivee)
    idLieuDepart  → LIEU(idLieu)
    idLieuArrivee → LIEU(idLieu)

PHOTO (PK idPhoto, fichier, legende, #idExcursion)

POINT_PASSAGE (PK idPoint, nom, description, ordre, #idExcursion)

OCCURRENCE (PK idOccurrence, dateDepart, dateRetour, #idExcursion)

PARTICIPANT (PK idParticipant, nom, prenom, telephone, email)

GUIDE (PK numLicence, nom, prenom, telMobile)

INSCRIPTION (PK #idOccurrence, PK #idParticipant, dateInscription)

ANIMER (PK #idOccurrence, PK #numLicence)
```

`planCircuit` et `PHOTO.fichier` stockent le chemin ou le nom du fichier, pas le fichier lui-même.

## 2. Modélisation fonctionnelle

### Diagramme de contexte statique

```mermaid
flowchart LR
    R["Responsable de l'association"]
    P["Participant (abonné)"]
    G["Guide"]
    S(("Système de gestion<br/>Natural Coach"))

    R -- "excursions, occurrences, lieux, photos,<br/>points de passage, guides, participants" --> S
    S -- "calendrier, listes d'inscrits,<br/>état des places, statistiques" --> R

    P -- "demande d'inscription / annulation,<br/>informations personnelles" --> S
    S -- "catalogue, détail d'excursion (plan, photos),<br/>confirmation d'inscription" --> P

    G -- "disponibilités" --> S
    S -- "planning des sorties,<br/>liste et coordonnées des participants" --> G
```

### Diagramme de cas d'utilisation

```mermaid
flowchart LR
    R(["Responsable"])
    P(["Participant"])
    G(["Guide"])

    subgraph SYS["Système Natural Coach"]
        UC1["Consulter le catalogue des excursions"]
        UC2["Consulter le détail d'une excursion<br/>(plan, photos, points de passage)"]
        UC3["S'inscrire à une excursion"]
        UC4["Consulter ses inscriptions"]
        UC5["Gérer les excursions"]
        UC6["Gérer les occurrences / calendrier"]
        UC7["Gérer les photos et points de passage"]
        UC8["Gérer les lieux et régions"]
        UC9["Gérer les participants (abonnés)"]
        UC10["Gérer les guides"]
        UC11["Affecter les guides à une occurrence"]
        UC12["Consulter les inscrits d'une occurrence"]
        UC13["Consulter son planning"]
        UC14["S'authentifier"]
        UC15["Vérifier les places disponibles"]
    end

    P --- UC1
    P --- UC4
    P --- UC3
    UC1 -. "include" .-> UC2
    UC3 -. "include" .-> UC14
    UC3 -. "include" .-> UC15

    R --- UC5
    R --- UC6
    R --- UC8
    R --- UC9
    R --- UC10
    R --- UC11
    R --- UC12
    UC5 -. "extend" .-> UC7
    UC5 -. "include" .-> UC14

    G --- UC13
    G --- UC12
    UC13 -. "include" .-> UC14
```

**Lecture rapide**

- **Participant** : consulte le catalogue et les détails, s'inscrit (après authentification et vérification des places) et consulte ses inscriptions.
- **Responsable** : administre le référentiel (excursions, occurrences, lieux, abonnés, guides) et affecte les guides.
- **Guide** : consulte son planning et la liste des inscrits de ses sorties.
