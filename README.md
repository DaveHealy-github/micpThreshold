# micpThreshold
plotMICP.m is a simple MATLAB script to help identify threshold pressures from mercury injection data. 

Input is a ASCII tab-delimited text file of injection pressures (in psi) and cumulative volume (in ml/g). This is standard output from, for example Micromeritics Autopore systems.  

The user can select a pressure window for curve fitting, to avoid 'bad data'. And then MATLAB fits a polynomial curve to the data. The inflection points of this polynomial fit are found as candidate threshold pressures; listed in the console and plotted on the figure. 

The script is just to aid the selection of the threshold pressure; it is not fully objective, but hopefully reduces subjective bias. 
