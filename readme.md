# Artifact
Dylan Ducas

## Introduction
Artifact est un jeu inspiré par des jeux "bullethell", par exemple Touhou, mais avec une plus grande liberté de mouvement. Le jeu possède une histoire très courte et pas complète; La fin du jeu est juste après le premier boss. Vous incarné un petit vaisseau triangulaire, une sorte d'artéfacte, qui peut tirer des balles auto-guidées et des bombes et qui se déplace sans gravité.

## Concepts

#### - Smooth Polygon
Dans ce projet, je voulais la possibilité de faire des niveaux possèdants de courbes suffisament arrondies comme dans le jeu dont je me suis inspiré au début: DATA WING.

L'interpolation de séries de point est souvant très utile, permettant de simplifié le travail du dévellopeur en transformant un série de coordonées en quelque chose de plus complex, comme en ralentissant l'arrivé ou le départ sur un chemin. Pour m'éviter de devoir placé chaque point de mes polygons à la main, je me suis créer ce méchanisme qui ajoute des points à mon polygon pour l'arrondire. 

J'ai essayer plusieurs moyens de parvenir au résultat que j'ai aujourd'hui mais la solution qui à marcher est d'utilisé le système de sample d'une Curve2D dans Godot. J'ai eu l'idée d'utiliser la Curve2D lorsque je suis tomber sur [cette documentation](https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html).

Avant smooth polygon:

![Avant smooth polygon](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/9d8dc5d7-a5cb-425a-9333-bee467f9d8cb)

Après smooth polygon:

![Après smooth polygon](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/d208e833-acd0-44b0-b999-daecf283206a)

---

#### - DialogueCreator
Dans ce projet, je voulais avoir la possibilité de créer des arbres de dialogues. J'avais vu un créateur de dialogue intéressant dans l'engin de jeu "RPG in a box" et c'est pourquoi je m'en suis inspirer pour faire mon créateur de dialogue.

Le système de dialogue marche avec des "boites" qui ont chacune un role différent. Par exemple, la boite "msg" sert à afficher un message, "script" sert à executer un script, "choice" sert à créer un choix avec des options "choice option". Le système de "RPG in a box" est très similaire. Ces boites ont une relation parent enfant ce qui permet de les ordonné dans un fichier JSON qui sera lu par mon DialoguePlayer.

https://github.com/Gyrcas/Bullethell_slide/assets/88252411/ff861ece-d2fa-465b-ab3e-379a2fcf7b88

---

#### - Injection de mods
Dans mon jeu, je voulais offrir la possibilité de pouvoir modifier le code du jeu sans avoir à éditer le code source. J'ai toujours été fan de jeu offrant la possibilité de mod comme les jeux de la franchise Elder Scrolls ou bien ceux de Fallout.

Après de nombreuses recherches, j'ai découvert qu'il est possible de modifier et de sauvegardé les fichiers de scène (.tscn). J'ai alors réalisé que je pouvais injecter directement du contenu supplémentaire dans les fichiers. Les mods sont ajouter comme enfant du node principal de la scène. Étonnamant, il est même possible de créer un mod qui rajoute un Singleton au jeu en modifiant le menu principal. En effet, en ajoutant n'importe quel node comme enfant du root, celui-ci devient un Singleton.

(Note) De plus, j'ai découvert récemment qu'un jeu utilise un système similaire pour ses DLC, Crosscode.

Pour ce qui est de la gestion des mods, j'ai décidé de simplifier la procedure en obligeant les mods à immiter la structure du projet. Par exemple:

Disons que je veut modifier la scène player.tscn. le chemin du fichier est:

dossier_de_jeu/entities/player.tscn

Donc, pour que le mod soit fonctionnel, il devrait être dans un dossier avec le nom du mod à l'intérieur du dossier de mods:

(player.tscn est un dossier et non un fichier dans cette exemple)

dossier_de_jeu/mods/nom_du_mod/entities/player.tscn/mon_mod.tscn

https://github.com/Gyrcas/Bullethell_slide/assets/88252411/7b17e4b7-175c-47cb-b59c-d61007a3b34b

---

#### - Target
Dans mon jeu, j'ai une target qui peut automatiquement visée les enemies. Les balles du joueur sont associées à la target et la suivent automatiquement
Je l'ai inventé donc pas de source.

![target](https://github.com/Gyrcas/Bullethell_slide/assets/88252411/2cca7316-8a3d-43f3-a98f-6f1b41529984)

---

#### - Shader black hole
Dans mon jeu, j'ai combiné des shaders, plus exactement un effet de ripple et d'abération chromatique, pour créer des effets de trous noirs intéressants.
J'ai pris ces shaders puis les ai combiné:

[ripple](https://godotshaders.com/shader/ripple-shader/)

[abération chromatique](https://godotshaders.com/shader/just-chromatic-aberration/)

https://github.com/Gyrcas/Bullethell_slide/assets/88252411/b0328aac-951c-417d-911c-9f840b4f387b



