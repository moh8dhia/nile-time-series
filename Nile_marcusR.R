# Chargement des packages avancés
# install.packages(c("tseries", "strucchange"))
library(forecast)
library(tseries)
library(strucchange)

data(Nile)

# --- 1. TESTS DE STATIONNARITÉ ---
print("--- Test ADF ---")
adf.test(Nile) # p-value < 0.05 indique stationnarité. Ici, on s'attend à rejeter ou être limite.
print("--- Test KPSS ---")
kpss.test(Nile) # p-value < 0.05 indique NON-stationnarité.

# --- 2. DÉTECTION DE RUPTURE STRUCTURELLE ---
# Test de détection de cassure dans la moyenne
rupture <- breakpoints(Nile ~ 1)
summary(rupture)
plot(Nile, main="Série du Nil avec Rupture Structurelle (1898)")
lines(fitted(rupture, breaks = 1), col="red", lwd=2)
# L'année de rupture identifiée correspondra à la construction du barrage.

# --- 3. MODÈLES CONCURRENTS ---
# Modèle 1 : Holt classique (Tendance linéaire)
modele_holt <- ets(Nile, model = "AAN")

checkresiduals(modele_holt)

# Modèle 2 : Holt amorti (Damped Trend)
modele_holt_damped <- ets(Nile, model = "AAN", damped = TRUE)

checkresiduals(modele_holt_damped)

# --- 4. COMPARAISON DES PERFORMANCES ---
print("--- Métriques Holt Classique ---")
accuracy(modele_holt)
print("--- Métriques Holt Amorti ---")
accuracy(modele_holt_damped)

# Tu pourras comparer ces RMSE et AIC avec ceux du modèle SARIMA de ton camarade.
