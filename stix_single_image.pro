;---------------------------------------------------------------------------
;+
; :project:
;       STIX
;
; :name:
;       stx_imaging_demo
;
; :description:
;    This demonstration script shows how to read a Level 1(A) STIX science data file and to reconstruct the image of the 
;    flaring X-ray source by means of every available imaging algorithm
;
; :categories:
;    demo, imaging
;
; :history:
;   02-september-2021, Massa P., first release
;   23-august-2022, Massa P., made compatible with the up-to-date imaging sofwtare
;
;-

;;******************************** LOAD DATA - June 7 2020, 21:41 UT ********************************

; path of the folder where the stix data are stored
path = '/mnt/LOFAR-PSP/ilofar_STIX_shilpi/stix_data/'


; stix data path
path_sci_file = path+'new_stx_data/solo_L1_stix-sci-xray-cpd_20221111T113420-20221111T114142_V01_2211112966-50227.fits'



; filename of the background fits file
path_bkg_file = path+'new_stx_data/solo_L1_stix-sci-xray-cpd_20221109T234908-20221110T003708_V01_2211097578-50221.fits'

; Filename of the auxiliary L2 fits file 
aux_file    = path+'new_stx_data/solo_L2_stix-aux-ephemeris_20221111_V01.fits'




;;*********************************** SET TIME AND ENERGY RANGES ***********************************

; Time range to be selected for image reconstruction
time_range    = ['11-Nov-2022 11:36:06', '11-Nov-2022 11:36:10']              ;['11-Nov-2022 11:36:27', '11-Nov-2022 11:36:36']
; Energy range to be selected for image reconstruction (keV) 
energy_range  = [18,22]



;;******************************** CONSTRUCT AUXILIARY DATA STRUCTURE ********************************

; Create a structure containing auxiliary data to use for image reconstruction
; - STX_POINTING: X and Y coordinates of STIX pointing (arcsec, SOLO_SUN_RTN coordinate frame). 
;                 The coordinates are derived from the STIX SAS solution (when available) or from 
;                 the spacecraft pointing information 
; - RSUN: apparent radius of the Sun in arcsec
; - ROLL_ANGLE: spacecraft roll angle in degrees
; - L0: Heliographic longitude in degrees
; - B0: Heliographic latitude in degrees

aux_data = stx_create_auxiliary_data(aux_file, time_range)


;*************************************** ESTIMATE FLARE LOCATION **************************************

; Returns the coordinates of the estimated flare location (arcsec, Helioprojective Cartesian coordinates 
; from Solar Orbiter vantage point) in the 'flare_loc' keyword. These coordinates are used for setting the
; center of the maps to be reconstructed

stx_estimate_flare_location, path_sci_file, time_range, aux_data, flare_loc=flare_loc, $
                             path_bkg_file=path_bkg_file, /silent       ;/silent to stop showing the plot



;************************************ CONSTRUCT VISIBILITY STRUCTURE ***********************************

; Set the coordinates of the center of the map to be reconstruct ed ('mapcenter') and of the estimated flare 
; location ('xy_flare'). The latters are used for performing a projection correction to the visibility
; phases and for correcting the grid internal shadowing effect. The coordinates given as input to the 
; imaging pipeline have to be conceived in the STIX reference frame; hence, we perform a transformation
; from Helioprojective Cartesian to STIX reference frame with 'stx_hpc2stx_coord'

mapcenter = stx_hpc2stx_coord(flare_loc, aux_data)
xy_flare  = mapcenter

; Create a calibrated visibility structure. For selecting the subcollimators to be used, uncomment the following
; lines and set the labels of the sub-collimators to be considered

;subc_index = stx_label2ind(['10a','10b','10c','9a','9b','9c','8a','8b','8c','7a','7b','7c',$
;                             '6a','6b','6c','5a','5b','5c','4a','4b','4c','3a','3b','3c'])

vis=stx_construct_calibrated_visibility(path_sci_file, time_range, energy_range, mapcenter, subc_index=subc_index, $
                                        path_bkg_file=path_bkg_file, xy_flare=xy_flare)
;you can type help,vis,/str to loom at the total counts and bkg counts.or you can also do vis.TOT_counts
stop

;*************************************** SET IMAGE AND PIXEL SIZE ***********************************

; Number of pixels of the map to be reconstructed
imsize    = [129, 129]
; Pixel size in arcsec  
pixel     = [2.,2.]       



;******************************************* BACKPROJECTION ********************************************************

; For using 'stx_show_bproj', create the visibility structure with the default 'subc_index' (from 10 to 3). Otherwise
; it throws an error

stx_show_bproj,vis,aux_data,imsize=imsize,pixel=pixel,out=bp_map,scaled_out=scaled_out
;
; - Window 0: each row corresponds to a different resolution (from top to bottom, label 10 to 3). The first three
;             columns refer to label 'a', 'b' and 'c'; the last column is the  sum of the first three.
; - Window 2: Natural weighting (first row) and uniform weighting (second row). From left to right, backprojection
;             obtained starting from subcollimators 10 and subsequently adding subcollimators with finer resolution

; BACKPROJECTION natural weighting
bp_nat_map = stx_bproj(vis,imsize,pixel,aux_data,/silent)  ;/silent is used to not show the plot

; BACKPROJECTION uniform weighting
bp_uni_map = stx_bproj(vis,imsize,pixel,aux_data,/uni,/silent)



;**************************************** CLEAN (from visibilities) *********************************************

; Number of iterations
niter  = 200
; Gain used in each clean iteration
gain   = 0.1
; The plot of the clean components and of the cleaned map is shown at every iteration
nmap   = 1      

;Output are 5 maps
;index 0: CLEAN map
;index 1: Bproj map
;index 2: residual map
;index 3: clean component map
;index 4: clean map without residuals added
beam_width = 20.
;clean_map=stx_vis_clean(vis,aux_data,niter=niter,image_dim=imsize[0],PIXEL=pixel[0],uni=0,gain=0.1,nmap=nmap,$
;                        beam_width=beam_width)

;; Plot of visibility amplitudes and phases fit: use clean components map
;stx_plot_fit_map, clean_map[3], this_window=1



;;************************************************ MEM_GE *********************************************************

; Maximum entropy method (see Massa P. et al (2020) for details)
mem_ge_map=stx_mem_ge(vis,imsize,pixel,aux_data)

loadct,5,/silent
window, 0
cleanplot
plot_map, mem_ge_map, /cbar,title='MEM_GE - CLEAN contour (50%)'
plot_map,clean_map[0],/over,/perc,level=[50]

stx_plot_fit_map, mem_ge_map, this_window=1


;******************************** Save maps to fits*************************

stx_map2fits, mem_ge_map, "/home/shilpi/stix_idl_files/map_15-20/map_11:36:06-08.fits", path_sci_file
end
