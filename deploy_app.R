library(rsconnect)

deployApp(
          appDir = ".",
          appFiles = list("app.R", "data", "overview.md"),
          appName = "PAD-Interventions"
          )
