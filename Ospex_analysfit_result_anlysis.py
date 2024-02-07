### Plot slope delta, low_energy cutoff and chi square from ospex saved fits files

from astropy.io import fits
import pdb
import datetime, pylab
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from matplotlib import dates
from matplotlib.ticker import AutoMinorLocator

######## Function to Plot stix timeseries with marked time range
def summary_plot(counts, times, axes ):
    
    ####### Plot the timeseries
    nt, nd, npix, ne = counts.shape
    labels = ['4-10 keV', '10-15 keV', '15-25 keV', '25-50 keV', '50-84 keV']
    color = 'Reds'
    cm = pylab.get_cmap(color)
    collist = cm(np.linspace(0, 255, 6).astype(int))
    
    
    for did, pid, eid in product(range(nd), range(npix), range(ne)):
    	
    	lines = axes.plot(times, counts[:, did, pid, eid], label = labels[eid], color = collist[eid+1])
    
    axes.set_yscale('log')
    axes.legend(fontsize = 8)
    axes.xaxis.set_major_formatter(dates.DateFormatter('%H:%M:%S'))
    axes.xaxis.set_major_locator(dates.MinuteLocator(interval=2))
    axes.set_ylabel('Counts')
    #axes.xaxis.set_major_formatter(DateFormatter("%H:%M"))
    axes.xaxis.set_minor_locator(AutoMinorLocator())
    

fitsfile = '/home/shilpi/stix_idl_files/ospex_analysis/ospex_results_15_sep_2023.fits'

hdu1 = fits.open(fitsfile)
#pdb.set_trace()

##### all the info regarding params for vth+thick2 stored in hdu1[1].data['PARAMS']

params = hdu1[1].data['PARAMS']
time = hdu1[1].data['time']
timedel = hdu1[1].data['TIMEDEL']
sigmas = hdu1[1].data['SIGMAS']

delta = [params[i][4] for i in range(params.shape[0])]
E_c = [params[i][7] for i in range(params.shape[0])]
d_er = [sigmas[i][4]/2 for i in range(params.shape[0])]
E_c_er = [sigmas[i][7]/2 for i in range(params.shape[0])]
chi_sq = [ hdu1[1].data['CHISQ'][i] for i in range(params.shape[0])]
	

dt = [datetime.datetime(2022,11,11,0,0,0)+datetime.timedelta(seconds = time[i]) for i in range(params.shape[0])]
#pdb.set_trace()
dt1 = [datetime.datetime(2022,11,11,0,0,0)+datetime.timedelta(seconds = time[i]-timedel[i]/2) for i in range(params.shape[0])]
# we have to get the end time of the last time interval
dt1.append(datetime.datetime(2022,11,11,0,0,0)+datetime.timedelta(seconds = time[params.shape[0]-1]+timedel[params.shape[0]-1]/2))
#pdb.set_trace()
fig, axs = plt.subplots(4)

##### Plot delta vs time
delta.append(delta[len(delta)-1])  ##### you have to add the last number twice for the step function

axs[1].step(dt1,delta, where='post')
#pdb.set_trace()
axs[1].errorbar(dt,delta[0:len(delta)-1], yerr = d_er, fmt = 'o')
axs[1].set_ylabel(r'$\delta$')
#plt.xlabel('time')


##### Plot E_c vs time
E_c.append(E_c[len(E_c)-1])  ##### you have to add the last number twice for the step function

axs[2].step(dt1,E_c, where='post')
#pdb.set_trace()
axs[2].errorbar(dt,E_c[0:len(delta)-1], yerr = E_c_er, fmt = 'o')
axs[2].set_ylabel('low energy cutoff')
#plt.xlabel('time')

##### Plot chi square vs time
chi_sq.append(chi_sq[len(chi_sq)-1])  ##### you have to add the last number twice for the step function

axs[3].step(dt1,chi_sq, where='post')
#pdb.set_trace()
#axs[1].errorbar(dt,E_c[0:4], yerr = E_c_er, fmt = 'o')
axs[3].set_ylabel('chi square')
'''
##### Plot total integrated flu vs time
chi_sq.append(chi_sq[len(chi_sq)-1])  ##### you have to add the last number twice for the step function

axs[2].step(dt1,chi_sq, where='post')
#pdb.set_trace()
#axs[1].errorbar(dt,E_c[0:4], yerr = E_c_er, fmt = 'o')
axs[2].set_ylabel('chi square')
'''
path = '/mnt/LOFAR-PSP/ilofar_STIX_shilpi/'
counts = np.load(path+'stix_tseries_data/counts.npy')
times = np.load(path+'stix_tseries_data/corr_times.npy',allow_pickle = True)

summary_plot(counts, times, axs[0])
timediff = datetime.timedelta(seconds = 183.45)
axs[0].set_xlim(dt1[0]+timediff,dt1[-1]+timediff )

plt.show()

