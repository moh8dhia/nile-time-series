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

# ---------------------------------------------------------
# 1. MODÈLE LINÉAIRE (ax + b)
# ---------------------------------------------------------
temps <- time(Nile)
modele_lin <- lm(Nile ~ temps)

print("--- Résumé du Modèle Linéaire ---")
summary(modele_lin) # Regarde la p-value de 'temps' pour voir si la tendance est significative

# ---------------------------------------------------------
# 2. PREUVE DU BRUIT BLANC (Analyse des résidus)
# ---------------------------------------------------------
residus_lin <- residuals(modele_lin)

# Affichage graphique pour l'analyse visuelle
par(mfrow=c(1,2))
plot(residus_lin, main="Résidus du modèle linéaire", ylab="Erreurs")
abline(h=0, col="red", lty=2)
acf(residus_lin, main="Corrélogramme des résidus (ACF)") # Si des barres dépassent les pointillés bleus, ce n'est pas un bruit blanc !

# Tests statistiques formels
print("--- Test de Ljung-Box (Autocorrélation) ---")
# p-value < 0.05 indique que les résidus SONT corrélés (ce n'est pas un bruit blanc)
Box.test(residus_lin, lag = 10, type = "Ljung-Box") 

print("--- Test de Shapiro-Wilk (Normalité) ---")
# p-value < 0.05 indique que les résidus ne suivent pas une loi normale
shapiro.test(residus_lin) 

# ---------------------------------------------------------
# 3. MODÈLE QUADRATIQUE (at^2 + bt + c)
# ---------------------------------------------------------
temps2 <- temps^2
modele_quad <- lm(Nile ~ temps + temps2)

print("--- Résumé du Modèle Quadratique ---")
summary(modele_quad) # Regarde la p-value de 'temps2' pour voir si la courbure est utile

# Comparaison des deux modèles avec le critère AIC (le plus petit est le meilleur)
print(paste("AIC Linéaire :", AIC(modele_lin)))
print(paste("AIC Quadratique :", AIC(modele_quad)))

# Remise à zéro de l'affichage
par(mfrow=c(1,1))
