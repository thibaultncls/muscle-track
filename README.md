# Muscle Track

## Description
Muscle Track est une application mobile développée avec Flutter et Dart permettant aux utilisateurs d'enregistrer et de suivre leurs entraînements de musculation. L'application utilise SQLite pour la gestion des données et Provider pour la gestion des états.

## Fonctionnalités
- Ajouter des exercices : Enregistrez de nouveaux exercices avec des détails tels que le nom, les répétitions, les séries, et le poids.
- Historique des entraînements : Consultez l'historique complet de vos entraînements passés.
- Édition et suppression : Modifiez ou supprimez facilement les entrées d'entraînement.


## Utilisation
1. DashboardPage : La page d'accueil affiche une vue d'ensemble des entraînements récents et des options pour ajouter un nouvel exercice.
2.  WorkoutPage : Suivre les entraînements en direct
3. HistoryPage : Accédez à l'historique des entraînements pour voir les exercices passés.

## Configuration
### Base de données
L'application utilise SQLite pour stocker les données localement. Les modèles de données et les méthodes de requête se trouvent dans le répertoire `lib/helpers/providers`.

### Gestion des états
La gestion des états est assurée par Provider. Les différents providers sont définis dans le répertoire `lib/helpers/providers`.


## Licence
Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Auteur
- Thibault Nicolas - Développeur principal

## Remerciements
- Remerciements spéciaux à la communauté Flutter pour leur support et leurs ressources.

---

Pour toute question ou assistance, n'hésitez pas à me contacter via thibault-n@hotmail.fr.
