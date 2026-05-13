# Chargement des packages avancés
# install.packages(c("tseries", "strucchange"))
library(forecast)
library(tseries)
library(strucchange)

data(Nile)

nile <- Nile

#test de stationnarité
adf.test(nile)
print("p-value du test ADF :")
print(adf.test(nile)$p.value)

# on fait une différenciation d'ordre 1 pour rendre la série stationnaire
nile_diff <- diff(nile, differences = 1)
adf.test(nile_diff)
print("p-value du test ADF après différenciation :")
print(adf.test(nile_diff)$p.value)

print("en appliquant une différenciation d'ordre 1, la série devient 
stationnaire (p-value = 0.01), on aura donc une différenciation d'ordre 1
(d=1) dans notre modèle SARIMA")

# trouver les paramètres p et q à l'aide des graphiques ACF et PACF

par(mfrow=c(2,1))
Acf(nile_diff, main="ACF de la série différenciée")
Pacf(nile_diff, main="PACF de la série différenciée")

print("le graphique ACF indique q=1 car il y a une barre significative à lag 1")
print("le graphique PACF montre plusieurs barres significatives, à 1, 2, 7, 10
la série est du type moyenne mobile (MA)")


# modélisation SARIMA

# sarima(nile, p=0, d=1, q=1, P=0, D=0, Q=0, S=NA)
# P=D=Q=0 car il n'y a pas de saisonnalité



mod_fitsarima <- Arima(nile, order=c(0,1,1), seasonal=c(0,0,0))
checkresiduals(mod_fitsarima)
print("résumé du modèle SARIMA :")
summary(mod_fitsarima)
print("on a ma1=-0.7329, poids de l'erreur du pas précédent,
p-value=0.1458, on ne rejette pas l'hypothèse nulle, les résidus sont indep.
AIC = 1269.09, à comparer avec les AIC des ARIMA (flavio)")

#prédiction pour les 10 prochaines années
pred_sarima <- forecast(mod_fitsarima, h=10)
print("prédiction pour les 10 prochaines années :")
print(pred_sarima)

#graphique de la série et des prévisions
plot(pred_sarima, main="Prévisions SARIMA pour les 10 prochaines années",
xlab="Année", ylab="Débit du Nil")
lines(nile, col="blue") # ajouter la série originale en bleu

#prédiction pour l'année 2026
pred_2026 <- forecast(mod_fitsarima, h=1)
print("prédiction pour l'année 2026 :")
print(pred_2026)