; Running this script will open spex gui.

pro try_ospex

; path of the folder where the stix data are stored
path = '/mnt/LOFAR-PSP/ilofar_STIX_shilpi/stix_data/'


; stix data path
path_sci_file = path+'new_stx_data/solo_L1_stix-sci-xray-cpd_20221111T113420-20221111T114142_V01_2211112966-50227.fits'


; filename of the background fits file
path_bkg_file = path+'new_stx_data/solo_L1_stix-sci-xray-cpd_20221109T234908-20221110T003708_V01_2211097578-50221.fits'



stx_get_header_corrections, path_sci_file, distance = distance, time_shift = time_shift
stx_convert_pixel_data, $
	fits_path_data = path_sci_file,$
	fits_path_bk = path_bkg_file, $
	distance = distance, $
	time_shift = 0, $
	ospex_obj = ospex_obj_l1
	
end
