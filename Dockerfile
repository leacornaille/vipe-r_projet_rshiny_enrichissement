FROM rocker/r-ver:4.5.3

LABEL maintainer="Julien Chevreau <julien.chevreau@univ-rouen.fr>"

# Installer les dépendances principales pour les packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libglpk-dev \
    libuv1-dev \ 
    && rm -rf /var/lib/apt/lists/*


# Creer un groupe dans le conteneur pour éviter l'accès root.
RUN addgroup --system app \
    && adduser --system --ingroup app app
    
RUN R -e "install.packages('BiocManager', repos = 'https://cloud.r-project.org')"

# Aller dans le répertoire utilisateur
WORKDIR /home/app
# Copie du dossier avec l'appli et les fichiers shiny dans le répertoire
COPY shiny_AEF/ .
# Installer les dépendances
RUN Rscript global.R
# Changer les permissions utilisateur
RUN chown app:app -R /home/app
# Changer le nom de l'utilisateur
USER app
# Exposer le port pour shiny
EXPOSE 3838
# Lancer shiny
CMD ["R", "-e", "shiny::runApp('/home/app/', host = '0.0.0.0', port = 3838)"]