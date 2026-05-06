# Nile Time Series Analysis

This project focuses on the analysis of the **Nile river annual flow dataset**, available in R.
Before modeling, we analyze the variance of the time series.

If the variance appears to increase over time, a logarithmic transformation is applied in order to stabilize it and simplify the modeling process by converting a multiplicative structure into an additive one.

We compare both the original and transformed series to determine the most appropriate approach.

## Objective

The goal is to study the behavior of the time series, understand its structure, and build predictive models.

More specifically, we aim to:
- Analyze the trend and variability of the data
- Study autocorrelations (ACF, PACF)
- Check stationarity
- Build predictive models

## Methods

Several time series methods are used, inspired by the course project:

- ARIMA / SARIMA models
- Exponential smoothing
- Linear regression with trend and seasonality

## Dataset

The dataset used is the **Nile dataset**, which represents the annual flow of the Nile river.

It is directly available in R:

```r
Nile



=============================================================================
DÉMARCHE MÉTHODOLOGIQUE : MODÉLISATION DE LA SÉRIE TEMPORELLE (LE NIL)
=============================================================================

OBJECTIF : Établir une modélisation rigoureuse justifiant l'utilisation 
d'un lissage exponentiel pour la série annuelle du débit du Nil.

-----------------------------------------------------------------------------
ÉTAPE 1 : ANALYSE VISUELLE ET EXPLORATOIRE
-----------------------------------------------------------------------------
1. Visualisation de la série chronologique :
   - Tracer la série brute pour observer son comportement global.
   - Observation primaire : Il y a une baisse visible du niveau moyen au 
     fil du temps, mais ce n'est pas une ligne droite parfaite. Il y a une 
     cassure nette autour de 1898 (construction du barrage d'Assouan).

2. Analyse spectrale (Périodogramme) :
   - Objectif : Détecter des cycles ou une saisonnalité.
   - Résultat : Toute la masse spectrale est concentrée en 0. 
   - Conclusion : Absence totale de saisonnalité. La série est pilotée 
     soit par une tendance, soit par des changements d'état (paliers).

-----------------------------------------------------------------------------
ÉTAPE 2 : RECHERCHE DE TENDANCES DÉTERMINISTES
-----------------------------------------------------------------------------
1. Modélisation Linéaire (Droite de régression) :
   - Ajustement d'un modèle de type y = ax + b (débit en fonction du temps).
   - Analyse des coefficients pour vérifier si la pente (a) est 
     statistiquement significative.

2. Modélisation Quadratique :
   - Ajustement d'un modèle y = at^2 + bt + c pour tester si la baisse 
     s'accélère ou ralentit.
   - Comparaison des critères d'information (AIC) entre le modèle linéaire 
     et le modèle quadratique pour voir si l'ajout de la courbure est justifié.

-----------------------------------------------------------------------------
ÉTAPE 3 : VÉRIFICATION DU BRUIT BLANC (LE POINT DE BASCULE)
-----------------------------------------------------------------------------
Pour qu'un modèle de tendance déterministe (comme la droite) soit suffisant, 
il faut que ce qu'il n'explique pas (les résidus/erreurs) soit un "Bruit Blanc".

1. Analyse graphique des résidus :
   - Tracé des résidus : On observe qu'ils ne sont pas répartis au hasard 
     autour de zéro. Il y a des paquets positifs (avant 1898) et des paquets 
     négatifs (après 1898).
   - Corrélogramme (ACF) : Les barres dépassent les limites de significativité, 
     prouvant que les erreurs sont corrélées entre elles.

2. Tests statistiques formels :
   - Test de Ljung-Box : Confirme mathématiquement la présence d'autocorrélation.
   - Test de Shapiro-Wilk : Vérifie si les erreurs suivent une loi normale.

3. Conclusion de l'Étape 3 : 
   - Les résidus NE SONT PAS un bruit blanc. Le modèle de tendance déterministe 
     est invalide (notamment à cause de la rupture structurelle de 1898). 
   - Il faut donc passer à un modèle stochastique, capable de s'adapter aux 
     changements locaux : le Lissage Exponentiel.

-----------------------------------------------------------------------------
ÉTAPE 4 : LE CHOIX DU LISSAGE EXPONENTIEL (APPROCHE PAR ÉLIMINATION)
-----------------------------------------------------------------------------
L'objectif est de choisir le bon modèle dans la famille ETS (Erreur, Tendance, Saisonnalité).

1. Pourquoi éliminer le Lissage Exponentiel Simple (SES) ?
   - Le SES (Modèle ETS(A,N,N)) ne gère qu'un niveau local constant. 
   - Puisque la série présente une dérive (tendance à la baisse/changement 
     de niveau), le SES serait systématiquement en retard sur la réalité.

2. Pourquoi éliminer la méthode de Holt-Winters ?
   - Holt-Winters intègre une composante saisonnière.
   - L'analyse spectrale (Étape 1) a prouvé l'absence de saisonnalité. 
     Utiliser Holt-Winters sur-paramétrerait inutilement le modèle.

3. La sélection finale : La Méthode de Holt (Lissage Double)
   - Le modèle ETS(A,A,N) (Erreur Additive, Tendance Additive, Pas de saisonnalité).
   - Il possède une équation pour lisser le niveau et une autre pour lisser 
     la pente. Il s'adapte aux changements locaux, lissant ainsi le choc 
     de 1898 de manière plus souple qu'une régression classique.

4. L'optimisation ultime : Holt Classique vs Holt Amorti (Damped)
   - Holt classique projette la tendance à l'infini (risque de prédire un 
     débit négatif à long terme).
   - Holt amorti (Modèle ETS(A,Ad,N)) "freine" la tendance avec le temps.
   - Action : Comparer l'AIC et la précision (RMSE) des deux variantes de Holt 
     pour sélectionner le modèle final le plus robuste.

-----------------------------------------------------------------------------
ÉTAPE 5 : VALIDATION FINALE ET PRÉVISIONS
-----------------------------------------------------------------------------
1. Validation du modèle de Holt sélectionné :
   - Appliquer les tests de Bruit Blanc (Ljung-Box, ACF) sur les résidus 
     du modèle de Holt. 
   - Si les tests sont validés, le modèle a capturé toute l'information utile.

2. Génération des prévisions :
   - Calcul des prévisions sur l'horizon souhaité (ex: 10 ans).
   - Tracé du graphique final incluant la série brute, l'ajustement du modèle, 
     les prévisions futures et les intervalles de confiance (80% et 95%).
=============================================================================