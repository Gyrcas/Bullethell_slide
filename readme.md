# Artifact
###### Dylan Ducas

## Introduction
Artifact est un jeu d'action et d'aventure en vue de coté oû vous controllez un petit artéfact représenté par un triangle blanc. Le jeu s'inspire de jeu comme CastleVania: SOTN pour le monde ou l'on peut trouver des abilités pour rendre le joueur plus puissant et d'autre jeux surnommé "bullet hell" ou le but est d'esquiver un grand nombre de balle tout en tirant sur les enemies. Touhou est un exemple de bullet hell.

La présentation sera divisé en deux parties. Tout d'abord, un court résumé de plusieurs méchanismes qui ont été créés et utilisés lors de ce projet, incluant une comparaison avec d'autres méthodes existantes ainsi que les avantages et inconvénient de la méthode utilisé. Ensuite, Les notions que j'ai apprises par moi-même seront ainsi que les difficultés que j'ai rencontrées lors de ce projet.

## Développement
### Méchanismes
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

---

#### - DialogueCreator
Permet de facilement créer, modifier ou jouer des dialogues. Offre diverses options de dialogues comme des choix, des scripts, des conditions, etc.

Plusieurs éditeurs existaient déjà mais j'avais déjà créer un éditeur par le passé que je voulais recréer et il est plus à mes goûts que ceux qui étaient déjà disponibles.

Avantages:
- Simple
- Puissant

Désavantages:
- Plus compliqué que prévu
- Quelques problèmes d'affichages dans l'éditeur

https://github.com/Gyrcas/Bullethell_slide/assets/88252411/ff861ece-d2fa-465b-ab3e-379a2fcf7b88

---

#### - Roue d'habilités
Roue d'habilités permettant au joueur de selectionné une abilité puis de l'executer.

Un UI plus simple aurait été possible, mais celui-ci est esthétique et intéressant.

Avantages:
- Beau
- Adaptable

Désavantages:
- Commence à être bizarre si trop d'abilités

![perk wheel](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/f67f2013-b731-43e6-b37a-b71f320e5dc5)

---

#### - Injection de mods
Permet l'injection de code ajouté à une scène permettant de modifier le code du jeu pour modifier de mechanique de jeu, en ajouter ou même en supprimer.

Bien qu'il y aurait eu plus simple pour permettre à n'importe qui d'éditer mon code puisque Godot est accessible à tous et que je pourrais laisser mon code non cripté, cependant, il serait difficile dans ce cas de fusionner différents "mods" dans le jeu. Mon code le permet. Je me suis inspirer de jeu comme Skyrim, Celeste et Fallout New Vegas qui ont tous une communauté de mods active et j'ai toujours adoré les jeux me permettant d'installer des mods.

https://github.com/Gyrcas/Bullethell_slide/assets/88252411/7b17e4b7-175c-47cb-b59c-d61007a3b34b

---

### Notions apprises et difficultés rencontrées
 
#### - Curve2D et interpolation

Pour faire mon SmoothPolygon2D, j'ai enormément chercher comment transormer une simple suite de point en courbe. La méthode que j'ai trouvée utilise la ressource Curve2D avec sa fonction sample_baked pour obtenir une obtenir une interpolation de courbe à partir des points que je lui ai fournit pour une progression donnée.

Les principales difficultés rencontrées ont été de trouvée la bonne manière de procédée pour executé l'interpolation. La page qui m'a donnée l'inspiration est la [page de Godot sur le bezier et les courbes](https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html).

#### - Addons

J'ai appris comment faire des addons pour Godot comme mon SmoothPolygon2D ou mon DialogueCreator. J'étais surtout intéressé par ce sujet car je voulais intégrer mon créateur de dialogue directement dans Godot et à ma surprise, c'était assez simple! Je simplement trouvé comment en créé un en regardant dans la [documentation de Godot](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html).

#### - Tweens

Le tweens sont géniaux! Je les ai découvert en cherchant un moyen de faire des animations avec des valeurs de départ changeantes. La seul difficultés rencontrées serait la modification d'un index spécifique d'un array grâce à un tween n'est pas possible de base. J'ai donc créé une variable avec un setter qui modifies mon index et puis je tween cette variable.

#### - Modification de fichier

J'ai découvert comment faire de la modification de fichier car je voulais faire une sauvegarde de mes options et aussi pouvoir lire les fichiers dans un dossiers. J'ai trouvé un forum qui m'a mené vers [cette page](https://docs.godotengine.org/en/3.1/tutorials/io/saving_games.html). La principale difficulté que j'ai rencontré est que au lieu de faire File.new(), il faut faire FileAccess.open(path) pour obtenir un fichier dans Godot 4.

## Conclusion

J'ai bien aimé ce projet car c'est le premier projet Godot que j'ai poussé aussi loin et qui me parait prometteur pour le futur. Mon projet est déjà assez complet en soi donc je crois que j'ai déjà exploré tout ce que je voulais explorer. Même si j'aurais la possibilité de changer de projet, je garderais celui-ci. J'ai bien sûr des idées pour d'autres projets dans ma tête, mais celui-ci à une bonne chance de produire quelque chose d'intéressant.

