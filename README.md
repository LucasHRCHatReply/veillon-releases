# Veillon pour macOS

Veillon réunit, dans une seule app de la barre des menus, les moniteurs d'un Mac (processeur, mémoire, disques, réseau,
batterie, capteurs, Bluetooth, historique de 28 jours, alertes) et son nettoyage (caches, doublons, grands fichiers,
désinstalleur d'apps, vie privée, performance). Aucun compte, aucune licence, aucune télémétrie, aucun service en ligne.

- **Barre des menus** : sept éléments (normal, deux lignes, compact), un panneau combiné, un raccourci clavier, des alertes à seuil.
- **Fenêtre** : dix-neuf pages, de l'aperçu au nettoyage, avec liste avant toute suppression, Corbeille et annulation.
- **Sans mot de passe par défaut** : tout se lit sans droit ; les gestes d'administrateur passent par la fenêtre de macOS.
- **Facultatif** : Accès complet au disque (Mail, permissions, récents) et une aide pour régler les ventilateurs.

Version de test. Ce dépôt ne contient que les versions à installer. Le code source n'est pas public.

## Ce qu'il faut

- un Mac à puce Apple (M1 ou plus récent) ;
- macOS 26 ou plus.

Aucun compte GitHub, aucun outil à installer, aucun mot de passe administrateur.

## Installer

Dans Terminal (Cmd + Espace, « Terminal »), une seule commande, qui installe aussi les mises à jour :

```
curl -fsSL https://raw.githubusercontent.com/LucasHRCHatReply/veillon-releases/main/installer.sh | zsh
```

Le script vérifie l'empreinte SHA-256, l'identifiant et l'équipe de signature, puis place Veillon dans `/Applications`.

## Mettre à jour

Relancer la commande ci-dessus. L'historique et les réglages sont conservés.

## Désinstaller

`uninstall.sh`, dans le dossier du zip téléchargé depuis la page des Releases (`zsh uninstall.sh`, `--tout` pour effacer aussi l'historique).
