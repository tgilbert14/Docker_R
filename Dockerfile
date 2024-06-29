
# Base R Shiny image
FROM rocker/shiny:latest as builder

# Install R dependencies
RUN R -e 'install.packages(c("tidyverse", "ggplot2", "gapminder"))'

# Multi-stage build: Copy only necessary files to final image
FROM rocker/shiny:latest
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library

# Create a non-root user and change ownership
RUN useradd -m shinyuser
RUN chown shinyuser:shinyuser /srv/shiny-server
USER shinyuser

# Set an environment variable
ENV APP_NAME myShinyApp

# Copy the Shiny app code
COPY --chown=shinyuser:shinyuser app.R /srv/shiny-server/${APP_NAME}/app.R

# Expose the application port
EXPOSE 8180

# Health check to verify app is running
HEALTHCHECK CMD curl --fail http://localhost:8180 || exit 1

# Run the R Shiny app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/${APP_NAME}')"]

