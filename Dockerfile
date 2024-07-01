# Base R Shiny image
FROM rocker/r-base:latest

# Metadata to image
LABEL maintainer="Tim Gilbert <tsgilbert@arizona.edu>"

# Adds layer for required shiny and R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    && rm -rf /var/lib/apt/lists/*
    
# Install shiny app dependencies
RUN install.r shiny

# Install other R dependencies
RUN R -e 'install.packages(c("dplyr", "ggplot2", "gapminder"))'

RUN echo "local(options(shiny.port = 8181, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

# Create group for users so not root
#RUN addgroup --system app \
#    && adduser --system --ingroup app app
    
# Make a directory in the container
#RUN mkdir /home/app
WORKDIR /home/app

# Copy the Shiny app code - . referes to working dir
COPY app.R .

# Sets permission for app user
#RUN chown app:app -R /home/app

# sets the user or UID when running
#USER app

# Expose the application port
EXPOSE 8181

# Run the R Shiny app - default for executing container
CMD ["R", "-e", "shiny::runApp('/home/app', port = 8181, host = '0.0.0.0')"]