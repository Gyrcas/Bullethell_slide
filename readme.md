# Artifact
###### Dylan Ducas

## Introduction
Artifact est un jeu d'action et d'aventure en vue de coté oû vous controllez un petit artéfact représenté par un triangle blanc. Le jeu s'inspire de jeu comme CastleVania: SOTN pour le monde ou l'on peut trouver des abilités pour rendre le joueur plus puissant et d'autre jeux surnommé "bullet hell" ou le but est d'esquiver un grand nombre de balle tout en tirant sur les enemies. Touhou est un exemple de bullet hell.

La présentation sera divisé en deux parties. Tout d'abord, un court résumé de plusieurs méchanismes qui ont été créés et utilisés lors de ce projet, incluant une comparaison avec d'autres méthodes existantes ainsi que les avantages et inconvénient de la méthode utilisé.

## Développement
#### - Smooth Polygon
Le smooth polygon est un méchanisme que j'ai créé pour me permettre de faire des niveaux pour Artifact moins polygonaux. J'ai essayer de trouver des addons Godot me permettant d'avoir ce méchanisme préfait pour moi mais le seul que j'ai trouvé ne marchait pas et n'est même plus disponible dans la librairy d'asset de Godot.

Avantages:
- Smooth
- Facile à utilisé
- Possède plusieurs autres utilités comme la possibilité de couper facilement le polygon.

Désavantages:
- Peut créer des problèmes de performances si les paramêtres sont mal utilisés.

Avant smooth polygon:

![Avant smooth polygon](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/9d8dc5d7-a5cb-425a-9333-bee467f9d8cb)

Après smooth polygon:

![Après smooth polygon](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/d208e833-acd0-44b0-b999-daecf283206a)

---

#### - InputsMapper
Permet au joueur de changer les touches du jeu.

Bien qu'il existe des addons qui essaient déjà d'accomplir ce but, je voulais que le mien soit adapter à mon projet et facilement éditable.

Avantages:
- Adaptable
- Facilement intégrable

Désavantages:
- Doit être codé

![InputsMapper](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/3954cd05-7435-4808-8232-840db175941d)

---

#### - Système de sauvegarde (GS)
Permet de faire des sauvegardes, de les supprimer et de les recharger plus tard.

Il n'y avait pas vraiment d'autres méthodes pour le faire sauf télécharger un addon mais je voulais en créer un pour le comprendre et me permettre facilement de l'utilisé.

Avantages:
- Facilement utilisable
- Ne stock que les variables dont il a besoin d'avoir accès

Désavantages:
- Doir être codé

https://github.com/Gyrcas/Bullethell_slide/assets/88252411/93325887-1b16-4590-b7f9-0cbbb38e9432



