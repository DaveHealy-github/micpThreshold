%   plotMICP.m
%       plots MICP data (Hg saturation v pressure), and 
%       calculates inflection point(s) on pressure curve as options 
%       for threshold pressure(s) 
%   
%   read in ASCII tab delimited file of pressure (psi), cumulative
%   volume (ml/g)  
%
%   Dave Healy 
%   d.healy@abdn.ac.uk
%   Last modified: June 2021 

clear all ; 
close all ; 

%   read in data
fnData = '1.txt' ; 
A = importdata(fnData) ; 
Ppsi = A(:,1) ; 
CumVol = A(:,2) ; 
IncrIntrusion = diff(CumVol) ; 

%   calculate Hg saturation, as %
maxCumVol = max(CumVol) ; 
HgSat = CumVol/maxCumVol * 100 ; 

% %   plot Hg saturation v pressure, linear 
% figure ; 
% plot(Ppsi, HgSat, '.-k', 'LineWidth', 1.5, 'MarkerSize', 15) ; 
% ylabel('Hg saturation, %') ; 
% xlabel('Capillary pressure, psi') ; 
% grid on ; 
% box on ; 

%   plot same, semilog axis Y 
figure ; 
semilogx(Ppsi, HgSat, 'dk') ; 
ylabel('Hg saturation, %') ; 
xlabel('Capillary pressure, psi') ; 
ylim([0 100]) ; 
grid on ; 
box on ; 
ax = gca ; 
ax.XTick = [ 1, 10, 100, 1000, 10000, 100000 ] ; 
ax.XTickLabel = { '1', '10', '100', '1,000', '10,000', '100,000' } ; 
title(['Raw data from ', fnData]) ; 

%   convert pressure: psi to MPa
PMPa = Ppsi * 6894.75729 / 1e6 ; 

%   resample volume over a regular spacing of pressure 
v = HgSat ; 
xq = 0:1:39000 ; 
vq = interp1(Ppsi, v, xq') ;

Ppsi_resampled = xq ; 
HgSat_resampled = vq(:,1) ; 
HgSat_resampled(isnan(HgSat_resampled)) = 0.0 ; 

%   window the data, based on observed Ppsi in Figure 1
Ppsi_lowbound = input('Enter a LOWER bound on pressure for the curve fitting: ') ;  
Ppsi_uppbound = input('Enter an UPPER bound on pressure for the curve fitting: ') ; 
startPindx = find(Ppsi_resampled > Ppsi_lowbound, 1) ; 
endPindx = find(Ppsi_resampled > Ppsi_uppbound, 1) ;

Ppsi_resampled_window = Ppsi_resampled(startPindx:endPindx)' ; 

%   fit a polynomial to the windowed, resampled data 
porder = 5 ;
[p, ~, mu] = polyfit(Ppsi_resampled_window, HgSat_resampled(startPindx:endPindx), porder) ;

%   find inflection points of this polynomial 
y2 = polyval(p, Ppsi_resampled_window, [], mu) ; 
y3 = gradient(y2) ; 
y4 = gradient(y3) ; 

inflectionP = find(abs(diff(sign(y4)))>1) ; 
Pth = Ppsi_resampled_window(inflectionP) ; 
HgSatth = zeros(length(Pth),1) ; 
for i = 1:length(Pth)
    HgSatth(i) = HgSat_resampled(find(Ppsi_resampled == Pth(i),1)) ; 
end 

f = figure ; 
semilogx(Ppsi, HgSat, 'dk', ... 
            Pth, HgSatth', '*r', ...  
                Ppsi_resampled_window, y2, '-r') ; 
ylabel('Hg saturation, %') ; 
xlabel('Capillary pressure, psi') ; 
grid on ; 
box on ; 
ax = gca ; 
ax.XTick = [ 1, 10, 100, 1000, 10000, 100000 ] ; 
ax.XTickLabel = { '1', '10', '100', '1,000', '10,000', '100,000' } ; 
ylim([0 100]) ; 
title(['Fitted data from ', fnData]) ; 
fnPlot = strrep(fnData, 'txt', 'jpeg') ; 
print(f, '-djpeg', '-r300', fnPlot) ; 

disp('Candidate threshold pressure(s), psi:') ; 
disp(Pth) ; 
