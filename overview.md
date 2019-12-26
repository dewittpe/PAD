
# Trends in Endovascular Peripheral Artery Disease Interventions by Provider Specialty and Clinical Setting in the Medicare Population

The data summaries provided by this tool are a supplement to the
manuscript “*Trends in Clinical Setting and Provider Specialty for
Endovascular Peripheral Artery Disease Interventions for the Medicare
population between 2011 and 2017*” (in press, 2019) by Kristofer
Schramm, Peter E. DeWitt, Stephanie Dybul, Paul Rochon, P Patel, R Hieb,
K Rodgers, R Ryu, M Wolhauer, Premal S Trivedi. That data in this
application includes 2018 and will be extended as Medicare data sets are
updates and released publically.

The code and data sets required to build this application can be found
on [Peter DeWitt’s github](https://github.com/dewittpe/PAD) page.

## Purpose:

Provide graphical descriptions of the trends in peripheral endovascular
interventions for treating peripheral artery disease (PAD) by physician
specialty, anatomic segment, and clinical location of services.

## Methods:

[Physican Supplier Procedure
Summary](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Physician-Supplier-Procedure-Summary/index)
(PSPS) files where queried for peripheral vascular interventions via
Current Procedural Terminology (CPT) codes. The reported totals are
submitted services for all Medicare part B enrollees. Services per
100,000 person years (100KPY) are reported to account for the increasing
Medicare enrollment form year to year. The “market share” for a provider
group, the percentage of the total services submitted attributed to a
provider group, illustrates the relative change from year to year in who
is providing the services.

R packages for working with the PSPS and general program statistics, the
foundation for this application, are available here:

  - [cms.psps](https://github.com/dewittpe/cms.psps)
  - [cms.program.statistics](https://github.com/dewittpe/cms.program.statistics)
  - [cms.hcpcs](https://github.com/dewittpe/cms.hcpcs)

## Notes

Current Procedural Terminology (CPT) codes for peripheral vascular
interventions.

| HCPCS\_CD | ANATOMIC\_SEGMENT | PROCEDURE                   | PLACEMENT       |
| :-------- | :---------------- | :-------------------------- | :-------------- |
| 37224     | Femoral/Popliteal | PTA                         |                 |
| 37225     | Femoral/Popliteal | atherectomy +/- PTA         |                 |
| 37227     | Femoral/Popliteal | atherectomy w/stent +/- PTA |                 |
| 37226     | Femoral/Popliteal | stent                       |                 |
| 37222     | Iliac             | PTA                         | each additional |
| 37220     | Iliac             | PTA                         | initial         |
| 0238T     | Iliac             | atherectomy                 | each vessel     |
| 37223     | Iliac             | stent                       | each additional |
| 37221     | Iliac             | stent                       | initial         |
| 37232     | Tibial/Peroneal   | PTA                         | each additional |
| 37228     | Tibial/Peroneal   | PTA                         | initial         |
| 37233     | Tibial/Peroneal   | atherectomy +/- PTA         | each additional |
| 37229     | Tibial/Peroneal   | atherectomy +/- PTA         | initial         |
| 37235     | Tibial/Peroneal   | atherectomy w/stent +/- PTA | each additional |
| 37231     | Tibial/Peroneal   | atherectomy w/stent +/- PTA | initial         |
| 37234     | Tibial/Peroneal   | stent                       | each additional |
| 37230     | Tibial/Peroneal   | stent                       | initial         |

# Using This Application

## Basic Use

Click on the “Data and Plots” tab in the side bar. You will be presented
with drop down menues for Providers, Anatomic Segment, and Place of
service. By default, all interventions, by all providers, in all
locations are presented. If you want to see the total by provider group,
for example, click on that option from the provider drop down menu. You
will then see checkboxes for the different provider groups. Check, or
uncheck, the checkboxes to subset the underlying data set to your
liking. (click on the legend of a plot to have a specific line/marker
set plotted or omitted without modifying the underlying data.)

Mousing over a data point will provide specific information such as
specific y-axis value and market share.

## The Plots

  - Top left: reports the total number of submitted services.
  - Top right: total services by 100,000 person (enrollee) years
    (100KPY)
  - Bottom left: percent change in total services submitted from 2011
    and from the prior year.
  - Bottom right: percent change in services per 100KPY from 2011 and
    from the prior year.
