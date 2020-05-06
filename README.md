# Trends in Endovascular Peripheral Artery Disease Interventions for the Medicare Population

This repo is focused on providing a [shiny app](https://dewittpe.shinyapps.io/PAD-Interventions/) for
exploring trends in endovascular peripheral artery disease interventions for the
Medicare population.

This work is based on the [Physician/Supplier Procedure Summary](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Physician-Supplier-Procedure-Summary/index)
data set made public by the Centers for Medicare & Medicaid Services.

This work is intended to supplement

Schramm, Kristofer M., Peter E. DeWitt, Stephanie Dybul, Paul J. Rochon, Parag
Patel, Robert A. Hieb, R. Kevin Rogers et al. "Recent Trends in Clinical Setting
and Provider Specialty for Endovascular Peripheral Artery Disease Interventions
for the Medicare Population." Journal of Vascular and Interventional Radiology
(2020).

https://doi.org/10.1016/j.jvir.2019.10.025

## Running the Application

The public version of the application is found at the link above.  To test the
application locally you can install R, shiny, etc., and run the application via

```r
shiny::runApp()
```

Alternatively, use docker and make.  The test recipe will create the docker
image and run the application in a container.  You can access the application
in your web browser at localhost:3838

```bash
make test
```
