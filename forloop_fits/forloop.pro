;:Given time and energy ranges this script will produce fits files.
;: Author: Shilpi Bhunia

pro forloop_images
;get the time list saved using save_tlist_csv.py
csv = read_csv('/home/shilpi/stix_idl_files/testing1/timefile.csv')
tlist = csv.FIELD1[1:-1]
a = SIZE(tlist)
;stop

path = '/mnt/LOFAR-PSP/ilofar_STIX_shilpi/stix_data/'                                                                  
path_sci_file = path+'new_stx_data/solo_L1_stix-sci-xray-cpd_20221111T113420-20221111T114142_V01_2211112966-50227.fits'
path_bkg_file = path+'new_stx_data/solo_L1_stix-sci-xray-cpd_20221109T234908-20221110T003708_V01_2211097578-50221.fits'
aux_file    = path+'new_stx_data/solo_L2_stix-aux-ephemeris_20221111_V01.fits'                                         
emin = ['4','10','15','25']                                                                                                              
emax = ['10','15','25','50']
b = SIZE(emin)
;stop                                                                                                             
dir_name = '/home/shilpi/stix_idl_files/testing1tiavey/'


for i = 0,a[3] do begin
  tstart = tlist[i]
  tend = tlist[i+1]
  for j = 0,b[1]-1 do begin
  	make_image, tstart, tend, path_sci_file, path_bkg_file, aux_file, emin[j], emax[j], dir_name
  endfor
endfor

end
