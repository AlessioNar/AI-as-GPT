# AI as a General Purpose Technology, a preliminary analysis of PCT patents

Repository containing R code written for the reproduction of the patent analysis performed for my MA thesis. Data is not included in the repository.

## Structure of the repository

The scripts used for performing the analysis are contained in the "r" folder, splitted in different actions:

- data_gathering
- applicants
- technology_evolution
- generality
- network_analysis
- utilities

Each of the folder contains a pipeline file, which executes the different steps in order, using as a data source a sqlite database containing tables from the patstat database.

The names are explicatives of the different parts of the analysis. The folder 'data_gathering' needs to be the first to be executed, since it extracts patent data from the database and reformats it in a format ready to be ingested by the other scripts. 

The code needed to reproduce section 4.3.1 is contained in the folder 'technology_evolution', while the one for section 4.3.2 is in the folder 'generality', the one for section 4.3.3 is in 'network_analysis' and the code for section 4.4 is contained in 'applicant'. 

In the sql folder are contained the sql queries used to retrieve the initial subset of AI patents, while in the bash folder are contained a set of bash scripts that can be used to reconstitute a patstat-like database from the subset download of partial databases from the patstat-online platform. 


