;
; :description:
;    Make a function that will create a map and save it into fits file.
; :Author: Shilpi Bhunia

pro make_image, tstart, tend, path_sci_file, path_bkg_file, aux_file, emin, emax, dir_name


;;*********************************** SET TIME AND ENERGY RANGES ***********************************

; Time range to be selected for image reconstruction
time_range    = [tstart, tend]              ;['11-Nov-2022 11:36:27', '11-Nov-2022 11:36:36']
; Energy range to be selected for image reconstruction (keV) 

min_e = FIX(emin)
max_e = FIX(emax)

energy_range  = [min_e,max_e]



;;******************************** CONSTRUCT AUXILIARY DATA STRUCTURE ********************************

; Create a structure containing auxiliary data to use for image reconstruction


aux_data = stx_create_auxiliary_data(aux_file, time_range)


;*************************************** ESTIMATE FLARE LOCATION **************************************

stx_estimate_flare_location, path_sci_file, time_range, aux_data, flare_loc=flare_loc, $
                             path_bkg_file=path_bkg_file, /silent       ;/silent to stop showing the plot



;************************************ CONSTRUCT VISIBILITY STRUCTURE ***********************************

est	
mapcenter = stx_hpc2stx_coord(flare_loc, aux_data)
xy_flare  = mapcenter

vis=stx_construct_calibrated_visibility(path_sci_file, time_range, energy_range, mapcenter, subc_index=subc_index, $
                                        path_bkg_file=path_bkg_file, xy_flare=xy_flare,/silent)



imsize    = [129, 129]
 
pixel     = [2.,2.]       

; Maximum entropy method (see Massa P. et al (2020) for details)
mem_ge_map=stx_mem_ge(vis,imsize,pixel,aux_data)

;loadct,5,/silent
;window, 0
;cleanplot
;plot_map, mem_ge_map, /cbar,title='MEM_GE - CLEAN contour (50%)' ;this shows the mem_ge plot

;stx_plot_fit_map, mem_ge_map, this_window=1 ; visibility amplitude and phase fit vs detectors plots


;******************************** Save maps to fits*************************


stx_map2fits, mem_ge_map, dir_name+"/map_"+tstart.Substring(11, 18)+"-"+tend.Substring(11, 18)+"-"+emin+"-"+emax+".fits", path_sci_file

end
