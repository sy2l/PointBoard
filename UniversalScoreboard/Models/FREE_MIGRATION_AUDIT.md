# PointBoard — Passage en application 100% gratuite

Date de création: 21/05/2026  
Dernière mise à jour: 21/05/2026  
Statut: En cours  
Version d'audit: 1.0

## Objectif
Rendre l’app entièrement gratuite, sans pub ni restriction, en supprimant proprement toute monétisation (IAP, paywalls, pubs) et en simplifiant le code.

## Portée
- Suppression/neutralisation des achats intégrés (StoreKit)
- Suppression/neutralisation des publicités (si présentes)
- Déverrouillage de tous les contenus/packs
- Nettoyage UI/UX: suppression des écrans de paywall/boutique
- Mise à jour des textes/prix/mentions
- Refactor minimal pour stabilité et maintenabilité

## Checklist des tâches

- [x] Analyser le système de packs existant (GamePack.swift) et confirmer que tous les packs sont considérés gratuits côté UI.
- [ ] Mettre à jour GamePack pour refléter le statut gratuit partout (prix, paidPacks, productID optionnel, commentaires).
- [ ] Rechercher les dépendances StoreKit (StoreManager, Product, purchase, canPurchase, isUnlocked) et neutraliser la logique d’achat pour retourner “déjà débloqué”.
- [ ] Rechercher et supprimer/masquer les écrans de paywall/boutique (ex: ShopView, PaywallView, PurchaseButton).
- [ ] Mettre à jour les textes marketing et labels de prix vers “Gratuit”.
- [ ] Vérifier les gardes UI (isLocked, requiresPack, gatedByPack) et les faire renvoyer “débloqué”.
- [ ] Nettoyer les assets/icônes liés au store si non utilisés.
- [ ] Vérifier la persistance (UserDefaults/SwiftData) pour éviter de stocker/relire des états d’achat.
- [ ] Mettre à jour la documentation interne et notes de version.

## Détails par fichier (pré-audit)

- GamePack.swift
  - Déclare les packs, noms, descriptions, prix (string), productID, et mapping preset->pack.
  - Actuellement: commentaire “App 100% gratuite, tous les packs débloqués”. Prix affiche “Gratuit” seulement pour coreFree; paidPacks filtre tout sauf coreFree.
  - Actions: uniformiser prix “Gratuit”, rendre paidPacks vide, documenter productID comme obsolète (non utilisé), conserver mapping pour UI mais sans gating.

- Store/Monétisation (à identifier)
  - Rechercher classes/services: StoreManager, PurchaseManager, IAPService, etc.
  - Actions: faire retourner ‘débloqué’, ignorer les appels d’achat, retirer le fetch des produits si inutile.

- Paywall/Boutique (à identifier)
  - Rechercher vues: PaywallView, StoreView, ShopView, PacksView avec boutons d’achat.
  - Actions: masquer ou remplacer par une page d’info “Tout est gratuit”.

- Gating UI (à identifier)
  - Rechercher: isLocked(preset), requiresPack, hasAccessTo(preset), featureFlags.
  - Actions: renvoyer toujours true pour l’accès.

- Publicités (si présentes)
  - Rechercher: AdMob, AppTrackingTransparency, SKAdNetwork, GADBannerView, Interstitial.
  - Actions: supprimer initialisation, vues et IDs; retirer capabilities si nécessaire.

## Notes d’implémentation
- Privilégier solutions natives Apple. C’est la méthode recommandée par Apple: supprimer la logique StoreKit si non utilisée, garder le minimum viable.
- Respecter MVVM + Services: neutraliser au niveau service (ex: StoreService) pour que la UI reste simple.
- Minimiser les breaking changes: conserver les signatures publiques mais faire retourner des valeurs “débloqué/gratuit”.

## Journal des changements

- 21/05/2026 — Initialisation de l’audit. Ajout des tâches et première passe sur GamePack.
