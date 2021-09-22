# Outlier Detection in Sensor Data using Functional Depth Measures

This is the final project of the OSE data science course (summer semester 2021) by Jakob R. Jürgens.

![ci](https://github.com/OpenSourceEconomics/ose-data-science-course-projeect-JakobJuergens/actions/workflows/ci.yml/badge.svg)

## Project overview
The main focus of this project is to develop a procedure to identify abnormal observations in sensor data collected during production processes. Each data point can be interpreted as a set of points where a function was observed.
Therefore the whole problem can be approached from a standpoint of outlier classification in functional data - An approach which I chose as the basis of my project.

This project was made possible by a cooperation with Daimler AG. The main focus is on outlier classification in functional data.
The algorithm implemented in Project_main.ipynb was taken from: 

Febrero, M., Galeano, P. and González-Manteiga, W. (2008), Outlier detection in functional data by depth measures, with application to identify abnormal NOx levels. 
Environmetrics, 19: 331-345. https://doi.org/10.1002/env.878

The method is explained an implemented in the Jupyter Notebook Project_Main.ipynb, which can be accessed using the following badges. All visualizations are done using a shiny app, that is separate from the Notebook.

<a href="https://nbviewer.jupyter.org/github/OpenSourceEconomics/ose-data-science-course-projeect-JakobJuergens/blob/master/Project_Main.ipynb"
   target="_parent">
   <img align="center"
  src="https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.png"
      width="109" height="20">
</a>

[![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/OpenSourceEconomics/ose-data-science-course-projeect-JakobJuergens/master?filepath=Project_Main.ipynb)

Even though I recommend using it locally due to a lengthy building time of the environment in Binder, the shiny app can be started using this badge:

RShiny: [![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/OpenSourceEconomics/ose-data-science-course-projeect-JakobJuergens/master?urlpath=shiny/) 

In case the page shows something like "shiny took too long to load", reload the page and it will work. The build process does not have to be repeated in that case.

## Acknowledgements
I want to thank a few people that either helped in making this project possible or aided me in some other way.
* Dr. Vincent Dekker and Bernhard Häußler, my contacts at Daimler AG who made this project possible
* Prof. Philipp Eisenhauer and Manuel Huth, who made this cooperation possible from the Universities' side
* Marc Kerstan, who allowed me to use his code for preparing sensor data collected in production processes at Daimler
* Prof. Dominik Liebl, who introduced me to the concept of using functional depth to identify outliers in functional data

## Sources:

* Cuevas, A. & Febrero-Bande, M. & Fraiman, R. (2006). On the use of bootstrap for estimating functions with functional data. Computational Statistics & Data Analysis. 51. 1063-1074.
* Febrero-Bande, M. & Galeano, P. & Gonzàlez-Manteiga, W. (2008). Outlier detection in functional data by depth measures, with application to identify abnormal NOx levels. Environmetrics. 19. 331 - 345.
* Gijbels, I. & Nagy, S. (2017). On a General Definition of Depth for Functional Data. Statistical Science. 32. 630-639.
