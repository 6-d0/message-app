# BACKEND
> Le backend est fait avec le framework [DRF](https://www.django-rest-framework.org), et python

Le système d'authentification est fait avec les `JWT Token`, lors de la connexion, on récupère un token qui expire tous les 5 minutes, il faudra utiliser le refresh token pour pouvoir récupérer un nouveau token ainsi que son refresh token associé. 