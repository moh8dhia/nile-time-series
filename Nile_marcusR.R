library(forecast)
library(tseries)
library(strucchange)

serie <- Nile
log_serie <- log(serie)

# ============================================================
# 1. VISUALISATION INITIALE
# ============================================================
par(mfrow = c(2,1))
plot(serie, main = "Série Nile (débit annuel)", ylab = "Débit", col = "steelblue", lwd = 1.5)
plot(log_serie, main = "log(Nile)", ylab = "log(Débit)", col = "darkgreen", lwd = 1.5)

# ============================================================
# 2. ANALYSE ACF / PACF
# ============================================================
par(mfrow = c(2,1))
Acf(serie,  lag.max = 50, main = "ACF – Nile")
Pacf(serie, lag.max = 50, main = "PACF – Nile")
# Lecture :
#   ACF  : décroissance lente → mémoire longue / possible tendance non stationnarisée
#   PACF : coupure nette après lag 1 → structure AR(1) plausible, pas de saisonnalité

# ============================================================
# 3. VÉRIFICATION DE LA TENDANCE AFFINE  y = ax + b + ε
# ============================================================
temps <- time(Nile)   # vecteur années 1871–1970

modele_lin <- lm(Nile ~ temps)
summary(modele_lin)
# Interprétation attendue :
#   coefficient `temps` significatif (p < 0.05) → tendance décroissante confirmée
#   R² modeste (~0.20-0.25) → la tendance linéaire explique peu ; bruit résiduel important

par(mfrow = c(1,1))
plot(serie,
     main = "Série Nile – débit annuel avec tendance affine",
     ylab = "Débit (m³/s)",
     xlab = "Année",
     col  = "steelblue",
     lwd  = 1.5,
     type = "l")

# Superposition de la droite de régression
abline(modele_lin, col = "red", lwd = 2, lty = 2)

# Valeurs aberrantes en surbrillance
points(time(serie)[outliers_idx],
       serie[outliers_idx],
       col = "orange", pch = 19, cex = 1.4)

legend("topright",
       legend = c("Série Nile", "Tendance affine (lm)", "Outliers"),
       col    = c("steelblue", "red", "orange"),
       lty    = c(1, 2, NA),
       pch    = c(NA, NA, 19),
       lwd    = c(1.5, 2, NA),
       bty    = "n")

# --- Vérification que les résidus sont un bruit blanc ---
residus <- residuals(modele_lin)

par(mfrow = c(3,1))
plot(residus, type = "l", main = "Résidus du modèle linéaire", col = "firebrick")
abline(h = 0, lty = 2)
Acf(residus,  lag.max = 30, main = "ACF des résidus")
Pacf(residus, lag.max = 30, main = "PACF des résidus")


cat("\n=== Test ADF (stationnarité des résidus) ===\n")
print(adf.test(residus))
# H0 : racine unitaire. Si p < 0.05 : résidus stationnaires → tendance bien captée.

cat("\n=== Test de Shapiro-Wilk (normalité) ===\n")
print(shapiro.test(residus))

# Visualisation de la droite de tendance
par(mfrow = c(1,1))
plot(serie, main = "Nile + tendance affine estimée",
     col = "steelblue", lwd = 1.5, ylab = "Débit")
abline(modele_lin, col = "red", lwd = 2, lty = 2)
legend("topright", legend = c("Série", "Tendance lm()"),
       col = c("steelblue","red"), lty = c(1,2), lwd = 2)
# ============================================================
# LAG PLOT des résidus
# ============================================================
lag.plot(residus,
         lags    = 9,
         layout  = c(3, 3),
         main    = "Lag plot des résidus du modèle linéaire",
         col     = "steelblue",
         do.lines = FALSE)
# Lecture : si les points sont dispersés sans structure → résidus indépendants
# Une diagonale visible à lag 1 signalerait une autocorrélation résiduelle

# ============================================================
# TESTS DE BLANCHEUR des résidus
# ============================================================

# --- Ljung-Box (plusieurs lags pour robustesse) ---
cat("\n=== Test de Ljung-Box ===\n")
for (lag in c(5, 10, 15, 20)) {
  test <- Box.test(residus, lag = lag, type = "Ljung-Box")
  cat(sprintf("lag = %2d  |  statistique = %.3f  |  p-value = %.4f  %s\n",
              lag,
              test$statistic,
              test$p.value,
              ifelse(test$p.value > 0.05, "✓ BB non rejeté", "✗ autocorrélation détectée")))
}

## Test plus restrictif qu'un Lag-plot, en réalité les résidus sont décorrélés.
## Un AR(1) suffit pour la modélisation

# ============================================================
# 4. DÉTECTION DES VALEURS ABERRANTES
# ============================================================
# Méthode : outliers > moyenne ± 2.5 * écart-type (sur la série originale)
m  <- mean(serie)
s  <- sd(serie)
seuil_haut <- m + 2.5 * s
seuil_bas  <- m - 2.5 * s

outliers_idx  <- which(serie < seuil_bas | serie > seuil_haut)
cat("\n=== Valeurs aberrantes détectées ===\n")
print(serie[outliers_idx])   # années + valeurs

# Série purgée : on remplace les outliers par NA puis on les interpole
serie_clean <- serie
serie_clean[outliers_idx] <- NA
serie_clean <- na.interp(serie_clean)   # interpolation linéaire (package forecast)

par(mfrow = c(2,1))
plot(serie,       main = "Série originale",       col = "steelblue",   lwd = 1.5)
points(time(serie)[outliers_idx], serie[outliers_idx], col = "red", pch = 19, cex = 1.3)
legend("topright", legend = "Outliers", col = "red", pch = 19)
plot(serie_clean, main = "Série purgée (outliers interpolés)", col = "darkorange", lwd = 1.5)

# ============================================================
# 5. SÉLECTION DU MEILLEUR LISSAGE EXPONENTIEL (AIC)
# ============================================================
# ets() teste automatiquement les modèles Error/Trend/Season :
#   A = additif, M = multiplicatif, N = aucun
# Sur une série avec tendance sans saisonnalité → candidats : AAN, ANN, MAN, MNN

# --- 5a. Modèle sur la série ORIGINALE ---
cat("\n=== Modèle ETS – série originale ===\n")
modele_ets <- ets(serie, ic = "aic")
summary(modele_ets)
# ets() retourne le modèle dont l'AIC est minimal parmi tous les candidats.
# Attendu : AAN (Holt) → lissage de niveau + tendance additive

# Diagnostics résidus
checkresiduals(modele_ets)
# Affiche : résidus dans le temps, ACF des résidus, histogramme
# + test de Ljung-Box automatique

# Prévision 10 ans
prev_orig <- forecast(modele_ets, h = 10)
par(mfrow = c(1,1))
plot(prev_orig,
     main = paste("Prévision ETS", modele_ets$method, "– série originale"),
     col  = "steelblue", fcol = "firebrick", lwd = 1.5)
grid()

# --- 5b. Modèle sur la série PURGÉE (sans outliers) ---
cat("\n=== Modèle ETS – série purgée ===\n")
modele_ets_clean <- ets(serie_clean, ic = "aic")
summary(modele_ets_clean)

checkresiduals(modele_ets_clean)

prev_clean <- forecast(modele_ets_clean, h = 10)
par(mfrow = c(1,1))
plot(prev_clean,
     main = paste("Prévision ETS", modele_ets_clean$method, "– série purgée"),
     col  = "darkorange", fcol = "darkgreen", lwd = 1.5)
grid()

# ============================================================
# 6. COMPARAISON AIC DES DEUX MODÈLES
# ============================================================
cat("\n=== Comparaison AIC ===\n")
cat(sprintf("AIC modèle original  : %.2f  (%s)\n", modele_ets$aic,       modele_ets$method))
cat(sprintf("AIC modèle purgé     : %.2f  (%s)\n", modele_ets_clean$aic, modele_ets_clean$method))
cat(sprintf("Paramètre alpha (orig)  : %.4f\n", modele_ets$par["alpha"]))
cat(sprintf("Paramètre alpha (clean) : %.4f\n", modele_ets_clean$par["alpha"]))
if (!is.null(modele_ets$par["beta"])) {
  cat(sprintf("Paramètre beta  (orig)  : %.4f\n", modele_ets$par["beta"]))
  cat(sprintf("Paramètre beta  (clean) : %.4f\n", modele_ets_clean$par["beta"]))
}
# alpha proche de 1 → lissage fort, série très réactive (bruit dominant)
# alpha proche de 0 → lissage doux, tendance stable

# ============================================================
# 7. RÉCAPITULATIF DÉCISIONNEL
# ============================================================
# La justification du lissage exponentiel repose sur :
#   ✓ ACF à décroissance lente    → série non stationnaire, tendance présente
#   ✓ PACF coupure après lag 1    → dépendance AR(1) à courte mémoire
#   ✓ LM confirme pente β < 0     → tendance affine décroissante significative
#   ✓ Ljung-Box sur résidus du LM → résidus ~ BB (ou légèrement corrélés à lag 1)
#   ✓ ets() sélectionne AAN/ANN   → lissage de Holt (niveau + tendance) confirme
#     la structure détectée sans saisonnalité
#   ✓ AIC purgé < AIC original    → outliers biaissaient le modèle

# ============================================================
# PRÉVISION JUSQU'EN 2026 AVEC LE MODÈLE ETS SÉLECTIONNÉ
# ============================================================

# La série Nile se termine en 1970 → horizon = 2026 - 1970 = 56 ans
h <- 2026 - end(serie)[1]

prev_2026 <- forecast(modele_ets, h = h, level = c(80, 95))

# --- Graphique ---
par(mfrow = c(1,1))
plot(prev_2026,
     main    = paste("Prévision ETS", modele_ets$method, "– Nile jusqu'en 2026"),
     ylab    = "Débit (m³/s)",
     xlab    = "Année",
     col     = "steelblue",
     fcol    = "firebrick",
     shadecols = c("lightyellow", "lightsalmon"),
     lwd     = 1.5,
     flwd    = 1.5)
abline(v = 1970, col = "gray40", lty = 3)
legend("topright",
       legend = c("Données observées", "Prévision",
                  "IC 80%", "IC 95%"),
       col    = c("steelblue", "firebrick", "lightsalmon", "lightyellow"),
       lty    = c(1, 1, NA, NA),
       pch    = c(NA, NA, 15, 15),
       pt.cex = 1.5,
       lwd    = c(1.5, 1.5, NA, NA),
       bty    = "n")

# --- Tableau des valeurs prédites ---
cat("\n=== Valeurs prévues 1971–2026 ===\n")
pred_df <- data.frame(
  Annee     = as.integer(time(prev_2026$mean)),
  Prevision = round(as.numeric(prev_2026$mean),  1),
  IC80_inf  = round(as.numeric(prev_2026$lower[, "80%"]), 1),
  IC80_sup  = round(as.numeric(prev_2026$upper[, "80%"]), 1),
  IC95_inf  = round(as.numeric(prev_2026$lower[, "95%"]), 1),
  IC95_sup  = round(as.numeric(prev_2026$upper[, "95%"]), 1)
)
print(pred_df, row.names = FALSE)

# Valeur ponctuelle en 2026
val_2026 <- pred_df[pred_df$Annee == 2026, ]
cat(sprintf("\nPrévision ponctuelle 2026 : %.1f m³/s  [IC95 : %.1f – %.1f]\n",
            val_2026$Prevision, val_2026$IC95_inf, val_2026$IC95_sup))

